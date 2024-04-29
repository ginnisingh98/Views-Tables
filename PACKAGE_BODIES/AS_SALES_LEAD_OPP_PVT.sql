--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_OPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_OPP_PVT" as
/* $Header: asxvslob.pls 120.4 2006/04/20 02:56:34 subabu ship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_OPP_PVT
-- Purpose          : Sales Lead and Opportunity
-- NOTE             :
-- History          :
--      04/09/2001 FFANG  Created.
--
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_OPP_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvslob.pls';



PROCEDURE Create_Lead_Ctx(
    p_sales_lead_id              IN   NUMBER,
    p_opportunity_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2
    );


--   API Name:  Get_Potential_Opportunity

PROCEDURE Get_Potential_Opportunity(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := NULL,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_rec             IN   AS_SALES_LEADS_PUB.SALES_LEAD_rec_type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_OPPORTUNITY_tbl            OUT NOCOPY AS_OPPORTUNITY_PUB.HEADER_TBL_TYPE,
    X_OPP_LINES_tbl              OUT NOCOPY AS_OPPORTUNITY_PUB.LINE_TBL_TYPE
    )
 IS
    -- Bug 1558460
    -- solin, use customer_id to find opportunity. source_promotion_id is not
    -- needed any more.
    -- ffang 012501, PM wants all opportunities with same customer_id, don't
    -- need access checking on this.

--Modified By Francis on 08/22/2001 for bug#1950681 to replace the view.

    CURSOR C_Get_Opportunity (x_Customer_ID NUMBER) IS
       SELECT

          opp.last_update_date
         ,opp.last_updated_by
         ,opp.creation_Date
         ,opp.created_by
         ,opp.last_update_login
         ,opp.request_id
         ,opp.program_application_id
         ,opp.program_id
         ,opp.program_update_date
         ,opp.lead_id
         ,opp.lead_number
         ,opp.orig_system_reference
         ,opp.lead_source_code
         -- ,opp.lead_source
         ,opp.description
         ,opp.source_promotion_id
         ,AMS1.NAME source_promotion_code
         ,opp.customer_id
         ,PARTY.PARTY_NAME CUSTOMER_NAME
         ,NVL(ORGANIZATION_NAME_PHONETIC,  decode(PERSON_LAST_NAME_PHONETIC,Null,Null,PERSON_LAST_NAME_PHONETIC||', ')||PERSON_FIRST_NAME_PHONETIC) CUSTOMER_NAME_PHONETIC
         ,opp.address_id
         -- ,opp.address1 address
         -- ,opp.address2
         -- ,opp.address3
         -- ,opp.address4
         -- ,opp.city
         -- ,opp.state
         -- ,opp.country
         -- ,opp.province
         ,opp.sales_stage_id
         ,STGTL.NAME SALES_STAGE
         ,opp.win_probability
         ,opp.status STATUS_CODE
         ,ASSTATUSES.MEANING status
         ,opp.total_amount
         -- ,opp.converted_total_amount
         ,opp.channel_code
         ,ASOCHANNELS.MEANING CHANNEL
         ,opp.decision_date
         ,opp.currency_code
         -- ,opp.to_currency_code
         ,opp.close_reason CLOSE_REASON_CODE
         -- ,opp.close_reason
         -- ,opp.close_competitor_code
         ,opp.close_competitor_id
         ,opp.close_competitor
         ,opp.close_comment
         ,opp.end_user_customer_id
         ,opp.end_user_customer_name
         ,opp.end_user_address_id
         ,opp.parent_project
         -- ,opp.parent_project_code
         -- ,opp.updateable_flag
         ,opp.price_list_id
         -- ,opp.initiating_contact_id
         -- ,opp.rank
         -- ,opp.member_access
         -- ,opp.member_role
         -- ,opp.deleted_flag
         -- ,opp.auto_assignment_type
         -- ,opp.prm_assignment_type
         -- ,opp.customer_budget
         ,opp.methodology_code
         -- ,opp.original_lead_id
         -- ,opp.decision_timeframe_code
         -- ,opp.incumbent_partner_resource_id
         -- ,opp.incumbent_partner_party_id
         ,opp.offer_id
         -- ,opp.vehicle_response_code
         -- ,opp.budget_status_code
         -- ,opp.followup_date
         ,opp.no_opp_allowed_flag
         ,opp.delete_allowed_flag
         -- ,opp.prm_exec_sponsor_flag
         -- ,opp.prm_prj_lead_in_place_flag
         -- ,opp.prm_ind_classIFication_code
         -- ,opp.prm_lead_type
         -- ,opp.org_id
         ,opp.attribute_category
         ,opp.attribute1
         ,opp.attribute2
         ,opp.attribute3
         ,opp.attribute4
         ,opp.attribute5
         ,opp.attribute6
         ,opp.attribute7
         ,opp.attribute8
         ,opp.attribute9
         ,opp.attribute10
         ,opp.attribute11
         ,opp.attribute12
         ,opp.attribute13
         ,opp.attribute14
         ,opp.attribute15


        FROM
	      AS_LEADS_ALL OPP,
	      HZ_PARTIES PARTY,
	      AMS_P_SOURCE_CODES_V AMS1,
	      OE_LOOKUPS ASOCHANNELS,
	      AS_SALES_STAGES_ALL_B STGB,
	      AS_SALES_STAGES_ALL_TL STGTL,
	      AS_STATUSES_TL ASSTATUSES,
              AS_STATUSES_B ASSTB

        WHERE
            OPP.CUSTOMER_ID = x_Customer_Id AND
	    OPP.CUSTOMER_ID = PARTY.PARTY_ID AND
	    OPP.SOURCE_PROMOTION_ID = AMS1.SOURCE_CODE_ID(+) AND
	    OPP.CHANNEL_CODE = ASOCHANNELS.LOOKUP_CODE(+) AND
	    ASOCHANNELS.LOOKUP_TYPE(+) = 'SALES_CHANNEL' AND
	    OPP.SALES_STAGE_ID = STGB.SALES_STAGE_ID(+) AND
	    STGB.SALES_STAGE_ID = STGTL.SALES_STAGE_ID(+) AND
	    STGTL.LANGUAGE(+) = USERENV('LANG') AND
	    OPP.STATUS = ASSTB.STATUS_CODE  AND
	    ASSTB.OPP_OPEN_STATUS_FLAG = 'Y' AND
	    ASSTB.STATUS_CODE = ASSTATUSES.STATUS_CODE AND
	    ASSTATUSES.LANGUAGE = USERENV('LANG')  ;



    CURSOR C_Get_Opp_Line (x_Lead_ID NUMBER) IS
       SELECT
          last_update_date
         ,last_updated_by
         ,creation_Date
         ,created_by
         ,last_update_login
         ,request_id
    	    ,program_application_id
    	    ,program_id
    	    ,program_update_date
	    ,lead_id
         ,lead_line_id
    	    ,original_lead_line_id
         ,interest_type_id
         -- ,interest_type
         -- ,interest_status_code
         ,primary_interest_code_id
         -- ,primary_interest_code
         ,secondary_interest_code_id
         -- ,secondary_interest_code
         ,inventory_item_id
         -- ,inventory_item_conc_segs
         ,organization_id
         ,uom_code
         -- ,uom
         ,quantity
         ,ship_date
         ,total_amount
         -- ,sales_stage_id
         -- ,sales_stage
         -- ,win_probability
         -- ,status_code
         -- ,status
         -- ,decision_date
         -- ,channel_code
         -- ,channel
         -- ,unit_price
         -- ,price
         -- ,price_volume_margin
         -- ,quoted_line_flag
         -- ,member_access
         -- ,member_role
         -- ,currency_code
         -- ,owner_scredit_percent
         -- ,source_promotion_id
         -- ,offer_id
         -- ,org_id
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,product_category_id
         ,product_cat_set_id
      From AS_LEAD_LINES_ALL
      Where lead_id = x_Lead_Id;

    l_api_name           CONSTANT VARCHAR2(30) := 'Get_Potential_Opportunity';
    l_api_version_number CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_header_rec                 AS_OPPORTUNITY_PUB.HEADER_REC_TYPE;
    l_line_rec                   AS_OPPORTUNITY_PUB.LINE_REC_TYPE;
    l_SALES_LEAD_rec             AS_SALES_LEADS_PUB.SALES_LEAD_REC_type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_cnt                        NUMBER := 0;
    l_cnt_line                   NUMBER := 0;
    l_validation_mode            VARCHAR2(30) := AS_UTILITY_PVT.G_CREATE;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.slopv.Get_Potential_Opportunity';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_POTENTIAL_OPPORTUNITY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message

      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT:' || l_api_name || 'start');
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
                  p_module        => l_module,
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      For  C_Get_Opp_Rec IN C_Get_Opportunity (P_SALES_LEAD_rec.Customer_Id)
      Loop
           l_cnt := l_cnt + 1;
           l_header_rec.last_update_date  :=  C_Get_Opp_Rec.last_update_date;
           l_header_rec.last_updated_by   :=  C_Get_Opp_Rec.last_updated_by;
           l_header_rec.creation_Date     :=  C_Get_Opp_Rec.creation_Date;
           l_header_rec.created_by        :=  C_Get_Opp_Rec.created_by;
           l_header_rec.last_update_login :=  C_Get_Opp_Rec.last_update_login;
           l_header_rec.lead_id           :=  C_Get_Opp_Rec.lead_id;
           l_header_rec.lead_number       :=  C_Get_Opp_Rec.lead_number;
           l_header_rec.orig_system_reference
                                    :=  C_Get_Opp_Rec.orig_system_reference;
           l_header_rec.lead_source_code  :=  C_Get_Opp_Rec.lead_source_code;
           -- l_header_rec.lead_source       :=  C_Get_Opp_Rec.lead_source;
           l_header_rec.description       :=  C_Get_Opp_Rec.description;
           l_header_rec.source_promotion_id
                                    :=  C_Get_Opp_Rec.source_promotion_id;
           l_header_rec.customer_id       :=  C_Get_Opp_Rec.customer_id;
           l_header_rec.customer_name     :=  C_Get_Opp_Rec.customer_name;
           l_header_rec.address_id        :=  C_Get_Opp_Rec.address_id;
           -- l_header_rec.city              :=  C_Get_Opp_Rec.city;
           l_header_rec.sales_stage       :=  C_Get_Opp_Rec.sales_stage;
           l_header_rec.sales_stage_id    :=  C_Get_Opp_Rec.sales_stage_id;
           l_header_rec.win_probability   :=  C_Get_Opp_Rec.win_probability;
           l_header_rec.status_code       :=  C_Get_Opp_Rec.status_code;

           -- ffang 092302, for bug 2567661, status in opportunity header record
           -- has wrong definition (varchar2(80), it should be varchar2(240)),
           -- comment this out to avoid exception.
           -- l_header_rec.status            :=  C_Get_Opp_Rec.status;
           -- end ffang 092302, for bug 2567661

           -- l_header_rec.initiating_contact_id
           --                      :=  C_Get_Opp_Rec.initiating_contact_id;
           -- l_header_rec.rank              :=  C_Get_Opp_Rec.rank;
           l_header_rec.channel_code      :=  C_Get_Opp_Rec.channel_code;
           l_header_rec.channel           :=  C_Get_Opp_Rec.channel;
           l_header_rec.decision_date     :=  C_Get_Opp_Rec.decision_date;
           l_header_rec.currency_code     :=  C_Get_Opp_Rec.currency_code;
           l_header_rec.price_list_id     :=  C_Get_Opp_Rec.price_list_id;
           l_header_rec.close_reason_code :=  C_Get_Opp_Rec.close_reason_code;
           -- l_header_rec.close_reason      :=  C_Get_Opp_Rec.close_reason;
           -- l_header_rec.close_competitor_code
           --                      :=  C_Get_Opp_Rec.close_competitor_code;
           l_header_rec.close_competitor_id
                                :=  C_Get_Opp_Rec.close_competitor_id;
           l_header_rec.close_competitor  :=  C_Get_Opp_Rec.close_competitor;
           l_header_rec.close_comment     :=  C_Get_Opp_Rec.close_comment;
           l_header_rec.end_user_customer_id
                                :=  C_Get_Opp_Rec.end_user_customer_id;
           l_header_rec.end_user_customer_name
                                :=  C_Get_Opp_Rec.end_user_customer_name;
           l_header_rec.end_user_address_id
                                :=  C_Get_Opp_Rec.end_user_address_id;
           l_header_rec.total_amount      :=  C_Get_Opp_Rec.total_amount;
           l_header_rec.attribute_category
                                :=  C_Get_Opp_Rec.attribute_category;
           l_header_rec.attribute1        :=  C_Get_Opp_Rec.attribute1;
           l_header_rec.attribute2        :=  C_Get_Opp_Rec.attribute2;
           l_header_rec.attribute3        :=  C_Get_Opp_Rec.attribute3;
           l_header_rec.attribute4        :=  C_Get_Opp_Rec.attribute4;
           l_header_rec.attribute5        :=  C_Get_Opp_Rec.attribute5;
           l_header_rec.attribute6        :=  C_Get_Opp_Rec.attribute6;
           l_header_rec.attribute7        :=  C_Get_Opp_Rec.attribute7;
           l_header_rec.attribute8        :=  C_Get_Opp_Rec.attribute8;
           l_header_rec.attribute9        :=  C_Get_Opp_Rec.attribute9;
           l_header_rec.attribute10       :=  C_Get_Opp_Rec.attribute10;
           l_header_rec.attribute11       :=  C_Get_Opp_Rec.attribute11;
           l_header_rec.attribute12       :=  C_Get_Opp_Rec.attribute12;
           l_header_rec.attribute13       :=  C_Get_Opp_Rec.attribute13;
           l_header_rec.attribute14       :=  C_Get_Opp_Rec.attribute14;
           l_header_rec.attribute15       :=  C_Get_Opp_Rec.attribute15;
           l_header_rec.parent_project    :=  C_Get_Opp_Rec.parent_project;
           l_header_rec.updateable_flag   :=  'N';
           -- l_header_rec.member_access     :=  FND_API.G_MISS_CHAR;
           -- l_header_rec.member_role       :=  FND_API.G_MISS_CHAR;

           X_Opportunity_tbl(l_cnt) :=  l_header_rec;


           -- Move Opportunity Lines to X_OPP_LINES_TBL parameter
           For C_Get_Opp_Line_Rec In C_Get_Opp_Line (l_header_Rec.lead_id)
           Loop
               l_cnt_line := l_cnt_line + 1;
               l_line_rec.last_update_date
                         := C_Get_Opp_Line_Rec.last_update_date;
               l_line_rec.last_updated_by := C_Get_Opp_Line_Rec.last_updated_by;
               l_line_rec.creation_Date   := C_Get_Opp_Line_Rec.creation_Date;
               l_line_rec.created_by      := C_Get_Opp_Line_Rec.created_by;
               l_line_rec.last_update_login
                         :=  C_Get_Opp_Line_Rec.last_update_login;
               l_line_rec.lead_line_id    := C_Get_Opp_Line_Rec.lead_line_id;
               l_line_rec.interest_type_id
                         := C_Get_Opp_Line_Rec.interest_type_id;
               -- l_line_rec.interest_type:=  C_Get_Opp_Line_Rec.interest_type;
               l_line_rec.primary_interest_code_id
                         :=  C_Get_Opp_Line_Rec.primary_interest_code_id;
               -- l_line_rec.primary_interest_code
               --          :=  C_Get_Opp_Line_Rec.primary_interest_code;
               l_line_rec.secondary_interest_code_id
                         :=  C_Get_Opp_Line_Rec.secondary_interest_code_id;
               -- l_line_rec.secondary_interest_code
               --          :=  C_Get_Opp_Line_Rec.secondary_interest_code;
               l_line_rec.inventory_item_id
                         :=  C_Get_Opp_Line_Rec.inventory_item_id;
               -- l_line_rec.inventory_item_conc_segs
               --          :=  C_Get_Opp_Line_Rec.inventory_item_conc_segs;
               l_line_rec.organization_id := C_Get_Opp_Line_Rec.organization_id;
               l_line_rec.uom_code        := C_Get_Opp_Line_Rec.uom_code;
               -- l_line_rec.uom          := C_Get_Opp_Line_Rec.uom;
               l_line_rec.quantity        := C_Get_Opp_Line_Rec.quantity;
               l_line_rec.ship_date       := C_Get_Opp_Line_Rec.ship_date;
               l_line_rec.total_amount    := C_Get_Opp_Line_Rec.total_amount;
               -- l_line_rec.sales_stage_id:= C_Get_Opp_Line_Rec.sales_stage_id;
               -- l_line_rec.sales_stage   := C_Get_Opp_Line_Rec.sales_stage;
               -- l_line_rec.win_probability
               --              := C_Get_Opp_Line_Rec.win_probability;
               -- l_line_rec.status_code   :=  C_Get_Opp_Line_Rec.status_code;
               -- l_line_rec.status        :=  C_Get_Opp_Line_Rec.status;
               -- l_line_rec.decision_date :=  C_Get_Opp_Line_Rec.decision_date;
               -- l_line_rec.channel_code  :=  C_Get_Opp_Line_Rec.channel_code;
               -- l_line_rec.channel       :=  C_Get_Opp_Line_Rec.channel;
               -- l_line_rec.unit_price    :=  C_Get_Opp_Line_Rec.unit_price;
               -- l_line_rec.quoted_line_flag
               --              :=  C_Get_Opp_Line_Rec.quoted_line_flag;
               -- l_line_rec.member_access :=  C_Get_Opp_Line_Rec.member_access;
               -- l_line_rec.member_role   :=  C_Get_Opp_Line_Rec.member_role;
               -- l_line_rec.currency_code :=  C_Get_Opp_Line_Rec.currency_code;
               -- l_line_rec.owner_scredit_percent
               --              :=  C_Get_Opp_Line_Rec.owner_scredit_percent;
               l_line_rec.attribute_category
                               :=  C_Get_Opp_Line_Rec.attribute_category;
               l_line_rec.attribute1      :=  C_Get_Opp_Line_Rec.attribute1;
               l_line_rec.attribute2      :=  C_Get_Opp_Line_Rec.attribute2;
               l_line_rec.attribute3      :=  C_Get_Opp_Line_Rec.attribute3;
               l_line_rec.attribute4      :=  C_Get_Opp_Line_Rec.attribute4;
               l_line_rec.attribute5      :=  C_Get_Opp_Line_Rec.attribute5;
               l_line_rec.attribute6      :=  C_Get_Opp_Line_Rec.attribute6;
               l_line_rec.attribute7      :=  C_Get_Opp_Line_Rec.attribute7;
               l_line_rec.attribute8      :=  C_Get_Opp_Line_Rec.attribute8;
               l_line_rec.attribute9      :=  C_Get_Opp_Line_Rec.attribute9;
               l_line_rec.attribute10     :=  C_Get_Opp_Line_Rec.attribute10;
               l_line_rec.attribute11     :=  C_Get_Opp_Line_Rec.attribute11;
               l_line_rec.attribute12     :=  C_Get_Opp_Line_Rec.attribute12;
               l_line_rec.attribute13     :=  C_Get_Opp_Line_Rec.attribute13;
               l_line_rec.attribute14     :=  C_Get_Opp_Line_Rec.attribute14;
               l_line_rec.attribute15     :=  C_Get_Opp_Line_Rec.attribute15;

               l_line_rec.product_category_id := C_Get_Opp_Line_Rec.product_category_id;
               l_line_rec.product_cat_set_id  := C_Get_Opp_Line_Rec.product_cat_set_id;

               X_OPP_LINES_tbl(l_cnt_line) := l_line_rec;

           END Loop;

      END Loop;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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
END Get_Potential_Opportunity;


--   API Name:  Copy_Lead_To_Opportunity new
/* API renamed by Francis on 06/26/2001 from Link_Lead_To_Opportunity to Copy_Lead_To_Opportunity */

PROCEDURE Copy_Lead_To_Opportunity(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER,     --:= NULL,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                              := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID            IN   NUMBER,
    P_SALES_LEAD_LINE_TBL      IN   AS_SALES_LEADS_PUB.SALES_LEAD_LINE_TBL_TYPE
                              := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_TBL,
    P_OPPORTUNITY_ID           IN   NUMBER,
    X_Return_Status            OUT NOCOPY VARCHAR2,
    X_Msg_Count                OUT NOCOPY NUMBER,
    X_Msg_Data                 OUT NOCOPY VARCHAR2
    )
 IS

    CURSOR C_lead_link_Exists (X_Sales_Lead_Id NUMBER, X_Opportunity_Id NUMBER) IS
      SELECT 'X'
      FROM as_sales_lead_opportunity
      WHERE sales_lead_id = X_Sales_Lead_Id
            AND opportunity_id = X_Opportunity_Id;

    CURSOR C_Sales_Owner_Check (X_Identity_Salesforce_Id NUMBER,
                                X_Opportunity_Id NUMBER,
                                X_Team_Leader_Flag VARCHAR2) IS
      SELECT salesforce_id
      FROM as_accesses_all
      WHERE salesforce_id = X_Identity_Salesforce_Id
            AND lead_id = X_Opportunity_Id
            AND team_leader_flag = X_Team_Leader_Flag;

    CURSOR C_Get_Sales_Owner (X_Opportunity_Id NUMBER) IS
      SELECT salesforce_id
      FROM as_accesses_all
      WHERE lead_id = X_Opportunity_Id
            AND team_leader_flag = 'Y';

/*
    CURSOR C_Get_Last_Update_Date (X_Sales_Lead_Id NUMBER) IS
      SELECT last_update_date,channel_code
        FROM as_sales_leads
        WHERE sales_lead_id = X_Sales_Lead_Id;
*/

    CURSOR C_Get_Sales_Lead (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login
             ,request_id
             ,program_application_id
             ,program_id
             ,program_update_date
             ,lead_number
             ,status_code
             ,customer_id
             ,address_id
             ,source_promotion_id
             ,initiating_contact_id
             ,orig_system_reference
             ,contact_role_code
             ,channel_code
             ,budget_amount
             ,currency_code
             ,decision_timeframe_code
             ,close_reason
             ,lead_rank_code
             ,parent_project
             ,description
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,assign_to_person_id
             ,assign_to_salesforce_id
             ,budget_status_code
             ,assign_date
             ,accept_flag
             ,vehicle_response_code
             ,total_score
             ,scorecard_id
             ,keep_flag
             ,urgent_flag
             ,import_flag
             ,reject_reason_code
             ,lead_rank_id
             ,deleted_flag
             ,assign_sales_group_id
             ,offer_id
             -- ,security_group_id
             ,incumbent_partner_party_id
             ,incumbent_partner_resource_id
      FROM as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

    CURSOR C_Get_Opportunity (x_Opportunity_Id NUMBER) IS
      SELECT last_update_date
             ,last_updated_by
             ,creation_Date
             ,created_by
             ,last_update_login
             ,lead_id
             ,lead_number
             ,orig_system_reference
             ,lead_source_code
             ,description
             ,source_promotion_id
             ,customer_id
             ,address_id
             ,sales_stage_id
             ,win_probability
             ,status status_code
             -- ,initiating_contact_id
             -- ,rank
             ,channel_code
             ,decision_date
             ,currency_code
             ,price_list_id
             ,close_reason close_reason_code
             -- ,close_competitor_code
             ,close_competitor_id
             ,close_competitor
             ,close_comment
             ,end_user_customer_id
             ,end_user_customer_name
             ,end_user_address_id
             ,total_amount
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,parent_project
             -- ,FND_API.G_MISS_NUM  --   ,security_group_id
      From AS_LEADS_ALL
      Where lead_id = X_Opportunity_Id;

    CURSOR C_Get_Sales_lead_lines (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_line_id
             ,last_update_date
             ,last_updated_by
             ,creation_Date
             ,created_by
             ,last_update_login
             ,sales_lead_id
             ,interest_type_id
             ,primary_interest_code_id
             ,secondary_interest_code_id
             ,inventory_item_id
             ,organization_id
             ,uom_code
             ,quantity
             ,budget_amount  --total_amount
             ,source_promotion_id
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,offer_id
             -- ,security_group_id
             ,category_id
             ,category_set_id
      FROM as_sales_lead_lines
      WHERE sales_lead_id = X_Sales_Lead_Id;

    -- 102700 FFANG for bug 1478517, get sales lead contacts information
    CURSOR C_Get_Sales_Lead_Contacts(c_sales_lead_id number) IS
      SELECT contact_id
             ,contact_party_id
             ,last_update_date
             ,last_updated_by
             ,creation_Date
             ,created_by
             ,last_update_login
             ,enabled_flag
             ,rank
             ,customer_id
             ,address_id
             ,phone_id
             ,contact_role_code
             ,primary_contact_flag
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             -- ,security_group_id
      FROM as_sales_lead_contacts
      WHERE sales_lead_id = c_sales_lead_id;
    -- end 102700 FFANG

    -- ffang 020601, for bug 1628894, check duplicate contact before calling
    -- create_opp_contact
    CURSOR c_check_dup_contact (x_contact_party_id NUMBER) IS
        SELECT 'X'
        FROM AS_LEAD_CONTACTS_ALL
        WHERE contact_party_id = x_contact_party_id
              and lead_id = p_opportunity_id;
    l_dup_contact                VARCHAR2(1);
    -- end ffang 020601

    l_api_name            CONSTANT VARCHAR2(30) := 'Copy_Lead_To_Opportunity';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_Identity_Sales_Member_Rec  AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    l_Sales_Lead_Rec             AS_SALES_LEADS_PUB.Sales_Lead_Rec_Type;
    l_sales_lead_line_tbl        AS_SALES_LEADS_PUB.Sales_Lead_Line_Tbl_Type;
    l_header_rec                 AS_OPPORTUNITY_PUB.Header_Rec_Type;
    l_line_tbl                   AS_OPPORTUNITY_PUB.Line_Tbl_Type;
    l_line_out_tbl               AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;
    l_contact_tbl                AS_OPPORTUNITY_PUB.Contact_Tbl_Type;
    l_contact_out_tbl            AS_OPPORTUNITY_PUB.Contact_Out_Tbl_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_val                        VARCHAR2(1) default null;
    --axavier l_val_id                     NUMBER;
    l_lead_line_id               NUMBER;
    l_last_update_date           DATE := FND_API.G_MISS_DATE;
    l_channel_code               VARCHAR2(30);
    l_Lead_Opportunity_Id        NUMBER;
    l_Lead_Opp_Line_Id           NUMBER;
    l_sales_lead_line_id         NUMBER default null;
    -- l_line_security_group_id     NUMBER := FND_API.G_MISS_NUM;
    -- l_opp_security_group_id      NUMBER := FND_API.G_MISS_NUM;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);
    l_cnt                        NUMBER := 0;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.slopv.Copy_Lead_To_Opportunity';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_LEAD_TO_OPPORTUNITY_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT:' || l_api_name || ' Start');
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
                  p_module        => l_module,
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get sales lead header based on parameter P_Sales_Lead_Id
      OPEN  C_Get_Sales_Lead (P_Sales_Lead_Id);
      FETCH C_Get_Sales_Lead INTO
            l_Sales_Lead_Rec.sales_lead_id
           ,l_Sales_Lead_Rec.last_update_date
           ,l_Sales_Lead_Rec.last_updated_by
           ,l_Sales_Lead_Rec.creation_date
           ,l_Sales_Lead_Rec.created_by
           ,l_Sales_Lead_Rec.last_update_login
           ,l_Sales_Lead_Rec.request_id
           ,l_Sales_Lead_Rec.program_application_id
           ,l_Sales_Lead_Rec.program_id
           ,l_Sales_Lead_Rec.program_update_date
           ,l_Sales_Lead_Rec.lead_number
           ,l_Sales_Lead_Rec.status_code
           ,l_Sales_Lead_Rec.customer_id
           ,l_Sales_Lead_Rec.address_id
           ,l_Sales_Lead_Rec.source_promotion_id
           ,l_Sales_Lead_Rec.initiating_contact_id
           ,l_Sales_Lead_Rec.orig_system_reference
           ,l_Sales_Lead_Rec.contact_role_code
           ,l_Sales_Lead_Rec.channel_code
           ,l_Sales_Lead_Rec.budget_amount
           ,l_Sales_Lead_Rec.currency_code
           ,l_Sales_Lead_Rec.decision_timeframe_code
           ,l_Sales_Lead_Rec.close_reason
           ,l_Sales_Lead_Rec.lead_rank_code
           ,l_Sales_Lead_Rec.parent_project
           ,l_Sales_Lead_Rec.description
           ,l_Sales_Lead_Rec.attribute_category
           ,l_Sales_Lead_Rec.attribute1
           ,l_Sales_Lead_Rec.attribute2
           ,l_Sales_Lead_Rec.attribute3
           ,l_Sales_Lead_Rec.attribute4
           ,l_Sales_Lead_Rec.attribute5
           ,l_Sales_Lead_Rec.attribute6
           ,l_Sales_Lead_Rec.attribute7
           ,l_Sales_Lead_Rec.attribute8
           ,l_Sales_Lead_Rec.attribute9
           ,l_Sales_Lead_Rec.attribute10
           ,l_Sales_Lead_Rec.attribute11
           ,l_Sales_Lead_Rec.attribute12
           ,l_Sales_Lead_Rec.attribute13
           ,l_Sales_Lead_Rec.attribute14
           ,l_Sales_Lead_Rec.attribute15
           ,l_Sales_Lead_Rec.assign_to_person_id
           ,l_Sales_Lead_Rec.assign_to_salesforce_id
           ,l_Sales_Lead_Rec.budget_status_code
           ,l_Sales_Lead_Rec.assign_date
           ,l_Sales_Lead_Rec.accept_flag
           ,l_Sales_Lead_Rec.vehicle_response_code
           ,l_Sales_Lead_Rec.total_score
           ,l_Sales_Lead_Rec.scorecard_id
           ,l_Sales_Lead_Rec.keep_flag
           ,l_Sales_Lead_Rec.urgent_flag
           ,l_Sales_Lead_Rec.import_flag
           ,l_Sales_Lead_Rec.reject_reason_code
           ,l_Sales_Lead_Rec.lead_rank_id
           ,l_Sales_Lead_Rec.deleted_flag
           ,l_Sales_Lead_Rec.assign_sales_group_id
           ,l_Sales_Lead_Rec.offer_id
           -- ,l_Sales_Lead_Rec.security_group_id
           ,l_Sales_Lead_Rec.incumbent_partner_party_id
           ,l_Sales_Lead_Rec.incumbent_partner_resource_id;

      IF ( C_Get_Sales_Lead%NOTFOUND) THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Private API: SALES_LEAD_ID is invalid');
        END IF;

        AS_UTILITY_PVT.Set_Message(
            p_module        => l_module,
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'SALES_LEAD_ID',
            p_token2        => 'VALUE',
            p_token2_value  =>  P_Sales_Lead_Id );

        x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      CLOSE C_Get_Sales_Lead;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;




      -- Get opportunity header based on parameter P_Opportunity_Id
      OPEN  C_Get_Opportunity (P_Opportunity_Id);
      FETCH C_Get_Opportunity  INTO
            l_header_rec.last_update_date
           ,l_header_rec.last_updated_by
           ,l_header_rec.creation_Date
           ,l_header_rec.created_by
           ,l_header_rec.last_update_login
           ,l_header_rec.lead_id
           ,l_header_rec.lead_number
           ,l_header_rec.orig_system_reference
           ,l_header_rec.lead_source_code
           ,l_header_rec.description
           ,l_header_rec.source_promotion_id
           ,l_header_rec.customer_id
           ,l_header_rec.address_id
           ,l_header_rec.sales_stage_id
           ,l_header_rec.win_probability
           ,l_header_rec.status_code
           -- ,l_header_rec.initiating_contact_id
           -- ,l_header_rec.rank
           ,l_header_rec.channel_code
           ,l_header_rec.decision_date
           ,l_header_rec.currency_code
           ,l_header_rec.price_list_id
           ,l_header_rec.close_reason_code
           -- ,l_header_rec.close_competitor_code
           ,l_header_rec.close_competitor_id
           ,l_header_rec.close_competitor
           ,l_header_rec.close_comment
           ,l_header_rec.end_user_customer_id
           ,l_header_rec.end_user_customer_name
           ,l_header_rec.end_user_address_id
           ,l_header_rec.total_amount
           ,l_header_rec.attribute_category
           ,l_header_rec.attribute1
           ,l_header_rec.attribute2
           ,l_header_rec.attribute3
           ,l_header_rec.attribute4
           ,l_header_rec.attribute5
           ,l_header_rec.attribute6
           ,l_header_rec.attribute7
           ,l_header_rec.attribute8
           ,l_header_rec.attribute9
           ,l_header_rec.attribute10
           ,l_header_rec.attribute11
           ,l_header_rec.attribute12
           ,l_header_rec.attribute13
           ,l_header_rec.attribute14
           ,l_header_rec.attribute15
           ,l_header_rec.parent_project;
           -- ,l_opp_security_group_id;

      IF ( C_Get_Opportunity%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'Opportunity', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           --commented for bug 2013040 raise FND_API.G_EXC_ERROR;
           x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Close Cursor C_Get_Opportunity');
      END IF;
      Close C_Get_Opportunity;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke validation procedures
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Validate_sales_lead_id');
      END IF;

      -- Validate sales lead id whther it is a valid ID.
      AS_SALES_LEADS_PVT.Validate_Sales_Lead_Id (
              P_Init_Msg_List              => FND_API.G_FALSE
             ,P_Validation_mode            => FND_API.G_MISS_CHAR
             ,P_Sales_Lead_Id              => P_Sales_Lead_Id
             ,X_Return_Status              => X_Return_Status
             ,X_Msg_Count                  => X_Msg_Count
             ,X_Msg_Data                   => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- Validate one sales lead can only be link to one opportunity
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Validate existing link');
      END IF;

/*
      OPEN  C_Lead_Link_Exists (P_SALES_LEAD_ID, P_OPPORTUNITY_ID);
      FETCH C_Lead_Link_Exists into l_val;

      IF l_val IS NOT NULL
      THEN
		-- ffang 020301, we want the error message in every case, don't need
          -- to check message level.
          -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          -- THEN
              -- ffang 100900: For bug 1448995
              -- Use error message #45661 instead of API_INVALID_ID
              FND_MESSAGE.Set_Name('AS', 'API_DUPLICATE_LINK');
              FND_MESSAGE.Set_Token('SLD_ID', p_sales_lead_id, FALSE);
              -- end ffang 100900
              FND_MSG_PUB.ADD;
          -- END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      CLOSE C_Lead_Link_Exists;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;
*/

      l_Sales_Lead_Rec.Status_Code      := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'CONVERTED_TO_OPPORTUNITY');
      -- has to be changed once the profile problem is solved
      --l_Sales_Lead_Rec.Status_Code      := 'QUALIFIED';


      -- Validate if the sales lead owner is the opportunity team leader
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Validate sales lead owner');
      END IF;

/*
-- axavier commented this. This check is not required, as the as_sales_leads salesforce_id is not updated
      OPEN  C_Sales_Owner_Check (l_Sales_Lead_Rec.assign_to_salesforce_id,
                                 P_Opportunity_Id,'Y');
      FETCH C_Sales_Owner_Check INTO l_val_id;

      IF C_Sales_Owner_Check%NOTFOUND
      THEN
          OPEN   C_Get_Sales_Owner (P_Opportunity_Id);
          FETCH  C_Get_Sales_Owner INTO l_val_id;

          IF C_Get_Sales_Owner%NOTFOUND
          THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                  -- ffang 100900: For bug 1448995
                  -- Use error message #45662 instead of API_INVALID_ID
                  FND_MESSAGE.Set_Name('AS', 'API_INVALID_OPP');
                  FND_MESSAGE.Set_Token('OPP_ID', P_Opportunity_Id, FALSE);
                  -- end ffang 100900
                  FND_MSG_PUB.ADD;
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_Get_Sales_Owner;

          -- ffang 020301, we don't want to update Assign_To_salesforce_id
          -- to be the team leader's salesforce_id
          -- l_Sales_Lead_Rec.Assign_To_salesforce_id := l_val_id;
      END IF;

      CLOSE C_Sales_Owner_Check;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;
*/
      l_header_rec.updateable_flag        :=  'N';
      l_header_rec.member_access          :=  FND_API.G_MISS_CHAR;
      l_header_rec.member_role            :=  FND_API.G_MISS_CHAR;

      l_cnt := 0;
--      For C_Sales_Lead_lines_Rec In C_Get_Sales_lead_lines(P_Sales_Lead_Id)
      for i in 1 .. P_SALES_LEAD_LINE_TBL.count
      Loop
          l_cnt := l_cnt + 1;
          l_sales_lead_line_tbl(l_cnt).sales_lead_line_id
                           := P_SALES_LEAD_LINE_TBL(i).sales_lead_line_id;

          l_line_tbl(l_cnt).last_update_date
                           := P_SALES_LEAD_LINE_TBL(i).last_update_date;
          l_line_tbl(l_cnt).last_updated_by
                           := P_SALES_LEAD_LINE_TBL(i).last_updated_by;
          l_line_tbl(l_cnt).creation_Date
                           := P_SALES_LEAD_LINE_TBL(i).creation_Date;
          l_line_tbl(l_cnt).created_by
                           := P_SALES_LEAD_LINE_TBL(i).created_by;
          l_line_tbl(l_cnt).last_update_login
                           := P_SALES_LEAD_LINE_TBL(i).last_update_login;
          -- ffang 101200 for bug 1449308
          -- Should not use sales_lead_line_id as lead_line_id to create an
          -- opportunity line.
          /*
          l_line_tbl(l_cnt).lead_line_id
                           := P_SALES_LEAD_LINE_TBL(i).sales_lead_line_id;
          */
          l_line_tbl(l_cnt).lead_line_id := NULL;
          -- end ffang 101200
          l_line_tbl(l_cnt).lead_id := p_opportunity_id;
          -- 103000 FFANG as_lead_lines_all.status_code has been obsolete
          -- l_line_tbl(l_cnt).status_code       := 'PRELIMINARY';
          -- end 103000 FFANG
          /* Commented by gbatra for product hierarchy uptake
          l_line_tbl(l_cnt).interest_type_id
                           := P_SALES_LEAD_LINE_TBL(i).interest_type_id;
          l_line_tbl(l_cnt).primary_interest_code_id
                           := P_SALES_LEAD_LINE_TBL(i).primary_interest_code_id;
          l_line_tbl(l_cnt).secondary_interest_code_id
                           := P_SALES_LEAD_LINE_TBL(i).secondary_interest_code_id;
          */

          -- l_line_tbl(l_cnt).interest_status_code  -- obsolete
          l_line_tbl(l_cnt).inventory_item_id
                           := P_SALES_LEAD_LINE_TBL(i).inventory_item_id;
          l_line_tbl(l_cnt).organization_id
                           := P_SALES_LEAD_LINE_TBL(i).organization_id;
          l_line_tbl(l_cnt).uom_code
                           := P_SALES_LEAD_LINE_TBL(i).uom_code;
          l_line_tbl(l_cnt).quantity
                           := P_SALES_LEAD_LINE_TBL(i).quantity;
          l_line_tbl(l_cnt).total_amount
                           := P_SALES_LEAD_LINE_TBL(i).budget_amount;
          -- l_line_tbl(l_cnt).sales_stage_id  -- obsolete
          -- l_line_tbl(l_cnt).ship_date       -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).win_probability -- obsolete
          -- l_line_tbl(l_cnt).decision_date   -- obsolete
          -- 103000 FFANG as_lead_lines_all.channel_code has been obsolete
          -- l_line_tbl(l_cnt).channel_code  := l_header_rec.channel_code;
          -- end 103000 FFANG
          -- l_line_tbl(l_cnt).quoted_line_flag -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).original_lead_line_id -- not exist in sl lines
          -- l_line_tbl(l_cnt).org_id          -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).price           -- not exist in sales lead lines
          -- 103000 FFANG for bug 1479671
          l_line_tbl(l_cnt).source_promotion_id
                                := P_SALES_LEAD_LINE_TBL(i).source_promotion_id;
          --end 103000 FFANG
          -- l_line_tbl(l_cnt).price_volume_margin -- not exist in sl lines

          l_line_tbl(l_cnt).attribute_category
                           := P_SALES_LEAD_LINE_TBL(i).attribute_category;
          l_line_tbl(l_cnt).attribute1  := P_SALES_LEAD_LINE_TBL(i).attribute1;
          l_line_tbl(l_cnt).attribute2  := P_SALES_LEAD_LINE_TBL(i).attribute2;
          l_line_tbl(l_cnt).attribute3  := P_SALES_LEAD_LINE_TBL(i).attribute3;
          l_line_tbl(l_cnt).attribute4  := P_SALES_LEAD_LINE_TBL(i).attribute4;
          l_line_tbl(l_cnt).attribute5  := P_SALES_LEAD_LINE_TBL(i).attribute5;
          l_line_tbl(l_cnt).attribute6  := P_SALES_LEAD_LINE_TBL(i).attribute6;
          l_line_tbl(l_cnt).attribute7  := P_SALES_LEAD_LINE_TBL(i).attribute7;
          l_line_tbl(l_cnt).attribute8  := P_SALES_LEAD_LINE_TBL(i).attribute8;
          l_line_tbl(l_cnt).attribute9  := P_SALES_LEAD_LINE_TBL(i).attribute9;
          l_line_tbl(l_cnt).attribute10 := P_SALES_LEAD_LINE_TBL(i).attribute10;
          l_line_tbl(l_cnt).attribute11 := P_SALES_LEAD_LINE_TBL(i).attribute11;
          l_line_tbl(l_cnt).attribute12 := P_SALES_LEAD_LINE_TBL(i).attribute12;
          l_line_tbl(l_cnt).attribute13 := P_SALES_LEAD_LINE_TBL(i).attribute13;
          l_line_tbl(l_cnt).attribute14 := P_SALES_LEAD_LINE_TBL(i).attribute14;
          l_line_tbl(l_cnt).attribute15 := P_SALES_LEAD_LINE_TBL(i).attribute15;
          l_line_tbl(l_cnt).member_access := FND_API.G_MISS_CHAR;
          l_line_tbl(l_cnt).member_role   := FND_API.G_MISS_CHAR;
	     l_line_tbl(l_cnt).owner_scredit_percent := FND_API.G_MISS_NUM;
          -- l_line_security_group_id
          --                   := P_SALES_LEAD_LINE_TBL(i).security_group_id;
          -- 103000 FFANG for bug 1479671
          l_line_tbl(l_cnt).offer_id :=  P_SALES_LEAD_LINE_TBL(i).offer_id;
          -- end 103000 FFANG
          l_line_tbl(l_cnt).product_category_id :=  P_SALES_LEAD_LINE_TBL(i).category_id;
          l_line_tbl(l_cnt).product_cat_set_id :=  P_SALES_LEAD_LINE_TBL(i).category_set_id;

      END Loop;

      IF l_line_tbl.count > 0
      THEN
          -- ffang 030503, bug 2826512, call PUB instead of PVT
          -- AS_OPP_line_PVT.Create_opp_lines (
          AS_OPPORTUNITY_PUB.Create_Opp_Lines (
              p_api_version_number => 2.0,
              p_init_msg_list => FND_API.G_FALSE,
              p_commit => FND_API.G_FALSE, -- ffang020100
              -- p_commit => FND_API.G_TRUE,
              p_validation_level => p_validation_level,
              -- ffang 012501, When adding a opportunity line, enforce security
              -- checking
              P_Check_Access_Flag => 'Y',        -- P_Check_Access_Flag,
              -- P_Check_Access_Flag => FND_API.G_FALSE,
              P_Admin_Flag => P_Admin_Flag,     -- FND_API.G_FALSE,
              P_Admin_Group_Id => P_Admin_Group_Id,     -- NULL,
              P_Identity_Salesforce_Id =>  p_identity_salesforce_id,
                              -- l_Sales_Lead_Rec.assign_to_salesforce_id,
              P_salesgroup_id => P_identity_salesgroup_id,
              P_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
              P_Partner_Cont_Party_id => null,
              P_line_tbl => l_line_tbl,
              P_Header_Rec => l_header_rec,
              X_LINE_OUT_TBL => l_line_out_tbl,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          For l_index In 1..l_line_out_tbl.count Loop
              -- ffang 101200 for bug 1449308
              -- l_Lead_Opp_Line_Id should be initialized.
              l_Lead_Opp_Line_Id := NULL;
              -- end ffang 101200

              AS_SALES_LEAD_OPP_PKG.Lead_Opp_Lines_Insert_Row (
                  px_LEAD_OPP_LINE_ID   => l_Lead_Opp_Line_Id
                 ,p_SALES_LEAD_LINE_ID  =>
                            l_sales_lead_line_tbl(l_index).sales_lead_line_id
                 ,p_OPP_LINE_ID         => l_line_out_tbl(l_index).lead_line_id
                 ,p_LAST_UPDATE_DATE    => SYSDATE
                 ,p_LAST_UPDATED_BY     => FND_GLOBAL.User_Id
                 ,p_CREATION_DATE       => SYSDATE
                 ,p_CREATED_BY          => FND_GLOBAL.User_Id
                 ,p_LAST_UPDATE_LOGIN   => FND_GLOBAL.Conc_Login_Id
                 ,p_REQUEST_ID          => FND_GLOBAL.Conc_Request_Id
                 ,p_PROGRAM_APPLICATION_ID => FND_GLOBAL.Prog_Appl_Id
                 ,p_PROGRAM_ID          => FND_GLOBAL.Conc_Program_Id
                 ,p_PROGRAM_UPDATE_DATE => SYSDATE
                 ,p_ATTRIBUTE_CATEGORY => l_line_tbl(l_index).attribute_category
                 ,p_ATTRIBUTE1          => l_line_tbl(l_index).attribute1
                 ,p_ATTRIBUTE2          => l_line_tbl(l_index).attribute2
                 ,p_ATTRIBUTE3          => l_line_tbl(l_index).attribute3
                 ,p_ATTRIBUTE4          => l_line_tbl(l_index).attribute4
                 ,p_ATTRIBUTE5          => l_line_tbl(l_index).attribute5
                 ,p_ATTRIBUTE6          => l_line_tbl(l_index).attribute6
                 ,p_ATTRIBUTE7          => l_line_tbl(l_index).attribute7
                 ,p_ATTRIBUTE8          => l_line_tbl(l_index).attribute8
                 ,p_ATTRIBUTE9          => l_line_tbl(l_index).attribute9
                 ,p_ATTRIBUTE10         => l_line_tbl(l_index).attribute10
                 ,p_ATTRIBUTE11         => l_line_tbl(l_index).attribute11
                 ,p_ATTRIBUTE12         => l_line_tbl(l_index).attribute12
                 ,p_ATTRIBUTE13         => l_line_tbl(l_index).attribute13
                 ,p_ATTRIBUTE14         => l_line_tbl(l_index).attribute14
                 ,p_ATTRIBUTE15         => l_line_tbl(l_index).attribute15
                 -- ,p_SECURITY_GROUP_ID   => l_line_security_group_id
               );
          END Loop;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      -- 102700 FFANG for bug 1478517, copy sales lead contacts information to
      -- opportunity contact table

      -- Copy sales lead contacts data to opportunity record contacts
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Copy sales lead contacts data to opp');
      END IF;
      l_cnt := 0;
/*
      For C_SL_Contacts_Rec In C_Get_Sales_lead_Contacts(P_Sales_Lead_Id) Loop

          -- ffang 020601, for bug 1628894, check if contact_party_id already
          -- existed in as_lead_contacts_all, if not then copy values.
          OPEN c_check_dup_contact (C_SL_Contacts_Rec.contact_party_id);
          FETCH  c_check_dup_contact INTO l_dup_contact;

          IF c_check_dup_contact%NOTFOUND THEN
              l_cnt := l_cnt + 1;

              l_contact_tbl(l_cnt).lead_id           := p_opportunity_id;
              l_contact_tbl(l_cnt).contact_id  := C_SL_Contacts_Rec.contact_id;
              l_contact_tbl(l_cnt).contact_party_id
                                      := C_SL_Contacts_Rec.contact_party_id;
              l_contact_tbl(l_cnt).last_update_date  := SYSDATE;
              l_contact_tbl(l_cnt).last_updated_by   := FND_GLOBAL.USER_ID;
              l_contact_tbl(l_cnt).creation_Date     := SYSDATE;
              l_contact_tbl(l_cnt).created_by        := FND_GLOBAL.USER_ID;
              l_contact_tbl(l_cnt).last_update_login :=FND_GLOBAL.CONC_LOGIN_ID;
              l_contact_tbl(l_cnt).enabled_flag:=C_SL_Contacts_Rec.enabled_flag;
              l_contact_tbl(l_cnt).customer_id := C_SL_Contacts_Rec.customer_id;
              l_contact_tbl(l_cnt).address_id := C_SL_Contacts_Rec.address_id;
              l_contact_tbl(l_cnt).phone_id   := C_SL_Contacts_Rec.phone_id;
              -- ffang 041802, for bug 2251391, opp contact role stores in rank
              l_contact_tbl(l_cnt).rank := C_SL_Contacts_Rec.contact_role_code;
              -- end ffang 041802
              l_contact_tbl(l_cnt).primary_contact_flag
                              := C_SL_Contacts_Rec.primary_contact_flag;
              l_contact_tbl(l_cnt).role := C_SL_Contacts_Rec.contact_role_code;
              l_contact_tbl(l_cnt).attribute_category
                              := C_SL_Contacts_Rec.attribute_category;
              l_contact_tbl(l_cnt).attribute1 := C_SL_Contacts_Rec.attribute1;
              l_contact_tbl(l_cnt).attribute2 := C_SL_Contacts_Rec.attribute2;
              l_contact_tbl(l_cnt).attribute3 := C_SL_Contacts_Rec.attribute3;
              l_contact_tbl(l_cnt).attribute4 := C_SL_Contacts_Rec.attribute4;
              l_contact_tbl(l_cnt).attribute5 := C_SL_Contacts_Rec.attribute5;
              l_contact_tbl(l_cnt).attribute6 := C_SL_Contacts_Rec.attribute6;
              l_contact_tbl(l_cnt).attribute7 := C_SL_Contacts_Rec.attribute7;
              l_contact_tbl(l_cnt).attribute8 := C_SL_Contacts_Rec.attribute8;
              l_contact_tbl(l_cnt).attribute9 := C_SL_Contacts_Rec.attribute9;
              l_contact_tbl(l_cnt).attribute10 := C_SL_Contacts_Rec.attribute10;
              l_contact_tbl(l_cnt).attribute11 := C_SL_Contacts_Rec.attribute11;
              l_contact_tbl(l_cnt).attribute12 := C_SL_Contacts_Rec.attribute12;
              l_contact_tbl(l_cnt).attribute13 := C_SL_Contacts_Rec.attribute13;
              l_contact_tbl(l_cnt).attribute14 := C_SL_Contacts_Rec.attribute14;
              l_contact_tbl(l_cnt).attribute15 := C_SL_Contacts_Rec.attribute15;
              -- l_contact_tbl(l_cnt).security_group_id
              --                 := C_SL_Contacts_Rec.security_group_id;
          END IF;

          CLOSE c_check_dup_contact;
      END Loop;

      IF l_contact_tbl.count > 0
      THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(NULL, 'Calling AS_OPP_CONTACT_PVT.Create_Opp_contacts');
        END IF;

          -- ffang 030503, bug 2826512, call PUB instead of PVT
          -- AS_OPP_CONTACT_PVT.Create_opp_contacts (
          AS_OPPORTUNITY_PUB.Create_Contacts (
              p_api_version_number => 2.0,
              p_init_msg_list => FND_API.G_FALSE,
              p_commit => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              -- ffang 012501, When adding a opportunity contact, enforce
              -- security checking
              P_Check_Access_Flag => 'Y',     -- p_check_access_flag,
              -- P_Check_Access_Flag => FND_API.G_FALSE,
              P_Admin_Flag => p_admin_flag,
              -- P_Admin_Flag => FND_API.G_FALSE, -- p_admin_flag,
              P_Admin_Group_Id => P_Admin_Group_Id,
              P_Identity_Salesforce_Id => p_identity_salesforce_id,
              P_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
              P_Partner_Cont_Party_id => null,
              P_contact_tbl => l_contact_tbl,
              X_contact_OUT_TBL => l_contact_out_tbl,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          -- end 102700 FFANG
      END IF;
*/
      -- Update Sales Leads for Status Code and Sales lead owner IF needed
      -- ffang 030503, bug 2826512, call PUB instead of PVT
      -- AS_SALES_LEADS_PVT.Update_sales_lead(
      AS_SALES_LEADS_PUB.Update_sales_lead(
         P_Api_Version_Number     => l_api_version_number,
         P_Init_Msg_List          => FND_API.G_FALSE,
         P_Commit                 => FND_API.G_FALSE,
         P_Validation_Level       => P_Validation_Level,
         P_Check_Access_Flag      => 'Y',   -- P_Check_Access_Flag,
         P_Admin_Flag             => P_Admin_Flag,
         P_Admin_Group_Id         => P_Admin_Group_Id,
         P_identity_salesforce_id => P_identity_salesforce_id,
         P_Sales_Lead_Profile_Tbl => P_Sales_Lead_Profile_Tbl,
         P_SALES_LEAD_Rec         => l_Sales_Lead_Rec,
         X_Return_Status          => X_Return_Status,
         X_Msg_Count              => X_Msg_Count,
         X_Msg_Data               => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;


      OPEN  C_Lead_Link_Exists (P_SALES_LEAD_ID, P_OPPORTUNITY_ID);
      FETCH C_Lead_Link_Exists into l_val;

      IF l_val IS NOT NULL
      THEN
          -- Francis. May be we want to update the record wtth the update date
          NULL;
      ELSE
          -- ffang 071202, bug 2451983
          l_Lead_Opportunity_Id := NULL;
          -- end ffang 071202, bug 2451983

          -- Insert Interaction Data for linking Sales Lead to Opportunity
          AS_SALES_LEAD_OPP_PKG.Lead_Opportunity_Insert_Row (
              px_LEAD_OPPORTUNITY_ID    => l_Lead_Opportunity_Id
             ,p_SALES_LEAD_ID           => P_Sales_Lead_Id
             ,p_OPPORTUNITY_ID          => P_Opportunity_Id
             ,p_LAST_UPDATE_DATE        => SYSDATE
             ,p_LAST_UPDATED_BY         => FND_GLOBAL.User_Id
             ,p_CREATION_DATE           => SYSDATE
             ,p_CREATED_BY              => FND_GLOBAL.User_Id
             ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.Conc_Login_Id
             ,p_REQUEST_ID              => FND_GLOBAL.Conc_Request_Id
             ,p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id
             ,p_PROGRAM_ID              => FND_GLOBAL.Conc_Program_Id
             ,p_PROGRAM_UPDATE_DATE     => SYSDATE
             ,p_ATTRIBUTE_CATEGORY      => l_header_rec.attribute_category
             ,p_ATTRIBUTE1              => l_header_rec.attribute1
             ,p_ATTRIBUTE2              => l_header_rec.attribute2
             ,p_ATTRIBUTE3              => l_header_rec.attribute3
             ,p_ATTRIBUTE4              => l_header_rec.attribute4
             ,p_ATTRIBUTE5              => l_header_rec.attribute5
             ,p_ATTRIBUTE6              => l_header_rec.attribute6
             ,p_ATTRIBUTE7              => l_header_rec.attribute7
             ,p_ATTRIBUTE8              => l_header_rec.attribute8
             ,p_ATTRIBUTE9              => l_header_rec.attribute9
             ,p_ATTRIBUTE10             => l_header_rec.attribute10
             ,p_ATTRIBUTE11             => l_header_rec.attribute11
             ,p_ATTRIBUTE12             => l_header_rec.attribute12
             ,p_ATTRIBUTE13             => l_header_rec.attribute13
             ,p_ATTRIBUTE14             => l_header_rec.attribute14
             ,p_ATTRIBUTE15             => l_header_rec.attribute15
             -- ,p_SECURITY_GROUP_ID       => l_opp_security_group_id
          );
      END IF;

      CLOSE C_Lead_Link_Exists;

       Create_Lead_Ctx(
          P_SALES_LEAD_ID,
          P_OPPORTUNITY_ID,
          X_Return_Status
       );

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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
END Copy_Lead_To_Opportunity;

--   API Name:  Link_Lead_To_Opportunity
/* API added by Francis on 06/26/2001 */

PROCEDURE Link_Lead_To_Opportunity(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag               IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id           IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id   IN   NUMBER,     --:= NULL,
    P_identity_salesgroup_id	 IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl   IN   AS_UTILITY_PUB.Profile_Tbl_Type
                              := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID            IN   NUMBER,
    P_OPPORTUNITY_ID           IN   NUMBER,
    X_Return_Status            OUT NOCOPY VARCHAR2,
    X_Msg_Count                OUT NOCOPY NUMBER,
    X_Msg_Data                 OUT NOCOPY VARCHAR2
    )
 IS

--NULL;

    CURSOR C_lead_link_Exists (X_Sales_Lead_Id NUMBER, X_Opportunity_Id NUMBER) IS
      SELECT 'X'
      FROM as_sales_lead_opportunity
      WHERE sales_lead_id = X_Sales_Lead_Id
            AND opportunity_id = X_Opportunity_Id;


    CURSOR C_Sales_Owner_Check (X_Identity_Salesforce_Id NUMBER,
                                X_Opportunity_Id NUMBER,
                                X_Team_Leader_Flag VARCHAR2) IS
      SELECT salesforce_id
      FROM as_accesses_all
      WHERE salesforce_id = X_Identity_Salesforce_Id
            AND lead_id = X_Opportunity_Id
            AND team_leader_flag = X_Team_Leader_Flag;

    CURSOR C_Get_Sales_Owner (X_Opportunity_Id NUMBER) IS
      SELECT salesforce_id
      FROM as_accesses_all
      WHERE lead_id = X_Opportunity_Id
            AND team_leader_flag = 'Y';


    CURSOR C_Get_Sales_Lead (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login
             ,request_id
             ,program_application_id
             ,program_id
             ,program_update_date
             ,lead_number
             ,status_code
             ,customer_id
             ,address_id
             ,source_promotion_id
             ,initiating_contact_id
             ,orig_system_reference
             ,contact_role_code
             ,channel_code
             ,budget_amount
             ,currency_code
             ,decision_timeframe_code
             ,close_reason
             ,lead_rank_code
             ,parent_project
             ,description
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,assign_to_person_id
             ,assign_to_salesforce_id
             ,budget_status_code
             ,assign_date
             ,accept_flag
             ,vehicle_response_code
             ,total_score
             ,scorecard_id
             ,keep_flag
             ,urgent_flag
             ,import_flag
             ,reject_reason_code
             ,lead_rank_id
             ,deleted_flag
             ,assign_sales_group_id
             ,offer_id
             -- ,security_group_id
             ,incumbent_partner_party_id
             ,incumbent_partner_resource_id
      FROM as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

    CURSOR C_Get_Opportunity (x_Opportunity_Id NUMBER) IS
      SELECT last_update_date
             ,last_updated_by
             ,creation_Date
             ,created_by
             ,last_update_login
             ,lead_id
             ,lead_number
             ,orig_system_reference
             ,lead_source_code
             ,description
             ,source_promotion_id
             ,customer_id
             ,address_id
             ,sales_stage_id
             ,win_probability
             ,status status_code
             -- ,initiating_contact_id
             -- ,rank
             ,channel_code
             ,decision_date
             ,currency_code
             ,price_list_id
             ,close_reason close_reason_code
             -- ,close_competitor_code
             ,close_competitor_id
             ,close_competitor
             ,close_comment
             ,end_user_customer_id
             ,end_user_customer_name
             ,end_user_address_id
             ,total_amount
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,parent_project
             -- ,FND_API.G_MISS_NUM  --   ,security_group_id
      From AS_LEADS_ALL
      Where lead_id = X_Opportunity_Id;

    l_api_name            CONSTANT VARCHAR2(30) := 'Link_Lead_To_Opportunity';
    l_api_version_number  CONSTANT NUMBER   := 2.0;
    l_Identity_Sales_Member_Rec  AS_SALES_MEMBER_PUB.Sales_Member_Rec_Type;
    l_Sales_Lead_Rec             AS_SALES_LEADS_PUB.Sales_Lead_Rec_Type;
--    l_sales_lead_line_tbl        AS_SALES_LEADS_PUB.Sales_Lead_Line_Tbl_Type;
    l_header_rec                 AS_OPPORTUNITY_PUB.Header_Rec_Type;
--    l_line_tbl                   AS_OPPORTUNITY_PUB.Line_Tbl_Type;
--    l_line_out_tbl               AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;
--    l_contact_tbl                AS_OPPORTUNITY_PUB.Contact_Tbl_Type;
--    l_contact_out_tbl            AS_OPPORTUNITY_PUB.Contact_Out_Tbl_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_val                        VARCHAR2(1) default null;
--axavier    l_val_id                     NUMBER;
--    l_lead_line_id               NUMBER;
    l_last_update_date           DATE := FND_API.G_MISS_DATE;
    l_channel_code               VARCHAR2(30);
    l_Lead_Opportunity_Id        NUMBER;
--    l_Lead_Opp_Line_Id           NUMBER;
--    l_sales_lead_line_id         NUMBER default null;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);
--    l_cnt                        NUMBER := 0;
    l_debug  BOOLEAN;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.slopv.Link_Lead_To_Opportunity';

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT LINK_LEAD_TO_OPPORTUNITY_PVT;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT:' || l_api_name || ' Start');
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
                  p_module        => l_module,
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get sales lead header based on parameter P_Sales_Lead_Id
      OPEN  C_Get_Sales_Lead (P_Sales_Lead_Id);
      FETCH C_Get_Sales_Lead INTO
            l_Sales_Lead_Rec.sales_lead_id
           ,l_Sales_Lead_Rec.last_update_date
           ,l_Sales_Lead_Rec.last_updated_by
           ,l_Sales_Lead_Rec.creation_date
           ,l_Sales_Lead_Rec.created_by
           ,l_Sales_Lead_Rec.last_update_login
           ,l_Sales_Lead_Rec.request_id
           ,l_Sales_Lead_Rec.program_application_id
           ,l_Sales_Lead_Rec.program_id
           ,l_Sales_Lead_Rec.program_update_date
           ,l_Sales_Lead_Rec.lead_number
           ,l_Sales_Lead_Rec.status_code
           ,l_Sales_Lead_Rec.customer_id
           ,l_Sales_Lead_Rec.address_id
           ,l_Sales_Lead_Rec.source_promotion_id
           ,l_Sales_Lead_Rec.initiating_contact_id
           ,l_Sales_Lead_Rec.orig_system_reference
           ,l_Sales_Lead_Rec.contact_role_code
           ,l_Sales_Lead_Rec.channel_code
           ,l_Sales_Lead_Rec.budget_amount
           ,l_Sales_Lead_Rec.currency_code
           ,l_Sales_Lead_Rec.decision_timeframe_code
           ,l_Sales_Lead_Rec.close_reason
           ,l_Sales_Lead_Rec.lead_rank_code
           ,l_Sales_Lead_Rec.parent_project
           ,l_Sales_Lead_Rec.description
           ,l_Sales_Lead_Rec.attribute_category
           ,l_Sales_Lead_Rec.attribute1
           ,l_Sales_Lead_Rec.attribute2
           ,l_Sales_Lead_Rec.attribute3
           ,l_Sales_Lead_Rec.attribute4
           ,l_Sales_Lead_Rec.attribute5
           ,l_Sales_Lead_Rec.attribute6
           ,l_Sales_Lead_Rec.attribute7
           ,l_Sales_Lead_Rec.attribute8
           ,l_Sales_Lead_Rec.attribute9
           ,l_Sales_Lead_Rec.attribute10
           ,l_Sales_Lead_Rec.attribute11
           ,l_Sales_Lead_Rec.attribute12
           ,l_Sales_Lead_Rec.attribute13
           ,l_Sales_Lead_Rec.attribute14
           ,l_Sales_Lead_Rec.attribute15
           ,l_Sales_Lead_Rec.assign_to_person_id
           ,l_Sales_Lead_Rec.assign_to_salesforce_id
           ,l_Sales_Lead_Rec.budget_status_code
           ,l_Sales_Lead_Rec.assign_date
           ,l_Sales_Lead_Rec.accept_flag
           ,l_Sales_Lead_Rec.vehicle_response_code
           ,l_Sales_Lead_Rec.total_score
           ,l_Sales_Lead_Rec.scorecard_id
           ,l_Sales_Lead_Rec.keep_flag
           ,l_Sales_Lead_Rec.urgent_flag
           ,l_Sales_Lead_Rec.import_flag
           ,l_Sales_Lead_Rec.reject_reason_code
           ,l_Sales_Lead_Rec.lead_rank_id
           ,l_Sales_Lead_Rec.deleted_flag
           ,l_Sales_Lead_Rec.assign_sales_group_id
           ,l_Sales_Lead_Rec.offer_id
           -- ,l_Sales_Lead_Rec.security_group_id
           ,l_Sales_Lead_Rec.incumbent_partner_party_id
           ,l_Sales_Lead_Rec.incumbent_partner_resource_id;

      IF ( C_Get_Sales_Lead%NOTFOUND) THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Private API: SALES_LEAD_ID is invalid');
        END IF;

        AS_UTILITY_PVT.Set_Message(
            p_module        => l_module,
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'SALES_LEAD_ID',
            p_token2        => 'VALUE',
            p_token2_value  =>  P_Sales_Lead_Id );

        x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      CLOSE C_Get_Sales_Lead;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;




      -- Get opportunity header based on parameter P_Opportunity_Id
      OPEN  C_Get_Opportunity (P_Opportunity_Id);
      FETCH C_Get_Opportunity  INTO
            l_header_rec.last_update_date
           ,l_header_rec.last_updated_by
           ,l_header_rec.creation_Date
           ,l_header_rec.created_by
           ,l_header_rec.last_update_login
           ,l_header_rec.lead_id
           ,l_header_rec.lead_number
           ,l_header_rec.orig_system_reference
           ,l_header_rec.lead_source_code
           ,l_header_rec.description
           ,l_header_rec.source_promotion_id
           ,l_header_rec.customer_id
           ,l_header_rec.address_id
           ,l_header_rec.sales_stage_id
           ,l_header_rec.win_probability
           ,l_header_rec.status_code
           -- ,l_header_rec.initiating_contact_id
           -- ,l_header_rec.rank
           ,l_header_rec.channel_code
           ,l_header_rec.decision_date
           ,l_header_rec.currency_code
           ,l_header_rec.price_list_id
           ,l_header_rec.close_reason_code
           -- ,l_header_rec.close_competitor_code
           ,l_header_rec.close_competitor_id
           ,l_header_rec.close_competitor
           ,l_header_rec.close_comment
           ,l_header_rec.end_user_customer_id
           ,l_header_rec.end_user_customer_name
           ,l_header_rec.end_user_address_id
           ,l_header_rec.total_amount
           ,l_header_rec.attribute_category
           ,l_header_rec.attribute1
           ,l_header_rec.attribute2
           ,l_header_rec.attribute3
           ,l_header_rec.attribute4
           ,l_header_rec.attribute5
           ,l_header_rec.attribute6
           ,l_header_rec.attribute7
           ,l_header_rec.attribute8
           ,l_header_rec.attribute9
           ,l_header_rec.attribute10
           ,l_header_rec.attribute11
           ,l_header_rec.attribute12
           ,l_header_rec.attribute13
           ,l_header_rec.attribute14
           ,l_header_rec.attribute15
           ,l_header_rec.parent_project;
           -- ,l_opp_security_group_id;

      IF ( C_Get_Opportunity%NOTFOUND) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
           FND_MESSAGE.Set_Token ('INFO', 'Opportunity', FALSE);
           FND_MSG_PUB.Add;
        END IF;
        -- commented by axavier for bug 2013040 raise FND_API.G_EXC_ERROR;
        x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;
      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Close Cursor C_Get_Opportunity');
      END IF;
      Close C_Get_Opportunity;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke validation procedures
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Validate_sales_lead_id');
      END IF;

      -- Validate sales lead id whther it is a valid ID.
      AS_SALES_LEADS_PVT.Validate_Sales_Lead_Id (
              P_Init_Msg_List              => FND_API.G_FALSE
             ,P_Validation_mode            => FND_API.G_MISS_CHAR
             ,P_Sales_Lead_Id              => P_Sales_Lead_Id
             ,X_Return_Status              => X_Return_Status
             ,X_Msg_Count                  => X_Msg_Count
             ,X_Msg_Data                   => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- Validate one sales lead can only be link to one opportunity
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Validate existing link');
      END IF;

      OPEN  C_Lead_Link_Exists (P_SALES_LEAD_ID , P_OPPORTUNITY_ID);
      FETCH C_Lead_Link_Exists into l_val;

      IF l_val IS NOT NULL
      THEN
		-- ffang 020301, we want the error message in every case, don't need
          -- to check message level.
          -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          -- THEN
              -- ffang 100900: For bug 1448995
              -- Use error message #45661 instead of API_INVALID_ID
              FND_MESSAGE.Set_Name('AS', 'API_DUPLICATE_LINK');
              FND_MESSAGE.Set_Token('SLD_ID', p_sales_lead_id, FALSE);
              FND_MESSAGE.Set_Token('OPP_ID', p_opportunity_id, FALSE);
              -- end ffang 100900
              FND_MSG_PUB.ADD;
          -- END IF;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      CLOSE C_Lead_Link_Exists;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      l_Sales_Lead_Rec.Status_Code      := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'CONVERTED_TO_OPPORTUNITY');
      -- has to be changed once the profile problem is solved
      --l_Sales_Lead_Rec.Status_Code      := 'QUALIFIED';

      -- Validate if the sales lead owner is the opportunity team leader
      -- Debug message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Validate sales lead owner');
      END IF;
/*
-- axavier commented this. This check is not required, as the as_sales_leads salesforce_id is not updated

      OPEN  C_Sales_Owner_Check (l_Sales_Lead_Rec.assign_to_salesforce_id,
                                 P_Opportunity_Id,'Y');
      FETCH C_Sales_Owner_Check INTO l_val_id;

      IF C_Sales_Owner_Check%NOTFOUND
      THEN
          OPEN   C_Get_Sales_Owner (P_Opportunity_Id);
          FETCH  C_Get_Sales_Owner INTO l_val_id;

          IF C_Get_Sales_Owner%NOTFOUND
          THEN
              IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
              THEN
                  -- ffang 100900: For bug 1448995
                  -- Use error message #45662 instead of API_INVALID_ID
                  FND_MESSAGE.Set_Name('AS', 'API_INVALID_OPP');
                  FND_MESSAGE.Set_Token('OPP_ID', P_Opportunity_Id, FALSE);
                  -- end ffang 100900
                  FND_MSG_PUB.ADD;
              END IF;

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_Get_Sales_Owner;

          -- ffang 020301, we don't want to update Assign_To_salesforce_id
          -- to be the team leader's salesforce_id
          -- l_Sales_Lead_Rec.Assign_To_salesforce_id := l_val_id;
      END IF;

      CLOSE C_Sales_Owner_Check;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;
*/
      l_header_rec.updateable_flag        :=  'N';
      l_header_rec.member_access          :=  FND_API.G_MISS_CHAR;
      l_header_rec.member_role            :=  FND_API.G_MISS_CHAR;

      -- Update Sales Leads for Status Code and Sales lead owner IF needed
      -- ffang 030503, bug 2826512, call PUB instead of PVT
      -- AS_SALES_LEADS_PVT.Update_sales_lead(
      AS_SALES_LEADS_PUB.Update_sales_lead(
         P_Api_Version_Number     => l_api_version_number,
         P_Init_Msg_List          => FND_API.G_FALSE,
         P_Commit                 => FND_API.G_FALSE,
         P_Validation_Level       => P_Validation_Level,
         -- P_Check_Access_Flag      => 'Y',   -- P_Check_Access_Flag, commented by axavier for oppty
         P_Check_Access_Flag      => P_Check_Access_Flag,
         P_Admin_Flag             => P_Admin_Flag,
         P_Admin_Group_Id         => P_Admin_Group_Id,
         P_identity_salesforce_id => P_identity_salesforce_id,
         P_Sales_Lead_Profile_Tbl => P_Sales_Lead_Profile_Tbl,
         P_SALES_LEAD_Rec         => l_Sales_Lead_Rec,
         X_Return_Status          => X_Return_Status,
         X_Msg_Count              => X_Msg_Count,
         X_Msg_Data               => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- ffang 062802, bug 2422212, LEAD_OPPORTUNITY_ID need to be initialized
      l_Lead_Opportunity_Id := NULL;
      -- end ffang 062802

      -- Insert Interaction Data for linking Sales Lead to Opportunity
      AS_SALES_LEAD_OPP_PKG.Lead_Opportunity_Insert_Row (
          px_LEAD_OPPORTUNITY_ID    => l_Lead_Opportunity_Id
         ,p_SALES_LEAD_ID           => P_Sales_Lead_Id
         ,p_OPPORTUNITY_ID          => P_Opportunity_Id
         ,p_LAST_UPDATE_DATE        => SYSDATE
         ,p_LAST_UPDATED_BY         => FND_GLOBAL.User_Id
         ,p_CREATION_DATE           => SYSDATE
         ,p_CREATED_BY              => FND_GLOBAL.User_Id
         ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.Conc_Login_Id
         ,p_REQUEST_ID              => FND_GLOBAL.Conc_Request_Id
         ,p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id
         ,p_PROGRAM_ID              => FND_GLOBAL.Conc_Program_Id
         ,p_PROGRAM_UPDATE_DATE     => SYSDATE
         ,p_ATTRIBUTE_CATEGORY      => l_header_rec.attribute_category
         ,p_ATTRIBUTE1              => l_header_rec.attribute1
         ,p_ATTRIBUTE2              => l_header_rec.attribute2
         ,p_ATTRIBUTE3              => l_header_rec.attribute3
         ,p_ATTRIBUTE4              => l_header_rec.attribute4
         ,p_ATTRIBUTE5              => l_header_rec.attribute5
         ,p_ATTRIBUTE6              => l_header_rec.attribute6
         ,p_ATTRIBUTE7              => l_header_rec.attribute7
         ,p_ATTRIBUTE8              => l_header_rec.attribute8
         ,p_ATTRIBUTE9              => l_header_rec.attribute9
         ,p_ATTRIBUTE10             => l_header_rec.attribute10
         ,p_ATTRIBUTE11             => l_header_rec.attribute11
         ,p_ATTRIBUTE12             => l_header_rec.attribute12
         ,p_ATTRIBUTE13             => l_header_rec.attribute13
         ,p_ATTRIBUTE14             => l_header_rec.attribute14
         ,p_ATTRIBUTE15             => l_header_rec.attribute15
         -- ,p_SECURITY_GROUP_ID       => l_opp_security_group_id
      );




       Create_Lead_Ctx(
          P_SALES_LEAD_ID,
          P_OPPORTUNITY_ID,
          X_Return_Status
       );
      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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

END Link_Lead_To_Opportunity;


--   API Name:  Create_Opportunity_For_Lead

PROCEDURE Create_Opportunity_For_Lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesgroup_id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_ID              IN   NUMBER,
    P_OPP_STATUS                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_OPPORTUNITY_ID             OUT NOCOPY NUMBER
    )
 IS
    CURSOR C_Get_Sales_Lead (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_id
           ,last_update_date
           ,last_updated_by
           ,creation_date
           ,created_by
           ,last_update_login
           ,request_id
           ,program_application_id
           ,program_id
           ,program_update_date
           ,lead_number
           ,status_code
           ,customer_id
           ,address_id
           ,source_promotion_id
           ,initiating_contact_id
           ,orig_system_reference
           ,contact_role_code
           ,channel_code
           ,budget_amount
           ,currency_code
           ,decision_timeframe_code
           ,close_reason
           ,lead_rank_id
           ,lead_rank_code
           ,parent_project
           ,description
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,assign_to_person_id
           ,assign_to_salesforce_id
           ,assign_sales_group_id
           ,assign_date
           ,budget_status_code
           ,accept_flag
           ,vehicle_response_code
           ,total_score
           ,scorecard_id
           ,keep_flag
           ,urgent_flag
           ,import_flag
           ,reject_reason_code
           ,deleted_flag
           ,offer_id
           -- ,security_group_id
           ,incumbent_partner_party_id
           ,incumbent_partner_resource_id
           ,prm_exec_sponsor_flag
           ,prm_prj_lead_in_place_flag
           ,prm_sales_lead_type
           ,prm_ind_classification_code
          -- the following 2 fields added for bug#3613374
	   ,sales_methodology_id
	   ,sales_stage_id
      FROM as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

    CURSOR C_Get_Sales_lead_lines (X_Sales_Lead_Id NUMBER) IS
      SELECT sales_lead_line_id
             ,last_update_date
             ,last_updated_by
             ,creation_date
             ,created_by
             ,last_update_login
             ,status_code
             ,interest_type_id
             ,primary_interest_code_id
             ,secondary_interest_code_id
             ,inventory_item_id
             ,organization_id
             ,uom_code
             ,quantity
             ,budget_amount
             ,source_promotion_id
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             ,offer_id
             ,security_group_id
             ,category_id
             ,category_set_id
      FROM as_sales_lead_lines
      WHERE sales_lead_id = X_Sales_Lead_Id;

    -- 102700 FFANG for bug 1478517, get sales lead contacts information
    CURSOR C_Get_Sales_Lead_Contacts(c_sales_lead_id number) IS
      SELECT contact_id
             ,contact_party_id
             ,last_update_date
             ,last_updated_by
             ,creation_Date
             ,created_by
             ,last_update_login
             ,enabled_flag
             ,rank
             ,customer_id
             ,address_id
             ,phone_id
             ,contact_role_code
             ,primary_contact_flag
             ,attribute_category
             ,attribute1
             ,attribute2
             ,attribute3
             ,attribute4
             ,attribute5
             ,attribute6
             ,attribute7
             ,attribute8
             ,attribute9
             ,attribute10
             ,attribute11
             ,attribute12
             ,attribute13
             ,attribute14
             ,attribute15
             -- ,security_group_id
      FROM as_sales_lead_contacts
      WHERE sales_lead_id = c_sales_lead_id;
    -- end 102700 FFANG

    CURSOR C_Get_Opportunity(X_Lead_Id NUMBER) IS
      SELECT last_update_date
      FROM as_leads_all
      WHERE lead_id = X_Lead_Id;

    -- ffang 020301, for checking if the linking has already existed.
/*
    CURSOR C_lead_link_Exists (X_Sales_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM as_sales_lead_opportunity
      WHERE sales_lead_id = X_Sales_Lead_Id ;
*/

    -- ffang 051602, bug 2278318, copy lead's sales team to oppty
    CURSOR c_get_lead_salesteam (c_sl_id NUMBER) IS
        SELECT freeze_flag, reassign_flag, team_leader_flag,
               customer_id, address_id, salesforce_id, person_id,
               partner_customer_id, sales_group_id, partner_address_id,
               created_person_id, freeze_date, reassign_reason,
               salesforce_role_code, salesforce_relationship_code,
               attribute_category, attribute1, attribute2, attribute3,
               attribute4, attribute5, attribute6, attribute7, attribute8,
               attribute9, attribute10, attribute11, attribute12, attribute13,
               attribute14, attribute15, reassign_request_date,
               reassign_requested_person_id, security_group_id,
               partner_cont_party_id, created_by_tap_flag, prm_keep_flag
               -- ffang 062502, bug 2432561
               , owner_flag
               -- end ffang 062502
         FROM  as_accesses_all
         WHERE sales_lead_id = c_sl_id;
--Code added for Enhancement convert lead to opportunity - Attachment
   --Enhancement related Bug#3913225 @ @ Callling the procedure Copy_Attachments--changes for ASN.B--Start--
    CURSOR C_Attachment_Exists(X_Sales_Lead_Id VARCHAR2) IS
	SELECT 'X'
	FROM fnd_attached_documents
	WHERE pk1_value=X_Sales_Lead_Id;
   l_val_exists	  VARCHAR2(1) default null;
   G_USER_ID     NUMBER                := FND_GLOBAL.USER_ID;
   --Enhancement related Bug#3913225 @ @ Changes for ASN.B--End
-- Start Bug#3966128

CURSOR c_address_id(x_partner_party_id NUMBER) is
  SELECT hz.party_site_id
  FROM PV_PARTNERS_V pv,
       hz_party_sites hz
  WHERE pv.partner_id = x_partner_party_id
  AND hz.party_id =pv.partner_party_id
  AND pv.PARTNER_PARTY_NAME IS NOT NULL
  AND pv.INTERNAL_FLAG||'' = 'Y'
  AND pv.PARTNER_RESOURCE_ID IS NOT NULL
  AND pv.INTERNAL_STATUS = 'A'
  AND pv.PARTNER_STATUS = 'A'
  AND pv.RELATIONSHIP_STATUS = 'A'
  AND pv.SALES_PARTNER_FLAG = 'Y'
  and hz.identifying_address_flag = 'Y'
  and hz.status = 'A';

  l_address_id NUMBER;
  l_partner_party_id NUMBER;
  l_psalesteam_rec  as_access_pub.sales_team_rec_type:=as_api_records_pkg.get_p_sales_team_rec;
-- End Bug#3966128

    l_sales_team_rec       AS_ACCESS_PUB.SALES_TEAM_REC_TYPE;
    l_proceed_st_flag      VARCHAR2(1) := 'Y';
    l_access_id            NUMBER;
    -- end ffang 051602, bug 2278318

    l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Opp_For_Lead';
    l_api_version_number         CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec  AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_sales_lead_rec             AS_SALES_LEADS_PUB.Sales_Lead_Rec_Type;
    -- ffang 020301
    l_sl_rec                     AS_SALES_LEADS_PUB.Sales_Lead_Rec_Type
                                   := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC;
    l_val                        VARCHAR2(1) default null;
    -- end ffang 020301
    l_sales_lead_line_tbl        AS_SALES_LEADS_PUB.Sales_Lead_Line_Tbl_Type;
    l_header_rec                 AS_OPPORTUNITY_PUB.Header_Rec_Type;
    l_line_tbl                   AS_OPPORTUNITY_PUB.Line_Tbl_Type;
    l_line_out_tbl               AS_OPPORTUNITY_PUB.Line_Out_Tbl_Type;
    l_contact_tbl                AS_OPPORTUNITY_PUB.Contact_Tbl_Type;
    l_contact_out_tbl            AS_OPPORTUNITY_PUB.Contact_Out_Tbl_Type;
    l_access_profile_rec         AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_lead_line_id               NUMBER;
    l_lead_id                    NUMBER;
    l_last_update_date           DATE;
    l_cnt                        NUMBER;
    l_lead_opp_line_id           NUMBER;
    l_sales_lead_line_id         NUMBER default null;
    -- l_line_security_group_id     NUMBER;
    -- l_opp_security_group_id      NUMBER;
    l_update_access_flag         VARCHAR2(1);
    l_member_role                VARCHAR2(5);
    l_member_access              VARCHAR2(5);

    -- ffang 071202
    l_Lead_Opportunity_Id        NUMBER;
    -- end ffang 071202
    l_debug  BOOLEAN;
    l_debug_high  BOOLEAN;
    l_debug_err   BOOLEAN;
    -- Begin Added for Bug#3613374
    l_sales_lead_methodology_id  NUMBER;
    l_sales_methodology_id  NUMBER;
    l_sales_lead_stage_id  NUMBER;
    l_sales_stage_id  NUMBER;
    -- End Added for Bug#3613374
    l_default_org_id   number;
    l_default_ou_name  varchar2(240);
    l_ou_count         number;
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.slopv.Create_Opportunity_For_Lead';
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_FOR_LEAD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      l_debug_high := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
      l_debug_err  := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR);

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT:' || l_api_name || 'start');
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
                  p_module        => l_module,
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
          -- Call Get_Access_Profiles to get access_profile_rec
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Get_Access_Profiles');
        END IF;

          AS_SALES_LEADS_PUB.Get_Access_Profiles(
              p_profile_tbl         => p_sales_lead_profile_tbl,
              x_access_profile_rec  => l_access_profile_rec);

        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Has_updateLeadAccess');
        END IF;

          AS_ACCESS_PUB.Has_updateLeadAccess(
              p_api_version_number  => 2.0
             ,p_init_msg_list       => FND_API.G_FALSE
             ,p_validation_level    => p_validation_level
             ,p_access_profile_rec  => l_access_profile_rec
             ,p_admin_flag          => p_admin_flag
             ,p_admin_group_id      => p_admin_group_id
             ,p_person_id     => l_identity_sales_member_rec.employee_person_id
             ,p_sales_lead_id       => p_sales_lead_id
             ,p_check_access_flag   => 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
             ,p_partner_cont_party_id => NULL
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,x_update_access_flag  => l_update_access_flag);

          IF l_update_access_flag <> 'Y' THEN
            IF l_debug_err THEN
              AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'API_NO_CREATE_PRIVILEGE');
            END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- ffang 020301, validate one sales lead can only create/link one
      -- opportunity
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Validate existing link');
      END IF;

/*
      OPEN  C_Lead_Link_Exists (P_SALES_LEAD_ID);
      FETCH C_Lead_Link_Exists into l_val;

      IF l_val IS NOT NULL
      THEN
          FND_MESSAGE.Set_Name('AS', 'API_DUPLICATE_LINK');
          FND_MESSAGE.Set_Token('SLD_ID', p_sales_lead_id, FALSE);
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      CLOSE C_Lead_Link_Exists;
*/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Get sales lead header based on parameter P_Sales_Lead_Id
      OPEN  C_Get_Sales_Lead (P_Sales_Lead_Id);
      FETCH C_Get_Sales_Lead INTO
            l_Sales_Lead_Rec.sales_lead_id
           ,l_Sales_Lead_Rec.last_update_date
           ,l_Sales_Lead_Rec.last_updated_by
           ,l_Sales_Lead_Rec.creation_date
           ,l_Sales_Lead_Rec.created_by
           ,l_Sales_Lead_Rec.last_update_login
           ,l_Sales_Lead_Rec.request_id
           ,l_Sales_Lead_Rec.program_application_id
           ,l_Sales_Lead_Rec.program_id
           ,l_Sales_Lead_Rec.program_update_date
           ,l_Sales_Lead_Rec.lead_number
           ,l_Sales_Lead_Rec.status_code
           ,l_Sales_Lead_Rec.customer_id
           ,l_Sales_Lead_Rec.address_id
           ,l_Sales_Lead_Rec.source_promotion_id
           ,l_Sales_Lead_Rec.initiating_contact_id
           ,l_Sales_Lead_Rec.orig_system_reference
           ,l_Sales_Lead_Rec.contact_role_code
           ,l_Sales_Lead_Rec.channel_code
           ,l_Sales_Lead_Rec.budget_amount
           ,l_Sales_Lead_Rec.currency_code
           ,l_Sales_Lead_Rec.decision_timeframe_code
           ,l_Sales_Lead_Rec.close_reason
           ,l_Sales_Lead_Rec.lead_rank_id
           ,l_Sales_Lead_Rec.lead_rank_code
           ,l_Sales_Lead_Rec.parent_project
           ,l_Sales_Lead_Rec.description
           ,l_Sales_Lead_Rec.attribute_category
           ,l_Sales_Lead_Rec.attribute1
           ,l_Sales_Lead_Rec.attribute2
           ,l_Sales_Lead_Rec.attribute3
           ,l_Sales_Lead_Rec.attribute4
           ,l_Sales_Lead_Rec.attribute5
           ,l_Sales_Lead_Rec.attribute6
           ,l_Sales_Lead_Rec.attribute7
           ,l_Sales_Lead_Rec.attribute8
           ,l_Sales_Lead_Rec.attribute9
           ,l_Sales_Lead_Rec.attribute10
           ,l_Sales_Lead_Rec.attribute11
           ,l_Sales_Lead_Rec.attribute12
           ,l_Sales_Lead_Rec.attribute13
           ,l_Sales_Lead_Rec.attribute14
           ,l_Sales_Lead_Rec.attribute15
           ,l_Sales_Lead_Rec.assign_to_person_id
           ,l_Sales_Lead_Rec.assign_to_salesforce_id
           ,l_Sales_Lead_Rec.assign_sales_group_id
           ,l_Sales_Lead_Rec.assign_date
           ,l_Sales_Lead_Rec.budget_status_code
           ,l_Sales_Lead_Rec.accept_flag
           ,l_Sales_Lead_Rec.vehicle_response_code
           ,l_Sales_Lead_Rec.total_score
           ,l_Sales_Lead_Rec.scorecard_id
           ,l_Sales_Lead_Rec.keep_flag
           ,l_Sales_Lead_Rec.urgent_flag
           ,l_Sales_Lead_Rec.import_flag
           ,l_Sales_Lead_Rec.reject_reason_code
           ,l_Sales_Lead_Rec.deleted_flag
           ,l_Sales_Lead_Rec.offer_id
           -- ,l_Sales_Lead_Rec.security_group_id
           ,l_Sales_Lead_Rec.incumbent_partner_party_id
           ,l_Sales_Lead_Rec.incumbent_partner_resource_id
           ,l_Sales_Lead_Rec.prm_exec_sponsor_flag
           ,l_Sales_Lead_Rec.prm_prj_lead_in_place_flag
           ,l_Sales_Lead_Rec.prm_sales_lead_type
           ,l_Sales_Lead_Rec.prm_ind_classification_code
        -- 2 fields added for Bug#3613374
	   ,l_sales_lead_methodology_id
	   ,l_sales_lead_stage_id;


      IF ( C_Get_Sales_Lead%NOTFOUND) THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Private API: SALES_LEAD_ID is invalid');
        END IF;

        AS_UTILITY_PVT.Set_Message(
            p_module        => l_module,
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_INVALID_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'SALES_LEAD_ID',
            p_token2        => 'VALUE',
            p_token2_value  =>  P_Sales_Lead_Id );

        x_return_status := FND_API.G_RET_STS_ERROR;

      END IF;

      CLOSE C_Get_Sales_Lead;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Begin Added for Bug#3613374
     IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'  THEN
	      CHECK_SALES_STAGE(
		      p_api_version_number       => 2.0
		     ,p_init_msg_list             => FND_API.G_FALSE
		     ,p_validation_level           => p_validation_level
		     ,p_sales_lead_id	           =>P_Sales_Lead_Id
		     ,P_sales_lead_stage_id        =>l_sales_lead_stage_id
		     ,P_sales_lead_methodology_id  =>l_sales_lead_methodology_id
		     ,X_sales_stage_id             =>l_sales_stage_id
		     ,X_sales_methodology_id       =>l_sales_methodology_id
		     ,X_Return_Status              =>x_return_status
		     ,X_Msg_Count                  =>x_msg_count
		     ,X_Msg_Data                   =>x_msg_data);
	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		  RAISE FND_API.G_EXC_ERROR;
	      ELSE
		 l_header_rec.Sales_Methodology_Id := l_sales_methodology_id;
		 l_header_rec.sales_stage_id       := l_sales_stage_id;
                null;
	      END IF;
      END IF;
    -- End Added for Bug#3613374

      l_last_update_date := l_Sales_Lead_Rec.last_update_Date;


      -- Copy the sales lead information (header level) to opportunity
      -- l_header_rec.last_update_date       := SYSDATE;
      -- l_header_rec.last_updated_by        := FND_GLOBAL.USER_ID;
      -- l_header_rec.creation_Date          := SYSDATE;
      -- l_header_rec.created_by             := FND_GLOBAL.USER_ID;
      -- l_header_rec.last_update_login      := FND_GLOBAL.CONC_LOGIN_ID;
      -- l_header_rec.lead_number            := l_Sales_Lead_Rec.lead_number;

      -- ffang 121200 for bug 1529866: opportunity's status should be get from
      -- p_opp_status.
      -- IF l_Sales_Lead_Rec.prm_sales_lead_type  = 'INDIRECT' THEN
      --  l_header_rec.status_code          := 'UNASSIGNED';
      -- ELSE
      --  l_header_rec.status_code          := 'NEW_OPPORTUNITY';
      -- END IF;

      l_header_rec.status_code          := p_opp_status;
      -- end ffang 121200

      l_header_rec.customer_id          := l_Sales_Lead_Rec.customer_id;
      l_header_rec.address_id           := l_Sales_Lead_Rec.address_id;
      -- l_header_rec.lead_source_code   -- Not exist in sales leads Table
      l_header_rec.orig_system_reference
                      := l_Sales_Lead_Rec.orig_system_reference;
      -- l_header_rec.sales_stage_id     -- Not exist in sales leads
      l_header_rec.initiating_contact_id
                      := l_Sales_Lead_Rec.initiating_contact_id;
      l_header_rec.channel_code         := l_Sales_Lead_Rec.channel_code;
      -- l_header_rec.Total_amount    -- will be the sum of lines' total_amount
      l_header_rec.currency_code        := l_Sales_Lead_Rec.currency_code;
      -- l_header_rec.decision_date     -- Not exist in sales leads Table
      -- l_header_rec.win_probability   -- Not exist in sales leads Table
      -- 102600 FFANG, pass close_reason to opportunity's close_reason_code
      -- l_header_rec.close_reason_code      -- Not exist in sales leads Table
      l_header_rec.close_reason_code    := l_Sales_Lead_Rec.close_reason;
      -- end 102600 FFANG
      -- l_header_rec.close_competitor_code  -- Not exist in sales leads Table
      -- l_header_rec.close_competitor_id    -- Not exist in sales leads Table
      -- l_header_rec.close_competitor       -- Not exist in sales leads Table
      -- l_header_rec.close_comment          -- Not exist in sales leads Table
      l_header_rec.rank                 := l_Sales_Lead_Rec.lead_rank_code;
      l_header_rec.description          := l_Sales_Lead_Rec.description;
      -- l_header_rec.end_user_customer_name -- Not exist in sales leads Table
      l_header_rec.source_promotion_id  := l_Sales_Lead_Rec.source_promotion_id;
      -- l_header_rec.end_user_customer_id   -- Not exist in sales leads Table
      -- l_header_rec.end_user_address_id    -- Not exist in sales leads Table
      -- l_header_rec.org_id                 -- Not exist in sales leads Table
      -- l_header_rec.no_opp_allowed_flag    -- Not exist in sales leads Table
      -- l_header_rec.delete_allowed_flag    -- Not exist in sales leads Table
      l_header_rec.parent_project       := l_Sales_Lead_Rec.parent_project;
      -- l_header_rec.price_list_id          -- Not exist in sales leads Table
      -- l_header_rec.deleted_flag           -- Not exist in sales leads Table
      -- l_header_rec.auto_assignment_type   -- Not exist in sales leads Table
      -- l_header_rec.prm_assignment_type    -- Not exist in sales leads Table
      -- 102600 FFANG for BUG 1478517, pass budget_amount to opportunity's
      -- customer_budget instead of total_amount, since create_opp_lines will
      -- update total_amount according to lines' total amount
      l_header_rec.customer_budget      := l_Sales_Lead_Rec.budget_amount;
      -- end 102600 FFANG
      -- l_header_rec.methodology_code       -- Not exist in sales leads Table
      -- l_header_rec.original_lead_id       -- Not exist in sales leads Table
      l_header_rec.decision_timeframe_code
                         := l_Sales_Lead_Rec.decision_timeframe_code;
      l_header_rec.attribute_category   := l_Sales_Lead_Rec.attribute_category;
      l_header_rec.attribute1           := l_Sales_Lead_Rec.attribute1;
      l_header_rec.attribute2           := l_Sales_Lead_Rec.attribute2;
      l_header_rec.attribute3           := l_Sales_Lead_Rec.attribute3;
      l_header_rec.attribute4           := l_Sales_Lead_Rec.attribute4;
      l_header_rec.attribute5           := l_Sales_Lead_Rec.attribute5;
      l_header_rec.attribute6           := l_Sales_Lead_Rec.attribute6;
      l_header_rec.attribute7           := l_Sales_Lead_Rec.attribute7;
      l_header_rec.attribute8           := l_Sales_Lead_Rec.attribute8;
      l_header_rec.attribute9           := l_Sales_Lead_Rec.attribute9;
      l_header_rec.attribute10          := l_Sales_Lead_Rec.attribute10;
      l_header_rec.attribute11          := l_Sales_Lead_Rec.attribute11;
      l_header_rec.attribute12          := l_Sales_Lead_Rec.attribute12;
      l_header_rec.attribute13          := l_Sales_Lead_Rec.attribute13;
      l_header_rec.attribute14          := l_Sales_Lead_Rec.attribute14;
      l_header_rec.attribute15          := l_Sales_Lead_Rec.attribute15;
      l_header_rec.parent_project       := l_Sales_Lead_Rec.parent_project;
      -- l_header_rec.security_group_id   := l_Sales_Lead_Rec.security_group_id;
      l_header_rec.incumbent_partner_resource_id
                         := l_Sales_Lead_Rec.incumbent_partner_resource_id;
      l_header_rec.incumbent_partner_party_id
                         := l_Sales_Lead_Rec.incumbent_partner_party_id;
      l_header_rec.offer_id             := l_Sales_Lead_Rec.offer_id;
      l_header_rec.vehicle_response_code
                         := l_Sales_Lead_Rec.vehicle_response_code;
      l_header_rec.budget_status_code
                         := l_Sales_Lead_Rec.budget_status_code;
      -- l_header_rec.followup_date          -- Not exist in sales leads Table
      l_header_rec.prm_exec_sponsor_flag
                         := l_Sales_Lead_Rec.prm_exec_sponsor_flag;
      l_header_rec.prm_prj_lead_in_place_flag
                         := l_Sales_Lead_Rec.prm_prj_lead_in_place_flag;
      l_header_rec.prm_ind_classification_code
                         := l_Sales_Lead_Rec.prm_ind_classification_code;
      l_header_rec.prm_lead_type        := l_Sales_Lead_Rec.prm_sales_lead_type;
      mo_utils.get_default_ou(l_default_org_id, l_default_ou_name, l_ou_count);
      l_header_rec.org_id := l_default_org_id;
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling AS_OPP_HEADER_PVT.Create_opp_header');
      END IF;
      IF l_debug_high THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'P_Ident_SF_Id : ' || P_Identity_Salesforce_Id);
      END IF;
      -- ffang 030503, bug 2826512, call PUB instead of PVT
      -- AS_OPP_HEADER_PVT.Create_opp_header (
      AS_OPPORTUNITY_PUB.Create_Opp_Header (
          p_api_version_number => 2.0,
          p_init_msg_list => FND_API.G_FALSE,
          p_commit => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          P_Check_Access_Flag => 'N',   -- 'Y',
          -- P_Check_Access_Flag => P_Check_Access_Flag,
          P_Admin_Flag => P_Admin_Flag,
          P_Admin_Group_Id => P_Admin_Group_Id,
          P_Identity_Salesforce_Id => P_identity_Salesforce_id,
          P_salesgroup_id => P_identity_salesgroup_id,
          P_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
          P_Partner_Cont_Party_id => FND_API.G_MISS_NUM,
          P_Header_Rec => l_header_rec,
          X_LEAD_ID => l_lead_id,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;


      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Open Cursor C_Get_Opportunity:' || l_lead_id);
      END IF;

      OPEN C_Get_Opportunity(l_lead_id);
      FETCH C_Get_Opportunity INTO l_header_rec.last_update_date;
      CLOSE C_Get_Opportunity;

      l_header_rec.lead_id := l_lead_id;


      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Copy lines data to opp, sales_lead_id='||P_Sales_Lead_Id);
      END IF;

      -- Copy sales lead lines data to opportunity record lines
      l_cnt := 0;
      For C_Sales_Lead_lines_Rec In C_Get_Sales_lead_lines(P_Sales_Lead_Id) Loop
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'open lines cursor successfully');
        END IF;
          l_cnt := l_cnt + 1;

          l_sales_lead_line_tbl(l_cnt).sales_lead_line_id
                           := C_Sales_Lead_lines_Rec.sales_lead_line_id;

          l_line_tbl(l_cnt).last_update_date  := SYSDATE;
          l_line_tbl(l_cnt).last_updated_by   := FND_GLOBAL.USER_ID;
          l_line_tbl(l_cnt).creation_Date     := SYSDATE;
          l_line_tbl(l_cnt).created_by        := FND_GLOBAL.USER_ID;
          l_line_tbl(l_cnt).last_update_login := FND_GLOBAL.CONC_LOGIN_ID;
          l_line_tbl(l_cnt).lead_id           := l_lead_id;
          -- 103000 FFANG as_lead_lines_all.status_code has been obsolete
          -- l_line_tbl(l_cnt).status_code       := 'NEW_OPPORTUNITY';
		-- end 103000 FFANG
          l_line_tbl(l_cnt).interest_type_id
                          := C_Sales_Lead_lines_Rec.interest_type_id;
          l_line_tbl(l_cnt).primary_interest_code_id
                          := C_Sales_Lead_lines_Rec.primary_interest_code_id;
          l_line_tbl(l_cnt).secondary_interest_code_id
                          := C_Sales_Lead_lines_Rec.secondary_interest_code_id;
          -- l_line_tbl(l_cnt).interest_status_code  -- obsolete
          l_line_tbl(l_cnt).inventory_item_id
                          := C_Sales_Lead_lines_Rec.inventory_item_id;
          l_line_tbl(l_cnt).organization_id
                          := C_Sales_Lead_lines_Rec.organization_id;
          l_line_tbl(l_cnt).uom_code      := C_Sales_Lead_lines_Rec.uom_code;
          l_line_tbl(l_cnt).quantity      := C_Sales_Lead_lines_Rec.quantity;
          l_line_tbl(l_cnt).total_amount
                          := C_Sales_Lead_lines_Rec.budget_amount;
          -- l_line_tbl(l_cnt).sales_stage_id  -- obsolete
          -- l_line_tbl(l_cnt).ship_date       -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).win_probability -- obsolete
          -- l_line_tbl(l_cnt).decision_date   -- obsolete
          -- 103000 FFANG as_lead_lines_all.channel_code has been obsolete
          -- l_line_tbl(l_cnt).channel_code  := l_header_rec.channel_code;
          -- end 103000 FFANG
          -- l_line_tbl(l_cnt).quoted_line_flag -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).original_lead_line_id -- not exist in sl lines
          -- l_line_tbl(l_cnt).org_id          -- not exist in sales lead lines
          -- l_line_tbl(l_cnt).price           -- not exist in sales lead lines
          -- 103000 FFANG for bug 1479671
          l_line_tbl(l_cnt).source_promotion_id
                                := C_Sales_Lead_lines_Rec.source_promotion_id;
          --end 103000 FFANG
          -- l_line_tbl(l_cnt).price_volume_margin -- not exist in sl lines
          l_line_tbl(l_cnt).attribute_category
                          := C_Sales_Lead_lines_Rec.attribute_category;
          l_line_tbl(l_cnt).attribute1    := C_Sales_Lead_lines_Rec.attribute1;
          l_line_tbl(l_cnt).attribute2    := C_Sales_Lead_lines_Rec.attribute2;
          l_line_tbl(l_cnt).attribute3    := C_Sales_Lead_lines_Rec.attribute3;
          l_line_tbl(l_cnt).attribute4    := C_Sales_Lead_lines_Rec.attribute4;
          l_line_tbl(l_cnt).attribute5    := C_Sales_Lead_lines_Rec.attribute5;
          l_line_tbl(l_cnt).attribute6    := C_Sales_Lead_lines_Rec.attribute6;
          l_line_tbl(l_cnt).attribute7    := C_Sales_Lead_lines_Rec.attribute7;
          l_line_tbl(l_cnt).attribute8    := C_Sales_Lead_lines_Rec.attribute8;
          l_line_tbl(l_cnt).attribute9    := C_Sales_Lead_lines_Rec.attribute9;
          l_line_tbl(l_cnt).attribute10   := C_Sales_Lead_lines_Rec.attribute10;
          l_line_tbl(l_cnt).attribute11   := C_Sales_Lead_lines_Rec.attribute11;
          l_line_tbl(l_cnt).attribute12   := C_Sales_Lead_lines_Rec.attribute12;
          l_line_tbl(l_cnt).attribute13   := C_Sales_Lead_lines_Rec.attribute13;
          l_line_tbl(l_cnt).attribute14   := C_Sales_Lead_lines_Rec.attribute14;
          l_line_tbl(l_cnt).attribute15   := C_Sales_Lead_lines_Rec.attribute15;
          l_line_tbl(l_cnt).member_access := FND_API.G_MISS_CHAR;
          l_line_tbl(l_cnt).member_role   := FND_API.G_MISS_CHAR;
          l_line_tbl(l_cnt).owner_scredit_percent := FND_API.G_MISS_NUM;
          -- l_line_tbl(l_cnt).security_group_id
          --              := C_Sales_Lead_lines_Rec.security_group_id;
          -- 103000 FFANG for bug 1479671
          l_line_tbl(l_cnt).offer_id :=  C_Sales_Lead_lines_Rec.offer_id;
          -- end 103000 FFANG
          l_line_tbl(l_cnt).product_category_id :=  C_Sales_Lead_lines_Rec.category_id;
          l_line_tbl(l_cnt).product_cat_set_id :=  C_Sales_Lead_lines_Rec.category_set_id;

      END Loop;

      if l_line_tbl.count > 0
      then
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling AS_OPP_LINE_PVT.Create_Opp_Lines');
        END IF;

          -- ffang 030503, bug 2826512, call PUB instead of PVT
          -- AS_OPP_line_PVT.Create_opp_lines (
          AS_OPPORTUNITY_PUB.Create_Opp_Lines (
              p_api_version_number => 2.0,
              p_init_msg_list => FND_API.G_FALSE,
              p_commit => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              P_Check_Access_Flag => 'N',   -- p_check_access_flag,
              -- P_Check_Access_Flag => FND_API.G_FALSE,
              P_Admin_Flag => p_admin_flag,
              P_Admin_Group_Id => P_Admin_Group_Id,
              P_Identity_Salesforce_Id => p_identity_salesforce_id,
              P_salesgroup_id => P_identity_salesgroup_id,
              P_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
              P_Partner_Cont_Party_id => null,
              P_line_tbl => l_line_tbl,
              P_Header_Rec => l_header_rec,
              X_LINE_OUT_TBL => l_line_out_tbl,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          For l_index In 1..l_line_out_tbl.count Loop
           IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling AS_SALES_LEAD_OPP_PKG.Lead_Opp_Lines_Insert_Row' ||
                 l_sales_lead_line_tbl(l_index).sales_lead_line_id ||
                 ',' || l_line_out_tbl(l_index).lead_line_id);
           END IF;

              l_lead_opp_line_id := null;
              AS_SALES_LEAD_OPP_PKG.Lead_Opp_Lines_Insert_Row (
                  px_LEAD_OPP_LINE_ID   => l_Lead_Opp_Line_Id
                 ,p_SALES_LEAD_LINE_ID  =>
                              l_sales_lead_line_tbl(l_index).sales_lead_line_id
                 ,p_OPP_LINE_ID         => l_line_out_tbl(l_index).lead_line_id
                 ,p_LAST_UPDATE_DATE    => SYSDATE
                 ,p_LAST_UPDATED_BY     => FND_GLOBAL.User_Id
                 ,p_CREATION_DATE       => SYSDATE
                 ,p_CREATED_BY          => FND_GLOBAL.User_Id
                 ,p_LAST_UPDATE_LOGIN   => FND_GLOBAL.Conc_Login_Id
                 ,p_REQUEST_ID          => FND_GLOBAL.Conc_Request_Id
                 ,p_PROGRAM_APPLICATION_ID => FND_GLOBAL.Prog_Appl_Id
                 ,p_PROGRAM_ID          => FND_GLOBAL.Conc_Program_Id
                 ,p_PROGRAM_UPDATE_DATE => SYSDATE
                 ,p_ATTRIBUTE_CATEGORY => l_line_tbl(l_index).attribute_category
                 ,p_ATTRIBUTE1          => l_line_tbl(l_index).attribute1
                 ,p_ATTRIBUTE2          => l_line_tbl(l_index).attribute2
                 ,p_ATTRIBUTE3          => l_line_tbl(l_index).attribute3
                 ,p_ATTRIBUTE4          => l_line_tbl(l_index).attribute4
                 ,p_ATTRIBUTE5          => l_line_tbl(l_index).attribute5
                 ,p_ATTRIBUTE6          => l_line_tbl(l_index).attribute6
                 ,p_ATTRIBUTE7          => l_line_tbl(l_index).attribute7
                 ,p_ATTRIBUTE8          => l_line_tbl(l_index).attribute8
                 ,p_ATTRIBUTE9          => l_line_tbl(l_index).attribute9
                 ,p_ATTRIBUTE10         => l_line_tbl(l_index).attribute10
                 ,p_ATTRIBUTE11         => l_line_tbl(l_index).attribute11
                 ,p_ATTRIBUTE12         => l_line_tbl(l_index).attribute12
                 ,p_ATTRIBUTE13         => l_line_tbl(l_index).attribute13
                 ,p_ATTRIBUTE14         => l_line_tbl(l_index).attribute14
                 ,p_ATTRIBUTE15         => l_line_tbl(l_index).attribute15
                 -- ,p_security_group_id   => l_line_rec.security_group_id
               );

          END Loop;
      end if;

      -- 102700 FFANG for bug 1478517, copy sales lead contacts information to
      -- opportunity contact table

      -- Copy sales lead contacts data to opportunity record contacts
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Copy sales lead contacts data to opp');
      END IF;
      l_cnt := 0;
      For C_SL_Contacts_Rec In C_Get_Sales_lead_Contacts(P_Sales_Lead_Id) Loop
          l_cnt := l_cnt + 1;

          l_contact_tbl(l_cnt).lead_id           := l_lead_id;
          l_contact_tbl(l_cnt).contact_id  := C_SL_Contacts_Rec.contact_id;
          l_contact_tbl(l_cnt).contact_party_id
                          := C_SL_Contacts_Rec.contact_party_id;
          l_contact_tbl(l_cnt).last_update_date  := SYSDATE;
          l_contact_tbl(l_cnt).last_updated_by   := FND_GLOBAL.USER_ID;
          l_contact_tbl(l_cnt).creation_Date     := SYSDATE;
          l_contact_tbl(l_cnt).created_by        := FND_GLOBAL.USER_ID;
          l_contact_tbl(l_cnt).last_update_login := FND_GLOBAL.CONC_LOGIN_ID;
          l_contact_tbl(l_cnt).enabled_flag := C_SL_Contacts_Rec.enabled_flag;
          l_contact_tbl(l_cnt).customer_id  := C_SL_Contacts_Rec.customer_id;
          l_contact_tbl(l_cnt).address_id := C_SL_Contacts_Rec.address_id;
          l_contact_tbl(l_cnt).phone_id   := C_SL_Contacts_Rec.phone_id;
          -- ffang 041802, for bug 2251391, opp contact role stores in rank
          l_contact_tbl(l_cnt).rank := C_SL_Contacts_Rec.contact_role_code;
          -- end ffang 041802
          l_contact_tbl(l_cnt).primary_contact_flag
                          := C_SL_Contacts_Rec.primary_contact_flag;
          l_contact_tbl(l_cnt).role := C_SL_Contacts_Rec.contact_role_code;
          l_contact_tbl(l_cnt).attribute_category
                          := C_SL_Contacts_Rec.attribute_category;
          l_contact_tbl(l_cnt).attribute1 := C_SL_Contacts_Rec.attribute1;
          l_contact_tbl(l_cnt).attribute2 := C_SL_Contacts_Rec.attribute2;
          l_contact_tbl(l_cnt).attribute3 := C_SL_Contacts_Rec.attribute3;
          l_contact_tbl(l_cnt).attribute4 := C_SL_Contacts_Rec.attribute4;
          l_contact_tbl(l_cnt).attribute5 := C_SL_Contacts_Rec.attribute5;
          l_contact_tbl(l_cnt).attribute6 := C_SL_Contacts_Rec.attribute6;
          l_contact_tbl(l_cnt).attribute7 := C_SL_Contacts_Rec.attribute7;
          l_contact_tbl(l_cnt).attribute8 := C_SL_Contacts_Rec.attribute8;
          l_contact_tbl(l_cnt).attribute9 := C_SL_Contacts_Rec.attribute9;
          l_contact_tbl(l_cnt).attribute10 := C_SL_Contacts_Rec.attribute10;
          l_contact_tbl(l_cnt).attribute11 := C_SL_Contacts_Rec.attribute11;
          l_contact_tbl(l_cnt).attribute12 := C_SL_Contacts_Rec.attribute12;
          l_contact_tbl(l_cnt).attribute13 := C_SL_Contacts_Rec.attribute13;
          l_contact_tbl(l_cnt).attribute14 := C_SL_Contacts_Rec.attribute14;
          l_contact_tbl(l_cnt).attribute15 := C_SL_Contacts_Rec.attribute15;
          -- l_contact_tbl(l_cnt).security_group_id
          --                 := C_SL_Contacts_Rec.security_group_id;

      END Loop;

      IF l_contact_tbl.count > 0
      THEN
        IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling AS_OPP_CONTACT_PVT.Create_Opp_contacts');
        END IF;

          -- ffang 030503, bug 2826512, call PUB instead of PVT
          -- AS_OPP_CONTACT_PVT.Create_opp_contacts (
          AS_OPPORTUNITY_PUB.Create_Contacts (
              p_api_version_number => 2.0,
              p_init_msg_list => FND_API.G_FALSE,
              p_commit => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              P_Check_Access_Flag => 'N',    -- P_Check_Access_Flag,
              -- P_Check_Access_Flag => FND_API.G_FALSE,
              P_Admin_Flag => P_Admin_Flag,
              P_Admin_Group_Id => P_Admin_Group_Id,
              P_Identity_Salesforce_Id => p_identity_salesforce_id,
              P_profile_tbl => AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
              P_Partner_Cont_Party_id => null,
              P_contact_tbl => l_contact_tbl,
              X_contact_OUT_TBL => l_contact_out_tbl,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
          -- end 102700 FFANG
      END IF;

      -- Update Sales Leads for Status Code

      -- ffang 020301, AS_API_RECORDS_PKG.Get_P_Sales_Lead_Rec will initialize
      -- l_Sales_Lead_Rec, assign_to_xxx_id will be initialized as g_miss_num.
      -- Use another record instead (l_sl_rec). And we don't need to call
      -- AS_API_RECORDS_PKG.Get_P_Sales_Lead_Rec to initialize l_sl_rec,
      -- since it was default as miss_rec.

      -- l_Sales_Lead_Rec := AS_API_RECORDS_PKG.Get_P_Sales_Lead_Rec;
      -- l_Sales_Lead_Rec.Sales_Lead_Id    := p_Sales_Lead_Id;
      -- l_Sales_Lead_Rec.last_update_date := l_last_update_date;
      -- l_Sales_Lead_Rec.Status_Code      := 'QUALIFIED';

      l_SL_Rec.Sales_Lead_Id    := p_Sales_Lead_Id;
      l_SL_Rec.last_update_date := l_last_update_date;

      -- has to be changed once the profile problem is solved
      --l_SL_Rec.Status_Code      := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'QUALIFIED');
      l_SL_Rec.Status_Code      := nvl(FND_PROFILE.Value('AS_LEAD_LINK_STATUS'),'CONVERTED_TO_OPPORTUNITY');
      --l_SL_Rec.Status_Code      := 'QUALIFIED';

      l_SL_Rec.assign_to_salesforce_id
                                := l_Sales_Lead_Rec.assign_to_salesforce_id;
      l_SL_Rec.assign_to_person_id
                                := l_Sales_Lead_Rec.assign_to_person_id;
      l_SL_Rec.assign_sales_group_id
                                := l_Sales_Lead_Rec.assign_sales_group_id;
      -- end ffang 020301

      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Update_sales_lead');
      END IF;

      -- ffang 030503, bug 2826512, call PUB instead of PVT
      -- AS_SALES_LEADS_PVT.Update_sales_lead(
      AS_SALES_LEADS_PUB.Update_sales_lead(
         P_Api_Version_Number     => l_api_version_number,
         P_Init_Msg_List          => FND_API.G_FALSE,
         P_Commit                 => FND_API.G_FALSE,
         P_Validation_Level       => P_Validation_Level,
         P_Check_Access_Flag      => 'Y',    -- P_Check_Access_Flag,
         P_Admin_Flag             => P_Admin_Flag,
         P_Admin_Group_Id         => P_Admin_Group_Id,
         P_identity_salesforce_id => P_identity_salesforce_id,
         P_Sales_Lead_Profile_Tbl => P_Sales_Lead_Profile_Tbl,
         P_SALES_LEAD_Rec         => l_SL_Rec,    -- ffang 020301
         -- P_SALES_LEAD_Rec         => l_Sales_Lead_Rec,
         X_Return_Status          => X_Return_Status,
         X_Msg_Count              => X_Msg_Count,
         X_Msg_Data               => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- ffang 071202, bug 2451983
      l_Lead_Opportunity_Id := NULL;
      -- end ffang 071202, bug 2451983

      -- Insert Interaction Data for linking Sales Lead to Opportunity
      AS_SALES_LEAD_OPP_PKG.Lead_Opportunity_Insert_Row (
          -- ffang 071202, why use l_lead_id as lead_opportunity_id output?
          -- px_LEAD_OPPORTUNITY_ID    => l_Lead_Id
          px_LEAD_OPPORTUNITY_ID    => l_Lead_Opportunity_Id
         ,p_SALES_LEAD_ID           => P_Sales_Lead_Id
         ,p_OPPORTUNITY_ID          => l_Lead_Id
         ,p_LAST_UPDATE_DATE        => SYSDATE
         ,p_LAST_UPDATED_BY         => FND_GLOBAL.User_Id
         ,p_CREATION_DATE           => SYSDATE
         ,p_CREATED_BY              => FND_GLOBAL.User_Id
         ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.Conc_Login_Id
         ,p_REQUEST_ID              => FND_GLOBAL.Conc_Request_Id
         ,p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id
         ,p_PROGRAM_ID              => FND_GLOBAL.Conc_Program_Id
         ,p_PROGRAM_UPDATE_DATE     => SYSDATE
         ,p_ATTRIBUTE_CATEGORY      => l_header_rec.attribute_category
         ,p_ATTRIBUTE1              => l_header_rec.attribute1
         ,p_ATTRIBUTE2              => l_header_rec.attribute2
         ,p_ATTRIBUTE3              => l_header_rec.attribute3
         ,p_ATTRIBUTE4              => l_header_rec.attribute4
         ,p_ATTRIBUTE5              => l_header_rec.attribute5
         ,p_ATTRIBUTE6              => l_header_rec.attribute6
         ,p_ATTRIBUTE7              => l_header_rec.attribute7
         ,p_ATTRIBUTE8              => l_header_rec.attribute8
         ,p_ATTRIBUTE9              => l_header_rec.attribute9
         ,p_ATTRIBUTE10             => l_header_rec.attribute10
         ,p_ATTRIBUTE11             => l_header_rec.attribute11
         ,p_ATTRIBUTE12             => l_header_rec.attribute12
         ,p_ATTRIBUTE13             => l_header_rec.attribute13
         ,p_ATTRIBUTE14             => l_header_rec.attribute14
         ,p_ATTRIBUTE15             => l_header_rec.attribute15
         -- ,p_security_group_id       => l_opp_security_group_id
                                       -- l_header_rec.security_group_id
      );

      x_opportunity_id := l_lead_id;

       Create_Lead_Ctx(
          P_SALES_LEAD_ID,
          l_lead_id,
          X_Return_Status
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;

      -- ffang 051602, bug 2278318, copy lead's sales team to oppty
      IF nvl(FND_PROFILE.Value('AS_LEADLINK_MOVE_ST'), 'N') = 'Y' THEN
          FOR ST IN c_get_lead_salesteam (P_Sales_Lead_Id)
          LOOP
              l_sales_team_rec.freeze_flag := ST.freeze_flag;
              l_sales_team_rec.reassign_flag := ST.reassign_flag;
              l_sales_team_rec.team_leader_flag := ST.team_leader_flag;
              l_sales_team_rec.customer_id := ST.customer_id;
              l_sales_team_rec.address_id := ST.address_id;
              l_sales_team_rec.salesforce_id := ST.salesforce_id;
              l_sales_team_rec.person_id := ST.person_id;
              l_sales_team_rec.sales_group_id := ST.sales_group_id;
              l_sales_team_rec.partner_customer_id := ST.partner_customer_id;
              l_sales_team_rec.partner_address_id := ST.partner_address_id;
              l_sales_team_rec.created_person_id := ST.created_person_id;
              l_sales_team_rec.freeze_date := ST.freeze_date;
              l_sales_team_rec.reassign_reason := ST.reassign_reason;
              l_sales_team_rec.salesforce_role_code := ST.salesforce_role_code;
              l_sales_team_rec.salesforce_relationship_code :=
                                    ST.salesforce_relationship_code;
              l_sales_team_rec.attribute_category := ST.attribute_category;
              l_sales_team_rec.attribute1 := ST.attribute1;
              l_sales_team_rec.attribute2 := ST.attribute2;
              l_sales_team_rec.attribute3 := ST.attribute3;
              l_sales_team_rec.attribute4 := ST.attribute4;
              l_sales_team_rec.attribute5 := ST.attribute5;
              l_sales_team_rec.attribute6 := ST.attribute6;
              l_sales_team_rec.attribute7 := ST.attribute7;
              l_sales_team_rec.attribute8 := ST.attribute8;
              l_sales_team_rec.attribute9 := ST.attribute9;
              l_sales_team_rec.attribute10 := ST.attribute10;
              l_sales_team_rec.attribute11 := ST.attribute11;
              l_sales_team_rec.attribute12 := ST.attribute12;
              l_sales_team_rec.attribute13 := ST.attribute13;
              l_sales_team_rec.attribute14 := ST.attribute14;
              l_sales_team_rec.attribute15 := ST.attribute15;
              l_sales_team_rec.reassign_request_date:= ST.reassign_request_date;
              l_sales_team_rec.reassign_requested_person_id :=
                                    ST.reassign_requested_person_id;
              l_sales_team_rec.partner_cont_party_id:= ST.partner_cont_party_id;
              l_sales_team_rec.created_by_tap_flag := ST.created_by_tap_flag;
              l_sales_team_rec.prm_keep_flag := ST.prm_keep_flag;

              l_sales_team_rec.access_id := NULL;
              l_sales_team_rec.sales_lead_id := NULL;
              l_sales_team_rec.lead_id := l_lead_id;
              -- ffang 062502, bug 2432561
              -- ffang 031103, bug 2844916, don't pass lead's owner flag to opp st
              l_sales_team_rec.owner_flag := 'N';
              -- l_sales_team_rec.owner_flag := ST.owner_flag;
              -- end ffang 031103, bug 2844916
              -- end ffang 062502

              IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'Calling Create_SalesTeam');
              END IF;

              AS_ACCESS_PUB.Create_SalesTeam (
                   p_api_version_number         => 2.0
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,p_validation_level           => p_Validation_Level
                  ,p_access_profile_rec         => l_access_profile_rec
                  ,p_check_access_flag          => 'N'
                  ,p_admin_flag                 => P_Admin_Flag
                  ,p_admin_group_id             => P_Admin_Group_Id
                  ,p_identity_salesforce_id     => P_Identity_Salesforce_Id
                  ,p_sales_team_rec             => l_sales_team_rec
                  ,X_Return_Status              => x_Return_Status
                  ,X_Msg_Count                  => X_Msg_Count
                  ,X_Msg_Data                   => X_Msg_Data
                  ,x_access_id                  => l_Access_Id
              );

              IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'access_id : ' || l_Access_Id);
              END IF;
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;
          END LOOP;
      END IF;
      -- end ffang 051602, bug 2278318
      --Code added for Enhancement convert lead to opportunity - Attachment
      --Enhancement related Bug#3913225 @ @ Callling the procedure Copy_Attachments--changes for ASN.B--Start--
	OPEN C_Attachment_Exists(to_char(P_SALES_LEAD_ID));
	FETCH C_Attachment_Exists into l_val_exists;
	CLOSE C_Attachment_Exists;

	IF l_val_exists IS NOT NULL THEN
		--Copy attachments procedure calling
		FND_ATTACHED_DOCUMENTS2_PKG.Copy_Attachments(
		x_from_entity_name          => 'AS_LEAD_ATTCH',
		x_from_pk1_value            => to_char(P_SALES_LEAD_ID),
		x_to_entity_name            => 'AS_OPPORTUNITY_ATTCH',
		x_to_pk1_value              => to_char(x_opportunity_id),
		x_automatically_added_flag  => null,
		x_created_by                => G_USER_ID);

	ELSE
		NULL;
	END IF;
      --Enhancement related Bug#3913225 @ @ Callling the procedure Copy_Attachments--changes for ASN.B--End--
      -- Start Bug#3966128
         IF  nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') = 'Y'
	 AND l_Sales_Lead_Rec.incumbent_partner_party_id IS NOT NULL
	 AND l_Sales_Lead_Rec.incumbent_partner_resource_id IS NOT NULL
	 THEN
	    open c_address_id(l_Sales_Lead_Rec.incumbent_partner_party_id);
	    fetch c_address_id into l_address_id;
	    close c_address_id;
	    l_psalesteam_rec.customer_id:=l_Sales_Lead_Rec.customer_id;
	    l_psalesteam_rec.partner_customer_id:=l_Sales_Lead_Rec.incumbent_partner_party_id;
	    l_psalesteam_rec.partner_address_id:=l_address_id;
	    l_psalesteam_rec.lead_id:=x_opportunity_id;
	    l_psalesteam_rec.freeze_flag:='Y';
	    l_psalesteam_rec.salesforce_id:=l_Sales_Lead_Rec.incumbent_partner_resource_id;

	    AS_ACCESS_PUB.Create_SalesTeam(
	     p_api_version_number => 2.0,
	     p_init_msg_list      => FND_API.G_FALSE,
	     p_commit             => FND_API.G_FALSE,
	     p_validation_level   => p_Validation_Level,
	     p_access_profile_rec => l_access_profile_rec,
	     p_check_access_flag  => 'N',
	     p_admin_flag         => P_Admin_Flag,
	     p_admin_group_id     => P_Admin_Group_Id,
	     p_identity_salesforce_id => P_Identity_Salesforce_Id,
	     p_sales_team_rec       => l_psalesteam_rec,
	     x_return_status      => x_Return_Status,
	     x_msg_count          => X_Msg_Count,
	     x_msg_data           => X_Msg_Data,
	     x_access_id          => l_Access_Id);
              IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'access_id of preferred partner: ' || l_Access_Id);
              END IF;
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_ERROR;
              END IF;
	 END IF;
      -- End Bug#3966128

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, NULL, 'PVT: ' || l_api_name || ' End');
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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

END Create_Opportunity_For_Lead;

PROCEDURE Create_Lead_Ctx(
    p_sales_lead_id              IN   NUMBER,
    p_opportunity_id             IN   NUMBER,
    x_return_status              OUT NOCOPY VARCHAR2
    )
 IS
   l_jtf_notes_context_id  NUMBER;

   -- Selecting the JTF_NOTES_CONTEXT_ID.
   -- SELECT JTF_NOTES_S.NEXTVAL INTO l_jtf_notes_context_id FROM DUAL;

   CURSOR c_get_notes (x_sales_lead_id NUMBER, x_opportunity_id NUMBER) IS
     SELECT
         notes.jtf_note_id
     FROM
         JTF_NOTES_B notes
     WHERE
         notes.source_object_id = x_sales_lead_id AND
         notes.source_object_code = 'LEAD' AND
         NOT EXISTS  (
         SELECT
            context.jtf_note_id
         FROM
           JTF_NOTE_CONTEXTS context
         WHERE
            notes.jtf_note_id = context.jtf_note_id AND
            context.note_context_type = 'OPPORTUNITY' AND
            context.note_context_type_id = p_opportunity_id
         );


   BEGIN
     -- API savepoint
     -- commented for now may be break in a trigger
     -- SAVEPOINT Create_Lead_Ctx;

     -- Initialize return status to SUCCESS
     x_return_status := fnd_api.g_ret_sts_success;

     For notes_rec In c_get_notes (p_sales_lead_id, p_opportunity_id)
     Loop
              SELECT JTF_NOTES_S.NEXTVAL INTO l_jtf_notes_context_id FROM DUAL;

		-- Inserting into JTF_NOTES_CONTEXTS table
		INSERT INTO JTF_NOTE_CONTEXTS (
			NOTE_CONTEXT_ID
			, JTF_NOTE_ID
			, NOTE_CONTEXT_TYPE
			, NOTE_CONTEXT_TYPE_ID
			, LAST_UPDATE_DATE
			, LAST_UPDATED_BY
			, CREATION_DATE
			, CREATED_BY
			, LAST_UPDATE_LOGIN)
		values (
			l_jtf_notes_context_id,
			notes_rec.jtf_note_id ,
			'OPPORTUNITY'
			,p_opportunity_id,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.USER_ID);

     End Loop;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
          NULL;
       WHEN OTHERS THEN
          -- ROLLBACK TO Create_Lead_Ctx;
          x_return_status := fnd_api.g_ret_sts_error;


END Create_Lead_Ctx;

-- This procedure Added for Bug#3613374
PROCEDURE CHECK_SALES_STAGE(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level      	 IN    NUMBER   DEFAULT  FND_API.G_VALID_LEVEL_FULL,
    p_sales_lead_id		 IN    NUMBER,
    P_sales_lead_stage_id        IN    NUMBER,
    P_sales_lead_methodology_id  IN    NUMBER,
    X_sales_stage_id             OUT NOCOPY NUMBER,
    X_sales_methodology_id       OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2)
IS

cursor c_sales_stage(p_sales_stage_id NUMBER) is
   select applicability
     from as_sales_stages_all_vl
    where sales_stage_id = p_sales_stage_id;

cursor c_first_sales_stage(p_sales_method_id NUMBER) is
    SELECT  stage.sales_stage_id
      FROM  as_sales_stages_all_vl stage, as_sales_meth_stage_map map1
     WHERE  stage.sales_stage_id = map1.sales_stage_id
       AND  nvl(stage.applicability,'BOTH') in ('OPPORTUNITY', 'BOTH')
       AND  nvl(stage.ENABLED_FLAG,'Y') = 'Y'
       AND  trunc(sysdate) between trunc(nvl(START_DATE_ACTIVE,sysdate))
       AND  trunc(nvl(END_DATE_ACTIVE,sysdate))
       AND  map1.sales_methodology_id  =  p_sales_method_id
  ORDER BY  STAGE_SEQUENCE;

  l_sales_methodology_id  NUMBER := P_sales_lead_methodology_id;
  l_sales_stage_id        NUMBER := P_sales_lead_stage_id;
  l_applicability         VARCHAR2(100);
  l_api_name              CONSTANT VARCHAR2(40) := 'CHECK_SALES_STAGE';
  l_debug        BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_last_update_date date;
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.slopv.CHECK_SALES_STAGE';
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CHECK_SALES_STAGE_PVT;
      -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

  l_sales_methodology_id  := P_sales_lead_methodology_id;
  l_sales_stage_id        := P_sales_lead_stage_id;
   IF l_sales_methodology_id  IS NULL THEN
      l_sales_methodology_id := to_number(FND_PROFILE.VALUE ('AS_SALES_METHODOLOGY'));
      l_sales_stage_id       := to_number(FND_PROFILE.VALUE ('AS_OPP_SALES_STAGE'));
   END IF;

   IF l_sales_methodology_id  IS NULL THEN
      l_sales_stage_id := NULL;
   END IF;
   IF l_sales_methodology_id IS NOT NULL  THEN
       IF l_sales_stage_id IS NOT NULL THEN
          OPEN c_sales_stage(l_sales_stage_id);
          FETCH c_sales_stage INTO l_applicability;
          CLOSE c_sales_stage;
	END IF;
	IF l_sales_stage_id  IS NULL or
	   nvl(l_applicability,'BOTH') NOT IN ('OPPORTUNITY', 'BOTH') THEN
              OPEN c_first_sales_stage(l_sales_methodology_id);
	      FETCH c_first_sales_stage INTO l_sales_stage_id;
	      IF c_first_sales_stage%NOTFOUND THEN
		        AS_UTILITY_PVT.Set_Message(
			    p_module        => l_module,
			    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		            p_msg_name      => 'AS_STAGE_NOT_SETUP_FOR_METH');
 		        x_return_status :=FND_API.G_RET_STS_ERROR;
	      END IF;
	      CLOSE c_first_sales_stage;
	END IF;
     END IF;
    X_sales_stage_id       := l_sales_stage_id;
    X_sales_methodology_id := l_sales_methodology_id;
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
END CHECK_SALES_STAGE;

END AS_SALES_LEAD_OPP_PVT;

/
