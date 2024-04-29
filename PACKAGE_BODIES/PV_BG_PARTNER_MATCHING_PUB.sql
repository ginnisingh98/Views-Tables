--------------------------------------------------------
--  DDL for Package Body PV_BG_PARTNER_MATCHING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BG_PARTNER_MATCHING_PUB" as
/* $Header: pvxvpmbb.pls 120.5 2006/08/17 20:01:43 amaram ship $ */
-- Start of Comments
-- Package name     : PV_BG_PARTNER_MATCHING_PUB
-- Purpose          : Background partner matching API's
-- NOTE             :
-- History          :
--      01/07/2003 PKLIN  Created.
--
-- END of Comments


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'PV_BG_PARTNER_MATCHING_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpmbb.pls';


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);


PROCEDURE Start_Partner_Matching(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    P_Commit                  IN  VARCHAR2,
    P_Validation_Level        IN  NUMBER,
    P_Admin_Group_Id          IN  NUMBER,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Salesgroup_Id           IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Start_Partner_Matching';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_item_type        VARCHAR2(8) := 'PVXSLENW';
    l_item_key         VARCHAR2(30);
    l_status           VARCHAR2(80);
    l_result           VARCHAR2(10);
    l_workflow_process VARCHAR2(30) := 'PV_AUTOMATED_PARTNER_MATCHING';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT START_PARTNER_MATCHING_PVT;

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

    -- Start Process :
    --  If workflowprocess is passed, it will be run.
    --  If workflowprocess is NOT passed, the selector FUNCTION
    --  defined in the item type will determine which process to run.

    SELECT TO_CHAR(PV_LEAD_WORKFLOWS_S.nextval) INTO l_item_key
    FROM dual;

    wf_engine.CreateProcess( ItemType => l_Item_Type,
                             ItemKey  => l_Item_Key,
                             process  => l_Workflow_process);

    -- Initialize workflow item attributes
    --
    wf_engine.SetItemAttrNumber(itemtype => l_Item_Type,
                                itemkey  => l_Item_Key,
                                aname    => 'LEAD_ID',
                                avalue   => p_lead_id);

    wf_engine.SetItemAttrNumber(itemtype => l_Item_Type,
                                itemkey  => l_Item_Key,
                                aname    => 'IDENTITY_SALESFORCE_ID',
                                avalue   => p_identity_salesforce_id);

    wf_engine.SetItemAttrNumber(itemtype => l_Item_Type,
                                itemkey  => l_Item_Key,
                                aname    => 'SALESGROUP_ID',
                                avalue   => p_salesgroup_id);

    wf_engine.StartProcess(itemtype  => l_Item_Type,
                           itemkey   => l_Item_Key );

    wf_engine.ItemStatus(itemtype => l_Item_Type,
                         itemkey  => l_Item_Key,
                         status   => l_status,
                         result   => l_result);

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_status:' || l_status);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_result:' || l_result);
    END IF;

    IF l_result <> FND_API.G_RET_STS_SUCCESS AND
       l_result <> '#NULL'
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
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

END Start_Partner_Matching;

PROCEDURE Partner_Matching(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2)
IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Partner_Matching';
    l_lead_id                NUMBER;
    l_identity_salesforce_id NUMBER;
    l_salesgroup_id          NUMBER;
    l_user_name              VARCHAR2(100);
    --l_indirect_channel_flag  VARCHAR2(1);
    --l_routing_status         VARCHAR2(30);
    l_selected_rule_id       NUMBER;
    l_lead_name              VARCHAR2(240);
    l_process_rule_name      VARCHAR2(100);
    l_matched_partner_count  NUMBER;
    l_failure_code           VARCHAR2(30);
    l_lead_workflow_rec      pv_assign_util_pvt.lead_workflow_rec_type;
    l_itemKey                VARCHAR2(8);
    l_Sales_Team_Rec         AS_ACCESS_PUB.Sales_Team_Rec_Type;
    l_access_profile_rec     AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    l_access_id              NUMBER;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_msg_data2              VARCHAR2(2000);
    l_open_opportunity_flag  BOOLEAN;
    l_routing_exist_flag     BOOLEAN;


    CURSOR C_Get_User_Name(c_resource_id NUMBER) IS
      SELECT user_name
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_resource_id;

    CURSOR c_get_lead_name(c_lead_id NUMBER) IS
      SELECT description
      FROM as_leads_all
      WHERE lead_id = c_lead_id;

    CURSOR c_get_lead_rule_name(c_lead_id NUMBER, c_process_rule_id NUMBER) IS
      SELECT opp.description, rule.process_rule_name
      FROM as_leads_all opp, pv_process_rules_vl rule
      WHERE opp.lead_id = c_lead_id
      AND rule.process_rule_id = c_process_rule_id;

    CURSOR c_get_lead_info(c_lead_id NUMBER) IS
      SELECT customer_id, address_id
      FROM as_leads_all
      WHERE lead_id = c_lead_id;

    CURSOR c_get_group_id (c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    CURSOR C_Get_Resource_Id(c_user_name VARCHAR2) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE user_name = c_user_name;

CURSOR get_person_id_csr(c_salesforce_id NUMBER) is
      SELECT employee_person_id
      FROM as_salesforce_v
      WHERE salesforce_id = c_salesforce_id;

BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Partner_Matching: Start');
    END IF;
    IF funcmode = 'RUN'
    THEN
   result := FND_API.G_RET_STS_SUCCESS;
        l_lead_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'LEAD_ID');

        l_identity_salesforce_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'IDENTITY_SALESFORCE_ID');

        l_salesgroup_id := wf_engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname => 'SALESGROUP_ID');


        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'lead_id?' || l_lead_id);
        END IF;

        -- ==========================================================================
   -- Pre-Routing Check
   --
        -- Make sure the opportunity is "open" and the routing is unassigned. That
        -- is, no routing has already been done for this opportunity.
        -- ==========================================================================
        l_open_opportunity_flag := TRUE;
        l_routing_exist_flag    := FALSE;

   FOR x IN (
           SELECT b.opp_open_status_flag, c.lead_id
           FROM   as_leads_all      a,
                  as_statuses_b     b,
                  pv_lead_workflows c
           WHERE  a.lead_id   = l_lead_id AND
                  a.status    = b.status_code AND
                  b.opp_flag  = 'Y' AND
                  a.lead_id   = c.lead_id (+)
          )
        LOOP
           -- -----------------------------------------------------------------------
           -- This is not an "open" opportunity. It cannot be routed.
           -- -----------------------------------------------------------------------
           IF (x.opp_open_status_flag <> 'Y') THEN
              l_open_opportunity_flag := FALSE;

         FOR x IN (SELECT description FROM as_leads_all WHERE lead_id = l_lead_id) LOOP
            fnd_message.SET_NAME('PV', 'PV_OPP_ROUTING_CLOSED_OPP');
                 fnd_message.SET_TOKEN('OPPORTUNITY_NAME', x.description);
                 fnd_message.SET_TOKEN('LEAD_ID' , l_lead_id);
                 fnd_msg_pub.ADD;
         END LOOP;
      END IF;

           -- -----------------------------------------------------------------------
           -- This opportunity has already been routed.
           -- -----------------------------------------------------------------------
           IF (x.lead_id IS NOT NULL) THEN
         FOR x IN (SELECT description FROM as_leads_all WHERE lead_id = l_lead_id) LOOP
            fnd_message.SET_NAME('PV', 'PV_OPP_ROUTING_ALREADY_EXISTS');
                 fnd_message.SET_TOKEN('OPPORTUNITY_NAME', x.description);
                 fnd_message.SET_TOKEN('LEAD_ID' , l_lead_id);
                 fnd_msg_pub.ADD;
         END LOOP;

         l_routing_exist_flag := TRUE;
           END IF;
        END LOOP;


        -- --------------------------------------------------------------------
   -- Routing/Partner Matching is only allowed if there are no previous
   -- routings. i.e. there should be no record exists in pv_lead_workflows
   -- for this opportunity (lead_id).
   -- In addition, the opportunity must be an "open" opportunity.
        -- --------------------------------------------------------------------
   IF (l_open_opportunity_flag AND (NOT l_routing_exist_flag)) THEN
            OPEN c_get_user_name(l_identity_salesforce_id);
            FETCH c_get_user_name INTO l_user_name;
            CLOSE c_get_user_name;

            pv_opp_match_pub.Clear_Rules_Cache;
            pv_opp_match_pub.opportunity_selection(
                P_Api_Version                => 1.0,
                P_Init_Msg_List              => FND_API.G_TRUE,
                P_Commit                     => FND_API.G_FALSE,
                p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
                p_entity_id                  => l_lead_id,
                p_entity                     => 'LEAD',
                p_user_name                  => l_user_name,
                p_resource_id                => l_identity_salesforce_id,
                x_selected_rule_id           => l_selected_rule_id,
                x_matched_partner_count      => l_matched_partner_count,
                x_failure_code               => l_failure_code,
                X_Return_Status              => l_return_status,
                X_Msg_Count                  => l_msg_count,
                X_Msg_Data                   => l_msg_data);

            -- Raise exception when returning from API
            -- Exception handling will get the last message and set
            -- it in workflow.
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                result := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'selected_rule_id=' || l_selected_rule_id);
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'matched_partner_count=' || l_matched_partner_count);
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'failure_code=' || l_failure_code);
            END IF;

            IF l_selected_rule_id IS NULL
            THEN
                OPEN c_get_lead_name(l_lead_id);
                FETCH c_get_lead_name INTO l_lead_name;
                CLOSE c_get_lead_name;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    FND_MESSAGE.Set_Name('PV', 'PV_OPP_NOT_MATCH_RULE');
                    FND_MESSAGE.Set_Token('LEAD_NAME', l_lead_name);
                    FND_MSG_PUB.Add;
                END IF;

                result := 'COMPLETE';
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF l_matched_partner_count = 0
            THEN
                OPEN c_get_lead_rule_name(l_lead_id, l_selected_rule_id);
                FETCH c_get_lead_rule_name INTO l_lead_name,
                                                l_process_rule_name;
                CLOSE c_get_lead_rule_name;

                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                    FND_MESSAGE.Set_Name('PV', 'PV_OPP_NOT_MATCH_PARTNER');
                    FND_MESSAGE.Set_Token('LEAD_NAME', l_lead_name);
                    FND_MESSAGE.Set_Token('RULE_NAME', l_process_rule_name);
                    FND_MSG_PUB.Add;
                END IF;

                result := 'COMPLETE';
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

    END IF; -- function mode check
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Partner_Matching: End');
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      l_msg_data := FND_MSG_PUB.Get(
          p_msg_index   =>  FND_MSG_PUB.Count_Msg,
          p_encoded     =>  FND_API.G_FALSE);

      IF l_failure_code IS NOT NULL
      THEN
          ROLLBACK;
      END IF;

      l_Sales_Team_Rec.salesforce_id :=
          FND_PROFILE.Value('PV_BATCH_ASSIGN_USER_NAME');

      l_lead_workflow_rec.failure_code    := l_failure_code;
      l_lead_workflow_rec.failure_message := l_msg_data;

      -- Create a row in PV Lead Workflow table.
      l_lead_workflow_rec.last_updated_by := fnd_global.user_id;
      l_lead_workflow_rec.created_by := fnd_global.user_id;
      l_lead_workflow_rec.lead_id := l_lead_id;
      l_lead_workflow_rec.entity := 'OPPORTUNITY';
      l_lead_workflow_rec.wf_item_type :=
          pv_workflow_pub.g_wf_itemtype_pvasgnmt;
      l_lead_workflow_rec.wf_status := pv_assignment_pub.g_wf_status_closed;
      l_lead_workflow_rec.bypass_cm_ok_flag := NULL;
      l_lead_workflow_rec.latest_routing_flag := 'Y';
      -- l_lead_workflow_rec.routing_status := pv_assignment_pub.g_r_status_failed_auto;
      l_lead_workflow_rec.routing_status := 'FAILED_AUTO_ASSIGN';

      pv_assign_util_pvt.Create_lead_workflow_row
          (p_api_version_number  => 1.0
          ,p_init_msg_list       => FND_API.G_FALSE
          ,p_commit              => FND_API.G_FALSE
          ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
          ,p_workflow_rec        => l_lead_workflow_rec
          ,x_ItemKey             => l_itemKey
          ,x_return_status       => l_return_status
          ,x_msg_count           => l_msg_count
          ,x_msg_data            => l_msg_data);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_msg_data := FND_MSG_PUB.Get(
              p_msg_index   =>  FND_MSG_PUB.Count_Msg,
              p_encoded     =>  FND_API.G_FALSE);
          result := FND_API.G_RET_STS_ERROR;
          wf_core.token('STACK',l_msg_data);
          wf_core.raise('WFNTF_ERROR_STACK');
          wf_core.context(G_PKG_NAME, l_api_name, l_msg_data);
          RAISE;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'lwf rt status = ' || l_Return_Status);
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'itemKey = ' || l_itemKey);
      END IF;
      OPEN c_get_lead_info(l_lead_id);
      FETCH c_get_lead_info INTO l_Sales_Team_Rec.customer_id,
            l_Sales_Team_Rec.address_id;
      CLOSE c_get_lead_info;

      -- Create a sales team member for the opportunity
      l_Sales_Team_Rec.last_updated_by       := FND_GLOBAL.USER_ID;
      l_Sales_Team_Rec.last_update_date      := SYSDATE;
      l_Sales_Team_Rec.creation_date         := SYSDATE;
      l_Sales_Team_Rec.created_by            := FND_GLOBAL.USER_ID;
      l_Sales_Team_Rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;


      -- ----------------------------------------------------------------------
      -- Run Create_Salesteam only when an assignment manager is found in the
      -- profile PV_BATCH_ASSIGN_USER_NAME ().
      -- ----------------------------------------------------------------------
      IF (l_Sales_Team_Rec.salesforce_id IS NOT NULL) THEN
         --l_Sales_Team_Rec.partner_cont_party_id := p_partner_cont_party_id;
         l_Sales_Team_Rec.lead_id               := l_lead_id;
         l_Sales_Team_Rec.team_leader_flag      := 'Y';
         l_Sales_Team_Rec.reassign_flag         := 'N';
         l_Sales_Team_Rec.freeze_flag           :=  'Y';
             -- obsoleting AS_DEFAULT_FREEZE_FLAG in R12
	     --nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');

         OPEN c_get_group_id(l_Sales_Team_Rec.salesforce_id);
         FETCH c_get_group_id INTO l_sales_team_rec.sales_group_id;
         CLOSE c_get_group_id;

         IF l_sales_team_rec.sales_group_id = FND_API.G_MISS_NUM
         THEN
             l_sales_team_rec.sales_group_id := NULL;
         END IF;

         l_sales_team_rec.salesforce_role_code  := null;
	    -- obsoleting 	AS_DEF_OPP_ST_ROLE in R12
             --FND_PROFILE.Value('AS_DEF_OPP_ST_ROLE');

         OPEN get_person_id_csr(l_Sales_Team_Rec.salesforce_id);
         FETCH get_person_id_csr into l_Sales_Team_Rec.person_id;

         IF (get_person_id_csr%NOTFOUND)
         THEN
             l_Sales_Team_Rec.person_id := NULL;
         END IF;
         CLOSE get_person_id_csr;

         l_Sales_Team_Rec.created_by_TAP_flag := 'N';
         l_sales_team_rec.owner_flag := 'N';

         IF (AS_DEBUG_LOW_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'sf_id=' || l_Sales_Team_Rec.salesforce_id);
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'sg_id=' || l_Sales_Team_Rec.sales_group_id);
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'Calling Create_SalesTeam');
         END IF;
         AS_ACCESS_PUB.Create_SalesTeam (
            p_api_version_number         => 2.0
           ,p_init_msg_list              => FND_API.G_FALSE
           ,p_commit                     => FND_API.G_FALSE
           ,p_validation_level           => FND_API.G_VALID_LEVEL_NONE
           ,p_access_profile_rec         => l_access_profile_rec
           ,p_check_access_flag          => 'N' -- P_Check_Access_flag
           ,p_admin_flag                 => 'N'
           ,p_admin_group_id             => NULL
           ,p_identity_salesforce_id     => l_identity_salesforce_id
           ,p_sales_team_rec             => l_Sales_Team_Rec
           ,X_Return_Status              => l_Return_Status
           ,X_Msg_Count                  => l_Msg_Count
           ,X_Msg_Data                   => l_Msg_Data2
           ,x_access_id                  => l_Access_Id
         );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             l_msg_data := FND_MSG_PUB.Get(
                 p_msg_index   =>  FND_MSG_PUB.Count_Msg,
                 p_encoded     =>  FND_API.G_FALSE);
             result := FND_API.G_RET_STS_ERROR;
             wf_core.token('STACK',l_msg_data);

             -- this is what makes the workflow result turn RED!
             wf_core.raise('WFNTF_ERROR_STACK');
             wf_core.context(G_PKG_NAME, l_api_name, l_msg_data);
             RAISE;
         END IF;

         IF (AS_DEBUG_LOW_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'acc rt status = ' || l_Return_Status);
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'Create_SalesTeam:l_access_id = ' || l_access_id);
         END IF;
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      l_msg_data := FND_MSG_PUB.Get(
          p_msg_index   =>  FND_MSG_PUB.Count_Msg,
          p_encoded     =>  FND_API.G_FALSE);
      wf_core.token('STACK',l_msg_data);
      wf_core.raise('WFNTF_ERROR_STACK');

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.token('STACK', SQLERRM);
      wf_core.raise('WFNTF_ERROR_STACK');
      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

END Partner_Matching;


PROCEDURE Start_Campaign_Assignment(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2,
    P_Commit                  IN  VARCHAR2,
    P_Validation_Level        IN  NUMBER,
    P_Identity_Salesforce_Id  IN  NUMBER,
    P_Lead_id                 IN  NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Start_Campaign_Assignment';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_item_type        VARCHAR2(8) := 'PVXSLENW';
    l_item_key         VARCHAR2(30);
    l_flag             VARCHAR2(30);
    l_status           VARCHAR2(80);
    l_result           VARCHAR2(10);
    l_workflow_process VARCHAR2(30) := 'PV_CAMPAIGN_ROUTING';

    CURSOR lc_check ( pc_lead_id NUMBER)
    IS
    SELECT 'X' flag
      FROM   pv_lead_workflows
     WHERE   lead_id = pc_lead_id
       AND    latest_routing_flag = 'Y'
       AND    routing_status IN ('ACTIVE','MATCHED','OFFERED');

BEGIN
      SAVEPOINT Start_Campaign_Assignment;

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

    -- Start Process :
    --  If workflowprocess is passed, it will be run.
    --  If workflowprocess is NOT passed, the selector FUNCTION
    --  defined in the item type will determine which process to run.

       OPEN lc_check (p_lead_id);
       FETCH lc_check INTO l_flag;
       CLOSE lc_check;

      IF l_flag IS NULL THEN
           SELECT TO_CHAR(PV_LEAD_WORKFLOWS_S.nextval) INTO l_item_key FROM dual;

            wf_engine.CreateProcess( ItemType => l_Item_Type,
                                     ItemKey  => l_Item_Key,
                                     process  => l_Workflow_process);

           -- Initialize workflow item attributes
           --
            wf_engine.SetItemAttrNumber(itemtype => l_Item_Type,
                                        itemkey  => l_Item_Key,
                                        aname    => 'LEAD_ID',
                                        avalue   => p_lead_id);

            wf_engine.SetItemAttrNumber(itemtype => l_Item_Type,
                                        itemkey  => l_Item_Key,
                                        aname    => 'IDENTITY_SALESFORCE_ID',
                                        avalue   => p_identity_salesforce_id);

            wf_engine.StartProcess(itemtype  => l_Item_Type,
                                   itemkey   => l_Item_Key );

            wf_engine.ItemStatus(itemtype => l_Item_Type,
                                 itemkey  => l_Item_Key,
                                 status   => l_status,
                                 result   => l_result);
     END IF;
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_status:' || l_status);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'l_result:' || l_result);
    END IF;

    IF l_result <> FND_API.G_RET_STS_SUCCESS AND l_result <> '#NULL'
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

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

END Start_Campaign_Assignment;


PROCEDURE Campaign_Routing(
    itemtype         IN  VARCHAR2,
    itemkey          IN  VARCHAR2,
    actid            IN  NUMBER,
    funcmode         IN  VARCHAR2,
    result           OUT NOCOPY VARCHAR2)
IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Campaign_Routing';
    l_lead_id                NUMBER;
    l_identity_salesforce_id NUMBER;
    l_salesgroup_id          NUMBER;
    l_user_name              VARCHAR2(100);
    l_failure_code           VARCHAR2(30);
    l_itemkey           VARCHAR2(30);
    l_lead_workflow_rec      pv_assign_util_pvt.lead_workflow_rec_type;
    l_sales_team_rec        as_access_pub.sales_team_rec_type;
    l_access_profile_rec     AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
    l_access_id              NUMBER;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_msg_data2              VARCHAR2(2000);
    l_open_opportunity_flag  BOOLEAN;
    l_routing_exist_flag     BOOLEAN;

    CURSOR C_Get_User_Name(c_resource_id NUMBER) IS
      SELECT user_name
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_resource_id;

    CURSOR c_get_group_id (c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

CURSOR get_person_id_csr(c_salesforce_id NUMBER) is
      SELECT employee_person_id
      FROM as_salesforce_v
      WHERE salesforce_id = c_salesforce_id;

cursor lc_partners (pc_source_promotion_id number) is
   SELECT distinct acp.partner_id, rownum
   FROM   ams_source_codes ac, ams_act_partners acp, pv_partner_profiles pp
   WHERE  ac.source_code_id = pc_source_promotion_id
   AND    ac.arc_source_code_for in ('CAMP', 'CSCH')  AND ac.source_code_for_id = acp.act_partner_used_by_id
   AND    acp.arc_act_partner_used_by = ac.arc_source_code_for AND acp.partner_id = pp.partner_id;

cursor lc_get_lead_detail (pc_lead_id number) is
   select customer_id, address_id, source_promotion_id from as_leads_all where lead_id = pc_lead_id;

   l_partner_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_partner_rank_tbl    JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_partner_source_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

   l_partner_id_tmp        NUMBER;
   l_partner_rank_tmp      NUMBER;
   l_partner_source_tmp    VARCHAR2(10);
   l_countRow              NUMBER := 1;
   l_source_promotion_id   NUMBER;
   l_bypass_cm_ok_flag     VARCHAr2(1);
   l_assignment_type       VARCHAR2(30);
   l_address_id            NUMBER;
   l_customer_id           NUMBER;
   l_partner_resource_id   NUMBER;

BEGIN
   IF funcmode = 'RUN' THEN

      IF (AS_DEBUG_LOW_ON) THEN
			AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Campaign_Routing: Start');
      END IF;

      result := FND_API.G_RET_STS_SUCCESS;
      l_lead_id := wf_engine.GetItemAttrNumber(
                     itemtype => itemtype,
                     itemkey => itemkey,
                     aname => 'LEAD_ID');

      l_identity_salesforce_id := wf_engine.GetItemAttrNumber(
                     itemtype => itemtype,
                     itemkey => itemkey,
                     aname => 'IDENTITY_SALESFORCE_ID');

      -- ==========================================================================
      -- Pre-Routing Check
      --
      -- Make sure the opportunity is "open" and the routing is unassigned. That
      -- is, no routing has already been done for this opportunity.
      -- ==========================================================================
      l_open_opportunity_flag := TRUE;
      l_routing_exist_flag    := FALSE;

      FOR x IN (
           SELECT b.opp_open_status_flag, c.lead_id , c.routing_status
           FROM   as_leads_all      a,
                  as_statuses_b     b,
                  pv_lead_workflows c
           WHERE  a.lead_id = l_lead_id AND a.status = b.status_code AND
                  b.opp_flag = 'Y' AND a.lead_id   = c.lead_id (+) and c.latest_routing_flag (+) = 'Y')
      LOOP
         -- -----------------------------------------------------------------------
         -- This is not an "open" opportunity. It cannot be routed.
         -- -----------------------------------------------------------------------
         IF (x.opp_open_status_flag <> 'Y') THEN
            l_open_opportunity_flag := FALSE;

            FOR x IN (SELECT description FROM as_leads_all WHERE lead_id = l_lead_id) LOOP
               fnd_message.SET_NAME('PV', 'PV_OPP_ROUTING_CLOSED_OPP');
               fnd_message.SET_TOKEN('OPPORTUNITY_NAME', x.description);
               fnd_message.SET_TOKEN('LEAD_ID' , l_lead_id);
               fnd_msg_pub.ADD;
            END LOOP;
         END IF;

         -- -----------------------------------------------------------------------
         -- This opportunity has already been routed.
         -- -----------------------------------------------------------------------
         IF (x.lead_id IS NOT NULL AND x.routing_status IN ('ACTIVE','MATCHED','OFFERED')) THEN
            FOR x IN (SELECT description FROM as_leads_all WHERE lead_id = l_lead_id) LOOP
               fnd_message.SET_NAME('PV', 'PV_OPP_ROUTING_ALREADY_EXISTS');
               fnd_message.SET_TOKEN('OPPORTUNITY_NAME', x.description);
               fnd_message.SET_TOKEN('LEAD_ID' , l_lead_id);
               fnd_msg_pub.ADD;
            END LOOP;

            l_routing_exist_flag := TRUE;
         END IF;
      END LOOP;

      -- --------------------------------------------------------------------
      -- Routing/Partner Matching is only allowed if there are no previous
      -- routings. i.e. there should be no record exists in pv_lead_workflows
      -- for this opportunity (lead_id).
      -- In addition, the opportunity must be an "open" opportunity.
      -- --------------------------------------------------------------------
      IF (l_open_opportunity_flag AND (NOT l_routing_exist_flag)) THEN

			IF (AS_DEBUG_LOW_ON) THEN
				AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				'This is an open oppty and is not being routed');
			END IF;

         OPEN c_get_user_name(l_identity_salesforce_id);
         FETCH c_get_user_name INTO l_user_name;
         CLOSE c_get_user_name;

         open lc_get_lead_detail (pc_lead_id => l_lead_id);
         fetch lc_get_lead_detail into l_customer_id, l_address_id, l_source_promotion_id;
         close lc_get_lead_detail;

         if l_source_promotion_id is not null then

            OPEN lc_partners(pc_source_promotion_id => l_source_promotion_id);
            LOOP
               FETCH   lc_partners INTO l_partner_id_tmp, l_partner_rank_tmp;
               EXIT WHEN lc_partners%NOTFOUND;

               l_partner_id_tbl.extend;
               l_partner_id_tbl(l_countRow) := l_partner_id_tmp;

               l_partner_rank_tbl.extend;
               l_partner_rank_tbl(l_countRow) := l_partner_rank_tmp;

               l_partner_source_tbl.extend;
               l_partner_source_tbl(l_countRow) := 'CAMPAIGN';

               l_countRow := l_countRow + 1;
            END LOOP;
            close lc_partners;

         end if;

         IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Number of partners attach to campaign: ' || l_partner_id_tbl.count);
         end if;

         if l_partner_id_tbl.count = 0 then
            return;
         end if;

         IF l_partner_id_tbl.count = 1 THEN
            l_assignment_type := 'SINGLE';
         ELSE
            l_assignment_type := FND_PROFILE.value('PV_DEFAULT_ASSIGNMENT_TYPE');
         END IF;

         l_bypass_cm_ok_flag := nvl(FND_PROFILE.value('PV_CM_APPROVAL_FOR_CAMPAIGN'),'N');

         IF (FND_PROFILE.value('PV_AUTO_ROUTE_FOR_CAMPAIGN') = 'Y') THEN

            IF (AS_DEBUG_LOW_ON) THEN
               AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
               'Before calling Create Assignment' || l_lead_id || 'user name ' ||
                l_user_name || 'assn type ' || l_assignment_type );
            END IF;

            PV_ASSIGNMENT_PUB.CreateAssignment
            (p_api_version_number  => 1.0
            ,p_init_msg_list       => FND_API.G_FALSE
            ,p_commit              => FND_API.G_FALSE
            ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
            ,p_entity              => 'OPPORTUNITY'
            ,p_lead_id             => l_lead_id
            ,p_creating_username   => l_user_name
            ,p_assignment_type     => l_assignment_type
            ,p_bypass_cm_ok_flag   => l_bypass_cm_ok_flag
            ,p_partner_id_tbl      => l_partner_id_tbl
            ,p_rank_tbl            => l_partner_rank_tbl
            ,p_partner_source_tbl  => l_partner_source_tbl
            ,p_process_rule_id     => NULL
            ,x_return_status       => l_return_status
            ,x_msg_count           => l_msg_count
            ,x_msg_data            => l_msg_data);

            IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               l_failure_code := 'ROUTING_FAILED';
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         ELSE

				IF (AS_DEBUG_LOW_ON) THEN
					AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
					'Adding partners to external salesteam');
				END IF;

            FOR i in 1 .. l_partner_id_tbl.count LOOP

               SELECT  resource_id INTO l_partner_resource_id
               FROM    jtf_rs_resource_extns
               WHERE   sysdate between start_date_active and nvl(end_date_active,sysdate)
               and source_id = l_partner_id_tbl(i) and category='PARTNER' and rownum = 1;

               l_sales_team_rec.lead_id := l_lead_id;
               l_sales_team_rec.customer_id := l_customer_id;
               l_sales_team_rec.freeze_flag := 'Y';
               l_sales_team_rec.partner_customer_id := l_partner_id_tbl(i);
               l_sales_team_rec.salesforce_id := l_partner_resource_id;
               l_sales_team_rec.address_id := l_address_id;

               l_access_profile_rec := null;

               as_access_pub.Create_SalesTeam
               (p_api_version_number  =>  2 -- API Version has been changed
               ,p_init_msg_list       =>  FND_API.G_FALSE
               ,p_commit              =>  FND_API.G_FALSE
               ,p_validation_level    =>  FND_API.G_VALID_LEVEL_NONE
               ,p_access_profile_rec  =>  l_access_profile_rec
               ,p_check_access_flag   =>  'N'
               ,p_admin_flag          =>  'N'
               ,p_admin_group_id      =>  null
               ,p_identity_salesforce_id => l_identity_salesforce_id
               ,p_sales_team_rec      =>  l_sales_team_rec
               ,x_return_status       =>  l_return_status
               ,x_msg_count           =>  l_msg_count
               ,x_msg_data            =>  l_msg_data
               ,x_access_id           =>  l_access_id);

               IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                  l_failure_code := 'OTHER';
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            END LOOP;

         END IF;
      END IF;
      result := 'COMPLETE';
    END IF; -- function mode check

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      l_msg_data := FND_MSG_PUB.Get(
          p_msg_index   =>  FND_MSG_PUB.Count_Msg,
          p_encoded     =>  FND_API.G_FALSE);

      ROLLBACK;

      IF (FND_PROFILE.value('PV_AUTO_ROUTE_FOR_CAMPAIGN') = 'Y') THEN
			l_Sales_Team_Rec.salesforce_id := FND_PROFILE.Value('PV_BATCH_ASSIGN_USER_NAME');

			l_lead_workflow_rec.failure_code    := l_failure_code;
			l_lead_workflow_rec.failure_message := l_msg_data;

			-- Create a row in PV Lead Workflow table.
			l_lead_workflow_rec.last_updated_by := fnd_global.user_id;
			l_lead_workflow_rec.created_by := fnd_global.user_id;
			l_lead_workflow_rec.lead_id := l_lead_id;
			l_lead_workflow_rec.entity := 'OPPORTUNITY';
			l_lead_workflow_rec.wf_item_type := pv_workflow_pub.g_wf_itemtype_pvasgnmt;
			l_lead_workflow_rec.wf_status := pv_assignment_pub.g_wf_status_closed;
			l_lead_workflow_rec.bypass_cm_ok_flag := NULL;
			l_lead_workflow_rec.latest_routing_flag := 'Y';
			l_lead_workflow_rec.routing_status := 'FAILED_AUTO_ASSIGN';

			pv_assign_util_pvt.Create_lead_workflow_row
				 (p_api_version_number  => 1.0
				 ,p_init_msg_list       => FND_API.G_FALSE
				 ,p_commit              => FND_API.G_FALSE
				 ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
				 ,p_workflow_rec        => l_lead_workflow_rec
				 ,x_ItemKey             => l_itemKey
				 ,x_return_status       => l_return_status
				 ,x_msg_count           => l_msg_count
				 ,x_msg_data            => l_msg_data);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				 l_msg_data := FND_MSG_PUB.Get(
					  p_msg_index   =>  FND_MSG_PUB.Count_Msg,
					  p_encoded     =>  FND_API.G_FALSE);
				 result := FND_API.G_RET_STS_ERROR;
				 wf_core.token('STACK',l_msg_data);
				 wf_core.raise('WFNTF_ERROR_STACK');
				 wf_core.context(G_PKG_NAME, l_api_name, l_msg_data);
				 RAISE;
			END IF;

			IF (AS_DEBUG_LOW_ON) THEN
				AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'lwf rt status = ' || l_Return_Status);
				AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'itemKey = ' || l_itemKey);
			END IF;

			-- Create a sales team member for the opportunity
			l_Sales_Team_Rec.customer_id           := l_customer_id;
			l_Sales_Team_Rec.address_id            := l_address_id;
			l_Sales_Team_Rec.last_updated_by       := FND_GLOBAL.USER_ID;
			l_Sales_Team_Rec.last_update_date      := SYSDATE;
			l_Sales_Team_Rec.creation_date         := SYSDATE;
			l_Sales_Team_Rec.created_by            := FND_GLOBAL.USER_ID;
			l_Sales_Team_Rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;

			-- ----------------------------------------------------------------------
			-- Run Create_Salesteam only when an assignment manager is found in the
			-- profile PV_BATCH_ASSIGN_USER_NAME ().
			-- ----------------------------------------------------------------------
			IF (l_Sales_Team_Rec.salesforce_id IS NOT NULL) THEN
				l_Sales_Team_Rec.lead_id               := l_lead_id;
				l_Sales_Team_Rec.team_leader_flag      := 'Y';
				l_Sales_Team_Rec.reassign_flag         := 'N';
				l_Sales_Team_Rec.freeze_flag           := 'Y';

				OPEN c_get_group_id(l_Sales_Team_Rec.salesforce_id);
				FETCH c_get_group_id INTO l_sales_team_rec.sales_group_id;
				CLOSE c_get_group_id;

				IF l_sales_team_rec.sales_group_id = FND_API.G_MISS_NUM
				THEN
					 l_sales_team_rec.sales_group_id := NULL;
				END IF;

				OPEN get_person_id_csr(l_Sales_Team_Rec.salesforce_id);
				FETCH get_person_id_csr into l_Sales_Team_Rec.person_id;

				IF (get_person_id_csr%NOTFOUND) THEN
					 l_Sales_Team_Rec.person_id := NULL;
				END IF;
				CLOSE get_person_id_csr;

				l_Sales_Team_Rec.created_by_TAP_flag := 'N';
				l_sales_team_rec.owner_flag := 'N';

				IF (AS_DEBUG_LOW_ON) THEN
					 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						  'sf_id=' || l_Sales_Team_Rec.salesforce_id);
					 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						  'sg_id=' || l_Sales_Team_Rec.sales_group_id);
					 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						  'Calling Create_SalesTeam');
				END IF;
				AS_ACCESS_PUB.Create_SalesTeam (
					p_api_version_number         => 2.0
				  ,p_init_msg_list              => FND_API.G_FALSE
				  ,p_commit                     => FND_API.G_FALSE
				  ,p_validation_level           => FND_API.G_VALID_LEVEL_NONE
				  ,p_access_profile_rec         => l_access_profile_rec
				  ,p_check_access_flag          => 'N' -- P_Check_Access_flag
				  ,p_admin_flag                 => 'N'
				  ,p_admin_group_id             => NULL
				  ,p_identity_salesforce_id     => l_identity_salesforce_id
				  ,p_sales_team_rec             => l_Sales_Team_Rec
				  ,X_Return_Status              => l_Return_Status
				  ,X_Msg_Count                  => l_Msg_Count
				  ,X_Msg_Data                   => l_Msg_Data2
				  ,x_access_id                  => l_Access_Id
				);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					 l_msg_data := FND_MSG_PUB.Get(
						  p_msg_index   =>  FND_MSG_PUB.Count_Msg,
						  p_encoded     =>  FND_API.G_FALSE);
					 result := FND_API.G_RET_STS_ERROR;
					 wf_core.token('STACK',l_msg_data);

					 -- this is what makes the workflow result turn RED!
					 wf_core.raise('WFNTF_ERROR_STACK');
					 wf_core.context(G_PKG_NAME, l_api_name, l_msg_data);
					 RAISE;
				END IF;

				IF (AS_DEBUG_LOW_ON) THEN
					AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
						  'acc rt status = ' || l_Return_Status);
					AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'Create_SalesTeam:l_access_id = ' || l_access_id);
				END IF;
			END IF;
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      l_msg_data := FND_MSG_PUB.Get(
          p_msg_index   =>  FND_MSG_PUB.Count_Msg,
          p_encoded     =>  FND_API.G_FALSE);
      wf_core.token('STACK',l_msg_data);
      wf_core.raise('WFNTF_ERROR_STACK');

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

   WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.token('STACK', SQLERRM);
      wf_core.raise('WFNTF_ERROR_STACK');
      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

END Campaign_Routing;

END PV_BG_PARTNER_MATCHING_PUB;

/
