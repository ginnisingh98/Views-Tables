--------------------------------------------------------
--  DDL for Package Body AS_OPP_COPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_COPY_PVT" as
/* $Header: asxvlcpb.pls 120.7.12010000.1 2008/07/29 03:11:39 appldev ship $ */
-- Start of Comments
-- Package name     : AS_OPP_COPY_PVT
-- Purpose          :
-- History          :
--    09-OCT-00     XDING   Created
--
-- NOTE             :
-- End of Comments
--

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_COPY_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvlcpb.pls';

PROCEDURE Copy_Opportunity
(   p_api_version_number            IN    NUMBER,
    p_init_msg_list                 IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                        IN    VARCHAR2      := FND_API.G_FALSE,
    p_validation_level              IN    NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                       IN    NUMBER,
    p_description                   IN    VARCHAR2,
    p_copy_salesteam            IN    VARCHAR2  :=FND_API.G_FALSE,
    p_copy_opp_lines            IN    VARCHAR2  :=FND_API.G_FALSE,
    p_copy_lead_contacts            IN    VARCHAR2  :=FND_API.G_FALSE,
    p_copy_lead_competitors         IN    VARCHAR2  :=FND_API.G_FALSE,
    p_copy_sales_credits        IN    VARCHAR2  :=FND_API.G_FALSE,
    p_copy_methodology              IN    VARCHAR2      :=FND_API.G_FALSE,
    p_new_customer_id           IN    NUMBER,
    p_new_address_id            IN    NUMBER,
    p_check_access_flag             IN    VARCHAR2,
    p_admin_flag                IN    VARCHAR2,
    p_admin_group_id                IN    NUMBER,
    p_identity_salesforce_id        IN    NUMBER,
    p_salesgroup_id         IN    NUMBER        := NULL,
    p_partner_cont_party_id     IN    NUMBER,
    p_profile_tbl               IN    AS_UTILITY_PUB.Profile_Tbl_Type
                      :=AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    x_return_status                 OUT NOCOPY   VARCHAR2,
    x_msg_count                     OUT NOCOPY   NUMBER,
    x_msg_data                      OUT NOCOPY   VARCHAR2,
    x_lead_id                       OUT NOCOPY   NUMBER
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Copy_Opportunity';
l_api_version_number    CONSTANT NUMBER   := 2.0;

l_header_rec        AS_OPPORTUNITY_PUB.Header_Rec_Type;
l_line_tbl      AS_OPPORTUNITY_PUB.Line_Tbl_Type;
l_Sales_Team_Rec        AS_ACCESS_PUB.Sales_Team_Rec_Type;

l_index         NUMBER;
l_lead_number       NUMBER;
l_rowid         ROWID;
l_access_id     NUMBER;
l_lead_line_id          NUMBER;
l_sales_credit_id   NUMBER;
l_lead_contact_id   NUMBER;
l_lead_competitor_id    NUMBER;
l_close_competitor_id   NUMBER;
l_lead_competitor_prod_id   NUMBER;
l_lead_decision_factor_id   NUMBER;

l_new_sales_methodology_id  NUMBER;
l_view_access_flag      VARCHAR2(1);
l_identity_sales_member_rec     AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_access_profile_rec            AS_ACCESS_PUB.Access_Profile_Rec_Type;
l_customer_id           NUMBER;
l_new_status            VARCHAR2(30);
l_default_status        VARCHAR2(30)    := fnd_profile.value('AS_OPP_STATUS');
l_new_total_amount      NUMBER;
l_TOT_REVENUE_OPP_FORECAST_AMT     NUMBER := NULL; -- Added for ASNB

l_sales_credit_tbl       AS_OPPORTUNITY_PUB.Sales_Credit_Tbl_type;
l_sales_credit_rec       AS_OPPORTUNITY_PUB.Sales_Credit_Rec_type;
x_sales_credit_out_tbl       AS_OPPORTUNITY_PUB.Sales_Credit_Out_Tbl_Type;
l_forecast_credit_type_id    NUMBER := FND_PROFILE.Value('AS_FORECAST_CREDIT_TYPE_ID');
l_val                    NUMBER;
l_date                   DATE;
l_copy_opp_lines         VARCHAR2(1) := p_copy_opp_lines;
l_cre_st_for_sc_flag     VARCHAR2(1) := 'N';
l_insert                 BOOLEAN;

CURSOR c_customer(c_lead_id NUMBER) IS
    SELECT customer_id
    FROM AS_LEADS_ALL
    WHERE lead_id = c_lead_id;

CURSOR c_header(c_lead_id NUMBER) IS
    SELECT *
    FROM AS_LEADS_ALL
    WHERE lead_id = c_lead_id;

-- If create sales team for sales credit flag is set to 'N', return
-- all records from AS_ACCESSES_ALL for that lead_id but if the flag
-- is set to 'Y', return the records from AS_ACCESSES_ALL that also
-- exist in AS_SALES_CREDITS
-- Note that the result set is ordered by owner_flag because according
-- to the logic, the owner should be updated before any other sales
-- team member is inserted as otherwise, the insert might fail if the
-- record being inserted has same unique keys as the owner created by
-- the header
CURSOR c_salesteam(c_lead_id NUMBER, c_cre_st_for_sc_flag VARCHAR2) IS
    SELECT *
    FROM AS_ACCESSES_ALL A
    WHERE lead_id = c_lead_id
    AND salesforce_id in             -- This condition was added for bug 5361442
    (SELECT s.salesforce_id
     FROM as_accesses_all s,
       jtf_rs_resource_extns j
     WHERE s.salesforce_id = j.resource_id
     AND (j.end_date_active IS NULL
          OR j.end_date_active > sysdate))
    AND (c_cre_st_for_sc_flag = 'N' OR EXISTS
      (SELECT 1
       FROM AS_SALES_CREDITS C
       WHERE C.lead_id = A.lead_id
       AND C.salesforce_id = A.salesforce_id
       AND C.salesgroup_id = A.sales_group_id))
    ORDER BY nvl(owner_flag, 'N') desc;

CURSOR c_owner_in_salesTeam(c_lead_id NUMBER,c_salesforce_id NUMBER,c_sales_group_id NUMBER) IS
        SELECT access_id,last_update_date
    FROM AS_ACCESSES_ALL
    WHERE lead_id = c_lead_id
    AND salesforce_id = c_salesforce_id
    AND nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99)
    AND nvl(owner_flag,'N')='Y';

-- Added for ASNB
CURSOR c_log_user_in_salesTeam(c_lead_id NUMBER,c_salesforce_id NUMBER,c_sales_group_id NUMBER) IS
        SELECT access_id,last_update_date
    FROM AS_ACCESSES_ALL
    WHERE lead_id = c_lead_id
    AND salesforce_id = c_salesforce_id
    AND nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99);

CURSOR c_lines(c_lead_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_LINES_ALL
    WHERE lead_id = c_lead_id;

CURSOR c_contacts(c_lead_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_CONTACTS
    WHERE lead_id = c_lead_id;

CURSOR c_competitors(c_lead_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_COMPETITORS
    WHERE lead_id = c_lead_id;

CURSOR c_sales_credits(c_lead_id NUMBER, c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_SALES_CREDITS
    WHERE lead_id = c_lead_id
    AND  lead_line_id = c_lead_line_id;

CURSOR c_competitor_products (c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_COMP_PRODUCTS
    WHERE lead_line_id = c_lead_line_id;

CURSOR c_decision_factors(c_lead_line_id NUMBER) IS
    SELECT *
    FROM AS_LEAD_DECISION_FACTORS
    WHERE lead_line_id = c_lead_line_id;

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.lcppv.Copy_Opportunity';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_OPPORTUNITY_PVT;

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
    IF (p_validation_level = fnd_api.g_valid_level_full)  THEN --fix for bug#3756261
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
        END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
        -- Call Get_Access_Profiles to get access_profile_rec
        AS_OPPORTUNITY_PUB.Get_Access_Profiles(
            p_profile_tbl         => p_profile_tbl,
            x_access_profile_rec  => l_access_profile_rec);

    OPEN c_customer(p_lead_id);
    FETCH c_customer into l_customer_id;
    CLOSE c_customer;

        AS_ACCESS_PUB.has_viewCustomerAccess
         (   p_api_version_number   => 2.0
        ,p_init_msg_list        => p_init_msg_list
        ,p_validation_level     => p_validation_level
        ,p_access_profile_rec   => l_access_profile_rec
        ,p_admin_flag           => p_admin_flag
        ,p_admin_group_id   => p_admin_group_id
        ,p_person_id        => l_identity_sales_member_rec.employee_person_id
        ,p_customer_id      => nvl(p_new_customer_id, l_customer_id)
        ,p_check_access_flag    => p_check_access_flag
        ,p_identity_salesforce_id => p_identity_salesforce_id
        ,p_partner_cont_party_id  => p_partner_cont_party_id
        ,x_return_status    => x_return_status
        ,x_msg_count        => x_msg_count
        ,x_msg_data     => x_msg_data
        ,x_view_access_flag => l_view_access_flag );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'has_viewCustomerAccess fail');
        END IF;

            END IF;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (l_view_access_flag <> 'Y') THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.Set_Name('AS', 'API_NO_VIEW_PRIVILEGE');
            FND_MESSAGE.Set_Token('INFO', 'CUSTOMER_ID,OPPORTUNITY_ID,SALESFORCE_ID', FALSE);
            FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
      END IF;

      --
      -- Copy the opportunity header
      --

      IF p_lead_id is null or p_lead_id = fnd_api.g_miss_num
      THEN
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Private API: p_lead_id is null');
          END IF;

          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FOR hdr IN c_header(p_lead_id) LOOP

      /* IF hdr.PRM_ASSIGNMENT_TYPE is NULL OR hdr.PRM_ASSIGNMENT_TYPE = 'UNASSIGNED' THEN
          l_new_status := hdr.STATUS;
      ELSE
          l_new_status := l_default_status;
      END IF; */ -- Fix for bug#3763097

      l_new_status := hdr.STATUS;   -- Fix for bug#3763097

      -- Bug 3426788
      -- If sales credits are to be copied, purchase lines should also be copied
      IF p_copy_sales_credits = 'Y' THEN
         l_copy_opp_lines := 'Y';
      END IF;

      IF p_copy_methodology = 'Y' THEN
        l_new_sales_methodology_id := hdr.SALES_METHODOLOGY_ID;
      ELSE
        l_new_sales_methodology_id := NULL;
      END IF;

      IF l_copy_opp_lines = 'Y' THEN
        l_new_total_amount := hdr.TOTAL_AMOUNT;
        l_TOT_REVENUE_OPP_FORECAST_AMT := hdr.TOTAL_REVENUE_OPP_FORECAST_AMT; -- Added for ASNB
      END IF;

          l_header_rec.ORIGINAL_LEAD_ID  := hdr.LEAD_ID;
          l_header_rec.STATUS_CODE  := l_new_status;        --bug1580008
          l_header_rec.CUSTOMER_ID  := nvl(p_new_customer_id, hdr.CUSTOMER_ID);
          l_header_rec.ADDRESS_ID  := p_new_address_id;
          l_header_rec.SALES_STAGE_ID  := hdr.SALES_STAGE_ID;
          l_header_rec.INITIATING_CONTACT_ID  := hdr.INITIATING_CONTACT_ID;
          l_header_rec.CHANNEL_CODE  := hdr.CHANNEL_CODE;
          l_header_rec.TOTAL_AMOUNT  := l_new_total_amount;     -- Bug 2040332
          l_header_rec.TOTAL_REVENUE_OPP_FORECAST_AMT := l_TOT_REVENUE_OPP_FORECAST_AMT;    -- Added for ASNB
          l_header_rec.CURRENCY_CODE  := hdr.CURRENCY_CODE;
          l_header_rec.DECISION_DATE  := hdr.DECISION_DATE;
          l_header_rec.WIN_PROBABILITY  := hdr.WIN_PROBABILITY;
          l_header_rec.CLOSE_REASON  := hdr.CLOSE_REASON;
          l_header_rec.CLOSE_COMPETITOR_CODE  := hdr.CLOSE_COMPETITOR_CODE;
          l_header_rec.CLOSE_COMPETITOR  := hdr.CLOSE_COMPETITOR;
          l_header_rec.CLOSE_COMMENT  := hdr.CLOSE_COMMENT;
          l_header_rec.DESCRIPTION  := p_description;
          l_header_rec.RANK  := hdr.RANK;
          l_header_rec.SOURCE_PROMOTION_ID  := hdr.SOURCE_PROMOTION_ID;
          l_header_rec.END_USER_CUSTOMER_ID  := hdr.END_USER_CUSTOMER_ID;
          l_header_rec.END_USER_ADDRESS_ID  := hdr.END_USER_ADDRESS_ID;
      l_header_rec.OWNER_SALESFORCE_ID := hdr.OWNER_SALESFORCE_ID;
      l_header_rec.OWNER_SALES_GROUP_ID := hdr.OWNER_SALES_GROUP_ID;
      --l_header_rec.OWNER_ASSIGN_DATE := hdr.OWNER_ASSIGN_DATE;
          --l_header_rec.ORG_ID  := hdr.ORG_ID; commented for bug 5477698
          -- l_header_rec.ORG_ID  := FND_PROFILE.Value('DEFAULT_ORG_ID');
	  l_header_rec.ORG_ID  :=  MO_UTILS.get_default_org_id;  -- added for bug 5219495
          l_header_rec.NO_OPP_ALLOWED_FLAG  := hdr.NO_OPP_ALLOWED_FLAG;
          l_header_rec.DELETE_ALLOWED_FLAG  := hdr.DELETE_ALLOWED_FLAG;
          l_header_rec.ATTRIBUTE_CATEGORY  := hdr.ATTRIBUTE_CATEGORY;
          l_header_rec.ATTRIBUTE1  := hdr.ATTRIBUTE1;
          l_header_rec.ATTRIBUTE2  := hdr.ATTRIBUTE2;
          l_header_rec.ATTRIBUTE3  := hdr.ATTRIBUTE3;
          l_header_rec.ATTRIBUTE4  := hdr.ATTRIBUTE4;
          l_header_rec.ATTRIBUTE5  := hdr.ATTRIBUTE5;
          l_header_rec.ATTRIBUTE6  := hdr.ATTRIBUTE6;
          l_header_rec.ATTRIBUTE7  := hdr.ATTRIBUTE7;
          l_header_rec.ATTRIBUTE8  := hdr.ATTRIBUTE8;
          l_header_rec.ATTRIBUTE9  := hdr.ATTRIBUTE9;
          l_header_rec.ATTRIBUTE10  := hdr.ATTRIBUTE10;
          l_header_rec.ATTRIBUTE11  := hdr.ATTRIBUTE11;
          l_header_rec.ATTRIBUTE12  := hdr.ATTRIBUTE12;
          l_header_rec.ATTRIBUTE13  := hdr.ATTRIBUTE13;
          l_header_rec.ATTRIBUTE14  := hdr.ATTRIBUTE14;
          l_header_rec.ATTRIBUTE15  := hdr.ATTRIBUTE15;
          l_header_rec.PARENT_PROJECT  := hdr.PARENT_PROJECT;
          l_header_rec.LEAD_SOURCE_CODE  := hdr.LEAD_SOURCE_CODE;
          l_header_rec.ORIG_SYSTEM_REFERENCE  := hdr.ORIG_SYSTEM_REFERENCE;
          l_header_rec.CLOSE_COMPETITOR_ID  := hdr.CLOSE_COMPETITOR_ID;
          l_header_rec.END_USER_CUSTOMER_NAME  := hdr.END_USER_CUSTOMER_NAME;
          l_header_rec.PRICE_LIST_ID  := hdr.PRICE_LIST_ID;
          l_header_rec.DELETED_FLAG  := hdr.DELETED_FLAG;
          l_header_rec.AUTO_ASSIGNMENT_TYPE  := NULL;   --bug1580008
          l_header_rec.PRM_ASSIGNMENT_TYPE  := NULL;    --bug1580008
          l_header_rec.CUSTOMER_BUDGET  := hdr.CUSTOMER_BUDGET;
          l_header_rec.METHODOLOGY_CODE  := hdr.METHODOLOGY_CODE;
      l_header_rec.SALES_METHODOLOGY_ID := l_new_sales_methodology_id;
          l_header_rec.DECISION_TIMEFRAME_CODE  := hdr.DECISION_TIMEFRAME_CODE;
          l_header_rec.INCUMBENT_PARTNER_RESOURCE_ID := hdr.INCUMBENT_PARTNER_RESOURCE_ID;
          l_header_rec.INCUMBENT_PARTNER_PARTY_ID  := hdr.INCUMBENT_PARTNER_PARTY_ID;
          l_header_rec.OFFER_ID  := hdr.OFFER_ID;
          l_header_rec.VEHICLE_RESPONSE_CODE  := hdr.VEHICLE_RESPONSE_CODE;
          l_header_rec.BUDGET_STATUS_CODE  := hdr.BUDGET_STATUS_CODE;
          l_header_rec.FOLLOWUP_DATE  := hdr.FOLLOWUP_DATE;
          l_header_rec.PRM_EXEC_SPONSOR_FLAG  := hdr.PRM_EXEC_SPONSOR_FLAG;
          l_header_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG := hdr.PRM_PRJ_LEAD_IN_PLACE_FLAG;
          l_header_rec.PRM_IND_CLASSIFICATION_CODE  := hdr.PRM_IND_CLASSIFICATION_CODE;
          l_header_rec.PRM_LEAD_TYPE  := hdr.PRM_LEAD_TYPE;
          l_header_rec.FREEZE_FLAG  := hdr.FREEZE_FLAG;
          l_header_rec.PRM_REFERRAL_CODE  := hdr.PRM_REFERRAL_CODE;

      l_close_competitor_id := hdr.close_competitor_id;

      -- if customer is changed, donot copy project
      if nvl(p_new_customer_id, -1) <> nvl(hdr.CUSTOMER_ID, -1) then
          l_header_rec.PARENT_PROJECT := null;
      end if;

      -- Donot copy owner if not copying salesteam
      IF (p_copy_Salesteam <> 'Y') THEN
      l_header_rec.OWNER_SALESFORCE_ID := null;
      l_header_rec.OWNER_SALES_GROUP_ID := null;
      END IF;

      -- Calling Private package: Create_OPP_HEADER
          -- Hint: Primary key needs to be returned
          AS_OPPORTUNITY_PUB.Create_opp_header(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => 'N',
            P_Admin_Flag                 => P_Admin_Flag ,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
            p_salesgroup_id          => p_salesgroup_id,
            P_Profile_Tbl                => P_Profile_tbl,
            P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
            P_Header_Rec             => l_Header_Rec ,
            X_LEAD_ID                => x_LEAD_ID,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

          -- Check return status from the above procedure call
          IF x_return_status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      IF l_debug THEN
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Create_opp_header fail');
          ELSE
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: Created lead '|| x_lead_id);
          END IF;
          END IF;

      END LOOP;

      -- Bug 3426788
      -- Add the persons having sales credits to the sales team if profile is ON
       IF ((p_copy_Salesteam <> 'Y') AND (p_copy_sales_credits = 'Y') AND ( FND_PROFILE.Value('AS_ENFORCE_SALES_TEAM') = 'Y')) THEN
            l_cre_st_for_sc_flag := 'Y';
       END IF;

      --
      -- Copy Sales team
      --

      IF (p_copy_salesteam = 'Y' OR l_cre_st_for_sc_flag = 'Y') THEN

    -- Copy salesteam. At this point TAP/Owner logic has already run.
    FOR str IN c_salesteam(p_lead_id,l_cre_st_for_sc_flag) LOOP

        l_Sales_Team_Rec.Last_Update_Date     := SYSDATE;
        l_Sales_Team_Rec.Last_Updated_By      := FND_GLOBAL.User_Id;
        l_Sales_Team_Rec.Creation_Date        := SYSDATE;
        l_Sales_Team_Rec.Created_By           := FND_GLOBAL.User_Id;
        l_Sales_Team_Rec.Last_Update_Login    := FND_GLOBAL.Conc_Login_Id;
        --l_Sales_Team_Rec.owner_flag           := str.owner_flag;
        l_Sales_Team_Rec.Freeze_Flag          := str.freeze_flag;
        l_Sales_Team_Rec.Reassign_Flag        := str.reassign_flag;
        l_Sales_Team_Rec.Team_Leader_Flag     := str.team_leader_flag;
        l_Sales_Team_Rec.Person_Id            := str.person_id;
        l_Sales_Team_Rec.Customer_Id          := nvl(p_new_customer_id, str.customer_id);

        -- if customer is changed, change the address to the new address
        if nvl(p_new_customer_id, -1) <> nvl(str.customer_id, -1) then
            l_Sales_Team_Rec.Address_Id         := p_new_address_id;
        else
            l_Sales_Team_Rec.Address_Id         := str.address_id;
        end if;

        l_Sales_Team_Rec.Salesforce_id        := str.salesforce_id;
        l_Sales_Team_Rec.Created_Person_Id    := str.created_person_id;
        l_Sales_Team_Rec.Partner_Customer_id  := str.partner_customer_id;
        l_Sales_Team_Rec.Partner_Address_id   := str.partner_address_id;
        l_Sales_Team_Rec.Lead_Id              := x_lead_id;
        l_Sales_Team_Rec.Freeze_Date          := str.freeze_date;
        l_Sales_Team_Rec.Reassign_Reason            := str.reassign_reason;
        l_Sales_Team_Rec.Reassign_request_date          := str.reassign_request_date;
        l_Sales_Team_Rec.Reassign_requested_person_id   := str.reassign_requested_person_id;
        l_Sales_Team_Rec.Attribute_Category         := str.attribute_category;
        l_Sales_Team_Rec.Attribute1           := str.attribute1;
        l_Sales_Team_Rec.Attribute2           := str.attribute2;
        l_Sales_Team_Rec.Attribute3           := str.attribute3;
        l_Sales_Team_Rec.Attribute4           := str.attribute4;
        l_Sales_Team_Rec.Attribute5           := str.attribute5;
        l_Sales_Team_Rec.Attribute6           := str.attribute6;
        l_Sales_Team_Rec.Attribute7           := str.attribute7;
        l_Sales_Team_Rec.Attribute8           := str.attribute8;
        l_Sales_Team_Rec.Attribute9           := str.attribute9;
        l_Sales_Team_Rec.Attribute10          := str.attribute10;
        l_Sales_Team_Rec.Attribute11          := str.attribute11;
        l_Sales_Team_Rec.Attribute12          := str.attribute12;
        l_Sales_Team_Rec.Attribute13          := str.attribute13;
        l_Sales_Team_Rec.Attribute14          := str.attribute14;
        l_Sales_Team_Rec.Attribute15          := str.attribute15;
        l_Sales_Team_Rec.Sales_group_id       := str.sales_group_id;
        l_Sales_Team_Rec.Sales_lead_id        := str.sales_lead_id;
        --l_Sales_Team_Rec.Internal_update_access   := str.internal_update_access;
        l_Sales_Team_Rec.Partner_Cont_Party_Id  := str.partner_cont_party_id;
        l_Sales_Team_Rec.Salesforce_Role_Code       := str.salesforce_role_code;
        l_Sales_Team_Rec.Salesforce_Relationship_Code   := str.salesforce_relationship_code;
    -- Added for ASNB
    IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'  THEN
       l_Sales_Team_Rec.contributor_flag   := str.contributor_flag;
    END IF;

        l_insert := true;
        if (nvl(str.owner_flag,'N') = 'Y' AND
            nvl(str.salesforce_id,-99) = nvl(l_header_rec.OWNER_SALESFORCE_ID,-99) AND
            nvl(str.sales_group_id,-99) = nvl(l_header_rec.OWNER_SALES_GROUP_ID,-99)) then
            open  c_owner_in_salesTeam(x_lead_id,str.salesforce_id,str.sales_group_id);
            fetch c_owner_in_salesTeam into l_val,l_date;
            if (c_owner_in_salesTeam%FOUND) then
                l_insert := false;
            end if;
            Close c_owner_in_salesTeam;
        end if;

        if (l_insert) then
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
                ,p_check_access_flag          => 'N' -- P_Check_Access_flag
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
                           'Create_SalesTeam:l_access_id > ' || l_access_id);

            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        -- Begin Added for ASNB
        IF  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y' AND
            P_Identity_Salesforce_Id = l_Sales_Team_Rec.salesforce_id AND
        nvl(l_Sales_Team_Rec.contributor_flag,'N') = 'Y'
        THEN
            open  c_log_user_in_salesTeam(x_lead_id,l_Sales_Team_Rec.salesforce_id,l_Sales_Team_Rec.sales_group_id);
            fetch c_log_user_in_salesTeam into l_val,l_date;
            close c_log_user_in_salesTeam;
            l_Sales_Team_Rec.last_update_date := l_date;
            l_Sales_Team_Rec.access_id := l_val;
            l_Sales_Team_Rec.Freeze_Flag := 'Y';
            AS_ACCESS_PUB.Update_SalesTeam (
            p_api_version_number         => 2.0
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => p_Validation_Level
            ,p_access_profile_rec         => l_access_profile_rec
            ,p_check_access_flag          => 'N' -- P_Check_Access_flag
            ,p_admin_flag                 => P_Admin_Flag
            ,p_admin_group_id             => P_Admin_Group_Id
            ,p_identity_salesforce_id     => P_Identity_Salesforce_Id
            ,p_sales_team_rec             => l_Sales_Team_Rec
            ,X_Return_Status              => x_Return_Status
            ,X_Msg_Count                  => X_Msg_Count
            ,X_Msg_Data                   => X_Msg_Data
            ,x_access_id                  => l_Access_Id
            );

        END IF;
        -- End Added for ASNB
        ELSE
            IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Update_SalesTeam: access_id > ' || l_val);
            END IF;
            l_Sales_Team_Rec.last_update_date := l_date;
            l_Sales_Team_Rec.access_id := l_val;
            --dbms_output.put_line('access_id ' || l_Sales_Team_Rec.access_id);
            --dbms_output.put_line('date from db ' || to_char(l_date,'MM:DD:YYYY HH24:MI:SS'));
            AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
                ,p_init_msg_list              => FND_API.G_FALSE
                ,p_commit                     => FND_API.G_FALSE
                ,p_validation_level           => p_Validation_Level
                ,p_access_profile_rec         => l_access_profile_rec
                ,p_check_access_flag          => 'N' -- P_Check_Access_flag
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
                           'Update_SalesTeam: Done');
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END LOOP;
      END IF;
      --
      -- Copy Opportunity Lines and line details - Sales Credits,
      -- Competitor Products and Decision Factors
      --

      IF(l_copy_opp_lines = 'Y') THEN
          l_header_rec.lead_id := x_lead_id;

      FOR lr IN c_lines(p_lead_id) LOOP
            l_lead_line_id := null;

            -- Copy lines
            AS_LEAD_LINES_PKG.Insert_Row(
                px_LEAD_LINE_ID  => l_LEAD_LINE_ID,
                p_LAST_UPDATE_DATE  => SYSDATE,
                p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
                p_CREATION_DATE  => SYSDATE,
                p_CREATED_BY  => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
                p_REQUEST_ID  => lr.REQUEST_ID,
                p_PROGRAM_APPLICATION_ID  => lr.PROGRAM_APPLICATION_ID,
                p_PROGRAM_ID  => lr.PROGRAM_ID,
                p_PROGRAM_UPDATE_DATE  => lr.PROGRAM_UPDATE_DATE,
                p_LEAD_ID  => x_LEAD_ID,
                p_INTEREST_TYPE_ID  => lr.INTEREST_TYPE_ID,
                p_PRIMARY_INTEREST_CODE_ID  => lr.PRIMARY_INTEREST_CODE_ID,
                p_SECONDARY_INTEREST_CODE_ID => lr.SECONDARY_INTEREST_CODE_ID,
                p_INTEREST_STATUS_CODE  => lr.INTEREST_STATUS_CODE,
                p_INVENTORY_ITEM_ID  => lr.INVENTORY_ITEM_ID,
                p_ORGANIZATION_ID  => lr.ORGANIZATION_ID,
                p_UOM_CODE  => lr.UOM_CODE,
                p_QUANTITY  => lr.QUANTITY,
                p_TOTAL_AMOUNT  => lr.TOTAL_AMOUNT,
                p_SALES_STAGE_ID  => lr.SALES_STAGE_ID,
                p_WIN_PROBABILITY  => lr.WIN_PROBABILITY,
                p_DECISION_DATE  => lr.DECISION_DATE,
                p_ORG_ID  => lr.ORG_ID,
                p_ATTRIBUTE_CATEGORY  => lr.ATTRIBUTE_CATEGORY,
                p_ATTRIBUTE1  => lr.ATTRIBUTE1,
                p_ATTRIBUTE2  => lr.ATTRIBUTE2,
                p_ATTRIBUTE3  => lr.ATTRIBUTE3,
                p_ATTRIBUTE4  => lr.ATTRIBUTE4,
                p_ATTRIBUTE5  => lr.ATTRIBUTE5,
                p_ATTRIBUTE6  => lr.ATTRIBUTE6,
                p_ATTRIBUTE7  => lr.ATTRIBUTE7,
                p_ATTRIBUTE8  => lr.ATTRIBUTE8,
                p_ATTRIBUTE9  => lr.ATTRIBUTE9,
                p_ATTRIBUTE10  => lr.ATTRIBUTE10,
                p_ATTRIBUTE11  => lr.ATTRIBUTE11,
                p_ATTRIBUTE12  => lr.ATTRIBUTE12,
                p_ATTRIBUTE13  => lr.ATTRIBUTE13,
                p_ATTRIBUTE14  => lr.ATTRIBUTE14,
                p_ATTRIBUTE15  => lr.ATTRIBUTE15,
                p_STATUS_CODE  => lr.STATUS_CODE,
                p_CHANNEL_CODE  => lr.CHANNEL_CODE,
                p_QUOTED_LINE_FLAG  => lr.QUOTED_LINE_FLAG,
                p_PRICE  => lr.PRICE,
                p_PRICE_VOLUME_MARGIN  => lr.PRICE_VOLUME_MARGIN,
                p_SHIP_DATE  => lr.SHIP_DATE,
                p_FORECAST_DATE  => lr.FORECAST_DATE,
                p_ROLLING_FORECAST_FLAG  => lr.ROLLING_FORECAST_FLAG,
                p_SOURCE_PROMOTION_ID  => lr.SOURCE_PROMOTION_ID,
                p_OFFER_ID  => lr.OFFER_ID,
                p_PRODUCT_CATEGORY_ID => lr.PRODUCT_CATEGORY_ID,
                p_PRODUCT_CAT_SET_ID => lr.PRODUCT_CAT_SET_ID);

            IF l_lead_line_id is null THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_lines_pkg.insert_row fail');
                END IF;

                RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_lines_pkg.insert_row '|| l_lead_line_id);
        END IF;

            END IF;

        -- Copy Sales Credits
            IF (p_copy_sales_credits = 'Y') THEN
        FOR scr IN c_sales_credits(p_lead_id, lr.lead_line_id) LOOP
                l_sales_credit_id := null;
                AS_SALES_CREDITS_PKG.Insert_Row(
            px_SALES_CREDIT_ID  => l_SALES_CREDIT_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => SYSDATE,
            p_CREATED_BY  => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
            p_REQUEST_ID  => scr.REQUEST_ID,
            p_PROGRAM_APPLICATION_ID  => scr.PROGRAM_APPLICATION_ID,
            p_PROGRAM_ID  => scr.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => scr.PROGRAM_UPDATE_DATE,
            p_LEAD_ID  => x_LEAD_ID,
            p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
            p_SALESFORCE_ID  => scr.SALESFORCE_ID,
            p_PERSON_ID  => scr.PERSON_ID,
            p_SALESGROUP_ID  => scr.SALESGROUP_ID,
            p_PARTNER_CUSTOMER_ID  => scr.PARTNER_CUSTOMER_ID,
            p_PARTNER_ADDRESS_ID  => scr.PARTNER_ADDRESS_ID,
            p_REVENUE_AMOUNT  => scr.REVENUE_AMOUNT,
            p_REVENUE_PERCENT  => scr.REVENUE_PERCENT,
            p_QUOTA_CREDIT_AMOUNT  => scr.QUOTA_CREDIT_AMOUNT,
            p_QUOTA_CREDIT_PERCENT  => scr.QUOTA_CREDIT_PERCENT,
            p_ATTRIBUTE_CATEGORY  => scr.ATTRIBUTE_CATEGORY,
            p_ATTRIBUTE1  => scr.ATTRIBUTE1,
            p_ATTRIBUTE2  => scr.ATTRIBUTE2,
            p_ATTRIBUTE3  => scr.ATTRIBUTE3,
            p_ATTRIBUTE4  => scr.ATTRIBUTE4,
            p_ATTRIBUTE5  => scr.ATTRIBUTE5,
            p_ATTRIBUTE6  => scr.ATTRIBUTE6,
            p_ATTRIBUTE7  => scr.ATTRIBUTE7,
            p_ATTRIBUTE8  => scr.ATTRIBUTE8,
            p_ATTRIBUTE9  => scr.ATTRIBUTE9,
            p_ATTRIBUTE10  => scr.ATTRIBUTE10,
            p_ATTRIBUTE11  => scr.ATTRIBUTE11,
            p_ATTRIBUTE12  => scr.ATTRIBUTE12,
            p_ATTRIBUTE13  => scr.ATTRIBUTE13,
            p_ATTRIBUTE14  => scr.ATTRIBUTE14,
            p_ATTRIBUTE15  => scr.ATTRIBUTE15,
            p_MANAGER_REVIEW_FLAG  => scr.MANAGER_REVIEW_FLAG,
            p_MANAGER_REVIEW_DATE  => scr.MANAGER_REVIEW_DATE,
            p_ORIGINAL_SALES_CREDIT_ID  => scr.ORIGINAL_SALES_CREDIT_ID,
            p_CREDIT_PERCENT  => scr.CREDIT_PERCENT,
            p_CREDIT_AMOUNT  => scr.CREDIT_AMOUNT,
            p_CREDIT_TYPE_ID  => scr.CREDIT_TYPE_ID,
        -- The following fields are not passed before ASNB
            p_OPP_WORST_FORECAST_AMOUNT  => scr.OPP_WORST_FORECAST_AMOUNT,
            p_OPP_FORECAST_AMOUNT  => scr.OPP_FORECAST_AMOUNT,
            p_OPP_BEST_FORECAST_AMOUNT => scr.OPP_BEST_FORECAST_AMOUNT,
        P_DEFAULTED_FROM_OWNER_FLAG =>scr.DEFAULTED_FROM_OWNER_FLAG -- Added for ASNB
        );

                IF l_sales_credit_id is null THEN
                    IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Private API: as_sales_credits_pkg.insert_row fail');
                    END IF;

                    RAISE FND_API.G_EXC_ERROR;
            ELSE
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Private API: as_sales_credits_pkg.insert_row '|| l_sales_credit_id);
            END IF;

                END IF;

        END LOOP; -- SC loop

        ELSE   -- default sales credits to the user
            IF l_forecast_credit_type_id IS NULL THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                    IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'The profile AS_FORECAST_CREDIT_TYPE_ID is null');
            END IF;

                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_sales_credit_rec.last_update_date     := SYSDATE;
            l_sales_credit_rec.last_updated_by      := FND_GLOBAL.USER_ID;
            l_sales_credit_rec.creation_Date    := SYSDATE;
            l_sales_credit_rec.created_by       := FND_GLOBAL.USER_ID;
            l_sales_credit_rec.last_update_login    := FND_GLOBAL.CONC_LOGIN_ID;
            l_sales_credit_rec.lead_id      := x_lead_id;
            l_sales_credit_rec.lead_line_id     := l_LEAD_LINE_ID;
            l_sales_credit_rec.salesforce_id    := l_identity_sales_member_rec.salesforce_id;
            l_sales_credit_rec.person_id        := l_identity_sales_member_rec.employee_person_id;
            l_sales_credit_rec.salesgroup_id    := p_salesgroup_id;

            IF (l_identity_sales_member_rec.partner_customer_id is NOT NULL) and
           (l_identity_sales_member_rec.partner_customer_id <>FND_API.G_MISS_NUM)
            THEN
                l_sales_credit_rec.partner_customer_id := l_identity_sales_member_rec.partner_customer_id;
                l_sales_credit_rec.partner_address_id  := l_identity_sales_member_rec.partner_address_id;
            ELSE
            l_sales_credit_rec.partner_customer_id := l_identity_sales_member_rec.partner_contact_id;
        END IF;

        l_sales_credit_rec.credit_type_id   := l_forecast_credit_type_id;
        l_sales_credit_rec.credit_amount    := lr.total_amount;
        l_sales_credit_rec.credit_percent   := 100;

        l_sales_credit_tbl(1)   := l_sales_credit_rec;

        AS_OPP_sales_credit_PVT.Create_sales_credits(
            P_Api_Version_Number         => 2.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => FND_API.G_FALSE,
            P_Validation_Level           => P_Validation_Level,
            P_Check_Access_Flag          => FND_API.G_FALSE,
            P_Admin_Flag                 => FND_API.G_FALSE,
            P_Admin_Group_Id             => P_Admin_Group_Id,
            P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
            P_Partner_Cont_Party_Id      => p_partner_cont_party_id,
            P_Profile_Tbl                => P_Profile_tbl,
            P_Sales_Credit_Tbl       => l_sales_credit_tbl,
            X_Sales_Credit_Out_Tbl       => x_sales_credit_out_tbl,
            X_Return_Status              => x_return_status,
            X_Msg_Count                  => x_msg_count,
            X_Msg_Data                   => x_msg_data);

            -- Check return status from the above procedure call
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Copy Line: Create_Sales_credit fail' );
        END IF;

                    raise FND_API.G_EXC_ERROR;
            END IF;

            SELECT sum(OPP_FORECAST_AMOUNT) INTO l_TOT_REVENUE_OPP_FORECAST_AMT
            FROM   AS_SALES_CREDITS
            WHERE  lead_id = l_Header_rec.lead_id AND
                   credit_type_id = l_forecast_credit_type_id;

            END IF; -- p_copy_sales_credits

            -- Update Header with forecast amount since create_opp_header
            -- defaults it to null
            UPDATE AS_LEADS_ALL
            SET TOTAL_REVENUE_OPP_FORECAST_AMT = l_TOT_REVENUE_OPP_FORECAST_AMT
            WHERE lead_id = l_Header_rec.lead_id;


            IF ( p_copy_lead_competitors = 'Y') THEN

            -- Copy Competitor Products
            FOR cpdr IN c_competitor_products(lr.lead_line_id) LOOP
        l_lead_competitor_prod_id := NULL;
            -- Invoke table handler(AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row)
            AS_LEAD_COMP_PRODUCTS_PKG.Insert_Row(
            p_ATTRIBUTE15  => cpdr.ATTRIBUTE15,
            p_ATTRIBUTE14  => cpdr.ATTRIBUTE14,
            p_ATTRIBUTE13  => cpdr.ATTRIBUTE13,
            p_ATTRIBUTE12  => cpdr.ATTRIBUTE12,
            p_ATTRIBUTE11  => cpdr.ATTRIBUTE11,
            p_ATTRIBUTE10  => cpdr.ATTRIBUTE10,
            p_ATTRIBUTE9  => cpdr.ATTRIBUTE9,
            p_ATTRIBUTE8  => cpdr.ATTRIBUTE8,
            p_ATTRIBUTE7  => cpdr.ATTRIBUTE7,
            p_ATTRIBUTE6  => cpdr.ATTRIBUTE6,
            p_ATTRIBUTE4  => cpdr.ATTRIBUTE4,
            p_ATTRIBUTE5  => cpdr.ATTRIBUTE5,
            p_ATTRIBUTE2  => cpdr.ATTRIBUTE2,
            p_ATTRIBUTE3  => cpdr.ATTRIBUTE3,
            p_ATTRIBUTE1  => cpdr.ATTRIBUTE1,
            p_ATTRIBUTE_CATEGORY  => cpdr.ATTRIBUTE_CATEGORY,
            p_PROGRAM_ID  => cpdr.PROGRAM_ID,
            p_PROGRAM_UPDATE_DATE  => cpdr.PROGRAM_UPDATE_DATE,
            p_PROGRAM_APPLICATION_ID  => cpdr.PROGRAM_APPLICATION_ID,
            p_REQUEST_ID  => cpdr.REQUEST_ID,
            p_WIN_LOSS_STATUS  => cpdr.WIN_LOSS_STATUS,
            p_COMPETITOR_PRODUCT_ID  => cpdr.COMPETITOR_PRODUCT_ID,
            p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
            p_LEAD_ID  => x_LEAD_ID,
            px_LEAD_COMPETITOR_PROD_ID  => l_LEAD_COMPETITOR_PROD_ID,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_CREATED_BY  => FND_GLOBAL.USER_ID,
        p_CREATION_DATE  => SYSDATE);

            IF l_lead_competitor_prod_id is null THEN
                    IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_comp_products_pkg.insert_row fail');
            END IF;

                    RAISE FND_API.G_EXC_ERROR;
        ELSE
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_comp_products_pkg.insert_row '|| l_lead_competitor_prod_id);
            END IF;

            END IF;
            END LOOP; -- CPD loop

        -- Copy Decision Factors
            FOR dfcr IN c_decision_factors(lr.lead_line_id) LOOP
        l_lead_decision_factor_id := NULL;
            AS_LEAD_DECISION_FACTORS_PKG.Insert_Row(
            p_ATTRIBUTE15  => dfcr.ATTRIBUTE15,
            p_ATTRIBUTE14  => dfcr.ATTRIBUTE14,
            p_ATTRIBUTE13  => dfcr.ATTRIBUTE13,
            p_ATTRIBUTE12  => dfcr.ATTRIBUTE12,
            p_ATTRIBUTE11  => dfcr.ATTRIBUTE11,
            p_ATTRIBUTE10  => dfcr.ATTRIBUTE10,
            p_ATTRIBUTE9  => dfcr.ATTRIBUTE9,
            p_ATTRIBUTE8  => dfcr.ATTRIBUTE8,
            p_ATTRIBUTE7  => dfcr.ATTRIBUTE7,
            p_ATTRIBUTE6  => dfcr.ATTRIBUTE6,
            p_ATTRIBUTE5  => dfcr.ATTRIBUTE5,
            p_ATTRIBUTE4  => dfcr.ATTRIBUTE4,
            p_ATTRIBUTE3  => dfcr.ATTRIBUTE3,
            p_ATTRIBUTE2  => dfcr.ATTRIBUTE2,
            p_ATTRIBUTE1  => dfcr.ATTRIBUTE1,
            p_ATTRIBUTE_CATEGORY  => dfcr.ATTRIBUTE_CATEGORY,
            p_PROGRAM_UPDATE_DATE  => dfcr.PROGRAM_UPDATE_DATE,
            p_PROGRAM_ID  => dfcr.PROGRAM_ID,
            p_PROGRAM_APPLICATION_ID  => dfcr.PROGRAM_APPLICATION_ID,
            p_REQUEST_ID  => dfcr.REQUEST_ID,
            p_DECISION_RANK  => dfcr.DECISION_RANK,
            p_DECISION_PRIORITY_CODE  => dfcr.DECISION_PRIORITY_CODE,
            p_DECISION_FACTOR_CODE  => dfcr.DECISION_FACTOR_CODE,
            px_LEAD_DECISION_FACTOR_ID  => l_LEAD_DECISION_FACTOR_ID,
            p_LEAD_LINE_ID  => l_LEAD_LINE_ID,
            p_CREATE_BY  => FND_GLOBAL.USER_ID,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
            p_CREATION_DATE  => SYSDATE);

            IF l_lead_decision_factor_id is null THEN
                    IF l_debug THEN
                    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_decision_factors_pkg.insert_row fail');
            END IF;

                    RAISE FND_API.G_EXC_ERROR;
        ELSE
            IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_decision_factors_pkg.insert_row '|| l_lead_decision_factor_id );
            END IF;
            END IF;
            END LOOP; -- DFC loop
            END IF;  -- copy competitors
          END LOOP; -- line loop

      END IF; -- If (p_copy_opp_line = 'Y')

      --
      -- Copy opportunity contacts
      --
      IF(p_copy_lead_contacts = 'Y') THEN
      FOR cnr IN c_contacts(p_lead_id) LOOP
      l_lead_contact_id := NULL;

          AS_LEAD_CONTACTS_PKG.Insert_Row(
             px_LEAD_CONTACT_ID  => l_LEAD_CONTACT_ID,
             p_LEAD_ID  => x_LEAD_ID,
             p_CONTACT_ID  => cnr.CONTACT_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => cnr.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID  => cnr.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => cnr.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => cnr.PROGRAM_UPDATE_DATE,
             p_ENABLED_FLAG  => cnr.ENABLED_FLAG,
             p_CUSTOMER_ID  => nvl(p_new_customer_id, cnr.CUSTOMER_ID),
             p_ADDRESS_ID  => p_new_address_id,
             p_RANK  => cnr.RANK,
             p_PHONE_ID  => cnr.PHONE_ID,
             p_ATTRIBUTE_CATEGORY  => cnr.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => cnr.ATTRIBUTE1,
             p_ATTRIBUTE2  => cnr.ATTRIBUTE2,
             p_ATTRIBUTE3  => cnr.ATTRIBUTE3,
             p_ATTRIBUTE4  => cnr.ATTRIBUTE4,
             p_ATTRIBUTE5  => cnr.ATTRIBUTE5,
             p_ATTRIBUTE6  => cnr.ATTRIBUTE6,
             p_ATTRIBUTE7  => cnr.ATTRIBUTE7,
             p_ATTRIBUTE8  => cnr.ATTRIBUTE8,
             p_ATTRIBUTE9  => cnr.ATTRIBUTE9,
             p_ATTRIBUTE10  => cnr.ATTRIBUTE10,
             p_ATTRIBUTE11  => cnr.ATTRIBUTE11,
             p_ATTRIBUTE12  => cnr.ATTRIBUTE12,
             p_ATTRIBUTE13  => cnr.ATTRIBUTE13,
             p_ATTRIBUTE14  => cnr.ATTRIBUTE14,
             p_ATTRIBUTE15  => cnr.ATTRIBUTE15,
             p_ORG_ID  => cnr.ORG_ID,
             p_PRIMARY_CONTACT_FLAG  => cnr.PRIMARY_CONTACT_FLAG,
             p_ROLE  => cnr.ROLE,
             p_CONTACT_PARTY_ID  => cnr.CONTACT_PARTY_ID);

          IF l_lead_contact_id is null THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_lines_pkg.insert_row fail');
          END IF;

              RAISE FND_API.G_EXC_ERROR;
      ELSE
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_contacts_pkg.insert_row '|| l_lead_contact_id);
          END IF;

          END IF;
      END LOOP;
      END IF;

      --
      -- Copy opportunity competitors
      --
      IF(p_copy_lead_competitors = 'Y') THEN
      FOR cmpr IN c_competitors(p_lead_id) LOOP
      l_lead_competitor_id := NULL;

          IF (cmpr.COMPETITOR_ID <> nvl(l_close_competitor_id, -1)) THEN
          AS_LEAD_COMPETITORS_PKG.Insert_Row(
             px_LEAD_COMPETITOR_ID  => l_LEAD_COMPETITOR_ID,
             p_LAST_UPDATE_DATE  => SYSDATE,
             p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
             p_CREATION_DATE  => SYSDATE,
             p_CREATED_BY  => FND_GLOBAL.USER_ID,
             p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
             p_REQUEST_ID  => cmpr.REQUEST_ID,
             p_PROGRAM_APPLICATION_ID =>cmpr.PROGRAM_APPLICATION_ID,
             p_PROGRAM_ID  => cmpr.PROGRAM_ID,
             p_PROGRAM_UPDATE_DATE  => cmpr.PROGRAM_UPDATE_DATE,
             p_LEAD_ID  => x_LEAD_ID,
             p_COMPETITOR_CODE  => cmpr.COMPETITOR_CODE,
             p_COMPETITOR  => cmpr.COMPETITOR,
             p_PRODUCTS  => cmpr.PRODUCTS,
             p_COMMENTS  => cmpr.COMMENTS,
             p_ATTRIBUTE_CATEGORY  => cmpr.ATTRIBUTE_CATEGORY,
             p_ATTRIBUTE1  => cmpr.ATTRIBUTE1,
             p_ATTRIBUTE2  => cmpr.ATTRIBUTE2,
             p_ATTRIBUTE3  => cmpr.ATTRIBUTE3,
             p_ATTRIBUTE4  => cmpr.ATTRIBUTE4,
             p_ATTRIBUTE5  => cmpr.ATTRIBUTE5,
             p_ATTRIBUTE6  => cmpr.ATTRIBUTE6,
             p_ATTRIBUTE7  => cmpr.ATTRIBUTE7,
             p_ATTRIBUTE8  => cmpr.ATTRIBUTE8,
             p_ATTRIBUTE9  => cmpr.ATTRIBUTE9,
             p_ATTRIBUTE10  => cmpr.ATTRIBUTE10,
             p_ATTRIBUTE11  => cmpr.ATTRIBUTE11,
             p_ATTRIBUTE12  => cmpr.ATTRIBUTE12,
             p_ATTRIBUTE13  => cmpr.ATTRIBUTE13,
             p_ATTRIBUTE14  => cmpr.ATTRIBUTE14,
             p_ATTRIBUTE15  => cmpr.ATTRIBUTE15,
             p_WIN_LOSS_STATUS  => cmpr.WIN_LOSS_STATUS,
             p_COMPETITOR_RANK  => cmpr.COMPETITOR_RANK,
         p_RELATIONSHIP_PARTY_ID => cmpr.RELATIONSHIP_PARTY_ID,
             p_COMPETITOR_ID  => cmpr.COMPETITOR_ID);

          IF l_lead_competitor_id is null THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_competitors_pkg.insert_row fail');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
      ELSE
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Private API: as_lead_competitors_pkg.insert_row '|| l_lead_competitor_id);
          END IF;
          END IF;
      END IF;

      END LOOP; -- cmpr loop
      END IF;  -- p_copy_lead_competitors

      -- Run TAP to reassign salesteam
        AS_RTTAP_OPPTY.RTTAP_WRAPPER(
          P_Api_Version_Number         => 1.0,
          P_Init_Msg_List              => FND_API.G_FALSE,
          P_Commit                     => FND_API.G_FALSE,
          p_lead_id                    => x_LEAD_ID,
          X_Return_Status              => x_return_status,
          X_Msg_Count                  => x_msg_count,
          X_Msg_Data                   => x_msg_data
        );

      -- Check return status from the above procedure call
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
        IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Territory Assignment Call Failed' );
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

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

END Copy_Opportunity;

End AS_OPP_COPY_PVT;

/
