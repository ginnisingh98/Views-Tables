--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_ENGINE_PVT" as
/* $Header: asxvsleb.pls 120.1.12010000.2 2009/03/20 10:53:27 annsrini ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_ENGINE_PVT
-- Purpose          : Sales Leads Engines
-- NOTE             :
-- History          :
--      02/04/2002 SOLIN  Created.
--                        AS provides package spec, PV provides package body
--                        for this package.
--      03/25/2002 SOLIN  Add PV_AUTOMATED_PARTNER_MATCHING workflow.
--      04/25/2002 SOLIN  Add operator IS_NOT_NULL to input filter.
--      05/01/2002 SOLIN  Add operator IS_NOT_NULL to attribute
--                        Product Interest.
--      05/15/2002 SOLIN  Add error message if opportunity can't find
--                        matching rule, or no partner is found for
--                        the matching rule.
--      05/29/2002 SOLIN  Add p_LEAD_DATE, p_SOURCE_SYSTEM, p_COUNTRY
--                        when calling sales lead table handler.
--                        Bug 2341515, 2368075
--      06/05/2002 SOLIN  Bug 2406434.
--                        If rating/channel selection engine can't find
--                        matched rule, use default value from profile.
--                        Evaluate rules with different precedence.
--      08/13/2002 SOLIN  Default value in table pv_entity_rules_applied
--                        will have process_status G_DEFAULT.
--      08/16/2002 SOLIN  Bug 2517227.
--                        Set indirect_channel_flag for old engine
--      08/20/2002 SOLIN  Bug 2520329.
--                        Don't throw exception if profile
--                        AS_DEFAULT_LEAD_ENGINE_RANK,
--                        AS_DEFAULT_LEAD_ENGINE_CHANNEL is NULL
--      08/26/2002 SOLIN  Bug 2531830.
--                        Don't set result for failed qualification rule.
--      09/26/2002 SOLIN  Bug 2595996.
--                        Set qualified_flag, lead_rank_id from sales lead
--                        record if old qualification engine or ranking engine
--                        don't need to be run.
--      11/04/2002 SOLIN  Add API Lead_Process_After_Create and
--                        Lead_Process_After_Update
--      11/18/2002 SOLIN  Bug 2671964.
--                        Creation date attribute doesn't work.
--                        In cursor C_Get_Lead_Info, append '000000', instead
--                        of '0000'
--      12/17/2002 SOLIN  Change for as_sales_leads.lead_rank_ind and
--                        as_sales_leads_log.manual_rank_flag
--      01/09/2003 SOLIN  Bug 2740032
--                        Obsolete profiles AS_RUN_NEW_LEAD_ENGINES,
--                        AS_AUTO_QUALIFY, AS_RANK_LEAD_OPTION
--      01/16/2003 SOLIN  Remove Start_Partner_Matching.
--                        It's moved to PV_BG_PARTNER_MATCHING_PUB.
--                        Change filename from pvxvsleb.pls to asxvsleb.pls
--      01/28/2003 SOLIN  Bug 2770000
--                        Find owner when user declines unqualified lead.
--      02/07/2003 SOLIN  Bug 2791689
--                        Call route_lead_to_marketing before calling
--                        Create_SalesTeam for lead creator.
--      02/10/2003 SOLIN  Bug 2795679
--                        Call route_lead_to_marketing for incubation channel
--                        lead.
--      02/12/2003 SOLIN  Bug 2791752
--                        Find lead owner if there's no lead owner in
--                        Lead_Process_After_Update.
--      02/28/2003 SOLIN  Bug 2825108
--                        Lead creator will have freeze_flag 'Y'.
--      03/07/2003 SOLIN  Bug 2822580
--                        Route_Lead_To_Marketing should remove access records
--                        when lead is updated.
--      03/14/2003 SOLIN  Bug 2852597
--                        Port 11.5.8 fix to 11.5.9.
--      03/20/2003 SOLIN  Bug 2825187
--                        Add one more parameter p_lead_action in
--                        aml_monitor_wf.launch_monitor
--      05/01/2003 SOLIN  Bug 2877904
--                        Add open_flag, object_creation_date, and
--                        lead_rank_score in as_accesses_all table
--      06/17/2003 SWKHANNA changed lead_process_after_update to include logic for starting
--                        monitor after grade change.
--
--      09/09/2003 SWKHANNA Added extra parameter to be passed in to launch monitor
--      12/08/2003 SOLIN  Bug 3305007
--                        NOT_CONTAINS operator doesn't work
--                        Change lookup_code from "NOT CONTAINS" to
--                        "NOT_CONTAINS" in Rate_Select_Lead
-- END of Comments


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_ENGINE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvsleb.pls';

-- lookup type PV_RULES_APPLIED_STATUS
G_FAIL_CRITERIA       CONSTANT VARCHAR2(30) := 'FAIL_CRITERIA';
G_PASS_RULE           CONSTANT VARCHAR2(30) := 'PASS_RULE';
G_DEFAULT             CONSTANT VARCHAR2(30) := 'DEFAULT';

-- lookup type PV_PROCESS_TYPE
G_LEAD_QUALIFICATION  CONSTANT VARCHAR2(30) := 'LEAD_QUALIFICATION';
G_LEAD_RATING         CONSTANT VARCHAR2(30) := 'LEAD_RATING';
G_CHANNEL_SELECTION   CONSTANT VARCHAR2(30) := 'CHANNEL_SELECTION';

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_15_TABLE IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_500_TABLE IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/


--   API Name:  Run_Lead_Engines

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);


PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
)
IS

BEGIN
    --IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        FND_MESSAGE.Set_Token('TEXT', p_msg_string);
        FND_MSG_PUB.Add;
    --END IF;
END Debug;


PROCEDURE Run_Lead_Engines(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    p_Commit                  IN  VARCHAR2,
    p_Validation_Level        IN  NUMBER,
    P_Admin_Group_Id          IN  NUMBER,
    P_identity_salesforce_id  IN  NUMBER,
    P_Salesgroup_id           IN  NUMBER,
    P_Sales_Lead_Id           IN  NUMBER,
    -- ckapoor Phase 2 filtering project 11.5.10
    -- P_Is_Create_Mode	      IN  VARCHAR2,

    X_Lead_Engines_Out_Rec    OUT NOCOPY AS_SALES_LEADS_PUB.Lead_Engines_Out_Rec_Type,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID, SL.ADDRESS_ID, SL.ASSIGN_TO_SALESFORCE_ID,
             SL.ASSIGN_TO_PERSON_ID, SL.ASSIGN_SALES_GROUP_ID,
             SL.QUALIFIED_FLAG, SL.PARENT_PROJECT,
             SL.CHANNEL_CODE, SL.DECISION_TIMEFRAME_CODE, SL.BUDGET_AMOUNT,
             SL.BUDGET_STATUS_CODE, SL.SOURCE_PROMOTION_ID, SL.STATUS_CODE,
             SL.REJECT_REASON_CODE, SL.LEAD_RANK_ID
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    -- Retrieve channel type
    CURSOR c_get_indirect_channel_flag(c_channel_code VARCHAR2) IS
      SELECT NVL(channel.indirect_channel_flag, 'N')
      FROM pv_channel_types channel
      WHERE channel.channel_lookup_code = c_channel_code;

    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Run_Lead_Engines';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_sales_lead_rec            AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type;

    l_return_status             VARCHAR2(1);
    l_count                     INTEGER  DEFAULT 0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_sales_lead_log_id         NUMBER;
    l_action_value              VARCHAR2(15);


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT RUN_LEAD_ENGINES_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      -- Initialize build sales team flag to 'N'
      x_lead_engines_out_rec.sales_team_flag := 'N';

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      OPEN C_Get_Lead_Info(p_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO
          l_sales_lead_rec.customer_id, l_sales_lead_rec.address_id,
          l_sales_lead_rec.assign_to_salesforce_id,
          l_sales_lead_rec.assign_to_person_id,
          l_sales_lead_rec.assign_sales_group_id,
          l_sales_lead_rec.qualified_flag, l_sales_lead_rec.parent_project,
          l_sales_lead_rec.channel_code,
          l_sales_lead_rec.decision_timeframe_code,
          l_sales_lead_rec.budget_amount, l_sales_lead_rec.budget_status_code,
          l_sales_lead_rec.source_promotion_id, l_sales_lead_rec.status_code,
          l_sales_lead_rec.reject_reason_code, l_sales_lead_rec.lead_rank_id;
      CLOSE C_Get_Lead_Info;

      -- Bug 2740032
      -- Before 11.5.9,
      -- 1. If profile AS_RUN_NEW_LEAD_ENGINES='Y', run Qualify_Lead,
      --    Rate_Select_Lead, otherwise, run
      --    AS_SALES_LEADS_PVT.IS_LEAD_QUALIFIED, AS_SCORECARD_PUB.Get_Score
      -- 2. Call qualification engine only when profile AS_AUTO_QUALIFY='Y'
      -- 3. Call ranking engine or rating engine only when profile
      --    AS_RANK_LEAD_OPTION='SYSTEM'
      --
      -- The above profiles are obsoleted in 11.5.9

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Chinar qualified_flag=' || l_sales_lead_rec.qualified_flag);
      END IF;

      IF l_sales_lead_rec.qualified_flag = 'N'
      THEN
          -- new qualification engine
          -- ckapoor Disqualification project - merged procedure for qual/rating/channel sel.

          --Qualify_Lead(
            --  P_Api_Version_Number         => 2.0,
             -- P_Init_Msg_List              => FND_API.G_FALSE,
             -- P_Commit                     => FND_API.G_FALSE,
             -- P_Validation_Level           => P_Validation_Level,
             -- P_Admin_Group_Id             => P_Admin_Group_Id,
             -- P_identity_salesforce_id     => P_identity_salesforce_id,
             -- P_Sales_Lead_id              => P_Sales_Lead_id,
              --X_Qualified_Flag             =>
               --   l_sales_lead_rec.qualified_flag,
              --X_Return_Status              => x_return_status,
              --X_Msg_Count                  => x_msg_count,
              --X_Msg_Data                   => x_msg_data); */

                Rate_Select_Lead(
	                    P_Api_Version_Number         => 2.0,
	                    P_Init_Msg_List              => FND_API.G_FALSE,
	                    P_Commit                     => FND_API.G_FALSE,
	                    P_Validation_Level           => P_Validation_Level,
	                    P_Admin_Group_Id             => P_Admin_Group_Id,
	                    P_identity_salesforce_id     => P_identity_salesforce_id,
	                    P_Sales_Lead_id              => P_Sales_Lead_id,
	                    P_Process_Type               => G_LEAD_QUALIFICATION,
	                    -- ckapoor Phase 2 filtering project 11.5.10
			    -- P_Is_Create_Mode	      	 => P_Is_Create_Mode,

	                    X_Action_Value               => l_sales_lead_rec.qualified_flag,
	                                                    -- l_action_value,
	                    X_Return_Status              => x_return_status,
	                    X_Msg_Count                  => x_msg_count,
             		    X_Msg_Data                   => x_msg_data);



          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'x_qual_flag=' || l_sales_lead_rec.qualified_flag);
          END IF;
          x_lead_engines_out_rec.qualified_flag :=
              l_sales_lead_rec.qualified_flag;

          IF l_sales_lead_rec.qualified_flag = 'N'
          THEN
              IF l_sales_lead_rec.channel_code =
                 FND_PROFILE.Value('AS_LEAD_INCUBATION_CHANNEL')
              THEN
                  x_lead_engines_out_rec.sales_team_flag := 'N';
              ELSE
                  x_lead_engines_out_rec.sales_team_flag := 'Y';
              END IF;


              -- RETURN; -- ckapoor - need to channel unqualified leads

          END IF; -- l_sales_lead_rec.qualified_flag = 'N'
      ELSE
          x_lead_engines_out_rec.qualified_flag :=
              l_sales_lead_rec.qualified_flag;
      END IF; -- run qualification engine

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Chinar lead_rank_id=' || l_sales_lead_rec.lead_rank_id);
      END IF;

            -- ckapoor. Disqualification project - give a default rating from profile
      -- for unqualified leads

      IF (l_sales_lead_rec.qualified_flag = 'N') -- anyways we are sure this has passed thru qual engine if this was manual case
      						 -- so this is definitely the value after passing thru qualification engine
      THEN

       IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Chinar Within qualified flag is N condition');
       END IF;
/*
      	 -- check manually no rank is passed.
      	 IF l_sales_lead_rec.lead_rank_id IS NULL OR
         l_sales_lead_rec.lead_rank_id = FND_API.G_MISS_NUM
      	 THEN
      	 	IF (AS_DEBUG_LOW_ON) THEN
		                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		                'Chinar giving default' || FND_PROFILE.Value('AS_DEF_RATING_UNQUAL_LEADS'));
       		END IF;
      		l_sales_lead_rec.lead_rank_id :=  FND_PROFILE.Value('AS_DEF_RATING_UNQUAL_LEADS');
      		x_lead_engines_out_rec.lead_rank_id :=
              			l_sales_lead_rec.lead_rank_id;
                -- ckapoor Disqualification project call sales lead table handler to save this value of lead_rank_id

                AS_SALES_LEADS_LOG_PKG.Insert_Row(
		                  px_log_id                 => l_sales_lead_log_id ,
		                  p_sales_lead_id           => p_sales_lead_id,
		                  p_created_by              => fnd_global.user_id,
		                  p_creation_date           => SYSDATE,
		                  p_last_updated_by         => fnd_global.user_id,
		                  p_last_update_date        => SYSDATE,
		                  p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
		                  p_request_id              =>
		                      FND_GLOBAL.Conc_Request_Id,
		                  p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
		                  p_program_id              =>
		                      FND_GLOBAL.Conc_Program_Id,
		                  p_program_update_date     => SYSDATE,
		                  p_status_code             => l_sales_lead_rec.status_code,
		                  p_assign_to_person_id     => l_sales_lead_rec.assign_to_person_id,
		                  p_assign_to_salesforce_id => l_sales_lead_rec.assign_to_salesforce_id,
		                  p_reject_reason_code      => l_sales_lead_rec.reject_reason_code,
		                  p_assign_sales_group_id   => l_sales_lead_rec.assign_sales_group_id,
		                  p_lead_rank_id            => l_sales_lead_rec.lead_rank_id,
		                  p_qualified_flag          => l_sales_lead_rec.qualified_flag,
		                  p_category                => NULL,
		                  p_manual_rank_flag        => 'N');

		              UPDATE as_sales_leads
		              SET lead_rank_id = l_sales_lead_rec.lead_rank_id,
		                  lead_rank_ind = 'N'
              		      WHERE sales_lead_id = p_sales_lead_id;


      	 END IF;

*/
      ELSIF  -- i.e if lead is qualified already, u want to go thru rating engine
      	     -- ckapoor - changed IF TO ELSIF

      	 l_sales_lead_rec.lead_rank_id IS NULL OR
         l_sales_lead_rec.lead_rank_id = FND_API.G_MISS_NUM
      THEN
          -- new rating engine
          Rate_Select_Lead(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              P_Process_Type               => G_LEAD_RATING,
	      -- ckapoor Phase 2 filtering project 11.5.10
	      -- P_Is_Create_Mode	      	 => P_Is_Create_Mode,

              X_Action_Value               => l_action_value,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'a_value=' || l_action_value);
          END IF;

          l_sales_lead_rec.lead_rank_id := TO_NUMBER(l_action_value);
          x_lead_engines_out_rec.lead_rank_id :=
              l_sales_lead_rec.lead_rank_id;
      ELSE -- if qualified and manually lead_rank_id is passed in
          x_lead_engines_out_rec.lead_rank_id :=
              l_sales_lead_rec.lead_rank_id;
      END IF; -- run rating engine  -- this now applies to IF THEN ELSE condition ckapoor

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'channel_code=' || l_sales_lead_rec.channel_code);
      END IF;

      -- ckapoor : since the return has been removed earlier, the code will
      -- fall through and we will run channel selection engine for all leads

      IF(l_sales_lead_rec.channel_code IS NULL OR
         l_sales_lead_rec.channel_code = FND_API.G_MISS_CHAR
         -- ckapoor : making change for solin : We should make it same as rating.
         -- Do not have special handling for channel in 11.5.10
         --OR
         --l_sales_lead_rec.channel_code = 'OTHER' OR
         --l_sales_lead_rec.channel_code = 'Other'
         -- end ckapoor making change for solin
         )
      THEN
          -- new channel selection engine
          Rate_Select_Lead(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              P_Process_Type               => G_CHANNEL_SELECTION,
              -- ckapoor Phase 2 filtering project 11.5.10
	      -- P_Is_Create_Mode	      	   => P_Is_Create_Mode,

              X_Action_Value               => l_sales_lead_rec.channel_code,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'a_value=' || l_sales_lead_rec.channel_code);
          END IF;

          x_lead_engines_out_rec.channel_code :=
              l_sales_lead_rec.channel_code;
      ELSE
          x_lead_engines_out_rec.channel_code :=
              l_sales_lead_rec.channel_code;
      END IF; -- run channel selection engine

      OPEN c_get_indirect_channel_flag(l_sales_lead_rec.channel_code);
      FETCH c_get_indirect_channel_flag INTO
          x_lead_engines_out_rec.indirect_channel_flag;
      CLOSE c_get_indirect_channel_flag;

      IF x_lead_engines_out_rec.indirect_channel_flag IS NULL
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  l_sales_lead_rec.channel_code
                  || ' not defined in Channel Types');
          END IF;
          x_lead_engines_out_rec.indirect_channel_flag := 'N';
      END IF;

      IF l_sales_lead_rec.channel_code =
         FND_PROFILE.Value('AS_LEAD_INCUBATION_CHANNEL')
      THEN
          x_lead_engines_out_rec.sales_team_flag := 'N';
      ELSE
          x_lead_engines_out_rec.sales_team_flag := 'Y';
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
--      	 WHEN AS_SALES_LEADS_PUB.Filter_Exception THEN
--	                RAISE AS_SALES_LEADS_PUB.Filter_Exception;

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
END Run_Lead_Engines;


-- ckapoor : Disqualification project
-- In 11.5.10 the following procedure will also support qualification in addition to
-- Rating and channel selection. This is being done since now qualification engine will be
-- very similar to rating/channel selection in that there can be multiple rules per rule set
-- and the outcome can be user set etc (qualified v/s unqualified). Hence we are merging the
-- qualify_lead with rate_select_lead. Rate_Select_Lead will support this additional P_process_type



PROCEDURE Rate_Select_Lead(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    P_Commit                  IN  VARCHAR2,
    P_Validation_Level        IN  NUMBER,
    P_Admin_Group_Id          IN  NUMBER,
    P_identity_salesforce_id  IN  NUMBER,
    P_Sales_Lead_id           IN  NUMBER,
    P_Process_Type            IN  VARCHAR2,
    -- ckapoor Phase 2 filtering project 11.5.10
    -- P_Is_Create_Mode	      IN VARCHAR2,
    X_Action_Value            OUT NOCOPY VARCHAR2,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
    IS

    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID,
             SL.ADDRESS_ID,
             SL.SOURCE_PROMOTION_ID,
             TO_CHAR(SL.CREATION_DATE, 'YYYYMMDD') || '000000',
             SL.STATUS_CODE,
             SL.ASSIGN_TO_PERSON_ID,
             SL.ASSIGN_TO_SALESFORCE_ID,
             SL.REJECT_REASON_CODE,
             SL.ASSIGN_SALES_GROUP_ID,
             SL.QUALIFIED_FLAG,
             -- ckapoor changed
             SL.LEAD_RANK_ID,
             PARTY.CATEGORY_CODE,
             CNT.EMAIL_ADDRESS
             -- ckapoor Phase 2 Filtering 11.5.10. Find the mode of caller
             -- , SL.IMPORT_FLAG

      FROM AS_SALES_LEADS SL, HZ_PARTIES PARTY, HZ_CONTACT_POINTS CNT
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id
      AND   SL.CUSTOMER_ID = PARTY.PARTY_ID
      AND   SL.PRIMARY_CNT_PERSON_PARTY_ID = CNT.OWNER_TABLE_ID(+)
      AND   CNT.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
      AND   CNT.CONTACT_POINT_TYPE(+) = 'EMAIL'
      AND   CNT.STATUS(+) = 'A';

  --  CURSOR C_Get_Area_Code(C_Customer_Id NUMBER, C_Address_Id NUMBER) IS

    CURSOR C_Get_Area_Code(C_Sales_Lead_ID NUMBER) IS

    select phone_area_code from HZ_CONTACT_POINTS phone,
    as_sales_leads lead , hz_parties party
    where
    lead.sales_lead_id = C_Sales_Lead_ID
    and ((lead.customer_id = party.party_id and party.party_type = 'PERSON'
    and PHONE.OWNER_TABLE_NAME='HZ_PARTIES' and PHONE.OWNER_TABLE_ID=lead.customer_id
    and PHONE.PRIMARY_FLAG ='Y' and PHONE.CONTACT_POINT_TYPE='PHONE' )
    or (PHONE.OWNER_TABLE_NAME='HZ_PARTIES' and PHONE.OWNER_TABLE_ID=lead.primary_contact_party_id
    and PHONE.PRIMARY_FLAG ='Y' and PHONE.CONTACT_POINT_TYPE='PHONE'
    and lead.primary_contact_party_id = party.party_id
    and party.party_type = 'PARTY_RELATIONSHIP'));


    -- ckapoor 11.5.10 Change cursor sql to match sql_text for Area Code (changed in 11.5.10)
    /*
      SELECT phon.phone_area_code
      FROM hz_contact_points phon
      WHERE phon.owner_table_id = c_address_id
      AND phon.owner_table_name = 'HZ_PARTY_SITES'
      AND phon.contact_point_type = 'PHONE'
      AND phon.status in ('A','I')
      UNION ALL
      SELECT phon.phone_area_code
      FROM hz_contact_points phon
      WHERE c_address_id IS NULL
      AND phon.owner_table_id = c_customer_id
      AND phon.owner_table_name = 'HZ_PARTIES'
      AND phon.contact_point_type = 'PHONE'
      AND phon.status in ('A','I'); */

    CURSOR C_Get_Location(C_Address_Id NUMBER) IS
      SELECT LOC.COUNTRY, LOC.STATE, LOC.PROVINCE, LOC.COUNTY,
             LOC.CITY, LOC.POSTAL_CODE
      FROM   HZ_PARTY_SITES SITE, HZ_LOCATIONS LOC
      WHERE  SITE.PARTY_SITE_ID = c_address_id
      AND    SITE.LOCATION_ID = LOC.LOCATION_ID;


   -- ckapoor Campaign setup type project
   Cursor C_Get_Campaign_Setup_Type(c_sales_lead_id NUMBER) IS
   select sc.custom_setup_id from ams_p_source_codes_v sc, as_sales_leads sl
   where
   sl.sales_lead_id = c_sales_lead_id and sl.source_promotion_id = sc.source_code_id;


   /*	select  v.custom_setup_id from as_sales_leads sl,
		    (
	        select cs.custom_setup_id custom_setup_id, sc.source_code_id
		    from ams_campaign_schedules_vl cs, ams_source_codes sc , ams_custom_setups_vl csv
		    where cs.source_code = sc.source_code and csv.object_type = 'CSCH' and csv.custom_setup_id = cs.custom_setup_id
		    and sc.arc_source_code_for = 'CSCH'
		    union
		    select eo.setup_type_id custom_setup_id, sc.source_code_id
		    from ams_event_offers_vl eo,ams_source_codes sc , ams_custom_setups_vl csv
		    where eo.source_code = sc.source_code    and csv.object_type in ('EVEO', 'EONE') and csv.custom_setup_id = eo.setup_type_id
		    and sc.arc_source_code_for in ('EVEO','EONE')

	        union
		    select eh.setup_type_id custom_setup_id, sc.source_code_id
		    from ams_event_headers_vl eh,ams_source_codes sc , ams_custom_setups_vl csv
		    where eh.source_code = sc.source_code    and csv.object_type in ('EVEH') and csv.custom_setup_id = eh.setup_type_id
		    and sc.arc_source_code_for = 'EVEH'


	        union
		    select ca.custom_setup_id custom_setup_id, sc.source_code_id
		    from ams_campaigns_vl ca,ams_source_codes sc, ams_custom_setups_vl csv
		    where ca.source_code = sc.source_code and csv.object_type in ('ECAM', 'COLL', 'DEAL', 'PARTNER', 'TRDP', 'EVCAM')
	        and csv.custom_setup_id = ca.custom_setup_id
	        and sc.arc_source_code_for = 'CAMP'

		    )  v
		where
		 v.source_code_id = sl.source_promotion_id and sl.sales_lead_id = c_sales_lead_id
   ; */



   -- end ckapoor

    CURSOR C_Get_Matching_Rules(c_sales_lead_id NUMBER,
                                c_process_type VARCHAR2,
                                c_country VARCHAR2,
                                c_source_promotion_id NUMBER,
                                -- ckapoor Campaign setup type
                                c_custom_setup_id NUMBER,
                                c_status_code VARCHAR2,
                                c_creation_date VARCHAR2,
                                c_email_address VARCHAR2,
                                c_area_code VARCHAR2,
                                c_state VARCHAR2,
                                c_province VARCHAR2,
                                c_county VARCHAR2,
                                c_city VARCHAR2,
                                c_postal_code VARCHAR2,
                                c_category_code VARCHAR2) IS
      SELECT rule.process_rule_id, rule.rank, rule.currency_code
      FROM  (
      -- -------------------------------------------------------------------
      -- Country
      -- -------------------------------------------------------------------
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code   = 'INPUT_FILTER' AND
             b.attribute_id          = pv_check_match_pub.g_a_Country_ AND
             a.process_type          = c_process_type AND
             a.process_rule_id       = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_country) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_country) OR
            (b.operator = 'IS_NOT_NULL' AND c_country IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_country IS NULL))
      -- -------------------------------------------------------------------
      -- Campaign
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code   = 'INPUT_FILTER' AND
             b.attribute_id          = pv_check_match_pub.g_a_Campaign_ AND
             a.process_type          = c_process_type AND
             a.process_rule_id       = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = TO_CHAR(c_source_promotion_id)) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> TO_CHAR(c_source_promotion_id)) OR
            (b.operator = 'IS_NOT_NULL' AND c_source_promotion_id IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_source_promotion_id IS NULL))
      -- ckapoor Custom setup type project

    -- -------------------------------------------------------------------
    -- Campaign setup type
    -- -------------------------------------------------------------------
    UNION ALL
    SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
    FROM   pv_process_rules_b a,
	   pv_enty_select_criteria b,
	   pv_selected_attr_values c
    WHERE  b.selection_type_code   = 'INPUT_FILTER' AND
	   b.attribute_id          =
           --575
	   pv_check_match_pub.g_a_Campaign_Setup_Type
	   AND
	   a.process_type          = c_process_type AND
	   a.process_rule_id       = b.process_rule_id AND
	   b.selection_criteria_id = c.selection_criteria_id(+) AND
	 ((b.operator = 'EQUALS' AND c.attribute_value = TO_CHAR(c_custom_setup_id)) OR
	  (b.operator = 'NOT_EQUALS' AND c.attribute_value <> TO_CHAR(c_custom_setup_id)) OR
	  (b.operator = 'IS_NOT_NULL' AND c_custom_setup_id IS NOT NULL) OR
    (b.operator = 'IS_NULL' AND c_custom_setup_id IS NULL))


      -- -------------------------------------------------------------------
      -- Lead Status
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code   = 'INPUT_FILTER' AND
             b.attribute_id          = pv_check_match_pub.g_a_Lead_Status AND
             a.process_type          = c_process_type AND
             a.process_rule_id       = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_status_code) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_status_code) OR
            (b.operator = 'IS_NOT_NULL' AND c_status_code IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_status_code IS NULL))
      -- -------------------------------------------------------------------
      -- Product Interest
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c,
             as_sales_lead_lines asll
      WHERE  a.process_rule_id       = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
             b.attribute_id = pv_check_match_pub.g_a_Product_Interest AND
             a.process_type          = c_process_type AND
             b.selection_type_code   = 'INPUT_FILTER' AND
             asll.sales_lead_id      = c_sales_lead_id AND
           ((b.operator = 'IS_NOT_NULL' AND asll.CATEGORY_ID IS NOT NULL) OR
	    (b.operator = 'EQUALS' AND TO_NUMBER(C.attribute_value)    IN
	            (select category_id from eni_prod_den_hrchy_parents_v
			where category_id in (
						select category_parent_id from eni_denorm_hrchy_parents
						start with category_id = ASLL.CATEGORY_ID
						connect by prior  category_parent_id = category_id
					union all
						select ASLL.CATEGORY_ID from dual)
			and disable_date is  null and
			purchase_interest = 'Y' )))


      -- -------------------------------------------------------------------
      -- Date Created
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  a.process_rule_id       = b.process_rule_id AND
             b.selection_type_code   = 'INPUT_FILTER' AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
             b.attribute_id          = pv_check_match_pub.g_a_Creation_Date AND
             a.process_type          = c_process_type AND
           ((b.operator = 'EQUALS' AND c_creation_date = c.attribute_value) OR
            (b.operator = 'NOT_EQUALS' AND c_creation_date <> c.attribute_value) OR
            (b.operator = 'LESS_THAN' AND c_creation_date < c.attribute_value) OR
            (b.operator = 'LESS_THAN_OR_EQUALS' AND c_creation_date <= c.attribute_value) OR
            (b.operator = 'GREATER_THAN' AND c_creation_date > c.attribute_value) OR
            (b.operator = 'GREATER_THAN_OR_EQUALS' AND c_creation_date >= c.attribute_value) OR
            (b.operator = 'IS_NOT_NULL' AND c_creation_date IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_creation_date IS NULL) OR
            (b.operator = 'BETWEEN' AND
               (c_creation_date BETWEEN c.attribute_value AND
                                        c.attribute_to_value)))
      -- -------------------------------------------------------------------
      -- Area Code
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id = pv_check_match_pub.g_a_Area_Code AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_area_code) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_area_code) OR
            (b.operator = 'IS_NOT_NULL' AND c_area_code IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_area_code IS NULL) OR
            (b.operator = 'CONTAINS' AND upper(c_area_code) like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'NOT_CONTAINS' AND upper(c_area_code) not like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'BEGINS_WITH' AND upper(c_area_code) like upper(c.attribute_value||'%')) OR
            (b.operator = 'ENDS_WITH' AND upper(c_area_code) like upper('%'||c.attribute_value)) OR
            (b.operator = 'BETWEEN' AND upper(c_area_code) between upper(c.attribute_value) and upper(c.attribute_to_value))
           )
      -- -------------------------------------------------------------------
      -- State
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_State_ AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_state) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_state) OR
            (b.operator = 'IS_NOT_NULL' AND c_state IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_state IS NULL))
      -- -------------------------------------------------------------------
      -- Province
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_Province AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_province) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_province) OR
            (b.operator = 'IS_NOT_NULL' AND c_province IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_province IS NULL) OR
            (b.operator = 'CONTAINS' AND upper(c_province) like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'NOT_CONTAINS' AND upper(c_province) not like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'BEGINS_WITH' AND upper(c_province) like upper(c.attribute_value||'%')) OR
            (b.operator = 'ENDS_WITH' AND upper(c_province) like upper('%'||c.attribute_value)) OR
            (b.operator = 'BETWEEN' AND upper(c_province) between upper(c.attribute_value) and upper(c.attribute_to_value))
           )
      -- -------------------------------------------------------------------
      -- County
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_County AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_county) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_county) OR
            (b.operator = 'IS_NOT_NULL' AND c_county IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_county IS NULL) OR
            (b.operator = 'CONTAINS' AND upper(c_county) like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'NOT_CONTAINS' AND upper(c_county) not like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'BEGINS_WITH' AND upper(c_county) like upper(c.attribute_value||'%')) OR
            (b.operator = 'ENDS_WITH' AND upper(c_county) like upper('%'||c.attribute_value)) OR
            (b.operator = 'BETWEEN' AND upper(c_county) between upper(c.attribute_value) and upper(c.attribute_to_value))
           )
      -- -------------------------------------------------------------------
      -- City
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_City AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_city) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_city) OR
            (b.operator = 'IS_NOT_NULL' AND c_city IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_city IS NULL) OR
            (b.operator = 'CONTAINS' AND upper(c_city) like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'NOT_CONTAINS' AND upper(c_city) not like upper('%'||c.attribute_value||'%')) OR
            (b.operator = 'BEGINS_WITH' AND upper(c_city) like upper(c.attribute_value||'%')) OR
            (b.operator = 'ENDS_WITH' AND upper(c_city) like upper('%'||c.attribute_value)) OR
            (b.operator = 'BETWEEN' AND upper(c_city) between upper(c.attribute_value) and upper(c.attribute_to_value))
           )
      -- -------------------------------------------------------------------
      -- Postal Code
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_Postal_Code AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_postal_code) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_postal_code) OR
            (b.operator = 'IS_NOT_NULL' AND c_postal_code IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_postal_code IS NULL) OR
            (b.operator = 'CONTAINS' AND upper(c_postal_code) like upper('%'||c.attribute_value||'%')) OR
	    (b.operator = 'NOT_CONTAINS' AND upper(c_postal_code) not like upper('%'||c.attribute_value||'%')) OR
	    (b.operator = 'BEGINS_WITH' AND upper(c_postal_code) like upper(c.attribute_value||'%')) OR
	    (b.operator = 'ENDS_WITH' AND upper(c_postal_code) like upper('%'||c.attribute_value)) OR
	    (b.operator = 'BETWEEN' AND upper(c_postal_code) between upper(c.attribute_value) and upper(c.attribute_to_value))
           )
      -- -------------------------------------------------------------------
      -- Customer Category
      -- -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_Customer_Category AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id(+) AND
           ((b.operator = 'EQUALS' AND c.attribute_value = c_category_code) OR
            (b.operator = 'NOT_EQUALS' AND c.attribute_value <> c_category_code) OR
            (b.operator = 'IS_NOT_NULL' AND c_category_code IS NOT NULL) OR
            (b.operator = 'IS_NULL' AND c_category_code IS NULL))
      -- ----------------------------------------------------------------
      -- All
      -------------------------------------------------------------------
      UNION ALL
      SELECT DISTINCT a.process_rule_id, a.rank, a.currency_code
      FROM   pv_process_rules_b a,
             pv_enty_select_criteria b,
             pv_selected_attr_values c
      WHERE  b.selection_type_code = 'INPUT_FILTER' AND
             b.attribute_id        = pv_check_match_pub.g_a_all AND
             a.process_type        = c_process_type AND
             a.process_rule_id     = b.process_rule_id AND
             b.selection_criteria_id = c.selection_criteria_id AND
             b.operator = 'EQUALS' AND c.attribute_value = 'Y'
      ) rule
      GROUP BY rule.process_rule_id, rule.rank, rule.currency_code
      HAVING (rule.process_rule_id, COUNT(*)) IN (
         SELECT a.process_rule_id, COUNT(*)
         FROM   pv_process_rules_b a,
                pv_enty_select_criteria b
         WHERE  a.process_rule_id     = b.process_rule_id AND
                b.selection_type_code = 'INPUT_FILTER' AND
                a.status_code         = 'ACTIVE' AND
                a.process_type        = c_process_type AND
                SYSDATE BETWEEN a.start_date AND a.end_date
         GROUP  BY a.process_rule_id)
      ORDER BY  rule.rank DESC;

    -- Retrieve rating criteria for the rule
    CURSOR c_get_rating_criterion_rule(c_process_rule_id NUMBER) IS
      SELECT rule.process_rule_id, rule.action, rule.action_value,
             rank.min_score
      FROM pv_process_rules_b rule, as_sales_lead_ranks_b rank
      WHERE rule.parent_rule_id = c_process_rule_id
      AND   rank.rank_id = TO_NUMBER(rule.action_value)
      ORDER BY rule.rank;

    -- Retrieve channel selection criteria for the rule
    CURSOR c_get_channel_criterion_rule(c_process_rule_id NUMBER) IS
      SELECT rule.process_rule_id, rule.action, rule.action_value,
             NVL(channel.rank, 0)
      FROM pv_process_rules_b rule, pv_channel_types channel
      WHERE rule.parent_rule_id = c_process_rule_id
      AND   channel.channel_lookup_code(+) = rule.action_value
      ORDER BY rule.rank;

    -- ckapoor 11.5.10. Disqualification project. Use API for qualification

    CURSOR c_get_qual_cri_rule(c_process_rule_id NUMBER) IS
      SELECT rule.process_rule_id, rule.action, rule.action_value ,
      	     decode(rule.action_value, 'Y', 1, 'N', 0)
      FROM pv_process_rules_b rule
      WHERE rule.parent_rule_id = c_process_rule_id
      ORDER BY rule.rank; -- just make sure 'Y' comes before 'N'
    -- end ckapoor

    -- pv_selected_attr_values is outer joined because of IS_NULL and
    -- IS_NOT_NULL operator.
    CURSOR C_Get_Criterion_Attributes(c_process_rule_id NUMBER) IS
      SELECT cra.selection_criteria_id, cra.attribute_id, cra.operator,
             val.attribute_value, val.attribute_to_value
      FROM pv_enty_select_criteria cra, pv_selected_attr_values val
      WHERE cra.process_rule_id = c_process_rule_id
      AND   cra.selection_type_code = 'CRITERION'
      AND   cra.selection_criteria_id = val.selection_criteria_id(+)
      ORDER BY cra.selection_criteria_id;

    -- Get rank score
    CURSOR c_get_rank_score(c_rank_id NUMBER) IS
      SELECT NVL(min_score, 0)
      FROM as_sales_lead_ranks_b
      WHERE rank_id = c_rank_id;

    -- ckapoor 11.5.10 Winning rule logging project : Cursor to get all the attributes
    -- for the winning rule

    CURSOR c_get_enty_select_criteria(c_winning_rule_id NUMBER) IS
      SELECT c.selection_criteria_id, c.attribute_id, c.selection_type_code, c.operator,
      b.return_type
      FROM pv_enty_select_criteria c, pv_attributes_b b
      WHERE c.process_rule_id = c_winning_rule_id
      and b.attribute_id = c.attribute_id;

    -- Cursor to get the attribute value information for all attributes selected
    -- via the above cursor i.e c_get_enty_select_criteria(..)

    CURSOR c_get_selected_attr_values(c_sel_cri_id NUMBER) IS
      SELECT attr_value_id, attribute_value, attribute_to_value
      FROM pv_selected_attr_values
      WHERE selection_criteria_id = c_sel_cri_id;


    -- end ckapoor 11.5.10 Winning rule logging project



    l_api_name                   CONSTANT VARCHAR2(30) := 'Rate_Select_Lead';
    l_api_version_number         CONSTANT NUMBER   := 2.0;

    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_customer_id                NUMBER;
    l_address_id                 NUMBER;
    l_source_promotion_id        NUMBER;
    l_creation_date              VARCHAR2(30);
    l_country                    VARCHAR2(60);
    l_state                      VARCHAR2(60);
    l_province                   VARCHAR2(60);
    l_county                     VARCHAR2(60);
    l_city                       VARCHAR2(60);
    l_postal_code                VARCHAR2(60);
    l_category_code              VARCHAR2(30);
    l_status_code                VARCHAR2(30);
    l_assign_to_person_id        NUMBER;
    l_assign_to_salesforce_id    NUMBER;
    l_reject_reason_code         VARCHAR2(30);
    l_assign_sales_group_id      NUMBER;
    l_qualified_flag             VARCHAR2(1);
    -- ckapoor changed
    l_old_lead_rank_id		 NUMBER;
    -- ckapoor
    l_email_address              VARCHAR2(2000);
    l_area_code                  VARCHAR2(10);
    l_delimiter                  CONSTANT VARCHAR2(3) := '+++';
    l_process_rule_id_tbl        NUMBER_TABLE;
    l_criterion_rule_id_tbl      NUMBER_TABLE;
    l_rank_tbl                   NUMBER_TABLE;
    l_action_tbl                 VARCHAR2_500_TABLE;
    l_action_value_tbl           VARCHAR2_15_TABLE;
    l_currency_code_tbl          VARCHAR2_15_TABLE;
    l_min_score_tbl              NUMBER_TABLE;
    l_match_rule_flag            VARCHAR2(1);
    l_match_attribute_flag       BOOLEAN;
    l_criterion_attribute_exist  BOOLEAN;
    l_rule_index                 NUMBER;
    l_criterion_rule_index       NUMBER;
    l_matched_rule_index_tbl     NUMBER_TABLE;
    l_attr_index                 NUMBER;
    l_min_score                  NUMBER := -1000; -- no socre is less than -1000
    l_input_filter_tbl           PV_CHECK_MATCH_PUB.t_input_filter;
    l_rank                       NUMBER;
    l_prev_attribute_id          NUMBER;
    l_prev_selection_criteria_id NUMBER;
    l_selection_criteria_id      NUMBER;
    l_attribute_id               NUMBER;
    l_operator                   VARCHAR2(30);
    l_prev_operator              VARCHAR2(30);
    l_attr_value                 VARCHAR2(500);
    l_attr_to_value              VARCHAR2(500);
    l_rule_attr_value            VARCHAR2(1500);
    l_rule_attr_to_value         VARCHAR2(1500);
    l_entity_attr_value_tbl      PV_CHECK_MATCH_PUB.t_entity_attr_value;
    l_entity_rule_applied_id     NUMBER;
    l_final_index                NUMBER;
    l_final_cron_rule_id         NUMBER;
    l_sales_lead_log_id          NUMBER;
    l_action                     VARCHAR2(500);
    l_action_value               VARCHAR2(15);
    l_fail_rule_selection_flag   VARCHAR2(1) := FND_API.G_FALSE;

    l_cursor                     NUMBER;
    l_rows_inserted              NUMBER;

    l_default_lead_rank_id       NUMBER;
    l_default_channel_code       VARCHAR2(30);
    l_lead_rank_id               NUMBER;
    l_lead_rank_score            NUMBER;
    l_default_qualified_flag     VARCHAR2(1);


    -- ckapoor 11.5.10 Winning rule project
    l_winning_rule_ent_rule_app_id NUMBER;

    l_enty_select_criteria_val c_get_enty_select_criteria%ROWTYPE;
    l_selected_attr_values_val c_get_selected_attr_values%ROWTYPE;

    l_concat_attribute_value VARCHAR2(4000);
    l_concat_attribute_to_value VARCHAR2(4000);

    l_rule_applied_attrs_id NUMBER; -- primary key for AML_RULE_APPLIED_ATTRS TABLE


    -- end ckapoor 11.5.10 Winning rule project


    -- ckapoor Campaign setup type project 11.5.10

    l_custom_setup_id NUMBER;
    -- end ckapoor

    -- ckapoor Phase 2 Filtering 11.5.10
    -- following value is the value u compare in the get rule sets cursor
    -- l_is_create_import_mode_val	VARCHAR2(1):='N';
    -- l_import_flag		VARCHAR2(1);
    -- l_filter_unqual_leads	VARCHAR2(1);




BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT RATE_SELECT_LEAD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      -- Update latest_flag before rating/channel selection engine starts.
      UPDATE pv_entity_rules_applied
      SET latest_flag = 'N'
      WHERE entity = 'SALES_LEAD'
      AND   entity_id = p_sales_lead_id
      AND   process_type = p_process_type;

      -- Get sales lead info.
      OPEN C_Get_Lead_Info(p_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO
          l_customer_id, l_address_id, l_source_promotion_id,
          l_creation_date, l_status_code,
          l_assign_to_person_id, l_assign_to_salesforce_id,
          l_reject_reason_code, l_assign_sales_group_id, l_qualified_flag,
          -- ckapoor : for disqualification project
          l_old_lead_rank_id,
          -- end ckapoor
          l_category_code, l_email_address;
          -- ckapoor Phase 2 filtering 11.5.10
          --, l_import_flag;

      CLOSE C_Get_Lead_Info;

      --OPEN C_Get_Area_Code(l_customer_id, l_address_id);
      OPEN C_Get_Area_Code(p_Sales_Lead_Id);

      FETCH C_Get_Area_Code INTO l_area_code;
      CLOSE C_Get_Area_Code;

      IF l_address_id IS NOT NULL
      THEN
          OPEN C_Get_Location(l_address_id);
          FETCH C_Get_Location INTO l_country, l_state, l_province, l_county,
              l_city, l_postal_code;
          CLOSE C_Get_Location;
      ELSE
          l_country := NULL;
      END IF;

      -- ckapoor Campaign setup type project
      -- ?? WHAT IF MULTIPLE RECORDS ARE OBTAINED????????

      -- Get custom setup id

      OPEN C_Get_Campaign_Setup_Type(p_Sales_Lead_Id);
      FETCH C_Get_Campaign_Setup_Type INTO
      	l_custom_setup_id;
      CLOSE C_Get_Campaign_Setup_Type;



      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Process_Type=' || p_process_type);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Sales_Lead_Id=' || p_sales_lead_id);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Source_promotion_id=' || l_source_promotion_id);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Status_code=' || l_status_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Creation_date=' || l_creation_date);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Country=' || l_country);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Email=' || l_email_address);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Area_Code=' || l_area_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'State=' || l_state);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Province=' || l_province);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'County=' || l_county);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'City=' || l_city);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Postal_Code=' || l_postal_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Category=' || l_category_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Campaign Setup type id =' || l_custom_setup_id);
        --  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        --      'Import flag =' || l_import_flag);

        --  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        --      'create flag =' || P_Is_Create_Mode);

      END IF;



    -- ckapoor Phase 2 Filtering 11.5.10
    -- Determine if it is import mode or not

    -- IF ((P_Is_Create_Mode = 'Y') AND ( l_import_flag = 'Y')) THEN

    --    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
    --                'Chinar import case' );

    --  l_is_create_import_mode_val := 'Y';
    -- END IF;

    -- if l_is_create_import_mode_val is 'N' then it cud be any of the other 2 cases create (other) and update



      OPEN C_Get_Matching_Rules(p_sales_lead_id, p_process_type,
                                l_country, l_source_promotion_id,
                                --ckapoor Campaign setup type
                                l_custom_setup_id,
                                l_status_code, l_creation_date,
                                l_email_address, l_area_code, l_state,
                                l_province, l_county, l_city, l_postal_code,
                                l_category_code);
      FETCH C_Get_Matching_Rules BULK COLLECT INTO l_process_rule_id_tbl,
          l_rank_tbl, l_currency_code_tbl;
          -- l_action_tbl, l_action_value_tbl
      CLOSE C_Get_Matching_Rules;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'rule count=' || l_process_rule_id_tbl.count);

      END IF;
      l_match_rule_flag := 'N';
      -- If there's any rule matching, check attribute one by one
      IF l_process_rule_id_tbl.count > 0
      THEN
          l_rule_index := l_process_rule_id_tbl.first;
          l_rank := l_rank_tbl(l_rule_index);
          WHILE l_rule_index <= l_process_rule_id_tbl.last
          LOOP
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'pro_rule_id=' || l_process_rule_id_tbl(l_rule_index));
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'rank=' || l_rank_tbl(l_rule_index));
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'l_match_rule_flag=' || l_match_rule_flag);
              END IF;

              IF l_rank_tbl(l_rule_index) <> l_rank AND
                 l_match_rule_flag = 'Y'
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'not same precedence/rule found');
                  END IF;
                  EXIT;
              END IF;

              pv_check_match_pub.Retrieve_Input_Filter (
                  p_api_version_number   => 1.0,
                  p_init_msg_list        => p_init_msg_list,
                  p_commit               => p_commit,
                  p_validation_level     => p_validation_level,
                  p_process_rule_id      =>
                      l_process_rule_id_tbl(l_rule_index),
                  p_delimiter            => l_delimiter,
                  x_input_filter         => l_input_filter_tbl,
                  x_return_status        => x_return_status,
                  x_msg_count            => x_msg_count,
                  x_msg_data             => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

              IF (p_process_type = G_LEAD_RATING)
              THEN
                  OPEN c_get_rating_criterion_rule(
                      l_process_rule_id_tbl(l_rule_index));
                  FETCH c_get_rating_criterion_rule BULK COLLECT INTO
                      l_criterion_rule_id_tbl, l_action_tbl, l_action_value_tbl,
                      l_min_score_tbl;
                  CLOSE c_get_rating_criterion_rule;
              -- ckapoor Disqualification project in 11.5.10.
              -- Using this api for qualification
              -- as well.

              ELSIF   p_process_type = G_CHANNEL_SELECTION
              THEN
                  -- Channel selection engine
                  OPEN c_get_channel_criterion_rule(
                      l_process_rule_id_tbl(l_rule_index));
                  FETCH c_get_channel_criterion_rule BULK COLLECT INTO
                      l_criterion_rule_id_tbl, l_action_tbl, l_action_value_tbl,
                      l_min_score_tbl;
                  CLOSE c_get_channel_criterion_rule;

                  -- NEEDS ????????????????????
              ELSIF p_process_type = G_LEAD_QUALIFICATION -- ckapoor Disqualification project
              THEN
              	   -- qualification engine
              	   -- this is the code for getting all rules within a rule set.
              	   OPEN c_get_qual_cri_rule(
		   l_process_rule_id_tbl(l_rule_index));
	     	   FETCH c_get_qual_cri_rule BULK COLLECT INTO
		   l_criterion_rule_id_tbl, l_action_tbl, l_action_value_tbl,
		   l_min_score_tbl;

                  CLOSE c_get_qual_cri_rule;

                  -- end ckapoor


              END IF;

              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'criterion rule count=' || l_criterion_rule_id_tbl.count);

              END IF;
              IF l_criterion_rule_id_tbl.count > 0
              THEN
                  l_criterion_rule_index := l_criterion_rule_id_tbl.first;
                  WHILE l_criterion_rule_index <= l_criterion_rule_id_tbl.last
                  LOOP
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'cri_rule_idx=' || l_criterion_rule_index);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'cri_rule_id=' ||
                              l_criterion_rule_id_tbl(l_criterion_rule_index));
                      END IF;

                      l_prev_attribute_id := FND_API.G_MISS_NUM;
                      l_prev_selection_criteria_id := FND_API.G_MISS_NUM;
                      l_rule_attr_value := l_delimiter;
                      l_rule_attr_to_value := l_delimiter;
                      l_match_attribute_flag := TRUE;
                      l_criterion_attribute_exist := FALSE;
                      OPEN C_Get_Criterion_Attributes(
                          l_criterion_rule_id_tbl(l_criterion_rule_index));
                      LOOP
                          FETCH C_Get_Criterion_Attributes INTO
                              l_selection_criteria_id, l_attribute_id,
                              l_operator, l_attr_value, l_attr_to_value;
                          EXIT WHEN C_Get_Criterion_Attributes%NOTFOUND;

                          l_criterion_attribute_exist := TRUE;
                          IF (AS_DEBUG_LOW_ON) THEN
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'sel_cra_id=' || l_selection_criteria_id);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'attr_id=' || l_attribute_id);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'op=' || l_operator);
                          END IF;
                          IF l_selection_criteria_id <>
                             l_prev_selection_criteria_id
                          THEN
                              IF l_prev_attribute_id <> FND_API.G_MISS_NUM
                              THEN
                                  IF (AS_DEBUG_LOW_ON) THEN
                                      AS_UTILITY_PVT.Debug_Message(
                                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'rul_val=' || l_rule_attr_value);
                                      AS_UTILITY_PVT.Debug_Message(
                                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'rul_to_val=' || l_rule_attr_to_value);
                                      AS_UTILITY_PVT.Debug_Message(
                                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'prev_attr_id=' || l_prev_attribute_id);
                                      AS_UTILITY_PVT.Debug_Message(
                                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'prev_op=' || l_prev_operator);
                                  END IF;
                                  l_match_attribute_flag :=
                                      pv_check_match_pub.Check_Match (
                                      p_attribute_id         =>
                                          l_prev_attribute_id,
                                      p_entity               => 'SALES_LEAD',
                                      p_entity_id            => p_sales_lead_id,
                                      p_rule_attr_value      =>
                                          l_rule_attr_value,
                                      p_rule_to_attr_value   =>
                                          l_rule_attr_to_value,
                                      p_operator             => l_prev_operator,
                                      p_input_filter         =>
                                          l_input_filter_tbl,
                                      p_delimiter            => l_delimiter,
                                      p_rule_currency_code   =>
                                          l_currency_code_tbl(l_rule_index),
                                      x_entity_attr_value    =>
                                          l_entity_attr_value_tbl);

                                  IF l_match_attribute_flag = FALSE
                                  THEN
                                      IF (AS_DEBUG_LOW_ON) THEN
                                          AS_UTILITY_PVT.Debug_Message(
                                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                              'attr not match');
                                      END IF;
                                      EXIT; -- exit attribute loop
                                  ELSE
                                      IF (AS_DEBUG_LOW_ON) THEN
                                          AS_UTILITY_PVT.Debug_Message(
                                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                              'attr match');
                                      END IF;
                                  END IF;
                              END IF; -- l_rule_attribute_value <> l_delimiter
                              l_rule_attr_value := l_delimiter;
                              l_rule_attr_to_value := l_delimiter;
                          END IF; -- l_selection_criteria_id <>
                                  -- l_prev_selection_criteria_id
                          l_rule_attr_value := l_rule_attr_value
                              || l_attr_value || l_delimiter;
                          l_rule_attr_to_value := l_rule_attr_to_value
                              || l_attr_to_value || l_delimiter;

                          l_prev_selection_criteria_id :=
                              l_selection_criteria_id;
                          l_prev_attribute_id := l_attribute_id;
                          l_prev_operator := l_operator;
                      END LOOP; -- attribute/value
                      CLOSE C_Get_Criterion_Attributes;
                      IF l_match_attribute_flag AND l_criterion_attribute_exist
                      THEN
                          IF (AS_DEBUG_LOW_ON) THEN
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'l attr_id=' || l_prev_attribute_id);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'rul_val=' || l_rule_attr_value);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'rul_to_val=' || l_rule_attr_to_value);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'prev_attr_id=' || l_prev_attribute_id);
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'prev_op=' || l_prev_operator);
                          END IF;
                          l_match_attribute_flag :=
                              pv_check_match_pub.Check_Match (
                              p_attribute_id         => l_prev_attribute_id,
                              p_entity               => 'SALES_LEAD',
                              p_entity_id            => p_sales_lead_id,
                              p_rule_attr_value      => l_rule_attr_value,
                              p_rule_to_attr_value   => l_rule_attr_to_value,
                              p_operator             => l_prev_operator,
                              p_input_filter         => l_input_filter_tbl,
                              p_delimiter            => l_delimiter,
                              p_rule_currency_code   =>
                                  l_currency_code_tbl(l_rule_index),
                              x_entity_attr_value    =>
                                  l_entity_attr_value_tbl);
                      END IF; -- l_match_attribute_flag = TRUE

                      IF l_match_attribute_flag AND l_criterion_attribute_exist
                      THEN
                          IF (AS_DEBUG_LOW_ON) THEN
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'cr_ru=' ||
                                  l_criterion_rule_id_tbl(l_criterion_rule_index));
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'l_min_score_tbl=' ||
                                  l_min_score_tbl(l_criterion_rule_index));
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'l_min_score=' || l_min_score);
                          END IF;
                          l_match_rule_flag := 'Y';
                          l_matched_rule_index_tbl(l_rule_index) :=
                              l_criterion_rule_index;
                          l_entity_rule_applied_id := NULL;
                          IF l_min_score_tbl(l_criterion_rule_index) >
                            l_min_score
                          THEN
                              l_min_score :=
                                  l_min_score_tbl(l_criterion_rule_index);
                              l_action := l_action_tbl(l_criterion_rule_index);
                              l_action_value :=
                                  l_action_value_tbl(l_criterion_rule_index);
                              l_final_index := l_rule_index;
                              l_final_cron_rule_id :=
                                  l_criterion_rule_id_tbl(l_criterion_rule_index);
                              IF (AS_DEBUG_LOW_ON) THEN
                                  AS_UTILITY_PVT.Debug_Message(
                                      FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                      'l_final_cron_rule_id=' ||
                                      l_final_cron_rule_id);
                              END IF;
                          END IF;

                          PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
                              px_ENTITY_RULE_APPLIED_ID =>
                                  l_entity_rule_applied_id
                             ,p_LAST_UPDATE_DATE => SYSDATE
                             ,p_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
                             ,p_CREATION_DATE => SYSDATE
                             ,p_CREATED_BY => FND_GLOBAL.USER_ID
                             ,p_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
                             ,p_OBJECT_VERSION_NUMBER => 1
                             ,p_REQUEST_ID => FND_GLOBAL.Conc_Request_Id
                             ,p_PROGRAM_APPLICATION_ID =>
                                  FND_GLOBAL.Prog_Appl_Id
                             ,p_PROGRAM_ID => FND_GLOBAL.Conc_Program_Id
                             ,p_PROGRAM_UPDATE_DATE => SYSDATE
                             ,p_ENTITY => 'SALES_LEAD'
                             ,p_ENTITY_ID => p_sales_lead_id
                             ,p_PROCESS_RULE_ID =>
                                l_criterion_rule_id_tbl(l_criterion_rule_index)
                             ,p_PARENT_PROCESS_RULE_ID =>
                                  l_process_rule_id_tbl(l_rule_index)
                             ,p_LATEST_FLAG => 'Y'
                             ,p_ACTION_VALUE =>
                                  l_action_value_tbl(l_criterion_rule_index)
                             ,p_PROCESS_TYPE => p_process_type
                             --,p_WINNING_RULE_FLAG => 'Y'
                             ,p_WINNING_RULE_FLAG => 'N'
                             ,p_ATTRIBUTE_CATEGORY => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE1 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE2 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE3 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE4 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE5 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE6 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE7 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE8 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE9 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE10 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE11 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE12 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE13 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE14 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE15 => FND_API.G_MISS_CHAR
                             ,p_PROCESS_STATUS => G_PASS_RULE
                             ,p_ENTITY_DETAIL => l_status_code);

                          EXIT; -- exit criterion rule
                      ELSE
                          IF (AS_DEBUG_LOW_ON) THEN
                              AS_UTILITY_PVT.Debug_Message(
                                  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'rule not match');
                          END IF;
                          l_entity_rule_applied_id := NULL;
                          l_matched_rule_index_tbl(l_rule_index) :=
                              FND_API.G_MISS_NUM;
                          PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
                              px_ENTITY_RULE_APPLIED_ID =>
                                  l_entity_rule_applied_id
                             ,p_LAST_UPDATE_DATE => SYSDATE
                             ,p_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
                             ,p_CREATION_DATE => SYSDATE
                             ,p_CREATED_BY => FND_GLOBAL.USER_ID
                             ,p_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
                             ,p_OBJECT_VERSION_NUMBER => 1
                             ,p_REQUEST_ID => FND_GLOBAL.Conc_Request_Id
                             ,p_PROGRAM_APPLICATION_ID =>
                                  FND_GLOBAL.Prog_Appl_Id
                             ,p_PROGRAM_ID => FND_GLOBAL.Conc_Program_Id
                             ,p_PROGRAM_UPDATE_DATE => SYSDATE
                             ,p_ENTITY => 'SALES_LEAD'
                             ,p_ENTITY_ID => p_sales_lead_id
                             ,p_PROCESS_RULE_ID =>
                                l_criterion_rule_id_tbl(l_criterion_rule_index)
                             ,p_PARENT_PROCESS_RULE_ID =>
                                  l_process_rule_id_tbl(l_rule_index)
                             ,p_LATEST_FLAG => 'Y'
                             ,p_ACTION_VALUE =>
                                  l_action_value_tbl(l_criterion_rule_index)
                             ,p_PROCESS_TYPE => p_process_type
                             ,p_WINNING_RULE_FLAG => NULL
                             ,p_ATTRIBUTE_CATEGORY => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE1 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE2 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE3 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE4 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE5 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE6 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE7 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE8 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE9 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE10 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE11 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE12 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE13 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE14 => FND_API.G_MISS_CHAR
                             ,p_ATTRIBUTE15 => FND_API.G_MISS_CHAR
                             ,p_PROCESS_STATUS => G_FAIL_CRITERIA
                             ,p_ENTITY_DETAIL => l_status_code);
                      END IF;
                      l_criterion_rule_index := l_criterion_rule_index + 1;
                  END LOOP; -- criterion rule
              END IF; -- l_criterion_rule_id_tbl.count

              IF NOT l_match_attribute_flag
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'no criterion rule match');
                  END IF;
                  l_entity_rule_applied_id := NULL;
                  PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
                      px_ENTITY_RULE_APPLIED_ID => l_entity_rule_applied_id
                     ,p_LAST_UPDATE_DATE => SYSDATE
                     ,p_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
                     ,p_CREATION_DATE => SYSDATE
                     ,p_CREATED_BY => FND_GLOBAL.USER_ID
                     ,p_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
                     ,p_OBJECT_VERSION_NUMBER => 1
                     ,p_REQUEST_ID => FND_GLOBAL.Conc_Request_Id
                     ,p_PROGRAM_APPLICATION_ID => FND_GLOBAL.Prog_Appl_Id
                     ,p_PROGRAM_ID => FND_GLOBAL.Conc_Program_Id
                     ,p_PROGRAM_UPDATE_DATE => SYSDATE
                     ,p_ENTITY => 'SALES_LEAD'
                     ,p_ENTITY_ID => p_sales_lead_id
                     ,p_PROCESS_RULE_ID => NULL
                     ,p_PARENT_PROCESS_RULE_ID =>
                          l_process_rule_id_tbl(l_rule_index)
                     ,p_LATEST_FLAG => 'Y'
                     ,p_ACTION_VALUE => NULL
                     ,p_PROCESS_TYPE => p_process_type
                     ,p_WINNING_RULE_FLAG => NULL
                     ,p_ATTRIBUTE_CATEGORY => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE1 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE2 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE3 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE4 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE5 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE6 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE7 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE8 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE9 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE10 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE11 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE12 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE13 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE14 => FND_API.G_MISS_CHAR
                     ,p_ATTRIBUTE15 => FND_API.G_MISS_CHAR
                     ,p_PROCESS_STATUS => G_FAIL_CRITERIA
                     ,p_ENTITY_DETAIL => l_status_code);
              END IF;
              l_rank := l_rank_tbl(l_rule_index);
              l_rule_index := l_rule_index + 1;
          END LOOP; -- for each matched rule
      ELSE
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'no rule input filter match');
          END IF;
      END IF; -- l_process_rule_id_tbl.count > 0

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'l_match_rule_flag:' || l_match_rule_flag);
      END IF;
      IF l_match_rule_flag = 'Y'
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'l_final_index:' || l_final_index);
              AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'l_final_cron_rule_id:' || l_final_cron_rule_id);
              AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'final rule id:' || l_process_rule_id_tbl(l_final_index));
          END IF;





          -- Update latest_flag before rating/channel selection engine starts.
          UPDATE pv_entity_rules_applied
          SET WINNING_RULE_FLAG = 'Y'
          WHERE entity = 'SALES_LEAD'
          AND   entity_id = p_sales_lead_id
          AND   process_type = p_process_type
          AND   latest_flag = 'Y'
          AND   process_rule_id = l_final_cron_rule_id
          AND   parent_process_rule_id = l_process_rule_id_tbl(l_final_index)

          returning entity_rule_applied_id into l_winning_rule_ent_rule_app_id ;




            -- ckapoor 11.5.10 filtering phase 2

	    -- if matched rule's action_value is N and lead_qual process type and create import mode
	    -- and profile true then throw exception
	    -- throw diff exception for unqualified case.

	    --if( l_rule_set_action_value_tbl(l_final_index) = 'F') then


	   -- if (p_process_type = 'LEAD_QUALIFICATION') then

	   -- l_filter_unqual_leads := FND_PROFILE.value('AS_FILTER_UNQUALIFIED_LEADS');

	   -- AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   -- 		    'filterprofile'||l_filter_unqual_leads);


	   --   if ((l_filter_unqual_leads = 'Y') and (l_is_create_import_mode_val='Y') and (l_action_value = 'N')) -- then
	   --      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   --	    'Match qual case');

	   --	 AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   --	    'Filtering error raised from API');
	   --	raise AS_SALES_LEADS_PUB.Filter_Exception;
	   --   end if;
	   --  end if;





                    --ckapoor Code for logging winning rule value
	             -- based on process_rule_id , write a cursor to get all attribs for the rule

	             -- TO ASK - what if there is no rows found..do i have to do NOTFOUND etc ??


	            l_concat_attribute_value := NULL;
	            l_concat_attribute_to_value := NULL;

	            AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Just before the outerloop for winning rule value logging');

	            FOR l_enty_select_criteria_val in c_get_enty_select_criteria(l_final_cron_rule_id) LOOP

	            	AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Within the outerloop for winning rule value logging');

	            	AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'selection_criteria_id ::'||l_enty_select_criteria_val.selection_criteria_id);

	  		l_concat_attribute_value := NULL;
	            	l_concat_attribute_to_value := NULL;

	            	FOR l_selected_attr_values_val in c_get_selected_attr_values(l_enty_select_criteria_val.selection_criteria_id) LOOP
	            	   AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Within the innerloop for winning rule value logging');
	  		   AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'attr_value_id ::'||l_selected_attr_values_val.attr_value_id);
	  		   --if (l_concat_attribute_value IS NULL) then
	  		   --      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'first time');
	  		   --	l_concat_attribute_value := l_selected_attr_values_val.attribute_value;
	  		   --els

	  		   if (l_selected_attr_values_val.attribute_value IS NOT NULL) then
	  		   	l_concat_attribute_value := l_concat_attribute_value || l_delimiter || l_selected_attr_values_val.attribute_value;

	  		   	if (l_enty_select_criteria_val.return_type = 'CURRENCY') then
	  		   		l_concat_attribute_value := l_concat_attribute_value || ':::' || l_currency_code_tbl(l_final_index);
	  		   	end if;

	  		   end if;

	  		   --next one is relevant only if it is a BETWEEN operator
	  		   -- if (l_concat_attribute_value IS NULL) then
	  		   --     AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'again first time');

	  		   --	l_concat_attribute_to_value := l_selected_attr_values_val.attribute_to_value;
	  		   -- els

	  		    if (l_selected_attr_values_val.attribute_to_value IS NOT NULL) then
	  		   	l_concat_attribute_to_value := l_concat_attribute_to_value || l_delimiter || l_selected_attr_values_val.attribute_to_value;

	  		    	if (l_enty_select_criteria_val.return_type = 'CURRENCY') then
			    		l_concat_attribute_to_value := l_concat_attribute_to_value || ':::' || l_currency_code_tbl(l_final_index);
			    	end if;
			    end if;

	            	END LOOP; -- for l_selected_attr_values_val



	            	if (l_concat_attribute_value IS NOT NULL) then
	            		l_concat_attribute_value := l_concat_attribute_value || l_delimiter;
	            	end if;

	            	if (l_concat_attribute_to_value IS NOT NULL) then
				l_concat_attribute_to_value := l_concat_attribute_to_value || l_delimiter;
			end if;




	            	-- at the end of this loop, we have the right values constructed

	            	AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'These values will be logged : ');
	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'entity_rule_applied_id :: ' || l_winning_rule_ent_rule_app_id);
	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'attribute_id ::' || l_enty_select_criteria_val.attribute_id);
	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'operator :: ' || l_enty_select_criteria_val.operator);
	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'a_v::' || l_concat_attribute_value);

	  		Debug('a_v2::' || l_concat_attribute_value);


	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'a_t_v::' || l_concat_attribute_to_value);

	  		Debug('a_t_v2::' || l_concat_attribute_to_value);


	  		-- As we are looping through the attributes, we will refer to the
	  		-- l_entity_attr_value_tbl returned by pv_check_match_pub.check_match(,,)
	  		-- This contains the cached attribute value

	  		AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  		'PV :: ' || l_entity_attr_value_tbl(l_enty_select_criteria_val.attribute_id).attribute_value);

	  		Debug('PV again:: ' || l_entity_attr_value_tbl(l_enty_select_criteria_val.attribute_id).attribute_value);


	  		-- One problem is that PV API returns the expanded concatenated value
	  		-- for FUE attribs (e.g # 510 i.e Prod Interest) We want the non expanded value
	  		-- so we have to call get_entity_attr_values(..) again.

	  		if (l_enty_select_criteria_val.attribute_id = pv_check_match_pub.g_a_Product_Interest) then

	  			l_entity_attr_value_tbl.delete(l_enty_select_criteria_val.attribute_id);

	  			pv_check_match_pub.Get_Entity_Attr_Values (
	  			      p_api_version_number   => 1.0,
	  			      p_attribute_id         => l_enty_select_criteria_val.attribute_id,
	  			      p_entity               => 'SALES_LEAD',
	  			      p_entity_id            => p_sales_lead_id,
	  			      p_delimiter            => l_delimiter,
	  			      p_expand_attr_flag     => 'N',
	  			      x_entity_attr_value    => l_entity_attr_value_tbl,
	  			      x_return_status        => x_return_status,
	  			      x_msg_count            => x_msg_count,
	  			      x_msg_data             => x_msg_data
	     			);

	  			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  				RAISE FND_API.G_EXC_ERROR;
	  			 END IF;

	  		        AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	  			'PV 510:: ' || l_entity_attr_value_tbl(l_enty_select_criteria_val.attribute_id).attribute_value);

	  			Debug('PV again 510:: ' || l_entity_attr_value_tbl(l_enty_select_criteria_val.attribute_id).attribute_value);


	  		end if;



	  	    -- Now that the values are constructed, log these into aml_rule_applied_attrs



		    AML_RULE_APPLIED_ATTRS_PKG.Insert_Row(
			      px_RULE_APPLIED_ATTR_ID  	=> l_rule_applied_attrs_id
			     ,p_LAST_UPDATE_DATE    	=> SYSDATE
			     ,p_LAST_UPDATED_BY 	=> fnd_global.user_id
			     ,p_CREATION_DATE   	=> SYSDATE
			     ,p_CREATED_BY   	        => fnd_global.user_id
			     ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID
			     ,p_OBJECT_VERSION_NUMBER   => FND_API.G_MISS_NUM
			     ,p_REQUEST_ID 	        => FND_GLOBAL.Conc_Request_Id
			     ,p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id
			     ,p_PROGRAM_ID    		=> FND_GLOBAL.Conc_Program_Id
			     ,p_PROGRAM_UPDATE_DATE     => SYSDATE
			     ,p_ENTITY_RULE_APPLIED_ID  => l_winning_rule_ent_rule_app_id
			     ,p_ATTRIBUTE_ID    	=> l_enty_select_criteria_val.attribute_id
			     ,p_OPERATOR        	=> l_enty_select_criteria_val.operator
			     ,p_ATTRIBUTE_VALUE    	=> l_concat_attribute_value
			     ,p_ATTRIBUTE_TO_VALUE    	=> l_concat_attribute_to_value
			     ,p_LEAD_VALUE   		=> l_entity_attr_value_tbl(l_enty_select_criteria_val.attribute_id).attribute_value

		   );




	            END LOOP ; -- for l_enty_select_criteria_val




	            -- for every attribute, goto pv_selected_attr_values and construct
	            --concatenated string.

	            -- for every attribute , goto pv_entity)attrs using attribute_id, and entity combo
	            --and get sql_text. Unique row

	            -- Use dynamic sql ?? to run the sql_text. This may return multiple records

	            -- if # > 1 then concatenate


	            -- Confirm if the above comments are needed




          IF p_process_type = G_LEAD_RATING
          THEN
              AS_SALES_LEADS_LOG_PKG.Insert_Row(
                  px_log_id                 => l_sales_lead_log_id ,
                  p_sales_lead_id           => p_sales_lead_id,
                  p_created_by              => fnd_global.user_id,
                  p_creation_date           => SYSDATE,
                  p_last_updated_by         => fnd_global.user_id,
                  p_last_update_date        => SYSDATE,
                  p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
                  p_request_id              =>
                      FND_GLOBAL.Conc_Request_Id,
                  p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
                  p_program_id              =>
                      FND_GLOBAL.Conc_Program_Id,
                  p_program_update_date     => SYSDATE,
                  p_status_code             => l_status_code,
                  p_assign_to_person_id     => l_assign_to_person_id,
                  p_assign_to_salesforce_id => l_assign_to_salesforce_id,
                  p_reject_reason_code      => l_reject_reason_code,
                  p_assign_sales_group_id   => l_assign_sales_group_id,
                  p_lead_rank_id            => TO_NUMBER(l_action_value),
                  p_qualified_flag          => l_qualified_flag,
                  p_category                => NULL,
                  p_manual_rank_flag        => 'N');

              UPDATE as_sales_leads
              SET lead_rank_ind = 'N'
              WHERE sales_lead_id = p_sales_lead_id;

          -- ckapoor : disqualification project
          ELSIF p_process_type = G_LEAD_QUALIFICATION -- qualification case
          THEN

          AS_SALES_LEADS_LOG_PKG.Insert_Row(
	                    px_log_id                 => l_sales_lead_log_id ,
	                    p_sales_lead_id           => p_sales_lead_id,
	                    p_created_by              => fnd_global.user_id,
	                    p_creation_date           => SYSDATE,
	                    p_last_updated_by         => fnd_global.user_id,
	                    p_last_update_date        => SYSDATE,
	                    p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
	                    p_request_id              =>
	                        FND_GLOBAL.Conc_Request_Id,
	                    p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
	                    p_program_id              =>
	                        FND_GLOBAL.Conc_Program_Id,
	                    p_program_update_date     => SYSDATE,
	                    p_status_code             => l_status_code,
	                    p_assign_to_person_id     => l_assign_to_person_id,
	                    p_assign_to_salesforce_id => l_assign_to_salesforce_id,
	                    p_reject_reason_code      => l_reject_reason_code,
	                    p_assign_sales_group_id   => l_assign_sales_group_id,
	                    p_lead_rank_id            => l_old_lead_rank_id,
	                    p_qualified_flag          => l_action_value,
	                    p_category                => NULL,
	                    p_manual_rank_flag        => NULL );

          END IF;

	  -- Use l_action(l_rule_index) and l_action_value(l_rule_index)
	  -- to update value
	  IF (AS_DEBUG_LOW_ON) THEN
	      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		 'act:' || l_action);
	      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		 'act_val:' || l_action_value);
	  END IF;

	  l_cursor := dbms_sql.open_cursor;
	  dbms_sql.parse(l_cursor, l_action, dbms_sql.native);

	  IF p_process_type = G_LEAD_RATING
	  THEN
	      l_lead_rank_id := TO_NUMBER(l_action_value);
	      dbms_sql.bind_variable(l_cursor, ':lead_rank_id', l_lead_rank_id);
	  ELSIF p_process_type = G_CHANNEL_SELECTION
	  THEN
		      -- CHANNEL_SELECTION
		      dbms_sql.bind_variable(l_cursor, ':channel_code', l_action_value);
          -- ckapoor : disqualification project
          ELSIF p_process_type = G_LEAD_QUALIFICATION  --qualification case
          THEN

		    dbms_sql.bind_variable(l_cursor, ':qualified_flag',l_action_value);
	  -- end ckapoor

          END IF;
          dbms_sql.bind_variable(l_cursor, ':sales_lead_id',
              p_sales_lead_id);
          l_rows_inserted := dbms_sql.execute(l_cursor);
          dbms_sql.close_cursor(l_cursor);
          x_action_value := l_action_value;
      ELSE
          -- no rules matched
          IF p_process_type = G_LEAD_RATING
          THEN
              l_default_lead_rank_id :=
                  TO_NUMBER(FND_PROFILE.Value('AS_DEFAULT_LEAD_ENGINE_RANK'));
              l_lead_rank_id := l_default_lead_rank_id;
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Default rank:' || l_default_lead_rank_id);
              END IF;

              IF l_default_lead_rank_id IS NULL
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'AS_NO_DEFAULT_RATING');
              END IF;

              AS_SALES_LEADS_LOG_PKG.Insert_Row(
                  px_log_id                 => l_sales_lead_log_id ,
                  p_sales_lead_id           => p_sales_lead_id,
                  p_created_by              => fnd_global.user_id,
                  p_creation_date           => SYSDATE,
                  p_last_updated_by         => fnd_global.user_id,
                  p_last_update_date        => SYSDATE,
                  p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
                  p_request_id              =>
                      FND_GLOBAL.Conc_Request_Id,
                  p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
                  p_program_id              =>
                      FND_GLOBAL.Conc_Program_Id,
                  p_program_update_date     => SYSDATE,
                  p_status_code             => l_status_code,
                  p_assign_to_person_id     => l_assign_to_person_id,
                  p_assign_to_salesforce_id => l_assign_to_salesforce_id,
                  p_reject_reason_code      => l_reject_reason_code,
                  p_assign_sales_group_id   => l_assign_sales_group_id,
                  p_lead_rank_id            => l_default_lead_rank_id,
                  p_qualified_flag          => l_qualified_flag,
                  p_category                => NULL,
                  p_manual_rank_flag        => 'N');

              UPDATE as_sales_leads
              SET lead_rank_id = l_default_lead_rank_id,
                  lead_rank_ind = 'N'
              WHERE sales_lead_id = p_sales_lead_id;

              x_action_value := TO_CHAR(l_default_lead_rank_id);
              -- ckapoor changed.
          ELSIF p_process_type = G_CHANNEL_SELECTION
          THEN
              l_default_channel_code :=
                  FND_PROFILE.Value('AS_DEFAULT_LEAD_ENGINE_CHANNEL');
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Default channel:' || l_default_channel_code);
              END IF;

              IF l_default_channel_code IS NULL
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'AS_NO_DEFAULT_CHANNEL');
              END IF;

              UPDATE as_sales_leads
              SET channel_code = l_default_channel_code
              WHERE sales_lead_id = p_sales_lead_id;

              x_action_value := l_default_channel_code;

              -- ckapoor changed
          ELSIF p_process_type = G_LEAD_QUALIFICATION -- qualification case
          THEN
            l_default_qualified_flag := FND_PROFILE.Value('AS_DEFAULT_LEAD_ENGINE_QUALIFIED_FLAG');
            IF (AS_DEBUG_LOW_ON) THEN
	      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		  'Default qualified flag:' || l_default_qualified_flag);
	  END IF;
	  IF l_default_qualified_flag IS NULL
	  THEN
	      AS_UTILITY_PVT.Set_Message(
		  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  p_msg_name      => 'AS_NO_DEFAULT_QUALIFIED_FLAG');

	     l_default_qualified_flag := 'N';
	  END IF;

	  UPDATE as_sales_leads
	  SET qualified_flag = l_default_qualified_flag
	  WHERE sales_lead_id = p_sales_lead_id;

              x_action_value := l_default_qualified_flag;

          END IF;

          l_entity_rule_applied_id := NULL;
          PV_ENTITY_RULES_APPLIED_PKG.Insert_Row(
              px_ENTITY_RULE_APPLIED_ID => l_entity_rule_applied_id
             ,p_LAST_UPDATE_DATE => SYSDATE
             ,p_LAST_UPDATED_BY => FND_GLOBAL.USER_ID
             ,p_CREATION_DATE => SYSDATE
             ,p_CREATED_BY => FND_GLOBAL.USER_ID
             ,p_LAST_UPDATE_LOGIN => FND_GLOBAL.CONC_LOGIN_ID
             ,p_OBJECT_VERSION_NUMBER => 1
             ,p_REQUEST_ID => FND_GLOBAL.Conc_Request_Id
             ,p_PROGRAM_APPLICATION_ID => FND_GLOBAL.Prog_Appl_Id
             ,p_PROGRAM_ID => FND_GLOBAL.Conc_Program_Id
             ,p_PROGRAM_UPDATE_DATE => SYSDATE
             ,p_ENTITY => 'SALES_LEAD'
             ,p_ENTITY_ID => p_sales_lead_id
             ,p_PROCESS_RULE_ID => NULL
             ,p_PARENT_PROCESS_RULE_ID => NULL
             ,p_LATEST_FLAG => 'Y'
             ,p_ACTION_VALUE => x_action_value
             ,p_PROCESS_TYPE => p_process_type
             ,p_WINNING_RULE_FLAG => NULL
             ,p_ATTRIBUTE_CATEGORY => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE1 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE2 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE3 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE4 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE5 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE6 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE7 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE8 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE9 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE10 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE11 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE12 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE13 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE14 => FND_API.G_MISS_CHAR
             ,p_ATTRIBUTE15 => FND_API.G_MISS_CHAR
             ,p_PROCESS_STATUS => G_DEFAULT
             ,p_ENTITY_DETAIL => l_status_code);




            -- ckapoor 11.5.10 filtering phase 2

	    -- if no rules match, then check for default qual flag

	    -- if (p_process_type = 'LEAD_QUALIFICATION') then

	    -- l_filter_unqual_leads := FND_PROFILE.value('AS_FILTER_UNQUALIFIED_LEADS');

	    --  if ((l_filter_unqual_leads = 'Y') and (l_is_create_import_mode_val='Y') and
	    -- (l_default_qualified_flag = 'N')) then
	    --     AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	    --	    'Default qual case');
	    --	 AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	    --	    'Filtering error raised from API');
	    --	raise AS_SALES_LEADS_PUB.Filter_Exception;
	    --  end if;
	    -- end if;




      END IF;

      -- Update LEAD_ENGINE_RUN_DATE
      -- Invoke table handler(Sales_Lead_Update_Row)
      AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
          p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_CREATED_BY  => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
          p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
          p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
          p_PROGRAM_UPDATE_DATE  => SYSDATE,
          p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
          p_STATUS_CODE => FND_API.G_MISS_CHAR,
          p_CUSTOMER_ID  => FND_API.G_MISS_NUM,
          p_ADDRESS_ID  => FND_API.G_MISS_NUM,
          p_SOURCE_PROMOTION_ID  => FND_API.G_MISS_NUM,
          p_INITIATING_CONTACT_ID => FND_API.G_MISS_NUM,
          p_ORIG_SYSTEM_REFERENCE => FND_API.G_MISS_CHAR,
          p_CONTACT_ROLE_CODE  => FND_API.G_MISS_CHAR,
          p_CHANNEL_CODE  => FND_API.G_MISS_CHAR,
          p_BUDGET_AMOUNT  => FND_API.G_MISS_NUM,
          p_CURRENCY_CODE  => FND_API.G_MISS_CHAR,
          p_DECISION_TIMEFRAME_CODE => FND_API.G_MISS_CHAR,
          p_CLOSE_REASON  => FND_API.G_MISS_CHAR,
          p_LEAD_RANK_ID  => FND_API.G_MISS_NUM,
          p_LEAD_RANK_CODE  => FND_API.G_MISS_CHAR,
          p_PARENT_PROJECT  => FND_API.G_MISS_CHAR,
          p_DESCRIPTION  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE_CATEGORY  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE1  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE2  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE3  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE4  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE5  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE6  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE7  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE8  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE9  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE10  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE11  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE12  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE13  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE14  => FND_API.G_MISS_CHAR,
          p_ATTRIBUTE15  => FND_API.G_MISS_CHAR,
          p_ASSIGN_TO_PERSON_ID  => FND_API.G_MISS_NUM,
          p_ASSIGN_TO_SALESFORCE_ID => FND_API.G_MISS_NUM,
          p_ASSIGN_SALES_GROUP_ID => FND_API.G_MISS_NUM,
          p_ASSIGN_DATE  => FND_API.G_MISS_DATE,
          p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
          p_ACCEPT_FLAG  => FND_API.G_MISS_CHAR,
          p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
          p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
          p_SCORECARD_ID  => FND_API.G_MISS_NUM,
          p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
          p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
          p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
          p_REJECT_REASON_CODE  => FND_API.G_MISS_CHAR,
          p_DELETED_FLAG => FND_API.G_MISS_CHAR,
          p_OFFER_ID  =>  FND_API.G_MISS_NUM,
          p_QUALIFIED_FLAG => FND_API.G_MISS_CHAR,
          p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
          p_INC_PARTNER_PARTY_ID => FND_API.G_MISS_NUM,
          p_INC_PARTNER_RESOURCE_ID => FND_API.G_MISS_NUM,
          p_PRM_EXEC_SPONSOR_FLAG   => FND_API.G_MISS_CHAR,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG => FND_API.G_MISS_CHAR,
          p_PRM_SALES_LEAD_TYPE     => FND_API.G_MISS_CHAR,
          p_PRM_IND_CLASSIFICATION_CODE => FND_API.G_MISS_CHAR,
          p_PRM_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
          p_AUTO_ASSIGNMENT_TYPE => FND_API.G_MISS_CHAR,
          p_PRIMARY_CONTACT_PARTY_ID => FND_API.G_MISS_NUM,
          p_PRIMARY_CNT_PERSON_PARTY_ID => FND_API.G_MISS_NUM,
          p_PRIMARY_CONTACT_PHONE_ID => FND_API.G_MISS_NUM,
          p_REFERRED_BY => FND_API.G_MISS_NUM,
          p_REFERRAL_TYPE => FND_API.G_MISS_CHAR,
          p_REFERRAL_STATUS => FND_API.G_MISS_CHAR,
          p_REF_DECLINE_REASON => FND_API.G_MISS_CHAR,
          p_REF_COMM_LTR_STATUS => FND_API.G_MISS_CHAR,
          p_REF_ORDER_NUMBER => FND_API.G_MISS_NUM,
          p_REF_ORDER_AMT => FND_API.G_MISS_NUM,
          p_REF_COMM_AMT => FND_API.G_MISS_NUM,
          -- bug No.2341515, 2368075
          p_LEAD_DATE =>  FND_API.G_MISS_DATE,
          p_SOURCE_SYSTEM => FND_API.G_MISS_CHAR,
          p_COUNTRY => FND_API.G_MISS_CHAR,
          p_TOTAL_AMOUNT => FND_API.G_MISS_NUM,
          p_EXPIRATION_DATE => FND_API.G_MISS_DATE,
          p_LEAD_RANK_IND => FND_API.G_MISS_CHAR,
          p_LEAD_ENGINE_RUN_DATE => SYSDATE,
          p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
          p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
          p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM

	  -- 11.5.10 new columns ckapoor


	, p_MARKETING_SCORE	=> FND_API.G_MISS_NUM
	, p_INTERACTION_SCORE   => FND_API.G_MISS_NUM
	, p_SOURCE_PRIMARY_REFERENCE	=> FND_API.G_MISS_CHAR
	, p_SOURCE_SECONDARY_REFERENCE	=> FND_API.G_MISS_CHAR
	, p_SALES_METHODOLOGY_ID	=> FND_API.G_MISS_NUM
	, p_SALES_STAGE_ID		=> FND_API.G_MISS_NUM



          );

       -- this code is only for CRMAP denorm project
      IF p_process_type = G_LEAD_RATING
      THEN
          IF l_lead_rank_id IS NULL
          THEN
              l_lead_rank_score := 0;
          ELSE
              OPEN c_get_rank_score(l_lead_rank_id);
              FETCH c_get_rank_score INTO l_lead_rank_score;
              CLOSE c_get_rank_score;
          END IF;

          UPDATE as_sales_leads
          SET lead_rank_score = l_lead_rank_score
          WHERE sales_lead_id = p_sales_lead_id;

          UPDATE as_accesses_all
          SET lead_rank_score = l_lead_rank_score
          WHERE sales_lead_id = p_sales_lead_id;
      END IF;
      -- end CRMAP denorm project

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION

      	 -- WHEN AS_SALES_LEADS_PUB.Filter_Exception THEN
	 --               RAISE AS_SALES_LEADS_PUB.Filter_Exception;
	 --               --RAISE_APPLICATION_ERROR(-20100, 'Filter Exception'));

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

END Rate_Select_Lead;


PROCEDURE Lead_Process_After_Create(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    p_Commit                  IN  VARCHAR2,
    p_Validation_Level        IN  NUMBER,
    P_Check_Access_Flag       IN  VARCHAR2,
    p_Admin_Flag              IN  VARCHAR2,
    P_Admin_Group_Id          IN  NUMBER,
    P_identity_salesforce_id  IN  NUMBER,
    P_Salesgroup_id           IN  NUMBER,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Lead_Process_After_Create';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_lead_engines_out_rec      AS_SALES_LEADS_PUB.Lead_Engines_Out_Rec_Type;
    L_Sales_Lead_Profile_Tbl    AS_UTILITY_PUB.Profile_Tbl_Type;
    l_opportunity_id            NUMBER;
    l_customer_id               NUMBER;
    l_address_id                NUMBER;
    l_referral_type             VARCHAR2(30);
    l_assign_to_salesforce_id   NUMBER;
    l_status_code               VARCHAR2(30);
    l_access_id                 NUMBER;
    l_person_id                 NUMBER;
    l_request_id                NUMBER;
    l_sales_team_rec            AS_ACCESS_PVT.sales_team_rec_type;
--  l_overriding_usernames      AS_SALES_LEAD_REFERRAL.t_overriding_usernames;
    l_open_status_flag          VARCHAR2(1);
    l_return_status             VARCHAR2(1);
    -- Added for bug 7654339
    l_freeze_flag               VARCHAR2(1);
    l_created_by_tap_flag       VARCHAR2(1);

    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID, SL.ADDRESS_ID, SL.REFERRAL_TYPE,
             SL.ASSIGN_TO_SALESFORCE_ID, SL.STATUS_CODE
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    CURSOR C_Get_Person(C_Resource_Id NUMBER) IS
      SELECT source_id
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = c_resource_id;

    CURSOR C_Get_Open_Status_Flag(C_Status_Code VARCHAR2) IS
      SELECT opp_open_status_flag
      FROM   as_statuses_b
      WHERE  status_code = c_status_code
      AND    lead_flag = 'Y';

  -- Below two cursors added for bug 7654339
    CURSOR C_Check_Freeze(c_sales_lead_id NUMBER) IS
      SELECT acc.freeze_flag
      FROM   as_accesses_all acc
      WHERE  acc.sales_lead_id = c_sales_lead_id
      AND    acc.owner_flag = 'Y';

   CURSOR C_Check_TAP(c_sales_lead_id NUMBER) IS
      SELECT 'Y'
      FROM  as_accesses_all acc
      WHERE acc.sales_lead_id = c_sales_lead_id
      AND   acc.created_by_tap_flag = 'Y';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT LEAD_PROCESS_AFTER_CREATE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      Run_Lead_Engines(
          P_Api_Version_Number         => 2.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          P_Validation_Level           => P_Validation_Level,
          P_Admin_Group_Id             => P_Admin_Group_Id,
          P_identity_salesforce_id     => P_identity_salesforce_id,
          P_Salesgroup_id              => P_Salesgroup_id,
          P_Sales_Lead_id              => P_Sales_Lead_id,
          -- ckapoor Phase 2 filtering project 11.5.10
          -- P_Is_Create_Mode	       => 'Y',

          X_Lead_Engines_Out_Rec       => l_lead_engines_out_rec,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN C_Get_Lead_Info(P_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO l_customer_id, l_address_id, l_referral_type,
            l_assign_to_salesforce_id, l_status_code;
      CLOSE C_Get_Lead_Info;

      IF L_Lead_Engines_Out_Rec.sales_team_flag = 'Y'
      THEN
          -- not incubation lead
          As_Sales_Lead_Assign_PVT.Build_Lead_Sales_Team(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Salesgroup_id              => P_Salesgroup_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              X_Request_id                 => l_request_id,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- below code added for bug 7654339
          l_freeze_flag := 'N';
	  l_created_by_tap_flag := 'N';
	  OPEN  C_Check_Freeze(p_sales_lead_id);
          FETCH C_Check_Freeze INTO l_freeze_flag;
          CLOSE C_Check_Freeze;
	  OPEN  C_Check_TAP(p_sales_lead_id);
          FETCH C_Check_TAP INTO l_created_by_tap_flag;
          CLOSE C_Check_TAP;

	-- Condition modified for bug 7654339
        -- Creator to be deleted from Sales Team in Real Time TAP when there are winning resources from TAP

	IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'Y'  AND
             l_created_by_tap_flag  = 'Y' THEN

              DELETE from as_accesses_all acc
               WHERE acc.sales_lead_id = p_sales_lead_id
                 AND nvl(acc.freeze_flag,'N') = 'N'
		     AND acc.created_by_tap_flag = 'N';
        END IF;

	  -- condition modified for bug 7654339
	  IF NVL(l_freeze_flag,'N') = 'N' AND
             l_created_by_tap_flag  = 'Y' AND
	     NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'Y'
          THEN
              As_Sales_Lead_Assign_PVT.Find_Lead_Owner(
                  p_sales_lead_id, p_salesgroup_id, l_request_id,
                  l_return_status, x_msg_count, x_msg_data);

              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE fnd_api.g_exc_unexpected_error;
              END IF;
          ELSE
              As_Sales_Lead_Assign_PVT.Process_Access_Record(
                  p_sales_lead_id, l_request_id);
          END IF;

      ELSE
          -- incubation lead
          IF l_assign_to_salesforce_id IS NULL
          THEN
              AS_SALES_LEADS_PUB.ROUTE_LEAD_TO_MARKETING(
                  P_Api_Version_Number         => 2.0,
                  P_Init_Msg_List              => FND_API.G_FALSE,
                  P_Commit                     => FND_API.G_FALSE,
                  P_Validation_Level           => P_Validation_Level,
                  P_Admin_Group_Id             => P_Admin_Group_Id,
                  P_identity_salesforce_id     => P_identity_salesforce_id,
                  P_Sales_Lead_id              => P_Sales_Lead_id,
                  X_Return_Status              => x_return_status,
                  X_Msg_Count                  => x_msg_count,
                  X_Msg_Data                   => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;

          OPEN C_Get_Person(P_identity_salesforce_id);
          FETCH C_Get_Person INTO l_person_id;
          CLOSE C_Get_Person;

          -- Add creator to sales team
          l_Sales_Team_Rec.last_update_date     := SYSDATE;
          l_Sales_Team_Rec.last_updated_by      := FND_GLOBAL.USER_ID;
          l_Sales_Team_Rec.creation_date        := SYSDATE;
          l_Sales_Team_Rec.created_by           := FND_GLOBAL.USER_ID;
          l_Sales_Team_Rec.last_update_login    := FND_GLOBAL.CONC_LOGIN_ID;
          l_Sales_Team_Rec.customer_id          := l_Customer_Id;
          l_Sales_Team_Rec.address_id           := l_Address_Id;
          l_Sales_Team_Rec.salesforce_id        := P_identity_salesforce_id;
          l_Sales_Team_Rec.person_id            := l_person_id;
          l_Sales_Team_Rec.sales_group_id       := P_salesgroup_id;
          l_Sales_Team_Rec.sales_lead_id        := p_sales_lead_id;
          l_Sales_Team_Rec.team_leader_flag     := 'Y';
          l_Sales_Team_Rec.owner_flag           := 'N';
          l_Sales_Team_Rec.freeze_flag          := 'Y';
          l_Sales_Team_Rec.reassign_flag        := 'N';
          l_Sales_Team_Rec.created_by_TAP_flag  := 'N';

          As_Access_PVT.Create_SalesTeam( -- for creator
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Access_Profile_Rec         => NULL,
              P_Check_Access_Flag          => 'N',
              P_Admin_Flag                 => P_Admin_Flag,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              p_sales_team_rec             => l_sales_team_rec,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data,
              X_Access_Id                  => l_access_id);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'indirect?' || L_Lead_Engines_Out_Rec.indirect_channel_flag);
      END IF;
      IF L_Lead_Engines_Out_Rec.indirect_channel_flag = 'Y' AND
         L_Lead_Engines_Out_Rec.qualified_flag = 'Y' AND
         FND_PROFILE.Value('AS_AUTO_CONVERT_LEAD_OPP') = 'Y'
      THEN
          As_Sales_Lead_Opp_PVT.Create_Opportunity_For_Lead(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Check_Access_Flag          => P_Check_Access_Flag,
              P_Admin_Flag                 => P_Admin_Flag,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_identity_Salesgroup_id     => P_Salesgroup_id,
              P_Sales_Lead_Profile_Tbl     => L_Sales_Lead_Profile_Tbl,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              P_OPP_STATUS                 => NULL,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data,
              X_Opportunity_Id             => l_opportunity_id);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          PV_BG_PARTNER_MATCHING_PUB.Start_Partner_Matching(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Salesgroup_id              => P_Salesgroup_id,
              P_Lead_id                    => L_Opportunity_Id,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

--      IF l_referral_type IS NOT NULL
--      THEN
--          AS_SALES_LEAD_REFERRAL.Notify_Party(
--              P_Api_Version                => 2.0,
--              P_Init_Msg_List              => FND_API.G_FALSE,
--              P_Commit                     => FND_API.G_FALSE,
--              P_Validation_Level           => P_Validation_Level,
--              P_Lead_Id                    => p_sales_lead_id,
--              P_Lead_Status                => NULL,
--              P_salesforce_id              => P_identity_salesforce_id,
--              p_overriding_usernames       => l_overriding_usernames,
--              X_Return_Status              => x_return_status,
--              X_Msg_Count                  => x_msg_count,
--              X_Msg_Data                   => x_msg_data);

--          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--              RAISE FND_API.G_EXC_ERROR;
--          END IF;
--      END IF;

      OPEN C_Get_Lead_Info(P_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO l_customer_id, l_address_id, l_referral_type,
            l_assign_to_salesforce_id, l_status_code;
      CLOSE C_Get_Lead_Info;

      OPEN C_Get_Open_Status_Flag(l_status_code);
      FETCH C_Get_Open_Status_Flag INTO l_open_status_flag;
      CLOSE C_Get_Open_Status_Flag;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'status_code=' || l_status_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'open status flag=' || l_open_status_flag);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'assign_to_sf_id=' || l_assign_to_salesforce_id);
      END IF;

      IF l_open_status_flag = 'Y' AND l_assign_to_salesforce_id IS NOT NULL
        AND l_lead_engines_out_rec.qualified_flag = 'Y'
      THEN
          aml_monitor_wf.launch_monitor(
              P_Api_Version_Number         =>  2.0,
              P_Init_Msg_List              =>  FND_API.G_FALSE,
              p_commit                     =>  FND_API.G_FALSE,
              P_Sales_Lead_Id              =>  p_sales_lead_id,
              P_Changed_From_stage         =>  'CREATION_DATE',
              P_Lead_Action                =>  'CREATE',
              -- 9/9/03 SWKHANNA -- Added for Lead Upgrade/Downgrade Functionality
              P_Attribute_Changed          =>  NULL,
              X_Return_Status              =>  x_return_status,
              X_Msg_Count                  =>  x_msg_count,
              X_Msg_Data                   =>  x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      -- ER 3052066
      -- Leave a record for TAP New mode
      -- Used to sync TRANS and NM_TRANS table
      BEGIN
          INSERT INTO AS_CHANGED_ACCOUNTS_ALL(
              customer_id, address_id, sales_lead_id, last_update_date,
              last_updated_by, creation_date, created_by,
              last_update_login, change_type, delete_flag, insert_flag,
              processed_flag)
          VALUES
             (l_Customer_Id, l_Address_id, P_Sales_Lead_id, SYSDATE,
              FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID,
              FND_GLOBAL.CONC_LOGIN_ID, 'LEAD', 'N', 'Y',
              'Y');
      EXCEPTION
          WHEN OTHERS THEN
            UPDATE AS_CHANGED_ACCOUNTS_ALL
            SET processed_flag = 'Y'
            WHERE sales_lead_id = p_sales_lead_id;
      END;
--      IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'Y'
--      THEN
          -- 1. If AS_ENABLE_LEAD_ONLINE_TAP is 'Y', update record.
          -- 2. If AS_ENABLE_LEAD_ONLINE_TAP is 'N', still keep it in
          --    as_changed_accounts_all, so TAP New Mode will pick up this
          --    record.
--          DELETE FROM as_changed_accounts_all
--          WHERE sales_lead_id = p_sales_lead_id;
--          IF (AS_DEBUG_LOW_ON) THEN
--              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
--                  'Delete as_changed_accounts_all record');
--          END IF;
--          UPDATE as_changed_accounts_all
--          SET processed_flag = 'Y'
--          WHERE sales_lead_id = p_sales_lead_id;
--      END IF;

      IF l_return_status = 'W'
      THEN
          x_return_status := 'W';
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      IF x_return_status = 'W'
      THEN
          FND_MSG_PUB.Count_And_Get
          (
             p_encoded        =>   FND_API.G_FALSE,
             p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );
      ELSE
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );
      END IF;

      EXCEPTION

      	 -- WHEN AS_SALES_LEADS_PUB.Filter_Exception THEN
	 --               RAISE AS_SALES_LEADS_PUB.Filter_Exception;

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
END Lead_Process_After_Create;


PROCEDURE Lead_Process_After_Update(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    p_Commit                  IN  VARCHAR2,
    p_Validation_Level        IN  NUMBER,
    P_Check_Access_Flag       IN  VARCHAR2,
    p_Admin_Flag              IN  VARCHAR2,
    P_Admin_Group_Id          IN  NUMBER,
    P_identity_salesforce_id  IN  NUMBER,
    P_Salesgroup_id           IN  NUMBER,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Lead_Process_After_Update';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_auto_run_lead_engines     VARCHAR2(1);
    l_lead_engines_out_rec      AS_SALES_LEADS_PUB.Lead_Engines_Out_Rec_Type;
    L_Sales_Lead_Profile_Tbl    AS_UTILITY_PUB.Profile_Tbl_Type;
    l_opportunity_id            NUMBER;
    l_customer_id               NUMBER;
    l_address_id                NUMBER;
    l_referral_type             VARCHAR2(30);
    l_assign_to_salesforce_id   NUMBER;
    l_status_code               VARCHAR2(30);
    l_reject_reason_code        VARCHAR2(30);
    l_access_id                 NUMBER;
    l_person_id                 NUMBER;
    l_request_id                NUMBER;
    l_sales_team_rec            AS_ACCESS_PVT.sales_team_rec_type;
--  l_overriding_usernames      AS_SALES_LEAD_REFERRAL.t_overriding_usernames;
    l_owner_exists_flag         VARCHAR2(1) := 'N';
    l_owner_changed_flag        VARCHAR2(1) := 'N';
    l_open_status_flag          VARCHAR2(1);
    l_creation_date_tbl         JTF_DATE_TABLE;
    l_resource_id_tbl           JTF_NUMBER_TABLE;
    l_creation_date             DATE;
    l_resource_id               NUMBER;
    l_i                         NUMBER;
    l_return_status             VARCHAR2(1);

-- swkhanna Jun17,03
    l_rank_changed_flag        VARCHAR2(1) := 'N';
    l_lead_rank_id             NUMBER;
    l_rank_id                  NUMBER;
    l_rank_id_tbl              JTF_NUMBER_TABLE;
-- 9/9/03 SWKHANNA
    l_attribute_changed        VARCHAR2(60);

    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID, SL.ADDRESS_ID, SL.REFERRAL_TYPE,
             SL.ASSIGN_TO_SALESFORCE_ID, SL.QUALIFIED_FLAG,
             SL.LEAD_RANK_ID, SL.CHANNEL_CODE, SL.STATUS_CODE,
             SL.REJECT_REASON_CODE
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    -- Retrieve channel type
    CURSOR c_get_indirect_channel_flag(c_channel_code VARCHAR2) IS
      SELECT NVL(channel.indirect_channel_flag, 'N')
      FROM pv_channel_types channel
      WHERE channel.channel_lookup_code = c_channel_code;

    -- Check whether owner exists or not
    CURSOR c_check_owner_exists(c_sales_lead_id NUMBER) IS
      SELECT 'Y'
      FROM as_accesses_all acc
      WHERE acc.sales_lead_id = c_sales_lead_id
      AND acc.owner_flag = 'Y';

    CURSOR C_Get_Person(C_Resource_Id NUMBER) IS
      SELECT source_id
      FROM   jtf_rs_resource_extns
      WHERE  resource_id = c_resource_id;

    CURSOR C_Get_Open_Status_Flag(c_sales_lead_id NUMBER) IS
      SELECT lead.status_code, sta.opp_open_status_flag
      FROM   as_statuses_b sta, as_sales_leads lead
      WHERE  lead.sales_lead_id = c_sales_lead_id
      AND    lead.status_code = sta.status_code
      AND    sta.lead_flag = 'Y';


      -- swkhanna Jun17,03
      -- also added lead_rank_id in select clause
    CURSOR C_Get_Log(C_Sales_Lead_Id NUMBER) IS
      SELECT creation_date, assign_to_salesforce_id, lead_rank_id
      FROM   as_sales_leads_log
      WHERE  sales_lead_id = c_sales_lead_id
      ORDER BY log_id DESC;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT LEAD_PROCESS_AFTER_UPDATE_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT:' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************

      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (p_validation_level = fnd_api.g_valid_level_full)
      THEN
          AS_SALES_ORG_MANAGER_PVT.Get_CurrentUser(
              p_api_version_number => 2.0
             ,p_init_msg_list      => p_init_msg_list
             ,p_salesforce_id      => P_Identity_Salesforce_Id
             ,p_admin_group_id     => p_admin_group_id
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data           => x_msg_data
             ,x_sales_member_rec   => l_identity_sales_member_rec);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      OPEN C_Get_Lead_Info(P_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO l_customer_id, l_address_id, l_referral_type,
          l_assign_to_salesforce_id,
          l_lead_engines_out_rec.qualified_flag,
          l_lead_engines_out_rec.lead_rank_id,
          l_lead_engines_out_rec.channel_code,
          l_status_code, l_reject_reason_code;
      CLOSE C_Get_Lead_Info;

      -- Profile OS: Auto Run Lead Engines While Update
      l_auto_run_lead_engines := FND_PROFILE.Value('AS_AUTO_RUN_LEAD_ENGINES');
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'auto run engine=' || l_auto_run_lead_engines);
      END IF;
      IF NVL(l_auto_run_lead_engines, 'N') = 'Y'
      THEN
          Run_Lead_Engines(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Salesgroup_id              => P_Salesgroup_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              -- ckapoor Phase 2 filtering project 11.5.10
              -- P_Is_Create_Mode	           => 'N',

              X_Lead_Engines_Out_Rec       => l_lead_engines_out_rec,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      ELSE
          OPEN c_get_indirect_channel_flag(l_lead_engines_out_rec.channel_code);
          FETCH c_get_indirect_channel_flag INTO
              l_lead_engines_out_rec.indirect_channel_flag;
          CLOSE c_get_indirect_channel_flag;

          IF l_lead_engines_out_rec.channel_code =
             FND_PROFILE.Value('AS_LEAD_INCUBATION_CHANNEL')
          THEN
              l_lead_engines_out_rec.sales_team_flag := 'N';
          ELSE
              l_lead_engines_out_rec.sales_team_flag := 'Y';
          END IF;
      END IF;

      OPEN c_check_owner_exists(p_sales_lead_id);
      FETCH c_check_owner_exists INTO l_owner_exists_flag;
      CLOSE c_check_owner_exists;

      IF L_Lead_Engines_Out_Rec.sales_team_flag = 'Y'
      THEN
          -- not incubation lead
          As_Sales_Lead_Assign_PVT.Rebuild_Lead_Sales_Team(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Salesgroup_id              => P_Salesgroup_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              X_Request_id                 => l_request_id,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Check owner again here because Rebuild_Lead_Sales_Team may
          -- remove owner in as_accesses_all
          l_owner_exists_flag := 'N';
          OPEN c_check_owner_exists(p_sales_lead_id);
          FETCH c_check_owner_exists INTO l_owner_exists_flag;
          CLOSE c_check_owner_exists;

          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'assign to=' || l_assign_to_salesforce_id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'reject reason=' || l_reject_reason_code);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'owner exist?' || l_owner_exists_flag);
          END IF;
          IF l_assign_to_salesforce_id IS NULL OR
             l_reject_reason_code IS NOT NULL OR
             l_owner_exists_flag = 'N'
          THEN
              As_Sales_Lead_Assign_PVT.Find_Lead_Owner(
                  p_sales_lead_id, p_salesgroup_id, l_request_id,
                  l_return_status, x_msg_count, x_msg_data);

              IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE fnd_api.g_exc_unexpected_error;
              END IF;
              l_owner_changed_flag := 'Y';
          ELSE
              As_Sales_Lead_Assign_PVT.Process_Access_Record(
                  p_sales_lead_id, l_request_id);
          END IF;
      ELSE
          -- lead with incubation channel
          AS_SALES_LEADS_PUB.ROUTE_LEAD_TO_MARKETING(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF L_Lead_Engines_Out_Rec.indirect_channel_flag = 'Y' AND
         FND_PROFILE.Value('AS_AUTO_CONVERT_LEAD_OPP') = 'Y' AND
         l_status_code <> 'CONVERTED_TO_OPPORTUNITY'
      THEN
          As_Sales_Lead_Opp_PVT.Create_Opportunity_For_Lead(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Check_Access_Flag          => P_Check_Access_Flag,
              P_Admin_Flag                 => P_Admin_Flag,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_identity_Salesgroup_id     => P_Salesgroup_id,
              P_Sales_Lead_Profile_Tbl     => L_Sales_Lead_Profile_Tbl,
              P_Sales_Lead_id              => P_Sales_Lead_id,
              P_OPP_STATUS                 => NULL,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data,
              X_Opportunity_Id             => l_opportunity_id);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          PV_BG_PARTNER_MATCHING_PUB.Start_Partner_Matching(
              P_Api_Version_Number         => 2.0,
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Commit                     => FND_API.G_FALSE,
              P_Validation_Level           => P_Validation_Level,
              P_Admin_Group_Id             => P_Admin_Group_Id,
              P_identity_salesforce_id     => P_identity_salesforce_id,
              P_Salesgroup_id              => P_Salesgroup_id,
              P_Lead_id                    => L_Opportunity_Id,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

--      IF l_referral_type IS NOT NULL
--      THEN
--          AS_SALES_LEAD_REFERRAL.Notify_Party(
--              P_Api_Version                => 2.0,
--              P_Init_Msg_List              => FND_API.G_FALSE,
--              P_Commit                     => FND_API.G_FALSE,
--              P_Validation_Level           => P_Validation_Level,
--              P_Lead_Id                    => p_sales_lead_id,
--              P_Lead_Status                => NULL,
--              P_salesforce_id              => P_identity_salesforce_id,
--              p_overriding_usernames       => l_overriding_usernames,
--              X_Return_Status              => x_return_status,
--              X_Msg_Count                  => x_msg_count,
--              X_Msg_Data                   => x_msg_data);

--          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--              RAISE FND_API.G_EXC_ERROR;
--          END IF;
--      END IF;

      OPEN C_Get_Open_Status_Flag(p_sales_lead_id);
      FETCH C_Get_Open_Status_Flag INTO l_status_code, l_open_status_flag;
      CLOSE C_Get_Open_Status_Flag;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'status=' || l_status_code);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'open?' || l_open_status_flag);
      END IF;

      OPEN C_Get_Lead_Info(P_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO l_customer_id, l_address_id, l_referral_type,
          l_assign_to_salesforce_id,
          l_lead_engines_out_rec.qualified_flag,
         -- l_lead_engines_out_rec.lead_rank_id,
         -- swkhanna Jun17,03
          l_lead_rank_id,
          l_lead_engines_out_rec.channel_code,
          l_status_code, l_reject_reason_code;
      CLOSE C_Get_Lead_Info;

      IF l_owner_changed_flag = 'N'
      THEN
          -- Get the time when previous owner still owns the lead.
          OPEN C_Get_Log(P_Sales_Lead_Id);
          FETCH C_Get_Log BULK COLLECT INTO
              l_creation_date_tbl, l_resource_id_tbl, l_rank_id_tbl ;
          CLOSE C_Get_Log;

          IF (AS_DEBUG_LOW_ON) AND l_creation_date_tbl.count>=1 THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'count=' || l_creation_date_tbl.count);
          END IF;
          IF l_creation_date_tbl.count >= 1
          THEN
              l_i := 1;

              WHILE l_i <= l_creation_date_tbl.count
              LOOP
                  l_resource_id := l_resource_id_tbl(l_i);
                  l_creation_date := l_creation_date_tbl(l_i);

                  IF l_resource_id = l_assign_to_salesforce_id AND
                     SYSDATE > l_creation_date+0.0001
                  THEN
                      -- There's no record inserted for this transaction.
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'same owner, no change');
                      END IF;
                      l_owner_changed_flag := 'N';
                      EXIT;
                  END IF;
                  IF l_resource_id <> l_assign_to_salesforce_id
                  THEN
                      -- User manually sets the owner.
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'different owner');
                      END IF;
                      EXIT;
                  END IF;

                  l_i := l_i + 1;
              END LOOP;

              IF l_resource_id <> l_assign_to_salesforce_id
              THEN
                  l_owner_changed_flag := 'Y';
              END IF;
          END IF;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'open status flag=' || l_open_status_flag);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'assign_to_sf_id=' || l_assign_to_salesforce_id);
      END IF;

      -- swkhanna Jun17,03

      IF l_rank_changed_flag = 'N'
      THEN
          --dbms_output.put_line('SWKHANNA l_rank_changed_flag:'||l_rank_changed_flag);
          -- Get the previous rank
          OPEN C_Get_Log(P_Sales_Lead_Id);
          FETCH C_Get_Log BULK COLLECT INTO
              l_creation_date_tbl, l_resource_id_tbl, l_rank_id_tbl;
          CLOSE C_Get_Log;

          IF (AS_DEBUG_LOW_ON) AND l_creation_date_tbl.count>=1 THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'count=' || l_creation_date_tbl.count);
          END IF;
          IF l_creation_date_tbl.count >= 1
          THEN
              l_i := 1;

              WHILE l_i <= l_creation_date_tbl.count
              LOOP
                  l_resource_id := l_resource_id_tbl(l_i);
                  l_rank_id := l_rank_id_tbl(l_i);
                  l_creation_date := l_creation_date_tbl(l_i);

                  IF l_rank_id = l_lead_rank_id AND
                     SYSDATE > l_creation_date+0.0001
                  THEN
                      -- There's no record inserted for this transaction.
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'same rank, no change');
                               --dbms_output.put_line('SWKHANNA same rank');
                      END IF;
                      l_rank_changed_flag := 'N';
                      EXIT;
                  END IF;
                  IF l_rank_id <> l_lead_rank_id
                  THEN
                      -- User manually sets the owner.
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'different rank');
                              --dbms_output.put_line('SWKHANNA different rank');
                      END IF;
                      EXIT;
                  END IF;

                  l_i := l_i + 1;
              END LOOP;

              IF l_rank_id <> l_lead_rank_id
              THEN
                  l_rank_changed_flag := 'Y';
              END IF;
          END IF;
      END IF;
-- swkhanna
-- 9/9/03 SWKHANNA Lead Upgrade/Downgrade Functionality
     if l_owner_changed_flag = 'Y' then
          l_attribute_changed := 'OWNER';
      end if;

      if l_rank_changed_flag = 'Y' then
         l_attribute_changed := 'RANK';
      end if;

      IF l_open_status_flag = 'Y' AND l_assign_to_salesforce_id IS NOT NULL AND
         --l_owner_changed_flag = 'Y' AND
        (l_owner_changed_flag = 'Y' OR l_rank_changed_flag = 'Y') AND
         l_lead_engines_out_rec.qualified_flag = 'Y'
      THEN
          aml_monitor_wf.launch_monitor(
              P_Api_Version_Number         =>  2.0,
              P_Init_Msg_List              =>  FND_API.G_FALSE,
              p_commit                     =>  FND_API.G_FALSE,
              P_Sales_Lead_Id              =>  p_sales_lead_id,
              P_Changed_From_stage         =>  'ASSIGNED_DATE',
              P_Lead_Action                =>  'UPDATE',
              -- 9/9/03 SWKHANNA -- added for Lead Upgrade/Downgrade
              P_Attribute_Changed          =>  l_attribute_changed,
              X_Return_Status              =>  x_return_status,
              X_Msg_Count                  =>  x_msg_count,
              X_Msg_Data                   =>  x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      -- ER 3052066
      -- Leave a record for TAP New mode
      -- Used to sync TRANS and NM_TRANS table
      BEGIN
          INSERT INTO AS_CHANGED_ACCOUNTS_ALL(
              customer_id, address_id, sales_lead_id, last_update_date,
              last_updated_by, creation_date, created_by,
              last_update_login, change_type, delete_flag, insert_flag,
              processed_flag)
          VALUES
             (l_Customer_Id, l_Address_id, P_Sales_Lead_id, SYSDATE,
              FND_GLOBAL.USER_ID, SYSDATE, FND_GLOBAL.USER_ID,
              FND_GLOBAL.CONC_LOGIN_ID, 'LEAD', 'N', 'Y',
              'Y');
      EXCEPTION
          WHEN OTHERS THEN
            UPDATE AS_CHANGED_ACCOUNTS_ALL
            SET processed_flag = 'Y'
            WHERE sales_lead_id = p_sales_lead_id;
      END;
--      IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'Y'
--      THEN
          -- 1. If AS_ENABLE_LEAD_ONLINE_TAP is 'Y', delete record.
          -- 2. If AS_ENABLE_LEAD_ONLINE_TAP is 'N', still keep it in
          --    as_changed_accounts_all, so TAP New Mode will pick up this
          --    record.
--          DELETE FROM as_changed_accounts_all
--          WHERE sales_lead_id = p_sales_lead_id;
--          IF (AS_DEBUG_LOW_ON) THEN
--              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
--                  'Delete as_changed_accounts_all record');
--          END IF;
--      END IF;

      IF l_return_status = 'W'
      THEN
          x_return_status := 'W';
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      IF x_return_status = 'W'
      THEN
          FND_MSG_PUB.Count_And_Get
          (
             p_encoded        =>   FND_API.G_FALSE,
             p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );
      ELSE
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );
      END IF;

      EXCEPTION

	--  WHEN AS_SALES_LEADS_PUB.Filter_Exception THEN
	--	RAISE AS_SALES_LEADS_PUB.Filter_Exception;

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
END Lead_Process_After_Update;






END AS_SALES_LEAD_ENGINE_PVT;

/
