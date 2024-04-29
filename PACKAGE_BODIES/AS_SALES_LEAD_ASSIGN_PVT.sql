--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_ASSIGN_PVT" as
/* $Header: asxvslab.pls 120.4 2006/01/27 17:44:57 solin noship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_ASSIGN_PVT
-- Purpose          : Sales Leads Assignment
-- NOTE             :
-- History          :
--      04/09/2001 FFANG  Created.
--      04/30/2001 SOLIN  Change for real time assignment and sales lead
--                        sales team.
--      07/09/2001 SOLIN  Change for JTF assignment manager change for
--                        bulk record.
--      07/25/2001 SOLIN  Enhancement bug 1732822.
--                        Set status_code to profile AS_LEAD_ROUTING_STATUS
--                        and accept_flag to 'N' when assign owner.
--      09/06/2001 SOLIN  Enhancement bug 1963262.
--                        Owner can decline sales lead.
--      09/27/2001 SOLIN  Creator get full access in sales lead sales team.
--      11/21/2001 SOLIN  New profile AS_ENABLE_LEAD_ONLINE_TAP.
--      12/04/2001 SOLIN  Bug 2137318
--                        Change for Oracle internal custom user hook.
--      12/10/2001 SOLIN  Bug 2102901.
--                        Add salesgroup_id for current user in
--                        Build_Lead_Sales_Team and Rebuild_Lead_Sales_Team
--      01/10/2002 SOLIN  Bug 2098158.
--                        Add p_PRIMARY_CNT_PERSON_PARTY_ID,
--                        p_PRIMARY_CONTACT_PHONE_ID when calling sales lead
--                        table handler.
--      02/10/2002 SOLIN  Change for CAPRI
--      05/14/2002 SOLIN  Bug 2364709.
--                        Set message if there's no channel manager for
--                        partner.
--                        Bug 2364567.
--                        Add partner to sales team even though lead
--                        is not created by partner.
--      06/02/2002 SOLIN  Bug 2395613.
--                        NULL index table key value.
--      08/13/2002 SOLIN  Bug 2503364, 2503366
--                        Change SQL to update AS_ACCESSES_ALL and
--                        AS_TERRITORY_ACCESSES
--      10/01/2002 SOLIN  Bug 2599946
--                        Remove as_changed_account_all record in
--                        Build_Lead_Sales_Team because sales lead record
--                        may be updated in lead creation process
--      11/04/2002 SOLIN  Enhancement Bug 2238553
--                        When owner is changed, don't change status.
--      11/18/2002 SOLIN  Change for NOCOPY and AS_UTILITY_PVT.Debug_Message
--      02/14/2003 SOLIN  Bug 2796513
--                        If owner was on the sales team with freeze_flag='Y'
--                        owner will still have freeze_flag='Y'
--      02/20/2003 SOLIN  Bug 2801769
--                        Remove checking for max reroute.
--      02/28/2003 SOLIN  Bug 2825108
--                        Lead creator should have KEEP flag 'Y'
--      03/03/2003 SOLIN  Bug 2825046
--                        Reassignment change for new lead lines.
--      03/14/2003 SOLIN  Bug 2852597
--                        Port 11.5.8 fix to 11.5.9.
--      03/20/2003 SOLIN  Bug 2831426
--                        Add open_flag in as_accesses_all table.
--      03/28/2003 SOLIN  Bug 2877597
--                        Change C_Validate_Salesforce cursor
--      04/17/2003 SOLIN  Bug 2899734, 2902742
--                        Change sql for trigger handlers.
--      04/23/2003 SOLIN  Bug 2921105
--                        Add channel_code in lead trigger.
--      04/28/2003 SOLIN  Bug 2926777
--                        Close_reason should be FND_API.G_MISS_CHAR when
--                        lead is reassigned.
--      04/30/2003 SOLIN  Bug 2931721
--                        Reset g_resource_id_tbl in Get_Available_Resource.
--      05/01/2003 SOLIN  Bug 2928041
--                        Add open_flag, object_creation_date, and
--                        lead_rank_score in as_accesses_all table
--      07/07/2003 SOLIN  Bug 3035251
--                        County qualifier doesn't work.
--                        Set UPPER for all VARCHAR2 qualifier.
--      07/10/2003 SOLIN  Bug 3046959(Bug 2983881 for 11.5.8)
--                        Change for new DUN's number qualifier
--      08/07/2003 SOLIN  Bug 3091085(Bug 3087354 for 11.5.8)
--                        Use JTF_QUAL_USGS_ALL, instead of JTF_QUAL_USGS(with
--                        security policies)
--      10/23/2003 SOLIN  ER 3052066
--                        Leave a record in as_changed_accounts after
--                        (Re)Build_lead_sales_team. TAP New mode need this
--                        record to sync TRANS and NM_TRANS table.
--      03/30/2004 SOLIN  Bug 3543801
--                        Long customer name issue
--                        Remove REPLACE in C_Get_Sales_Lead1 and
--                        C_Get_Sales_Lead2
--
-- END of Comments


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE CONSTANTS
 |
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEAD_ASSIGN_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvslab.pls';


/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE DATATYPES
 |
 *-------------------------------------------------------------------------*/
TYPE NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE FLAG_TABLE IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_30_TABLE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------*
 |
 |                             PRIVATE VARIABLES
 |
 *-------------------------------------------------------------------------*/
-- varray for insert (AS_ACCESSES_ALL)
g_i_access_id               NUMBER_TABLE;
g_i_resource_id             NUMBER_TABLE; -- salesforce_id
g_i_group_id                NUMBER_TABLE; -- sales_group_id
g_i_person_id               NUMBER_TABLE;
g_i_territory_id            NUMBER_TABLE;
g_i_party_id                NUMBER_TABLE; -- customer_id
g_i_party_site_id           NUMBER_TABLE; -- address_id
g_i_sales_lead_id           NUMBER_TABLE; -- sales_lead_id
g_i_full_access_flag        FLAG_TABLE;
g_i_owner_flag              FLAG_TABLE;
g_i_freeze_flag             FLAG_TABLE;
g_i_source                  VARCHAR2_30_TABLE;
g_i_partner_customer_id     NUMBER_TABLE;
g_i_partner_cont_party_id   NUMBER_TABLE;

-- varray for update (AS_ACCESSES_ALL)
g_u_access_id               NUMBER_TABLE;
g_u_full_access_flag        FLAG_TABLE;

-- varray for insert (AS_TERRITORY_ACCESSES)
g_ti_access_id              NUMBER_TABLE;
g_ti_territory_id           NUMBER_TABLE;

-- varray for update (AS_TERRITORY_ACCESSES)
g_tu_access_id              NUMBER_TABLE;
g_tu_territory_id           NUMBER_TABLE;


-- length of Insert array for AS_ACCESSES_ALL
g_i_count                   NUMBER := 0;
-- length of Update array for AS_ACCESSES_ALL
g_u_count                   NUMBER := 0;
-- length of Insert array for AS_TERRITORY_ACCESSES
g_ti_count                  NUMBER := 0;
-- length of Update array for AS_TERRITORY_ACCESSES
g_tu_count                  NUMBER := 0;


g_resource_id_tbl       AS_LEAD_ROUTING_WF.NUMBER_TABLE;
g_group_id_tbl          AS_LEAD_ROUTING_WF.NUMBER_TABLE;
g_person_id_tbl         AS_LEAD_ROUTING_WF.NUMBER_TABLE;

-- The follwing is the meaning of g_resource_flag_tbl:
-- 'D': This resource is the default resource from profile
--      AS_DEFAULT_RESOURCE_ID, "OS: Default Resource ID used for Sales
--      Lead Assignment".
-- 'L': This resource is the login user.
-- 'T': This resource is defined in territory.
g_resource_flag_tbl     AS_LEAD_ROUTING_WF.FLAG_TABLE;

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE  Insert_Access_Records(
    p_resource_id            IN     NUMBER,
    p_group_id               IN     NUMBER,
    p_full_access_flag       IN     VARCHAR2,
--    p_person_id              IN     NUMBER,
    p_territory_id           IN     NUMBER := NULL,
    p_party_id               IN     NUMBER,
    p_party_site_id          IN     NUMBER,
    p_partner_cont_party_id  IN     NUMBER := NULL,
    p_partner_customer_id    IN     NUMBER := NULL,
    p_sales_lead_id          IN     NUMBER,
    p_freeze_flag            IN     VARCHAR2,
    p_owner_flag             IN     VARCHAR2,
    p_source                 IN     VARCHAR2);

PROCEDURE  Create_Access_Records(
    p_resource_id            IN     NUMBER,
    p_group_id               IN     NUMBER,
    p_full_access_flag       IN     VARCHAR2,
--    p_person_id              IN     NUMBER,
    p_territory_id           IN     NUMBER,
    p_party_id               IN     NUMBER,
    p_party_site_id          IN     NUMBER,
    p_partner_cont_party_id  IN     NUMBER := NULL,
    p_partner_customer_id    IN     NUMBER := NULL,
    p_sales_lead_id          IN     NUMBER,
    p_freeze_flag            IN     VARCHAR2,
    p_source                 IN     VARCHAR2);

PROCEDURE Insert_Territory_Accesses(
    p_access_id              IN     NUMBER,
    p_territory_id           IN     NUMBER);

PROCEDURE Create_Territory_Accesses(
    p_access_id              IN     NUMBER,
    p_territory_id           IN     NUMBER);

PROCEDURE Flush_Access_Records(
    p_request_id             IN     NUMBER);

PROCEDURE Remove_Redundant_Accesses(
    p_sales_lead_id          IN     NUMBER,
    p_request_id             IN     NUMBER);

PROCEDURE Add_Creator_In_Sales_Team(
    p_customer_id            IN     NUMBER,
    p_address_id             IN     NUMBER,
    p_sales_lead_id          IN     NUMBER,
    p_identity_salesforce_id IN     NUMBER,
    p_salesgroup_id          IN     NUMBER);

PROCEDURE Oracle_Internal_CUHK(
    p_sales_lead_id          IN           NUMBER,
    p_salesgroup_id          IN           NUMBER,
    p_request_id             IN           NUMBER,
    x_return_status          OUT NOCOPY   VARCHAR2,
    x_msg_count              OUT NOCOPY   NUMBER,
    x_msg_data               OUT NOCOPY   VARCHAR2);

PROCEDURE Get_Partner_Lead_Owner(
    p_sales_lead_id          IN     NUMBER);

--   API Name:  Assign_Sales_Lead

PROCEDURE Assign_Sales_Lead (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN  VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id     IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN  AS_UTILITY_PUB.Profile_Tbl_Type
                                      := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_resource_type              IN  VARCHAR2    := NULL,
    P_role                       IN  VARCHAR2    := NULL,
    P_no_of_resources            IN  NUMBER      := 1,
    P_auto_select_flag           IN  VARCHAR2    := NULL,
    P_effort_duration            IN  NUMBER      := NULL,
    P_effort_uom                 IN  VARCHAR2    := NULL,
    P_start_date                 IN  DATE        := NULL,
    P_end_date                   IN  DATE        := NULL,
    P_territory_flag             IN  VARCHAR2    := 'Y',
    P_calendar_flag              IN  VARCHAR2    := 'Y',
    P_Sales_Lead_Id              IN  NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2,
    X_Assign_Id_Tbl              OUT NOCOPY AS_SALES_LEADS_PUB.Assign_Id_Tbl_Type
    )
 IS
    -- bug 1530383
    -- solin. Change the cursor for party with site, party without site.
    CURSOR C_Get_Address_Id(c_sales_lead_id NUMBER) IS
      SELECT SL.ADDRESS_ID
      FROM   AS_SALES_LEADS SL
      WHERE  SL.SALES_LEAD_ID = c_sales_lead_id;

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead1(X_Sales_Lead_Id NUMBER) IS
      SELECT SL.SALES_LEAD_ID,
             TO_NUMBER(NULL),
             UPPER(REPLACE(ADDR.CITY, '''', '''''')),
             UPPER(ADDR.POSTAL_CODE),
             UPPER(ADDR.STATE),
             UPPER(ADDR.PROVINCE),
             UPPER(REPLACE(ADDR.COUNTY, '''', '''''')),
             UPPER(ADDR.COUNTRY),
             SITE.PARTY_SITE_ID,
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(REPLACE(PARTY.PARTY_NAME, '''', '''''')),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             TO_NUMBER(NULL)
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_LOCATIONS ADDR,
             HZ_PARTY_SITES SITE,
             HZ_PARTIES PARTY
      WHERE  SL.SALES_LEAD_ID = X_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  SL.ADDRESS_ID = SITE.PARTY_SITE_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = 'HZ_PARTY_SITES'
        AND  PHONE.PRIMARY_FLAG(+) = 'Y'
        AND  PHONE.STATUS(+) = 'A'
        AND  PHONE.CONTACT_POINT_TYPE(+) = 'PHONE'
        AND  SITE.PARTY_SITE_ID = PHONE.OWNER_TABLE_ID(+)
        AND  SITE.LOCATION_ID = ADDR.LOCATION_ID
        AND  PARTY.PARTY_ID = SITE.PARTY_ID
        AND (PARTY.PARTY_TYPE = 'PERSON' OR PARTY.PARTY_TYPE = 'ORGANIZATION');

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead2(X_Sales_Lead_Id NUMBER) IS
      SELECT SL.SALES_LEAD_ID,
             NULL,
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_NUMBER(NULL),
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(REPLACE(PARTY.PARTY_NAME, '''', '''''')),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             NULL
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_PARTIES PARTY
      WHERE  SL.SALES_LEAD_ID = X_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = 'HZ_PARTIES'
        AND  PHONE.PRIMARY_FLAG(+) = 'Y'
        AND  PHONE.STATUS(+) = 'A'
        AND  PHONE.CONTACT_POINT_TYPE(+) = 'PHONE'
        AND  PARTY.PARTY_ID = PHONE.OWNER_TABLE_ID(+)
        AND (PARTY.PARTY_TYPE = 'PERSON' OR PARTY.PARTY_TYPE = 'ORGANIZATION');

    CURSOR C_Get_Sales_Group_Id (X_Resource_Id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
        and rrel.role_resource_type = 'RS_GROUP_MEMBER'
        and rrel.role_id = role.role_id
        and role.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
        and mem.delete_flag <> 'Y'
        and rrel.delete_flag <> 'Y'
        and sysdate between rrel.start_date_active and
                            nvl(rrel.end_date_active,sysdate)
        and mem.group_id = u.group_id
        and u.usage = 'SALES'
        and mem.group_id = grp.group_id
        and sysdate between grp.start_date_active and
                            nvl(grp.end_date_active,sysdate)
        and mem.resource_id = X_Resource_Id;

    l_api_name                     CONSTANT VARCHAR2(30) := 'Assign_Sales_Lead';
    l_api_version_number           CONSTANT NUMBER   := 2.0;
    l_AssignResources_Tbl          JTF_ASSIGN_PUB.AssignResources_Tbl_type;
                                -- JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_AssignResources_Rec          JTF_ASSIGN_PUB.AssignResources_Rec_type;
                                -- JTF_TERRITORY_PUB.JTF_Lead_rec_type;
    -- l_lead_rec                     JTF_ASSIGN_PUB.JTF_Lead_rec_type;
    l_lead_rec                     JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type;
    l_resource_id                  NUMBER;
    l_count                        INTEGER  := 0;
    l_identity_sales_member_rec    AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec           AS_ACCESS_PUB.Access_Profile_Rec_Type;

    l_data                         VARCHAR2(30);
    l_index_out                    NUMBER;
    l_check_calendar               VARCHAR2(1);
    l_address_id                   NUMBER := NULL;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT ASSIGN_SALES_LEAD_PVT;

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

/* ffang 112800
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

ffang 112800 */


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open Cursor C_Get_Sales_Lead');
      END IF;

      -- bug 1530383, use cursor for party with sites, party without sites.
      OPEN C_Get_Address_Id(p_Sales_Lead_Id);
      FETCH C_Get_Address_Id INTO l_address_id;
      CLOSE C_Get_Address_Id;

      -- One sales lead is supposed to have one record only, so we don't need
      -- a loop here.
      IF l_address_id IS NOT NULL
      THEN
          -- Sales lead is created in party site level.
          Open C_Get_Sales_Lead1(p_Sales_Lead_Id);
          Fetch C_Get_Sales_Lead1 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.PURCHASE_AMOUNT;
          CLOSE C_Get_Sales_Lead1;
      ELSE
          -- Sales lead is created in party level.
          Open C_Get_Sales_Lead2(p_Sales_Lead_Id);
          Fetch C_Get_Sales_Lead2 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.PURCHASE_AMOUNT;
          CLOSE C_Get_Sales_Lead2;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                             'SALES_LEAD_ID : ' || l_lead_rec.SALES_LEAD_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'CITY : ' || l_lead_rec.CITY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'POSTAL_CODE : ' || l_lead_rec.POSTAL_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'STATE : ' || l_lead_rec.STATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PROVINCE : ' || l_lead_rec.PROVINCE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'COUNTY : ' || l_lead_rec.COUNTY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'COUNTRY : ' || l_lead_rec.COUNTRY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'PARTY_SITE_ID : ' || l_lead_rec.PARTY_SITE_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'AREA_CODE : ' || l_lead_rec.AREA_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PARTY_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'CUSTOMER_NAME : ' || l_lead_rec.COMP_NAME_RANGE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PARTNER_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'NUM_OF_EMPLOYEES : ' || l_lead_rec.NUM_OF_EMPLOYEES(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'CATEGORY_CODE : ' || l_lead_rec.CATEGORY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'PARTY_RELATIONSHIP_ID : ' || l_lead_rec.PARTY_RELATIONSHIP_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'SIC_CODE : ' || l_lead_rec.SIC_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'BUDGET_AMOUNT : ' || l_lead_rec.BUDGET_AMOUNT(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'CURRENCY_CODE : ' || l_lead_rec.CURRENCY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'PRICING_DATE: ' || l_lead_rec.PRICING_DATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'PROMOTION_ID: ' || l_lead_rec.SOURCE_PROMOTION_ID(1));
      END IF;

      -- solin, use this profile to see whether we need calendar setup or not.
      l_check_calendar :=
             nvl(FND_PROFILE.Value('AS_SL_ASSIGN_CALENDAR_REQ'),'N');

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'Calling JTF_ASSIGN_PUB.Get_Assign_Lead_Resources');
      END IF;

      JTF_ASSIGN_PUB.Get_Assign_Lead_Resources (
            p_api_version                    => 1.0
           ,p_init_msg_list                  => JTF_ASSIGN_PUB.AM_FALSE
           -- ,p_commit                         => FND_API.G_FALSE
           ,p_resource_type                  => p_resource_type
           ,p_role                           => p_role
           ,p_no_of_resources                => p_no_of_resources
           ,p_auto_select_flag               => p_auto_select_flag
           ,p_effort_duration                => p_effort_duration
           ,p_effort_uom                     => p_effort_uom
           ,p_start_date                     => p_start_date
           ,p_end_date                       => p_end_date
           ,p_territory_flag                 => p_territory_flag
           -- ,p_calendar_flag                  => p_calendar_flag
           ,p_calendar_flag                  => l_check_calendar
           ,p_lead_rec                       => l_lead_rec
           ,x_assign_resources_tbl           => l_assignresources_tbl
           ,x_return_status                  => x_return_status
           ,x_msg_count                      => x_msg_count
           ,x_msg_data                       => x_msg_data
        );

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'After JTF_ASSIGN_PUB.Get_Assign_Lead_Resources:' ||
                         x_return_status);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'count=' || l_assignresources_tbl.count);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'first = '||l_assignresources_tbl.first);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'last = '||l_assignresources_tbl.last);
      END IF;

      IF x_return_status = 'E' THEN
            FND_MSG_PUB.Get (
                p_msg_index       => FND_MSG_PUB.G_LAST,
                p_encoded         => FND_API.G_TRUE ,
                p_data            => l_data,
                p_msg_index_out   => l_index_out
                );
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          l_data);
            END IF;

      ELSIF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		 IF (AS_DEBUG_LOW_ON) THEN
		 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                        'JTF AM failed');
		 END IF;
           -- exit;
           -- raise FND_API.G_EXC_ERROR;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'After JTF_ASSIGN_PUB.Get_Assign_Lead_Resources:');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
               'l_assignresources_tbl.count: ' || l_assignresources_tbl.count);
      END IF;

      l_count := l_AssignResources_tbl.COUNT;
      IF l_AssignResources_tbl.COUNT > 0 THEN
          For i In l_assignresources_tbl.first..l_assignresources_tbl.last
          Loop
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Resource ID(' || i || ') : ' ||
                                          l_AssignResources_tbl(i).Resource_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Group ID(' || i || ') : ' ||
                                          l_AssignResources_tbl(i).Group_Id);
              END IF;
              X_Assign_Id_Tbl(i).Sales_Group_Id
                                := l_AssignResources_tbl(i).group_Id;
              X_Assign_Id_Tbl(i).Resource_Id
                                := l_AssignResources_tbl(i).Resource_Id;
          END Loop;
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
END Assign_Sales_Lead;


PROCEDURE CALL_WF_TO_ASSIGN (
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN  VARCHAR2    := FND_API.G_FALSE,
    P_Sales_Lead_Id              IN  NUMBER,
    P_assigned_resource_id       IN  NUMBER      := NULL,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
    l_api_name                   CONSTANT VARCHAR2(30) := 'CALL_WF_TO_ASSIGN';
    l_api_version_number         CONSTANT NUMBER   := 2.0;
    l_itemtype                   VARCHAR2(8);
    l_itemkey                    VARCHAR2(50);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CALL_WF_TO_ASSIGN_PVT;

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

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling AS_LEAD_ROUTING_WF.STARTPROCESS');
      END IF;

      AS_LEAD_ROUTING_WF.STARTPROCESS (
         p_sales_lead_id        => p_sales_lead_id,
         p_salesgroup_id        => fnd_api.g_miss_num,
         x_return_status        => x_return_status,
         x_item_type            => l_itemtype,
         x_item_key             => l_itemkey );

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'x_return_status: '|| x_return_status);
      END IF;

	 -- verify the valid values of return_status from WF and handle them
      IF x_return_status = '#NULL' THEN
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          -- Will add these error messages to dictionary
      --     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
      --         'No assignment has been made.');
      ELSIF x_return_status = 'ERROR' THEN
          IF (AS_DEBUG_ERROR_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                       'AS_LEAD_ASSIGN_FAIL');
          END IF;
          RAISE FND_API.G_EXC_ERROR;

    -- code change for bug 1613424 start

      ELSIF x_return_status = 'W' THEN

		-- This is used to send the warning message stating that the
		-- resource id used is not form the territory setup

		x_return_status := 'W';

    -- code change for bug 1613424 end

      ELSE

          x_return_status := FND_API.G_RET_STS_SUCCESS;
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

END CALL_WF_TO_ASSIGN;

--   API Name:  Build_Lead_Sales_Team

PROCEDURE Build_Lead_Sales_Team(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Request_Id              OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID,
             SL.ADDRESS_ID,
             SL.ASSIGN_TO_SALESFORCE_ID,
             SL.ASSIGN_SALES_GROUP_ID,
             SL.REFERRAL_TYPE,
             SL.REFERRED_BY
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    CURSOR C_Validate_Partner_User(c_resource_id NUMBER) IS
      SELECT 'Y'
      FROM jtf_rs_resource_extns res
      WHERE res.category = 'PARTY'
      AND   res.resource_id = c_resource_id;

    CURSOR C_Get_CM(c_partner_id NUMBER) IS
      SELECT cm_id
      FROM pv_partner_profiles
      WHERE partner_id = c_partner_id;

    CURSOR C_Get_Partner_Name(c_referred_by NUMBER) IS
      SELECT party_name
      FROM hz_parties
      WHERE party_id = c_referred_by;

    -- If resource is partner user, source_id is party_id of the
    -- relationship.
    CURSOR C_Get_Partner_Cont_Party_id(c_resource_id NUMBER) IS
      SELECT source_id
      FROM jtf_rs_resource_extns
      WHERE resource_id = c_resource_id;

    CURSOR C_Get_Partner_Org_sf_id(c_referred_by NUMBER) IS
      SELECT resource_id
      FROM jtf_rs_resource_extns
      WHERE source_id = c_referred_by
      AND category = 'PARTNER';

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead1(C_Sales_Lead_Id NUMBER, c_hz_party_sites VARCHAR2,
                             c_status VARCHAR2, c_y VARCHAR2, c_phone VARCHAR2,
                             c_person VARCHAR2, c_organization VARCHAR2) IS
      SELECT SL.SALES_LEAD_ID,
             TO_NUMBER(NULL), -- sales_lead_line_id
             UPPER(ADDR.CITY),
             UPPER(ADDR.POSTAL_CODE),
             UPPER(ADDR.STATE),
             UPPER(ADDR.PROVINCE),
             UPPER(ADDR.COUNTY),
             UPPER(ADDR.COUNTRY),
             SITE.PARTY_SITE_ID,
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.PARTY_NAME),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE_TYPE) || ': ' || UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             TO_NUMBER(NULL), -- inventory_item_id
             TO_NUMBER(NULL), -- purchase_amount
             ORGP.CURR_FY_POTENTIAL_REVENUE,
             UPPER(ORGP.PREF_FUNCTIONAL_CURRENCY),
             UPPER(PARTY.DUNS_NUMBER_C),
             UPPER(SL.CHANNEL_CODE)
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_LOCATIONS ADDR,
             HZ_PARTY_SITES SITE,
             HZ_PARTIES PARTY,
             HZ_ORGANIZATION_PROFILES ORGP
      WHERE  SL.SALES_LEAD_ID = C_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  SL.ADDRESS_ID = SITE.PARTY_SITE_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = c_hz_party_sites -- 'HZ_PARTY_SITES'
        AND  PHONE.PRIMARY_FLAG(+) = c_y --'Y'
        AND  PHONE.STATUS(+) = c_status
        AND  PHONE.CONTACT_POINT_TYPE(+) = c_phone --'PHONE'
        AND  SITE.PARTY_SITE_ID = PHONE.OWNER_TABLE_ID(+)
        AND  SITE.LOCATION_ID = ADDR.LOCATION_ID
        AND  PARTY.PARTY_ID = SITE.PARTY_ID
        AND (PARTY.PARTY_TYPE = c_person OR PARTY.PARTY_TYPE = c_organization)
        AND  PARTY.PARTY_ID = ORGP.PARTY_ID(+)
        AND  NVL(ORGP.EFFECTIVE_END_DATE(+),SYSDATE + 1) > SYSDATE;

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead2(C_Sales_Lead_Id NUMBER, c_hz_parties VARCHAR2,
                             c_status VARCHAR2, c_y VARCHAR2, c_phone VARCHAR2,
                             c_person VARCHAR2, c_organization VARCHAR2) IS
      SELECT SL.SALES_LEAD_ID,
             TO_NUMBER(NULL), -- sales_lead_line_id
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_NUMBER(NULL),
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.PARTY_NAME),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE_TYPE) || ': ' || UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             TO_NUMBER(NULL), -- inventory_item_id
             TO_NUMBER(NULL), -- purchase_amount
             ORGP.CURR_FY_POTENTIAL_REVENUE,
             UPPER(ORGP.PREF_FUNCTIONAL_CURRENCY),
             UPPER(PARTY.DUNS_NUMBER_C),
             UPPER(SL.CHANNEL_CODE)
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_PARTIES PARTY,
             HZ_ORGANIZATION_PROFILES ORGP
      WHERE  SL.SALES_LEAD_ID = C_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = c_hz_parties --'HZ_PARTIES'
        AND  PHONE.PRIMARY_FLAG(+) = c_y --'Y'
        AND  PHONE.STATUS(+) = c_status
        AND  PHONE.CONTACT_POINT_TYPE(+) = c_phone --'PHONE'
        AND  PARTY.PARTY_ID = PHONE.OWNER_TABLE_ID(+)
        AND (PARTY.PARTY_TYPE = c_person OR PARTY.PARTY_TYPE = c_organization)
        AND  PARTY.PARTY_ID = ORGP.PARTY_ID(+)
        AND  NVL(ORGP.EFFECTIVE_END_DATE(+),SYSDATE + 1) > SYSDATE;

    CURSOR C_Explode_Resource_Team(c_team_id NUMBER) IS
      SELECT J.resource_id, J.group_id, J.person_id
      FROM
        (
          SELECT MIN(tm.team_resource_id) resource_id,
                 MIN(tm.person_id) person_id2, MIN(G.group_id) group_id,
                 MIN(t.team_id) team_id, tres.category resource_category,
                 MIN(TRES.source_id) person_id
          FROM   jtf_rs_team_members tm, jtf_rs_teams_b t,
                 jtf_rs_team_usages tu, jtf_rs_role_relations trr,
                 jtf_rs_roles_b tr, jtf_rs_resource_extns tres,
                 (
                   SELECT m.group_id group_id, m.resource_id resource_id
                   FROM   jtf_rs_group_members m, jtf_rs_groups_b g,
                          jtf_rs_group_usages u, jtf_rs_role_relations rr,
                          jtf_rs_roles_b r, jtf_rs_resource_extns res
                   WHERE
                          m.group_id = g.group_id
                   AND    SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                                      AND NVL(g.end_date_active,SYSDATE)
                   AND    u.group_id = g.group_id
                   AND    u.usage = 'SALES'
                   AND    m.group_member_id = rr.role_resource_id
                   AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
                   AND    rr.delete_flag <> 'Y'
                   AND    SYSDATE BETWEEN rr.start_date_active
                                  AND NVL(rr.end_date_active,SYSDATE)
                   AND    rr.role_id = r.role_id
                   AND    r.role_type_code IN
                          ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                   AND    r.active_flag = 'Y'
                   AND    res.resource_id = m.resource_id
                   AND    res.category = 'EMPLOYEE'
                 )  g
          WHERE tm.team_id = t.team_id
          AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
                            AND NVL(t.end_date_active,SYSDATE)
          AND   tu.team_id = t.team_id
          AND   tu.usage = 'SALES'
          AND   tm.team_member_id = trr.role_resource_id
          AND   tm.delete_flag <> 'Y'
          AND   tm.resource_type = 'INDIVIDUAL'
          AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
          AND   trr.delete_flag <> 'Y'
          AND   SYSDATE BETWEEN trr.start_date_active
                        AND NVL(trr.end_date_active,SYSDATE)
          AND   trr.role_id = tr.role_id
          AND   tr.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
          AND   tr.active_flag = 'Y'
          AND   tres.resource_id = tm.team_resource_id
          AND   tres.category = 'EMPLOYEE'
          AND   tm.team_resource_id = g.resource_id
          GROUP BY tm.team_member_id, tm.team_resource_id, tm.person_id,
                t.team_id, tres.category
          UNION
          SELECT MIN(m.resource_id) resource_id,
                 MIN(m.person_id) person_id2, MIN(m.group_id) group_id,
                 MIN(jtm.team_id) team_id, res.category resource_category,
                 MIN(res.source_id) person_id
          FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
                jtf_rs_group_usages u, jtf_rs_role_relations rr,
                jtf_rs_roles_b r, jtf_rs_resource_extns res,
                (
                  Select tm.team_resource_id group_id, t.team_id team_id
                  From   jtf_rs_team_members tm, jtf_rs_teams_b t,
                         jtf_rs_team_usages tu, jtf_rs_role_relations trr,
                         jtf_rs_roles_b tr, jtf_rs_resource_extns tres
                  Where  tm.team_id = t.team_id
                  and    sysdate between nvl(t.start_date_active,sysdate)
                                     and nvl(t.end_date_active,sysdate)
                  and   tu.team_id = t.team_id
                  and   tu.usage = 'SALES'
                  and   tm.team_member_id = trr.role_resource_id
                  and   tm.delete_flag <> 'Y'
                  and   tm.resource_type = 'GROUP'
                  and   trr.role_resource_type = 'RS_TEAM_MEMBER'
                  and   trr.delete_flag <> 'Y'
                  and   sysdate between trr.start_date_active and
                                     nvl(trr.end_date_active,sysdate)
                  and   trr.role_id = tr.role_id
                  and   tr.role_type_code in
                        ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                  and   tr.active_flag = 'Y'
                  and   tres.resource_id = tm.team_resource_id
                  and   tres.category = 'EMPLOYEE'
                  ) jtm
           WHERE m.group_id = g.group_id
           AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                             AND NVL(g.end_date_active,SYSDATE)
           AND   u.group_id = g.group_id
           AND   u.usage = 'SALES'
           AND   m.group_member_id = rr.role_resource_id
           AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
           AND   rr.delete_flag <> 'Y'
           AND   SYSDATE BETWEEN rr.start_date_active
                         AND NVL(rr.end_date_active,SYSDATE)
           AND   rr.role_id = r.role_id
           AND   r.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
           AND   r.active_flag = 'Y'
           AND   res.resource_id = m.resource_id
           AND   res.category = 'EMPLOYEE'
           AND   jtm.group_id = g.group_id
           GROUP BY m.resource_id, m.person_id, jtm.team_id, res.category
                ) J
        WHERE j.team_id = c_team_id;

    CURSOR C_Explode_Resource_Group(c_group_id NUMBER) IS
      SELECT J.resource_id, J.group_id, J.person_id
      FROM
        (
          SELECT MIN(m.resource_id) resource_id,
                 res.category resource_category,
                 MIN(m.group_id) group_id,MIN(res.source_id) person_id
          FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
                jtf_rs_group_usages u, jtf_rs_role_relations rr,
                jtf_rs_roles_b r, jtf_rs_resource_extns res
          WHERE
                m.group_id = g.group_id
          AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                            AND NVL(g.end_date_active,SYSDATE)
          AND   u.group_id = g.group_id
          AND   u.usage = 'SALES'
          AND   m.group_member_id = rr.role_resource_id
          AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
          AND   rr.role_id = r.role_id
          AND   rr.delete_flag <> 'Y'
          AND   SYSDATE BETWEEN rr.start_date_active
                        AND NVL(rr.end_date_active,SYSDATE)
          AND   r.role_type_code IN
                ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
          AND   r.active_flag = 'Y'
          AND   res.resource_id = m.resource_id
          AND   res.category = 'EMPLOYEE'
          GROUP BY m.group_member_id, m.resource_id, m.person_id,
                   m.group_id, res.category) j
      WHERE j.group_id = c_group_id;

    Cursor C_Validate_Salesforce(C_Resource_Id NUMBER, c_rs_individual VARCHAR2,
                                 c_sales VARCHAR2, c_telesales VARCHAR2,
                                 c_fieldsales VARCHAR2, c_prm VARCHAR2,
                                 c_n VARCHAR2, c_employee VARCHAR2) IS
      SELECT 'Y'
      FROM   per_all_people_f per,
             jtf_rs_resource_extns res,
             jtf_rs_role_relations rrel,
             jtf_rs_roles_b role
      WHERE  TRUNC(SYSDATE) BETWEEN per.effective_start_date
             AND per.effective_end_date
      AND    res.resource_id = rrel.role_resource_id
      AND    rrel.role_resource_type = c_rs_individual --'RS_INDIVIDUAL'
      AND    rrel.role_id = role.role_id
      AND    role.role_type_code IN (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES', 'TELESALES', 'FIELDSALES', 'PRM')
      AND    NVL(role.admin_flag, 'N') = c_n --'N'
      AND    res.source_id = per.person_id
      AND    res.resource_id = C_Resource_Id
      AND    res.category = c_employee; --'EMPLOYEE';

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category IN ('EMPLOYEE', 'PARTY')
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member VARCHAR2,
                           c_sales VARCHAR2, c_telesales VARCHAR2,
                           c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y VARCHAR2) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = c_rs_group_member --'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> c_y --'Y'
      AND rrel.delete_flag <> c_y --'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = c_sales --'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- Get sequence
    CURSOR c_get_conseq_cur IS
    SELECT fnd_concurrent_requests_s.nextval
    FROM   dual;

    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Build_Lead_Sales_Team';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_customer_id               NUMBER;
    l_address_id                NUMBER;
    l_assign_to_salesforce_id   NUMBER;
    l_assign_sales_group_id     NUMBER;
    l_referral_type             VARCHAR2(30);
    l_referred_by               NUMBER;
    l_partner_flag              VARCHAR2(1) := 'N';
    l_partner_cont_party_id     NUMBER;
    l_partner_org_sf_id         NUMBER;
    l_partner_name              VARCHAR2(360);

    l_lead_owner_tbl            AS_SALES_LEAD_OWNER.lead_owner_rec_tbl_type;

    l_AssignResources_Tbl       JTF_ASSIGN_PUB.AssignResources_Tbl_type;
                             -- JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_AssignResources_Rec       JTF_ASSIGN_PUB.AssignResources_Rec_type;
                             -- JTF_TERRITORY_PUB.JTF_Lead_rec_type;
--    l_lead_rec                  JTF_ASSIGN_PUB.JTF_Lead_rec_type;
    l_lead_rec                  JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type;
    l_return_status             VARCHAR2(10);
    l_count                     INTEGER  := 0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;

    l_data                      VARCHAR2(70);
    l_index_out                 NUMBER;


    -- The following variables are for as_accesses_all
    l_access_id_tbl             NUMBER_TABLE;
    l_owner_flag_tbl            FLAG_TABLE;

    -- The following variables are for as_territory_accesses
    l_ta_access_id_tbl          NUMBER_TABLE;
    l_ta_terr_id_tbl            NUMBER_TABLE;

    -- index of the above variables
    l_index                     NUMBER;
    l_ta_index                  NUMBER;

    l_access_id                 NUMBER;
    l_terr_id                   NUMBER;
    l_resource_id               NUMBER;
    l_group_id                  NUMBER;
    l_person_id                 NUMBER;
    l_team_leader_flag          VARCHAR2(1);
    l_found_flag                VARCHAR2(1);
    l_found_flag2               VARCHAR2(1);
    l_process_flag              VARCHAR2(1);
    l_salesforce_flag           VARCHAR2(1);
    l_assign_manual_flag        VARCHAR2(1);
    l_request_id                NUMBER;

    l_rs_id                     NUMBER;
    l_itemtype                  VARCHAR2(8);
    l_itemkey                   VARCHAR2(30);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT BUILD_LEAD_SALES_TEAM_PVT;

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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN C_Get_Lead_Info(p_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO
          l_customer_id, l_address_id, l_assign_to_salesforce_id,
          l_assign_sales_group_id, l_referral_type, l_referred_by;
      CLOSE C_Get_Lead_Info;

      IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'N' AND
         l_assign_to_salesforce_id IS NOT NULL
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Online TAP disabled/owner exist');
          END IF;
          Add_Creator_In_Sales_Team(l_customer_id, l_address_id,
              p_sales_lead_id, p_identity_salesforce_id, p_salesgroup_id);
          -- Standard call to get message count and IF count is 1,
          -- get message info.
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );

          RETURN;
      END IF;

      OPEN C_Validate_Partner_User(p_identity_salesforce_id);
      FETCH C_Validate_Partner_User INTO l_partner_flag;
      CLOSE C_Validate_Partner_User;

      g_i_count := 0;
      g_u_count := 0;
      g_ti_count := 0;
      g_tu_count := 0;

      -- Referral type is not null, for CAPRI
      IF l_referral_type IS NOT NULL
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Referral_type is ' || l_referral_type);
          END IF;

          AS_SALES_LEAD_OWNER.Get_Salesreps(
              p_api_version       => 2.0
             ,p_init_msg_list     => FND_API.g_false
             ,p_commit            => FND_API.g_false
             ,p_validation_level  => p_Validation_Level
             ,p_sales_lead_id     => p_sales_lead_id
             ,x_salesreps_tbl     => l_lead_owner_tbl
             ,x_return_status     => l_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data          => x_msg_data);

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'owner count=' || l_lead_owner_tbl.count);
          END IF;

          IF l_lead_owner_tbl.count > 0
          THEN
              FOR i IN l_lead_owner_tbl.first..l_lead_owner_tbl.last
              LOOP
                  OPEN c_get_group_id (l_lead_owner_tbl(i).cm_resource_id,
                      'RS_GROUP_MEMBER', 'SALES',
                      'TELESALES', 'FIELDSALES', 'PRM', 'Y');
                  FETCH c_get_group_id INTO l_group_id;
                  CLOSE c_get_group_id;

                  Insert_Access_Records(
                      p_resource_id      => l_lead_owner_tbl(i).cm_resource_id,
                      p_group_id         => l_group_id,
                      p_full_access_flag => 'Y',
                      p_party_id         => l_customer_id,
                      p_party_site_id    => l_address_id,
                      p_sales_lead_id    => p_sales_lead_id,
                      p_freeze_flag      => 'Y',
                      p_owner_flag       => l_lead_owner_tbl(i).owner_flag,
                      p_source           => 'LDOWNER');

              END LOOP;
          END IF;
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'referred_by=' || l_referred_by);
          END IF;

          OPEN C_Get_CM(l_referred_by);
          FETCH C_Get_CM INTO l_resource_id;
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'cm_id=' || l_resource_id);
          END IF;
          IF C_Get_CM%FOUND AND l_resource_id IS NOT NULL
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Add CM of referred by');
              END IF;
              OPEN c_get_group_id (l_resource_id, 'RS_GROUP_MEMBER', 'SALES',
                  'TELESALES', 'FIELDSALES', 'PRM', 'Y');
              FETCH c_get_group_id INTO l_group_id;
              CLOSE c_get_group_id;

              Insert_Access_Records(
                  p_resource_id      => l_resource_id,
                  p_group_id         => l_group_id,
                  p_full_access_flag => 'Y',
                  p_party_id         => l_customer_id,
                  p_party_site_id    => l_address_id,
                  p_sales_lead_id    => p_sales_lead_id,
                  p_freeze_flag      => 'Y',
                  p_owner_flag       => 'Y',
                  p_source           => 'LDOWNER');
          ELSE
              -- Bug 2364709.
              -- Set message if there's no channel manager
              IF C_Get_CM%FOUND
              THEN
                  -- l_resource_id must be null in this case.
                  OPEN C_Get_Partner_Name(l_referred_by);
                  FETCH C_Get_Partner_Name INTO l_partner_name;
                  CLOSE C_Get_Partner_Name;
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'AS_CM_NOT_DEFINED_FOR_PARTNER',
                      p_token1        => 'PARTNER_NAME',
                      p_token1_value  => l_partner_name);
              END IF;
          END IF;
          CLOSE C_Get_CM;

          IF l_partner_flag = 'Y'
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'partner user=' || p_identity_salesforce_id);
              END IF;
              OPEN C_Get_Partner_Cont_Party_id(p_identity_salesforce_id);
              FETCH C_Get_Partner_Cont_Party_id INTO l_partner_cont_party_id;
              CLOSE C_Get_Partner_Cont_Party_id;

              Insert_Access_Records(
                  p_resource_id           => p_identity_salesforce_id,
                  p_group_id              => p_salesgroup_id,
                  p_full_access_flag      => 'Y',
                  p_party_id              => l_customer_id,
                  p_party_site_id         => l_address_id,
                  p_partner_cont_party_id => l_partner_cont_party_id,
                  p_sales_lead_id         => p_sales_lead_id,
                  p_freeze_flag           => 'Y',
                  p_owner_flag            => 'N',
                  p_source                => 'CREATOR');
          END IF; -- l_partner_flag = 'Y'

          -- Bug 2364567.
          -- Add partner in sales team even though lead is not created
          -- by partner
          OPEN C_Get_Partner_Org_sf_id(l_referred_by);
          FETCH C_Get_Partner_Org_sf_id INTO l_partner_org_sf_id;
          CLOSE C_Get_Partner_Org_sf_id;
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'partner org=' || l_partner_org_sf_id);
          END IF;

          Insert_Access_Records(
              p_resource_id         => l_partner_org_sf_id,
              p_group_id            => NULL,
              p_full_access_flag    => 'Y',
              p_party_id            => l_customer_id,
              p_party_site_id       => l_address_id,
              p_partner_customer_id => l_referred_by,
              p_sales_lead_id       => p_sales_lead_id,
              p_freeze_flag         => 'Y',
              p_owner_flag          => 'N',
              p_source              => 'CREATOR');
      END IF; -- l_referral_type IS NOT NULL

      l_lead_rec.squal_num06.extend;
      l_lead_rec.TRANS_OBJECT_ID.extend;

      IF l_address_id IS NOT NULL
      THEN
          -- Sales lead is created in party site level.
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Open C_Get_Sales_Lead1');
          END IF;
          OPEN C_Get_Sales_Lead1(p_Sales_Lead_Id, 'HZ_PARTY_SITES', 'A',
                                 'Y', 'PHONE', 'PERSON', 'ORGANIZATION');
          FETCH C_Get_Sales_Lead1 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.INVENTORY_ITEM_ID,
              l_lead_rec.PURCHASE_AMOUNT,
              l_lead_rec.SQUAL_NUM01,
              l_lead_rec.CAR_CURRENCY_CODE,
              l_lead_rec.SQUAL_CHAR11,
              l_lead_rec.SQUAL_CHAR30;
          CLOSE C_Get_Sales_Lead1;
      ELSE
          -- Sales lead is created in party level.
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'Open C_Get_Sales_Lead2');
          END IF;
          OPEN C_Get_Sales_Lead2(p_Sales_Lead_Id, 'HZ_PARTIES', 'A',
                                 'Y', 'PHONE', 'PERSON', 'ORGANIZATION');
          FETCH C_Get_Sales_Lead2 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.INVENTORY_ITEM_ID,
              l_lead_rec.PURCHASE_AMOUNT,
              l_lead_rec.SQUAL_NUM01,
              l_lead_rec.CAR_CURRENCY_CODE,
              l_lead_rec.SQUAL_CHAR11,
              l_lead_rec.SQUAL_CHAR30;
          CLOSE C_Get_Sales_Lead2;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'sales_lead_id.count='|| l_lead_rec.sales_lead_id.count);
      END IF;
      IF l_lead_rec.sales_lead_id.count = 0
      THEN
          -- customer_id and address_id of this sales lead don't match each
          -- other, don't do any change and return.
          RETURN;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SALES_LEAD_ID : ' || l_lead_rec.SALES_LEAD_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CITY : ' || l_lead_rec.CITY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'POSTAL_CODE : ' || l_lead_rec.POSTAL_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'STATE : ' || l_lead_rec.STATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PROVINCE : ' || l_lead_rec.PROVINCE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'COUNTY : ' || l_lead_rec.COUNTY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'COUNTRY : ' || l_lead_rec.COUNTRY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_SITE_ID : ' || l_lead_rec.PARTY_SITE_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'AREA_CODE : ' || l_lead_rec.AREA_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CUSTOMER_NAME : ' || l_lead_rec.COMP_NAME_RANGE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTNER_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'NUM_OF_EMPLOYEES : ' || l_lead_rec.NUM_OF_EMPLOYEES(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CATEGORY_CODE : ' || l_lead_rec.CATEGORY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_RELATIONSHIP_ID : ' || l_lead_rec.PARTY_RELATIONSHIP_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SIC_CODE : ' || l_lead_rec.SIC_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'BUDGET_AMOUNT : ' || l_lead_rec.BUDGET_AMOUNT(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CURRENCY_CODE : ' || l_lead_rec.CURRENCY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PRICING_DATE: ' || l_lead_rec.PRICING_DATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PROMOTION_ID: ' || l_lead_rec.SOURCE_PROMOTION_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SQUAL_NUM01: ' || l_lead_rec.SQUAL_NUM01(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CAR_CURRENCY_CODE: ' || l_lead_rec.CAR_CURRENCY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'DUNS_NUMBER_C: ' || l_lead_rec.SQUAL_CHAR11(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CHANNEL_CODE: ' || l_lead_rec.SQUAL_CHAR30(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Calling JTF_ASSIGN_PUB.Get_Assign_Lead_Resources');
      END IF;

      JTF_ASSIGN_PUB.Get_Assign_Lead_Resources (
            p_api_version                    => 1.0
           ,p_init_msg_list                  => JTF_ASSIGN_PUB.AM_FALSE
           -- ,p_commit                         => FND_API.G_FALSE
           ,p_resource_type                  => NULL
           ,p_role                           => NULL
           ,p_no_of_resources                => 999
           ,p_auto_select_flag               => NULL
           ,p_effort_duration                => 8
           ,p_effort_uom                     => 'HR'
           ,p_start_date                     => SYSDATE-1
           ,p_end_date                       => SYSDATE+1
           ,p_territory_flag                 => 'Y'
           ,p_calendar_flag                  => 'N'
           ,p_lead_rec                       => l_lead_rec
           ,x_assign_resources_tbl           => l_assignresources_tbl
           ,x_return_status                  => l_return_status
           ,x_msg_count                      => x_msg_count
           ,x_msg_data                       => x_msg_data
        );

      IF l_return_status = 'E'
      THEN
          FND_MSG_PUB.Get (
              p_msg_index       => FND_MSG_PUB.G_LAST,
              p_encoded         => FND_API.G_TRUE ,
              p_data            => l_data,
              p_msg_index_out   => l_index_out
              );
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              l_data);
          END IF;

      ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'count=' || l_assignresources_tbl.count);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'first = '||l_assignresources_tbl.first);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'last = '||l_assignresources_tbl.last);
      END IF;

      l_count := l_AssignResources_tbl.COUNT;
      l_index := 1;
      l_ta_index := 1;
      IF l_AssignResources_tbl.COUNT > 0
      THEN
          FOR i IN l_AssignResources_tbl.first..l_AssignResources_tbl.last
          LOOP
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Terr ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Terr_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Resource ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Resource_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Group ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Group_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Role(' || i || ') : '
                  || l_AssignResources_tbl(i).Role);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Full_Access_Flag(' || i || ') : '
                  || l_AssignResources_tbl(i).Full_Access_Flag);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Resource_Type(' || i || ') : '
                  || l_AssignResources_tbl(i).Resource_Type);
              END IF;

              IF l_AssignResources_tbl(i).Resource_Type = 'RS_TEAM'
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Resource Team found');
                  END IF;
                  OPEN C_Explode_Resource_Team(
                           l_AssignResources_tbl(i).Resource_Id);
                  LOOP
                      FETCH C_Explode_Resource_Team INTO
                          l_resource_id, l_group_id, l_person_id;
                      EXIT WHEN C_Explode_Resource_Team%NOTFOUND;
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Resource_Id: ' || l_resource_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Group_Id: ' || l_group_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Person_Id: ' || l_person_id);
                      END IF;
                      Insert_Access_Records(
                          p_resource_id      => l_resource_id,
                          p_group_id         => l_group_id,
                          p_full_access_flag =>
                              l_AssignResources_tbl(i).Full_Access_Flag,
                          p_territory_id     =>
                              l_AssignResources_tbl(i).Terr_Id,
                          p_party_id         => l_customer_id,
                          p_party_site_id    => l_address_id,
                          p_sales_lead_id    => p_sales_lead_id,
                          p_freeze_flag      => 'N',
                          p_owner_flag       => 'N',
                          p_source           => 'TERRITORY');
                  END LOOP;
                  CLOSE C_Explode_Resource_Team;
              ELSIF l_AssignResources_tbl(i).Resource_Type = 'RS_GROUP'
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Resource Group found');
                  END IF;
                  OPEN C_Explode_Resource_Group(
                           l_AssignResources_tbl(i).Resource_Id);
                  LOOP
                      FETCH C_Explode_Resource_Group INTO
                          l_resource_id, l_group_id, l_person_id;
                      EXIT WHEN C_Explode_Resource_Group%NOTFOUND;
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Resource_Id: ' || l_resource_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Group_Id: ' || l_group_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Person_Id: ' || l_person_id);
                      END IF;
                      Insert_Access_Records(
                          p_resource_id      => l_resource_id,
                          p_group_id         => l_group_id,
                          p_full_access_flag =>
                              l_AssignResources_tbl(i).Full_Access_Flag,
                          p_territory_id     =>
                              l_AssignResources_tbl(i).Terr_Id,
                          p_party_id         => l_customer_id,
                          p_party_site_id    => l_address_id,
                          p_sales_lead_id    => p_sales_lead_id,
                          p_freeze_flag      => 'N',
                          p_owner_flag       => 'N',
                          p_source           => 'TERRITORY');
                  END LOOP;
                  CLOSE C_Explode_Resource_Group;
              ELSE
                  -- not resource team or resource group
                  l_salesforce_flag := 'N';
                  OPEN C_Validate_Salesforce(
                      l_AssignResources_tbl(i).Resource_Id,
                      'RS_INDIVIDUAL', 'SALES', 'TELESALES',
                      'FIELDSALES', 'PRM', 'N', 'EMPLOYEE');
                  FETCH C_Validate_Salesforce INTO l_salesforce_flag;
                  CLOSE C_Validate_Salesforce;

                  IF l_salesforce_flag = 'Y'
                  THEN
                      Insert_Access_Records(
                          p_resource_id      =>
                              l_AssignResources_tbl(i).Resource_Id,
                          p_group_id         =>
                              l_AssignResources_tbl(i).Group_Id,
                          p_full_access_flag =>
                              l_AssignResources_tbl(i).Full_Access_Flag,
                          p_territory_id     =>
                              l_AssignResources_tbl(i).Terr_Id,
                          p_party_id         => l_customer_id,
                          p_party_site_id    => l_address_id,
                          p_sales_lead_id    => p_sales_lead_id,
                          p_freeze_flag      => 'N',
                          p_owner_flag       => 'N',
                          p_source           => 'TERRITORY');
                  ELSE
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'rs_id ' ||
                              l_AssignResources_tbl(i).Resource_Id ||
                              ' is not salesforce');
                      END IF;
                  END IF; -- l_salesforce_flag = 'Y'
              END IF; -- resource type
          END LOOP; -- l_AssignResources_tbl.first..l_AssignResources_tbl.last
      END IF; -- l_AssignResources_tbl.COUNT > 0

      l_request_id := FND_GLOBAL.Conc_Request_Id;
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'req_id :' || l_request_id);
      END IF;
      IF l_request_id = 0 OR l_request_id = -1
      THEN
          -- If l_request_id = 0 or -1, select directly from sequence
          OPEN c_get_conseq_cur;
          FETCH c_get_conseq_cur INTO l_request_id;
          CLOSE c_get_conseq_cur;
      END IF;
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'req_id :' || l_request_id);
      END IF;

      IF l_assign_to_salesforce_id IS NOT NULL
      THEN
          -- Check whether user assigned owner is in the list or not.
          l_index := g_i_count;
          l_found_flag := 'N';
          WHILE l_index > 0
          LOOP
              IF g_i_resource_id(l_index) = l_assign_to_salesforce_id AND
                 NVL(g_i_group_id(l_index),-1) = NVL(l_assign_sales_group_id,-1)
              THEN
                  l_found_flag := 'Y';
                  EXIT;
              END IF;
              l_index := l_index - 1;
          END LOOP;
          IF l_found_flag = 'Y'
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'l_index=' || l_index || ',same as assignee');
              END IF;
              IF l_index < g_i_count
              THEN
                  WHILE l_index < g_i_count
                  LOOP
                      g_i_access_id(l_index) := g_i_access_id(l_index+1);
                      g_i_resource_id(l_index) := g_i_resource_id(l_index+1);
                      g_i_group_id(l_index) := g_i_group_id(l_index+1);
                      g_i_territory_id(l_index) := g_i_territory_id(l_index+1);
                      g_i_party_id(l_index) := g_i_party_id(l_index+1);
                      g_i_party_site_id(l_index) :=
                          g_i_party_site_id(l_index+1);
                      g_i_sales_lead_id(l_index) :=
                          g_i_sales_lead_id(l_index+1);
                      g_i_full_access_flag(l_index) :=
                          g_i_full_access_flag(l_index+1);
                      g_i_owner_flag(l_index) := g_i_owner_flag(l_index+1);
                      g_i_freeze_flag(l_index) := g_i_freeze_flag(l_index+1);
                      g_i_source(l_index) := g_i_source(l_index+1);
                      g_i_partner_cont_party_id(l_index) :=
                          g_i_partner_cont_party_id(l_index+1);
                      g_i_partner_customer_id(l_index) :=
                          g_i_partner_customer_id(l_index+1);

                      l_index := l_index + 1;
                  END LOOP;
              END IF;
              g_i_access_id.delete(g_i_count);
              g_i_resource_id.delete(g_i_count);
              g_i_group_id.delete(g_i_count);
              g_i_territory_id.delete(g_i_count);
              g_i_party_id.delete(g_i_count);
              g_i_party_site_id.delete(g_i_count);
              g_i_sales_lead_id.delete(g_i_count);
              g_i_full_access_flag.delete(g_i_count);
              g_i_owner_flag.delete(g_i_count);
              g_i_freeze_flag.delete(g_i_count);
              g_i_source.delete(g_i_count);
              g_i_partner_cont_party_id.delete(g_i_count);
              g_i_partner_customer_id.delete(g_i_count);
              g_i_count := g_i_count - 1;
          END IF; -- l_found_flag = 'Y'
      END IF; -- l_assign_to_salesforce_id IS NOT NULL

      Flush_Access_Records(l_request_id);

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'assign_to_sf_id=' || l_assign_to_salesforce_id);
      END IF;

      Add_Creator_In_Sales_Team(l_customer_id, l_address_id,
          p_sales_lead_id, p_identity_salesforce_id, p_salesgroup_id);

      x_request_id := l_request_id;
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
END Build_Lead_Sales_Team;


--   API Name:  Rebuild_Lead_Sales_Team

PROCEDURE Rebuild_Lead_Sales_Team(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2    := FND_API.G_FALSE,
    p_Commit                  IN  VARCHAR2    := FND_API.G_FALSE,
    p_Validation_Level        IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Admin_Group_Id          IN  NUMBER      := FND_API.G_MISS_NUM,
    P_identity_salesforce_id  IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Salesgroup_id           IN  NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Id           IN  NUMBER,
    X_Request_id              OUT NOCOPY NUMBER,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )
 IS
    CURSOR C_Check_Changed(C_Sales_Lead_Id NUMBER) IS
      SELECT ADDRESS_ID
      FROM AS_CHANGED_ACCOUNTS_ALL
      WHERE SALES_LEAD_ID = C_Sales_Lead_Id
      AND PROCESSED_FLAG = 'N';

    CURSOR C_Get_Lead_Info(C_Sales_Lead_Id NUMBER) IS
      SELECT SL.CUSTOMER_ID,
             SL.ADDRESS_ID,
             SL.ASSIGN_TO_SALESFORCE_ID,
             SL.ASSIGN_SALES_GROUP_ID,
             SL.REJECT_REASON_CODE
      FROM AS_SALES_LEADS SL
      WHERE SL.SALES_LEAD_ID = C_Sales_Lead_Id;

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead1(C_Sales_Lead_Id NUMBER, c_hz_party_sites VARCHAR2,
                             c_status VARCHAR2, c_y VARCHAR2, c_phone VARCHAR2,
                             c_person VARCHAR2, c_organization VARCHAR2) IS
      SELECT SL.SALES_LEAD_ID,
             TO_NUMBER(NULL), -- sales_lead_line_id
             UPPER(ADDR.CITY),
             UPPER(ADDR.POSTAL_CODE),
             UPPER(ADDR.STATE),
             UPPER(ADDR.PROVINCE),
             UPPER(ADDR.COUNTY),
             UPPER(ADDR.COUNTRY),
             SITE.PARTY_SITE_ID,
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.PARTY_NAME),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE_TYPE) || ': ' || UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             TO_NUMBER(NULL), -- inventory_item_id
             TO_NUMBER(NULL), -- purchase_amount
             ORGP.CURR_FY_POTENTIAL_REVENUE,
             UPPER(ORGP.PREF_FUNCTIONAL_CURRENCY),
             UPPER(PARTY.DUNS_NUMBER_C),
             UPPER(SL.CHANNEL_CODE)
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_LOCATIONS ADDR,
             HZ_PARTY_SITES SITE,
             HZ_PARTIES PARTY,
             HZ_ORGANIZATION_PROFILES ORGP
      WHERE  SL.SALES_LEAD_ID = C_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  SL.ADDRESS_ID = SITE.PARTY_SITE_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = c_hz_party_sites --'HZ_PARTY_SITES'
        AND  PHONE.PRIMARY_FLAG(+) = c_y --'Y'
        AND  PHONE.STATUS(+) = c_status
        AND  PHONE.CONTACT_POINT_TYPE(+) = c_phone --'PHONE'
        AND  SITE.PARTY_SITE_ID = PHONE.OWNER_TABLE_ID(+)
        AND  SITE.LOCATION_ID = ADDR.LOCATION_ID
        AND  PARTY.PARTY_ID = SITE.PARTY_ID
        AND (PARTY.PARTY_TYPE = c_person OR PARTY.PARTY_TYPE = c_organization)
        AND  PARTY.PARTY_ID = ORGP.PARTY_ID(+)
        AND  NVL(ORGP.EFFECTIVE_END_DATE(+),SYSDATE + 1) > SYSDATE;

    -- Bug 3035251
    -- Add UPPER for all VARCHAR2 qualifiers
    CURSOR C_Get_Sales_Lead2(C_Sales_Lead_Id NUMBER, c_hz_parties VARCHAR2,
                             c_status VARCHAR2, c_y VARCHAR2, c_phone VARCHAR2,
                             c_person VARCHAR2, c_organization VARCHAR2) IS
      SELECT SL.SALES_LEAD_ID,
             TO_NUMBER(NULL), -- sales_lead_line_id
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_CHAR(NULL),
             TO_NUMBER(NULL),
             UPPER(PHONE.PHONE_AREA_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.PARTY_NAME),
             PARTY.PARTY_ID,
             PARTY.EMPLOYEES_TOTAL,
             UPPER(PARTY.CATEGORY_CODE),
             PARTY.PARTY_ID,
             UPPER(PARTY.SIC_CODE_TYPE) || ': ' || UPPER(PARTY.SIC_CODE),
             SL.BUDGET_AMOUNT,
             UPPER(SL.CURRENCY_CODE),
             TRUNC(SL.CREATION_DATE),
             SL.SOURCE_PROMOTION_ID,
             TO_NUMBER(NULL), -- inventory_item_id
             TO_NUMBER(NULL), -- purchase_amount
             ORGP.CURR_FY_POTENTIAL_REVENUE,
             UPPER(ORGP.PREF_FUNCTIONAL_CURRENCY),
             UPPER(PARTY.DUNS_NUMBER_C),
             UPPER(SL.CHANNEL_CODE)
      FROM   AS_SALES_LEADS SL,
             HZ_CONTACT_POINTS PHONE,
             HZ_PARTIES PARTY,
             HZ_ORGANIZATION_PROFILES ORGP
      WHERE  SL.SALES_LEAD_ID = C_Sales_Lead_Id
        AND  SL.CUSTOMER_ID = PARTY.PARTY_ID
        AND  PHONE.OWNER_TABLE_NAME(+) = c_hz_parties --'HZ_PARTIES'
        AND  PHONE.PRIMARY_FLAG(+) = c_y --'Y'
        AND  PHONE.STATUS(+) = c_status
        AND  PHONE.CONTACT_POINT_TYPE(+) = c_phone --'PHONE'
        AND  PARTY.PARTY_ID = PHONE.OWNER_TABLE_ID(+)
        AND (PARTY.PARTY_TYPE = c_person OR PARTY.PARTY_TYPE = c_organization)
        AND  PARTY.PARTY_ID = ORGP.PARTY_ID(+)
        AND  NVL(ORGP.EFFECTIVE_END_DATE(+),SYSDATE + 1) > SYSDATE;

    CURSOR C_Explode_Resource_Team(c_team_id NUMBER) IS
      SELECT J.resource_id, J.group_id, J.person_id
      FROM
        (
          SELECT MIN(tm.team_resource_id) resource_id,
                 MIN(tm.person_id) person_id2, MIN(G.group_id) group_id,
                 MIN(t.team_id) team_id, tres.category resource_category,
                 MIN(TRES.source_id) person_id
          FROM   jtf_rs_team_members tm, jtf_rs_teams_b t,
                 jtf_rs_team_usages tu, jtf_rs_role_relations trr,
                 jtf_rs_roles_b tr, jtf_rs_resource_extns tres,
                 (
                   SELECT m.group_id group_id, m.resource_id resource_id
                   FROM   jtf_rs_group_members m, jtf_rs_groups_b g,
                          jtf_rs_group_usages u, jtf_rs_role_relations rr,
                          jtf_rs_roles_b r, jtf_rs_resource_extns res
                   WHERE
                          m.group_id = g.group_id
                   AND    SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                                      AND NVL(g.end_date_active,SYSDATE)
                   AND    u.group_id = g.group_id
                   AND    u.usage = 'SALES'
                   AND    m.group_member_id = rr.role_resource_id
                   AND    rr.role_resource_type = 'RS_GROUP_MEMBER'
                   AND    rr.delete_flag <> 'Y'
                   AND    SYSDATE BETWEEN rr.start_date_active
                                  AND NVL(rr.end_date_active,SYSDATE)
                   AND    rr.role_id = r.role_id
                   AND    r.role_type_code IN
                          ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                   AND    r.active_flag = 'Y'
                   AND    res.resource_id = m.resource_id
                   AND    res.category = 'EMPLOYEE'
                 )  g
          WHERE tm.team_id = t.team_id
          AND   SYSDATE BETWEEN NVL(t.start_date_active,SYSDATE)
                            AND NVL(t.end_date_active,SYSDATE)
          AND   tu.team_id = t.team_id
          AND   tu.usage = 'SALES'
          AND   tm.team_member_id = trr.role_resource_id
          AND   tm.delete_flag <> 'Y'
          AND   tm.resource_type = 'INDIVIDUAL'
          AND   trr.role_resource_type = 'RS_TEAM_MEMBER'
          AND   trr.delete_flag <> 'Y'
          AND   SYSDATE BETWEEN trr.start_date_active
                        AND NVL(trr.end_date_active,SYSDATE)
          AND   trr.role_id = tr.role_id
          AND   tr.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
          AND   tr.active_flag = 'Y'
          AND   tres.resource_id = tm.team_resource_id
          AND   tres.category = 'EMPLOYEE'
          AND   tm.team_resource_id = g.resource_id
          GROUP BY tm.team_member_id, tm.team_resource_id, tm.person_id,
                t.team_id, tres.category
          UNION
          SELECT MIN(m.resource_id) resource_id,
                 MIN(m.person_id) person_id2, MIN(m.group_id) group_id,
                 MIN(jtm.team_id) team_id, res.category resource_category,
                 MIN(res.source_id) person_id
          FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
                jtf_rs_group_usages u, jtf_rs_role_relations rr,
                jtf_rs_roles_b r, jtf_rs_resource_extns res,
                (
                  Select tm.team_resource_id group_id, t.team_id team_id
                  From   jtf_rs_team_members tm, jtf_rs_teams_b t,
                         jtf_rs_team_usages tu, jtf_rs_role_relations trr,
                         jtf_rs_roles_b tr, jtf_rs_resource_extns tres
                  Where  tm.team_id = t.team_id
                  and    sysdate between nvl(t.start_date_active,sysdate)
                                     and nvl(t.end_date_active,sysdate)
                  and   tu.team_id = t.team_id
                  and   tu.usage = 'SALES'
                  and   tm.team_member_id = trr.role_resource_id
                  and   tm.delete_flag <> 'Y'
                  and   tm.resource_type = 'GROUP'
                  and   trr.role_resource_type = 'RS_TEAM_MEMBER'
                  and   trr.delete_flag <> 'Y'
                  and   sysdate between trr.start_date_active and
                                     nvl(trr.end_date_active,sysdate)
                  and   trr.role_id = tr.role_id
                  and   tr.role_type_code in
                        ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
                  and   tr.active_flag = 'Y'
                  and   tres.resource_id = tm.team_resource_id
                  and   tres.category = 'EMPLOYEE'
                  ) jtm
           WHERE m.group_id = g.group_id
           AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                             AND NVL(g.end_date_active,SYSDATE)
           AND   u.group_id = g.group_id
           AND   u.usage = 'SALES'
           AND   m.group_member_id = rr.role_resource_id
           AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
           AND   rr.delete_flag <> 'Y'
           AND   SYSDATE BETWEEN rr.start_date_active
                         AND NVL(rr.end_date_active,SYSDATE)
           AND   rr.role_id = r.role_id
           AND   r.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
           AND   r.active_flag = 'Y'
           AND   res.resource_id = m.resource_id
           AND   res.category = 'EMPLOYEE'
           AND   jtm.group_id = g.group_id
           GROUP BY m.resource_id, m.person_id, jtm.team_id, res.category
                ) J
        WHERE j.team_id = c_team_id;

    CURSOR C_Explode_Resource_Group(c_group_id NUMBER) IS
      SELECT J.resource_id, J.group_id, J.person_id
      FROM
        (
          SELECT MIN(m.resource_id) resource_id,
                 res.category resource_category,
                 MIN(m.group_id) group_id,MIN(res.source_id) person_id
          FROM  jtf_rs_group_members m, jtf_rs_groups_b g,
                jtf_rs_group_usages u, jtf_rs_role_relations rr,
                jtf_rs_roles_b r, jtf_rs_resource_extns res
          WHERE
                m.group_id = g.group_id
          AND   SYSDATE BETWEEN NVL(g.start_date_active,SYSDATE)
                            AND NVL(g.end_date_active,SYSDATE)
          AND   u.group_id = g.group_id
          AND   u.usage = 'SALES'
          AND   m.group_member_id = rr.role_resource_id
          AND   rr.role_resource_type = 'RS_GROUP_MEMBER'
          AND   rr.role_id = r.role_id
          AND   rr.delete_flag <> 'Y'
          AND   SYSDATE BETWEEN rr.start_date_active
                        AND NVL(rr.end_date_active,SYSDATE)
          AND   r.role_type_code IN
                ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
          AND   r.active_flag = 'Y'
          AND   res.resource_id = m.resource_id
          AND   res.category = 'EMPLOYEE'
          GROUP BY m.group_member_id, m.resource_id, m.person_id,
                   m.group_id, res.category) j
      WHERE j.group_id = c_group_id;

    Cursor C_Validate_Salesforce(C_Resource_Id NUMBER, c_rs_individual VARCHAR2,
                                 c_sales VARCHAR2, c_telesales VARCHAR2,
                                 c_fieldsales VARCHAR2, c_prm VARCHAR2,
                                 c_n VARCHAR2, c_employee VARCHAR2) IS
      SELECT 'Y'
      FROM   per_all_people_f per,
             jtf_rs_resource_extns res,
             jtf_rs_role_relations rrel,
             jtf_rs_roles_b role
      WHERE  TRUNC(SYSDATE) BETWEEN per.effective_start_date
             AND per.effective_end_date
      AND    res.resource_id = rrel.role_resource_id
      AND    rrel.role_resource_type = c_rs_individual --'RS_INDIVIDUAL'
      AND    rrel.role_id = role.role_id
      AND    role.role_type_code IN (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES', 'TELESALES', 'FIELDSALES', 'PRM')
      AND    NVL(role.admin_flag, 'N') = c_n --'N'
      AND    res.source_id = per.person_id
      AND    res.resource_id = C_Resource_Id
      AND    res.category = c_employee; --'EMPLOYEE';

    -- Get access_id, terr_id for the records that come from LEAD territory.
    -- Delete these records before new resource records are created in
    -- AS_ACCESSES_ALL table.
    CURSOR C_Get_Acc_Terr(c_sales_lead_id NUMBER) IS
      SELECT ACC.ACCESS_ID, TERRACC.TERRITORY_ID
      FROM AS_ACCESSES_ALL ACC, AS_TERRITORY_ACCESSES TERRACC
      WHERE  ACC.FREEZE_FLAG = 'N'
      AND    ACC.SALES_LEAD_ID = c_sales_lead_id
      AND    ACC.OWNER_FLAG = 'N'
      AND    ACC.ACCESS_ID = TERRACC.ACCESS_ID;

    -- Get sequence
    CURSOR c_get_conseq_cur IS
    SELECT fnd_concurrent_requests_s.nextval
    FROM   dual;

    -- Check whether owner exists or not
    CURSOR c_check_owner_exists(c_sales_lead_id NUMBER) IS
    SELECT 'Y'
    FROM as_accesses_all acc
    WHERE acc.sales_lead_id = c_sales_lead_id
    AND acc.owner_flag = 'Y';

    l_api_name                  CONSTANT VARCHAR2(30)
                                := 'Rebuild_Lead_Sales_Team';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_customer_id               NUMBER;
    l_old_address_id            NUMBER := FND_API.G_MISS_NUM;
    l_new_address_id            NUMBER;
    l_assign_to_salesforce_id   NUMBER;
    l_assign_sales_group_id     NUMBER;
    l_reject_reason_code        VARCHAR2(30);
    l_AssignResources_Tbl       JTF_ASSIGN_PUB.AssignResources_Tbl_type;
                             -- JTF_TERRITORY_PUB.WinningTerrMember_tbl_type;
    l_AssignResources_Rec       JTF_ASSIGN_PUB.AssignResources_Rec_type;
                             -- JTF_TERRITORY_PUB.JTF_Lead_rec_type;
    --l_lead_rec                  JTF_ASSIGN_PUB.JTF_Lead_rec_type;
    l_lead_rec                  JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type;
    l_return_status             VARCHAR2(10);
    l_count                     INTEGER  := 0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;

    l_data                      VARCHAR2(70);
    l_index_out                 NUMBER;

    -- The following variables are for as_accesses_all
    l_access_id_tbl             NUMBER_TABLE;
    l_resource_id               NUMBER;
    l_group_id                  NUMBER;
    l_person_id                 NUMBER;

    -- The following variables are for as_territory_accesses
    l_ta_access_id_tbl          NUMBER_TABLE;
    l_ta_terr_id_tbl            NUMBER_TABLE;

    -- index of the above variables
    l_index                     NUMBER;
    l_ta_index                  NUMBER;

    l_access_id                 NUMBER;
    l_terr_id                   NUMBER;
    l_salesforce_flag           VARCHAR2(1);
    l_team_leader_flag          VARCHAR2(1);
    l_assign_manual_flag        VARCHAR2(1);
    l_request_id                NUMBER;
    l_owner_exists_flag         VARCHAR2(1) := 'N';

    l_itemtype                  VARCHAR2(8);
    l_itemkey                   VARCHAR2(30);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT REBUILD_LEAD_SALES_TEAM_PVT;

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

      -- Get sales lead info.
      -- l_old_address_id comes from as_changed_accounts_all.
      -- If user changed address_id, l_old_address_id is OLD address_id.
      -- Hense, cursor C_Get_Acc_Terr can get original records.
      OPEN C_Get_Lead_Info(p_Sales_Lead_Id);
      FETCH C_Get_Lead_Info INTO
          l_customer_id, l_new_address_id, l_assign_to_salesforce_id,
          l_assign_sales_group_id, l_reject_reason_code;
      CLOSE C_Get_Lead_Info;

      -- SOLIN, Bug 4733636
      -- Always call territory API as territory API performance is better now.
/*
      OPEN C_Check_Changed(p_sales_lead_id);
      FETCH C_Check_Changed INTO l_old_address_id;
      CLOSE C_Check_Changed;

      IF l_old_address_id = FND_API.G_MISS_NUM
      THEN
          -- There's no need to rebuild sales team for this sales lead
          -- because there's no record in as_changed_accounts_all
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Lead not in AS_CHANGED_ACCOUNTS_ALL');
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'PVT: ' || l_api_name || ' End');
          END IF;

          -- Standard call to get message count and IF count is 1,
          -- get message info.
          FND_MSG_PUB.Count_And_Get
          (  p_count          =>   x_msg_count,
             p_data           =>   x_msg_data );

          RETURN;
      ELSE
*/
          IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'Y'
          THEN
              -- 1. If AS_ENABLE_LEAD_ONLINE_TAP is 'Y', delete record.
              -- 2. If AS_ENABLE_LEAD_ONLINE_TAP is 'N', still keep it in
              --    as_changed_accounts_all, so TAP New Mode will pick up this
              --    record.
              UPDATE as_changed_accounts_all
              SET processed_flag = 'Y'
              WHERE sales_lead_id = p_sales_lead_id;
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Delete as_changed_accounts_all record');
              END IF;
          ELSIF l_assign_to_salesforce_id IS NOT NULL AND
                l_reject_reason_code IS NULL
          THEN
              -- If AS_ENABLE_LEAD_ONLINE_TAP is 'N' and no owner change
              -- required, return immediately.
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Lead Online TAP is disabled!');
              END IF;
              -- Standard call to get message count and IF count is 1,
              -- get message info.
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

              RETURN;
          END IF;
/*
          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'address_id in as_changed=' || l_old_address_id);
          END IF;
      END IF;
*/
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
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get access_id, terr_id for the records that come from LEAD territory.
      -- Delete these records before new resource records are created in
      -- AS_ACCESSES_ALL table.
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'customer_id=' || l_customer_id);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'old address_id=' || l_old_address_id);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'sales_lead_id=' || p_sales_lead_id);
      END IF;
      OPEN C_Get_Acc_Terr(p_sales_lead_id);
      FETCH C_Get_Acc_Terr BULK COLLECT INTO
          l_ta_access_id_tbl, l_ta_terr_id_tbl;
      CLOSE C_Get_Acc_Terr;

      IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              'l_ta_access_id_tbl.count:' || l_ta_access_id_tbl.count);
      END IF;

      IF l_ta_access_id_tbl.count > 0
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
              FOR l_i IN 1..l_ta_access_id_tbl.count
              LOOP
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Delete acc_id:' || l_ta_access_id_tbl(l_i)
                      || ' terr_id:' || l_ta_terr_id_tbl(l_i));
              END LOOP;
          END IF;

          FORALL l_i IN 1..l_ta_access_id_tbl.count
              DELETE FROM AS_ACCESSES_ALL
              WHERE ACCESS_ID = l_ta_access_id_tbl(l_i);

          FORALL l_i IN 1..l_ta_terr_id_tbl.count
              DELETE FROM AS_TERRITORY_ACCESSES
              WHERE ACCESS_ID = l_ta_access_id_tbl(l_i)
              AND   TERRITORY_ID = l_ta_terr_id_tbl(l_i);
      END IF;

      -- Delete non-frozen resources who are not from territory.
      DELETE FROM as_accesses_all acc
      WHERE acc.sales_lead_id = p_sales_lead_id
      AND acc.freeze_flag = 'N'
      --AND acc.salesforce_id <> p_identity_salesforce_id
      AND NOT EXISTS (
          SELECT 1
          FROM as_territory_accesses terracc
          WHERE terracc.access_id = acc.access_id);

      g_i_count := 0;
      g_u_count := 0;
      g_ti_count := 0;
      g_tu_count := 0;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Get sales lead info');
      END IF;

      l_lead_rec.squal_num06.extend;
      l_lead_rec.TRANS_OBJECT_ID.extend;

      IF l_new_address_id IS NOT NULL
      THEN
          -- Sales lead is created in party site level.
          OPEN C_Get_Sales_Lead1(p_Sales_Lead_Id, 'HZ_PARTY_SITES', 'A',
                                 'Y', 'PHONE', 'PERSON', 'ORGANIZATION');
          FETCH C_Get_Sales_Lead1 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.INVENTORY_ITEM_ID,
              l_lead_rec.PURCHASE_AMOUNT,
              l_lead_rec.SQUAL_NUM01,
              l_lead_rec.CAR_CURRENCY_CODE,
              l_lead_rec.SQUAL_CHAR11,
              l_lead_rec.SQUAL_CHAR30;
          CLOSE C_Get_Sales_Lead1;
      ELSE
          -- Sales lead is created in party level.
          OPEN C_Get_Sales_Lead2(p_Sales_Lead_Id, 'HZ_PARTIES', 'A',
                                 'Y', 'PHONE', 'PERSON', 'ORGANIZATION');
          FETCH C_Get_Sales_Lead2 BULK COLLECT INTO
              l_lead_rec.SALES_LEAD_ID,
              l_lead_rec.SALES_LEAD_LINE_ID,
              l_lead_rec.CITY,
              l_lead_rec.POSTAL_CODE,
              l_lead_rec.STATE,
              l_lead_rec.PROVINCE,
              l_lead_rec.COUNTY,
              l_lead_rec.COUNTRY,
              l_lead_rec.PARTY_SITE_ID,
              l_lead_rec.AREA_CODE,
              l_lead_rec.PARTY_ID,
              l_lead_rec.COMP_NAME_RANGE,
              l_lead_rec.PARTNER_ID,
              l_lead_rec.NUM_OF_EMPLOYEES,
              l_lead_rec.CATEGORY_CODE,
              l_lead_rec.PARTY_RELATIONSHIP_ID,
              l_lead_rec.SIC_CODE,
              l_lead_rec.BUDGET_AMOUNT,
              l_lead_rec.CURRENCY_CODE,
              l_lead_rec.PRICING_DATE,
              l_lead_rec.SOURCE_PROMOTION_ID,
              l_lead_rec.INVENTORY_ITEM_ID,
              l_lead_rec.PURCHASE_AMOUNT,
              l_lead_rec.SQUAL_NUM01,
              l_lead_rec.CAR_CURRENCY_CODE,
              l_lead_rec.SQUAL_CHAR11,
              l_lead_rec.SQUAL_CHAR30;
          CLOSE C_Get_Sales_Lead2;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'sales_lead_id.count='|| l_lead_rec.sales_lead_id.count);
      END IF;
      IF l_lead_rec.sales_lead_id.count = 0
      THEN
          -- customer_id and address_id of this sales lead don't match each
          -- other, don't do any change and return.
          RETURN;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SALES_LEAD_ID : ' || l_lead_rec.SALES_LEAD_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CITY : ' || l_lead_rec.CITY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'POSTAL_CODE : ' || l_lead_rec.POSTAL_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'STATE : ' || l_lead_rec.STATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PROVINCE : ' || l_lead_rec.PROVINCE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'COUNTY : ' || l_lead_rec.COUNTY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'COUNTRY : ' || l_lead_rec.COUNTRY(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_SITE_ID : ' || l_lead_rec.PARTY_SITE_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'AREA_CODE : ' || l_lead_rec.AREA_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CUSTOMER_NAME : ' || l_lead_rec.COMP_NAME_RANGE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTNER_ID : ' || l_lead_rec.PARTY_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'NUM_OF_EMPLOYEES : ' || l_lead_rec.NUM_OF_EMPLOYEES(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CATEGORY_CODE : ' || l_lead_rec.CATEGORY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PARTY_RELATIONSHIP_ID : ' || l_lead_rec.PARTY_RELATIONSHIP_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SIC_CODE : ' || l_lead_rec.SIC_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'BUDGET_AMOUNT : ' || l_lead_rec.BUDGET_AMOUNT(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CURRENCY_CODE : ' || l_lead_rec.CURRENCY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PRICING_DATE: ' || l_lead_rec.PRICING_DATE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'PROMOTION_ID: ' || l_lead_rec.SOURCE_PROMOTION_ID(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'SQUAL_NUM01: ' || l_lead_rec.SQUAL_NUM01(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CAR_CURRENCY_CODE: ' || l_lead_rec.CAR_CURRENCY_CODE(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'DUNS_NUMBER_C: ' || l_lead_rec.SQUAL_CHAR11(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'CHANNEL_CODE: ' || l_lead_rec.SQUAL_CHAR30(1));
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'Calling JTF_ASSIGN_PUB.Get_Assign_Lead_Resources');
      END IF;

      JTF_ASSIGN_PUB.Get_Assign_Lead_Resources (
            p_api_version                    => 1.0
           ,p_init_msg_list                  => JTF_ASSIGN_PUB.AM_FALSE
           -- ,p_commit                         => FND_API.G_FALSE
           ,p_resource_type                  => NULL
           ,p_role                           => NULL
           ,p_no_of_resources                => 999
           ,p_auto_select_flag               => NULL
           ,p_effort_duration                => 8
           ,p_effort_uom                     => 'HR'
           ,p_start_date                     => SYSDATE-1
           ,p_end_date                       => SYSDATE+1
           ,p_territory_flag                 => 'Y'
           ,p_calendar_flag                  => 'N'
           ,p_lead_rec                       => l_lead_rec
           ,x_assign_resources_tbl           => l_assignresources_tbl
           ,x_return_status                  => l_return_status
           ,x_msg_count                      => x_msg_count
           ,x_msg_data                       => x_msg_data
        );

      IF l_return_status = 'E'
      THEN
          FND_MSG_PUB.Get (
              p_msg_index       => FND_MSG_PUB.G_LAST,
              p_encoded         => FND_API.G_TRUE ,
              p_data            => l_data,
              p_msg_index_out   => l_index_out
              );
          IF (AS_DEBUG_LOW_ON) THEN
          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              l_data);
          END IF;

      ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS
      THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_request_id := FND_GLOBAL.Conc_Request_Id;
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'count=' || l_assignresources_tbl.count);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'first = '||l_assignresources_tbl.first);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'last = '||l_assignresources_tbl.last);
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'req_id :' || l_request_id);
      END IF;
      IF l_request_id = 0 OR l_request_id = -1
      THEN
          -- If l_request_id = 0 or -1, select directly from sequence
          OPEN c_get_conseq_cur;
          FETCH c_get_conseq_cur INTO l_request_id;
          CLOSE c_get_conseq_cur;
      END IF;
      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'req_id :' || l_request_id);
      END IF;

      l_count := l_AssignResources_tbl.COUNT;
      l_index := 1;
      l_ta_index := 1;
      IF l_AssignResources_tbl.COUNT > 0
      THEN
          FOR i IN l_AssignResources_tbl.first..l_AssignResources_tbl.last
          LOOP
              IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Terr ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Terr_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Resource ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Resource_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Group ID(' || i || ') : '
                  || l_AssignResources_tbl(i).Group_Id);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Full_Access_Flag(' || i || ') : '
                  || l_AssignResources_tbl(i).Full_Access_Flag);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Role(' || i || ') : '
                  || l_AssignResources_tbl(i).Role);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Resource_Type(' || i || ') : '
                  || l_AssignResources_tbl(i).Resource_Type);
              END IF;

              IF l_AssignResources_tbl(i).Resource_Type = 'RS_TEAM'
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Resource Team found');
                  END IF;
                  OPEN C_Explode_Resource_Team(
                           l_AssignResources_tbl(i).Resource_Id);
                  LOOP
                      FETCH C_Explode_Resource_Team INTO
                          l_resource_id, l_group_id, l_person_id;
                      EXIT WHEN C_Explode_Resource_Team%NOTFOUND;
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Resource_Id: ' || l_resource_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Group_Id: ' || l_group_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Person_Id: ' || l_person_id);
                      END IF;
                      Create_Access_Records(
                            p_resource_id         => l_resource_id,
                            p_group_id            => l_group_id,
                            p_full_access_flag    =>
                                l_AssignResources_tbl(i).Full_Access_Flag,
--                            p_person_id           =>
--                                l_insert_acc_rec.person_id(l_index),
                            p_territory_id        =>
                                l_AssignResources_tbl(i).Terr_Id,
                            p_party_id            => l_customer_id,
                            p_party_site_id       => l_new_address_id,
                            p_sales_lead_id       => p_sales_lead_id,
                            p_freeze_flag         => 'N',
                            p_source              => 'TERRITORY');
                  END LOOP;
                  CLOSE C_Explode_Resource_Team;
              ELSIF l_AssignResources_tbl(i).Resource_Type = 'RS_GROUP'
              THEN
                  IF (AS_DEBUG_LOW_ON) THEN
                      AS_UTILITY_PVT.Debug_Message(
                          FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'Resource Group found');
                  END IF;
                  OPEN C_Explode_Resource_Group(
                           l_AssignResources_tbl(i).Resource_Id);
                  LOOP
                      FETCH C_Explode_Resource_Group INTO
                          l_resource_id, l_group_id, l_person_id;
                      EXIT WHEN C_Explode_Resource_Group%NOTFOUND;
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Resource_Id: ' || l_resource_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Group_Id: ' || l_group_id);
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              ' Person_Id: ' || l_person_id);
                      END IF;
                      Create_Access_Records(
                            p_resource_id         => l_resource_id,
                            p_group_id            => l_group_id,
                            p_full_access_flag    =>
                                l_AssignResources_tbl(i).Full_Access_Flag,
--                            p_person_id           =>
--                                l_insert_acc_rec.person_id(l_index),
                            p_territory_id        =>
                                l_AssignResources_tbl(i).Terr_Id,
                            p_party_id            => l_customer_id,
                            p_party_site_id       => l_new_address_id,
                            p_sales_lead_id       => p_sales_lead_id,
                            p_freeze_flag         => 'N',
                            p_source              => 'TERRITORY');
                  END LOOP;
                  CLOSE C_Explode_Resource_Group;
              ELSE
                  -- not resource team or resource group
                  l_salesforce_flag := 'N';
                  OPEN C_Validate_Salesforce(
                      l_AssignResources_tbl(i).Resource_Id,
                      'RS_INDIVIDUAL', 'SALES', 'TELESALES',
                      'FIELDSALES', 'PRM', 'N', 'EMPLOYEE');
                  FETCH C_Validate_Salesforce INTO l_salesforce_flag;
                  CLOSE C_Validate_Salesforce;

                  IF l_salesforce_flag = 'Y'
                  THEN
                      Create_Access_Records(
                            p_resource_id         =>
                                l_AssignResources_tbl(i).Resource_Id,
                            p_group_id            =>
                                l_AssignResources_tbl(i).Group_Id,
                            p_full_access_flag    =>
                                l_AssignResources_tbl(i).Full_Access_Flag,
--                            p_person_id           =>
--                                l_insert_acc_rec.person_id(l_index),
                            p_territory_id        =>
                                l_AssignResources_tbl(i).Terr_Id,
                            p_party_id            => l_customer_id,
                            p_party_site_id       => l_new_address_id,
                            p_sales_lead_id       => p_sales_lead_id,
                            p_freeze_flag         => 'N',
                            p_source              => 'TERRITORY');
                  ELSE
                      IF (AS_DEBUG_LOW_ON) THEN
                          AS_UTILITY_PVT.Debug_Message(
                              FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                              'rs_id ' ||
                              l_AssignResources_tbl(i).Resource_Id ||
                              ' is not salesforce');
                      END IF;
                  END IF; -- l_salesforce_flag
              END IF; -- resource type
          END LOOP; -- l_AssignResources_tbl.first..l_AssignResources_tbl.last
      END IF; -- l_AssignResources_tbl.COUNT > 0
      Flush_Access_Records(l_request_id);

      -- If user change address_id, AS_ACCESSES_ALL table should be updated.
      -- There may be some records untouched, so update here, instead of
      -- in Flush_Access_Records.
      IF l_old_address_id <> l_new_address_id
      THEN
          UPDATE as_accesses_all
          SET address_id = l_new_address_id
          WHERE sales_lead_id = p_sales_lead_id
          AND address_id = l_old_address_id;
      ELSIF l_old_address_id IS NULL AND l_new_address_id IS NOT NULL
      THEN
          UPDATE as_accesses_all
          SET address_id = l_new_address_id
          WHERE sales_lead_id = p_sales_lead_id
          AND address_id IS NULL;
      ELSIF l_old_address_id IS NOT NULL AND l_new_address_id IS NULL
      THEN
          UPDATE as_accesses_all
          SET address_id = NULL
          WHERE sales_lead_id = p_sales_lead_id
          AND address_id = l_old_address_id;
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'assign_to_sf_id=' || l_assign_to_salesforce_id);
      END IF;

      OPEN c_check_owner_exists(p_sales_lead_id);
      FETCH c_check_owner_exists INTO l_owner_exists_flag;
      CLOSE c_check_owner_exists;

      IF (AS_DEBUG_LOW_ON) THEN
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
          'owner exist? ' || l_owner_exists_flag);
      END IF;

      DELETE FROM AS_TERRITORY_ACCESSES
      WHERE access_id IN
              (SELECT a.access_id
               FROM as_accesses_all a
               WHERE a.sales_lead_id = p_sales_lead_id
               AND a.freeze_flag = 'N'
               AND a.request_id = l_request_id)
      AND REQUEST_ID IS NULL;

      DELETE FROM AS_ACCESSES_ALL
      WHERE SALES_LEAD_ID = p_sales_lead_id
      AND   FREEZE_FLAG = 'N'
      AND   REQUEST_ID IS NULL;

      x_request_id := l_request_id;
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
END Rebuild_Lead_Sales_Team;

-- The following are private API without conuterpart public API.

FUNCTION Changed_Accounts_Record_Exist(
    P_Sales_Lead_Id NUMBER) RETURN BOOLEAN IS
CURSOR c1(C_Sales_Lead_Id NUMBER) IS
    SELECT CUSTOMER_ID
    FROM   AS_CHANGED_ACCOUNTS_ALL
    WHERE  SALES_LEAD_ID = C_Sales_Lead_Id
    AND    REQUEST_ID IS NULL;
l_dummy   NUMBER;
BEGIN
    OPEN c1(P_Sales_Lead_Id);
    FETCH c1 INTO l_dummy;
    IF (c1%NOTFOUND) THEN
        CLOSE c1;
        RETURN FALSE;
    ELSE
        CLOSE c1;
        RETURN TRUE;
    END IF;
END Changed_Accounts_Record_Exist;

FUNCTION Is_Same_Value( old VARCHAR2, new VARCHAR2 ) RETURN BOOLEAN IS
BEGIN
    IF( old = new ) THEN
        RETURN TRUE;
    ELSIF( old IS NULL AND new IS NULL ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_Same_Value;


FUNCTION Is_Same_Value( old NUMBER, new NUMBER ) RETURN BOOLEAN IS
BEGIN
    IF( old = new ) THEN
        RETURN TRUE;
    ELSIF( old IS NULL AND new IS NULL ) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_Same_Value;

PROCEDURE Sales_Leads_Trigger_Handler(
    P_Customer_Id                 IN  NUMBER,
    P_Sales_Lead_Id               IN  NUMBER,
    P_Old_Address_Id              IN  NUMBER,
    P_Old_Budget_Amount           IN  NUMBER,
    P_Old_Currency_Code           IN  VARCHAR2,
    P_Old_Source_Promotion_Id     IN  NUMBER,
    P_Old_Channel_Code            IN  VARCHAR2,
    P_New_Address_Id              IN  NUMBER,
    P_New_Budget_Amount           IN  NUMBER,
    P_New_Currency_Code           IN  VARCHAR2,
    P_New_Source_Promotion_Id     IN  NUMBER,
    P_New_Channel_Code            IN  VARCHAR2,
    P_New_Assign_To_Salesforce_Id IN  NUMBER,
    P_New_Reject_Reason_Code      IN  VARCHAR2,
    P_Trigger_Mode                IN  VARCHAR2) IS
Is_Changed           BOOLEAN := FALSE;
Amount_Enabled       VARCHAR2(1);
Promotion_Enabled    VARCHAR2(1);
Channel_Enabled      VARCHAR2(1);
l_address_id         NUMBER;
l_insert_flag        VARCHAR2(1) := 'N';
l_incubation_channel VARCHAR2(30);

-- Bug 3091085, SOLIN(Bug 3087354 for 11.5.8)
-- Use JTF_QUAL_USGS_ALL, instead of JTF_QUAL_USGS(with security policies)
-- This SQL is ordered by decending Enabled_Flag because sales team should
-- be rebuilt as long as any org. has enabled the qualifier.
CURSOR c1 IS
    SELECT Amount.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL Amount
    WHERE  Amount.QUAL_USG_ID = -1021
    AND    Amount.QUAL_TYPE_USG_ID = -1002     -- LEAD
    ORDER BY Amount.Enabled_Flag DESC;

CURSOR c2 IS
    SELECT Promotion.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL Promotion
    WHERE  Promotion.QUAL_USG_ID = -1020
    AND    Promotion.QUAL_TYPE_USG_ID = -1002  -- LEAD
    ORDER BY Promotion.Enabled_Flag DESC;

-- JTF Bug 2725578: SALES CHANNEL SUPPORT FOR TERRITORY ASSIGNMENT
CURSOR c3 IS
    SELECT Channel.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL Channel
    WHERE  Channel.QUAL_USG_ID = -1130
    AND    Channel.QUAL_TYPE_USG_ID = -1002  -- LEAD
    ORDER BY Channel.Enabled_Flag DESC;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Trigger mode:' || P_Trigger_Mode);
    END IF;

    IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'),'Y') = 'Y'
      AND (P_Trigger_Mode = 'ON-DELETE')
    THEN
--        IF (P_Trigger_Mode IN ('ON-INSERT', 'ON-DELETE'))
--        IF (P_Trigger_Mode = 'ON-DELETE')
--        THEN
            -- Build_Lead_Sales_Team will take care of assignment, no
            -- need to insert into as_changed_accounts_all
            RETURN;
--        END IF;
--        l_address_id := p_old_address_id;
    ELSE
        IF P_Trigger_Mode = 'ON-INSERT'
        THEN
            l_address_id := p_new_address_id;
            l_insert_flag := 'Y';
        ELSE
            l_address_id := p_old_address_id;
            l_insert_flag := 'N';
        END IF;
    END IF;

    -- regardless whether the profile is, always check enabled qualifiers
    OPEN c1;
    FETCH c1 into Amount_Enabled;
    CLOSE c1;
    OPEN c2;
    FETCH c2 into Promotion_Enabled;
    CLOSE c2;
    OPEN c3;
    FETCH c3 into Channel_Enabled;
    CLOSE c3;

    IF (NOT Is_Same_Value(p_old_address_id, p_new_address_id))
    THEN
        -- Usually, location qualifier is enabled, no need to check
        Is_Changed := TRUE;
    ELSIF (((NOT Is_Same_Value(p_old_budget_amount, p_new_budget_amount)) OR
            (NOT Is_Same_Value(p_old_currency_code, p_new_currency_code)))
       AND (Amount_Enabled='Y'))
    THEN
        Is_Changed := TRUE;
    ELSIF (NOT Is_Same_Value(p_old_source_promotion_id,
                             p_new_source_promotion_id)
       AND (Promotion_Enabled='Y'))
    THEN
        Is_Changed := TRUE;
    ELSIF (NOT Is_Same_Value(p_old_channel_code, p_new_channel_code)
       AND (Channel_Enabled='Y'))
    THEN
        Is_Changed := TRUE;
    END IF;

    IF p_new_assign_to_salesforce_id IS NULL OR
       p_new_reject_reason_code IS NOT NULL
    THEN
        -- If sales lead owner decides to set assign_to_salesforce_id to NULL,
        -- OR owner declines the sales lead,
        -- this sales lead has to be reassigned.
        Is_Changed := TRUE;
    END IF;

    IF (Is_Changed = TRUE)
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Is changed:TRUE');
        END IF;
--        IF NOT Changed_Accounts_Record_Exist(P_Sales_Lead_Id)
--        THEN
            BEGIN
            INSERT INTO AS_CHANGED_ACCOUNTS_ALL(
                customer_id, address_id, sales_lead_id, last_update_date,
                last_updated_by, creation_date, created_by, last_update_login,
                change_type, delete_flag, insert_flag, processed_flag)
            VALUES
               (P_Customer_Id, l_Address_id, P_Sales_Lead_id, SYSDATE, 0,
                SYSDATE, 0, 0, 'LEAD', 'N', l_insert_flag, 'N');
            EXCEPTION
                WHEN OTHERS THEN
                UPDATE AS_CHANGED_ACCOUNTS_ALL
                SET processed_flag = 'N'
                WHERE sales_lead_id = p_sales_lead_id;
            END;
--        END IF;
    END IF;

END Sales_Leads_Trigger_Handler;

PROCEDURE Sales_Lead_Lines_Handler(
    P_Sales_Lead_Id                  IN  NUMBER,
    P_Old_category_Id		     IN  NUMBER,
    P_Old_category_set_Id            IN  NUMBER,
    P_Old_Inventory_Item_Id          IN  NUMBER,
    P_Old_Purchase_Amount            IN  NUMBER,
    P_New_category_Id                IN  NUMBER,
    P_New_category_set_Id            IN  NUMBER,
    P_New_Inventory_Item_Id          IN  NUMBER,
    P_New_Purchase_Amount            IN  NUMBER,
    P_Trigger_Mode                   IN  VARCHAR2) IS
Is_Changed        BOOLEAN := FALSE;
l_customer_id     NUMBER;
l_address_id      NUMBER;
ItemNo_Enabled    VARCHAR2(1);
Expected_Enabled  VARCHAR2(1);
Amount_Enabled    VARCHAR2(1);

CURSOR c0(C_Sales_Lead_Id NUMBER) IS
    SELECT Customer_Id, Address_Id
    FROM AS_SALES_LEADS lead
    WHERE lead.sales_lead_Id = C_Sales_Lead_Id;

-- Bug 3091085, SOLIN(Bug 3087354 for 11.5.8)
-- Use JTF_QUAL_USGS_ALL, instead of JTF_QUAL_USGS(with security policies)
-- This SQL is ordered by decending Enabled_Flag because sales team should
-- be rebuilt as long as any org. has enabled the qualifier.
CURSOR c1 IS
    SELECT ItemNo.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL ItemNo
    WHERE  ItemNo.QUAL_USG_ID = -1019
    AND    ItemNo.QUAL_TYPE_USG_ID = -1002  -- Lead
    ORDER BY ItemNo.Enabled_Flag DESC;

CURSOR c2 IS
    SELECT Expected.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL Expected
    WHERE  Expected.QUAL_USG_ID = -1018
    AND    Expected.QUAL_TYPE_USG_ID = -1002  -- Lead
    ORDER BY Expected.Enabled_Flag DESC;

CURSOR c3 IS
    SELECT Amount.Enabled_Flag
    FROM   JTF_QUAL_USGS_ALL Amount
    WHERE  Amount.QUAL_USG_ID = -1022
    AND    Amount.QUAL_TYPE_USG_ID = -1002  -- Lead
    ORDER BY Amount.Enabled_Flag DESC;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Line Trigger mode:' || P_Trigger_Mode);
    END IF;
    -- regardless of profile AS_ENABLE_LEAD_ONLINE_TAP, always check
    -- enabled profile
    OPEN c0(P_Sales_Lead_Id);
    FETCH c0 INTO l_customer_id, l_address_id;
    CLOSE c0;

    IF l_customer_id IS NOT NULL
    THEN
        OPEN c1;
        FETCH c1 INTO ItemNo_Enabled;
        CLOSE c1;
        OPEN c2;
        FETCH c2 INTO Expected_Enabled;
        CLOSE c2;
        OPEN c3;
        FETCH c3 INTO Amount_Enabled;
        CLOSE c3;

        IF (P_Trigger_Mode IN ('ON-INSERT', 'ON-DELETE'))
        THEN
            Is_Changed := TRUE;
        ELSIF ((NOT Is_Same_Value(P_Old_category_Id,
                                  P_New_category_Id)
             OR NOT Is_Same_Value(P_Old_category_set_Id,
                                  P_New_category_set_Id))
             AND (Expected_Enabled = 'Y'))
        THEN
            Is_Changed := TRUE;
        ELSIF (NOT Is_Same_Value(p_old_inventory_item_id,
                                 p_new_inventory_item_id)
             AND (ItemNo_Enabled = 'Y'))
        THEN
            Is_Changed := TRUE;
        ELSIF (NOT Is_Same_Value(p_old_purchase_amount,
                                 p_new_purchase_amount)
             AND (Amount_Enabled = 'Y'))
        THEN
            Is_Changed := TRUE;
        END IF;

        IF( Is_Changed = TRUE)
--          AND NOT Changed_Accounts_Record_Exist(p_sales_lead_id))
        THEN
            BEGIN
            INSERT INTO AS_CHANGED_ACCOUNTS_ALL(
                customer_id, address_id, sales_lead_id, last_update_date,
                last_updated_by, creation_date, created_by,
                last_update_login, change_type, delete_flag, insert_flag,
                processed_flag)
            VALUES
               (l_customer_id, l_address_id, p_sales_lead_id, SYSDATE, 0,
                SYSDATE, 0, 0, 'LEAD', 'N', 'N', 'N');
            EXCEPTION
                WHEN OTHERS THEN
                UPDATE AS_CHANGED_ACCOUNTS_ALL
                SET processed_flag = 'N'
                WHERE sales_lead_id = p_sales_lead_id;
            END;
        END IF;
    END IF; -- l_customer_id IS NOT NULL
END Sales_Lead_Lines_Handler;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |   Insert Access Records
 |
 | PURPOSE
 |   Insert access records in an array. These array will be inserted into
 |   database when calling Flush_Access_Records().
 |
 | NOTES
 |
 | HISTORY
 |   01/16/02   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE  Insert_Access_Records(
    p_resource_id            IN     NUMBER,
    p_group_id               IN     NUMBER,
    p_full_access_flag       IN     VARCHAR2,
--    p_person_id              IN     NUMBER,
    p_territory_id           IN     NUMBER := NULL,
    p_party_id               IN     NUMBER,
    p_party_site_id          IN     NUMBER,
    p_partner_cont_party_id  IN     NUMBER := NULL,
    p_partner_customer_id    IN     NUMBER := NULL,
    p_sales_lead_id          IN     NUMBER,
    p_freeze_flag            IN     VARCHAR2,
    p_owner_flag             IN     VARCHAR2,
    p_source                 IN     VARCHAR2)
IS
l_found                VARCHAR2(1) := 'N';
l_access_id            NUMBER;
l_i                    NUMBER; -- index to Insert array

CURSOR c_get_access_id IS
    SELECT AS_ACCESSES_S.NEXTVAL
    FROM   SYS.DUAL;

BEGIN
    l_i := g_i_count;

    -- search backward in array to see if access record is already here
    -- One customer may get the same resource from different territories.
    WHILE l_found = 'N' AND l_i >= 1
    LOOP
        IF g_i_resource_id(l_i) = p_resource_id
           AND NVL(g_i_group_id(l_i),-1) = NVL(p_group_id,-1)
           AND g_i_party_id(l_i) = p_party_id
           AND NVL(g_i_party_site_id(l_i), -1) = NVL(p_party_site_id, -1)
           AND g_i_sales_lead_id(l_i) = p_sales_lead_id
        THEN
            l_found := 'Y';
        ELSE
            l_i := l_i - 1;
        END IF;
    END LOOP;

    IF l_found = 'Y'
    THEN
        -- Check full_access_flag, Full access flag Y overrides N
        IF g_i_full_access_flag(l_i) = 'N' AND p_full_access_flag = 'Y'
        THEN
            g_i_full_access_flag(l_i) := 'Y';
        END IF;

        -- Check owner_flag, owner flag Y overrides N
        IF g_i_owner_flag(l_i) = 'N' AND p_owner_flag = 'Y'
        THEN
            g_i_owner_flag(l_i) := 'Y';
        END IF;

        IF p_territory_id IS NOT NULL
        THEN
            Insert_Territory_Accesses(
                p_access_id              => g_i_access_id(l_i),
                p_territory_id           => p_territory_id);
        END IF;
    ELSE -- l_found <> 'Y'

        OPEN c_get_access_id;
        FETCH c_get_access_id INTO l_access_id;
        CLOSE c_get_access_id;

        g_i_count := g_i_count + 1;
        g_i_access_id(g_i_count) := l_access_id;
        g_i_resource_id(g_i_count) := p_resource_id;
        g_i_group_id(g_i_count) := p_group_id;

        IF p_full_access_flag = 'Y'
        THEN
            g_i_full_access_flag(g_i_count) := 'Y';
        ELSE
            g_i_full_access_flag(g_i_count) := 'N';
        END IF;

        IF p_owner_flag = 'Y'
        THEN
            g_i_owner_flag(g_i_count) := 'Y';
        ELSE
            g_i_owner_flag(g_i_count) := 'N';
        END IF;

--        g_i_person_id(g_i_count) := p_person_id;
        g_i_party_id(g_i_count) := p_party_id;
        g_i_party_site_id(g_i_count) := p_party_site_id;
        g_i_partner_cont_party_id(g_i_count) := p_partner_cont_party_id;
        g_i_partner_customer_id(g_i_count) := p_partner_customer_id;
        g_i_sales_lead_id(g_i_count) := p_sales_lead_id;
        g_i_freeze_flag(g_i_count) := p_freeze_flag;
        g_i_territory_id(g_i_count) := p_territory_id;
        g_i_source(g_i_count) := p_source;

        IF p_territory_id IS NOT NULL
        THEN
            Insert_Territory_Accesses(
                p_access_id              => l_access_id,
                p_territory_id           => p_territory_id);
        END IF;
    END IF; -- l_found = 'Y'

END Insert_Access_Records;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Create_Access_Records
 |
 | PURPOSE
 |   Create access records in an array. First check if the record is
 |   already in the database. If it is, add the record to update array,
 |   then call Create_Territory_Access(). If it isn't, search the array
 |   itself. If it's in the array, call Create_Territory_Access() as well.
 |   If it's not in the array, add the new record into the array and call
 |   Create_Territory_Access()
 |
 | NOTES
 |
 | HISTORY
 |   06/18/01   SOLIN          Created
 *-------------------------------------------------------------------------*/

PROCEDURE  Create_Access_Records(
    p_resource_id            IN     NUMBER,
    p_group_id               IN     NUMBER,
    p_full_access_flag       IN     VARCHAR2,
--    p_person_id              IN     NUMBER,
    p_territory_id           IN     NUMBER,
    p_party_id               IN     NUMBER,
    p_party_site_id          IN     NUMBER,
    p_partner_cont_party_id  IN     NUMBER := NULL,
    p_partner_customer_id    IN     NUMBER := NULL,
    p_sales_lead_id          IN     NUMBER,
    p_freeze_flag            IN     VARCHAR2,
    p_source                 IN     VARCHAR2

)
IS
l_found                VARCHAR2(1) := 'N';
l_access_id            NUMBER;
l_full_access_flag     VARCHAR2(1); -- from AS_ACCESSES_ALL table
--l_full_access_flag     VARCHAR2(1); -- from JTF_TERR_RSC table
l_employee_person_id   NUMBER;
l_access_id_new        NUMBER;

l_id_found             VARCHAR2(1) := 'N';
l_u                    NUMBER; -- Index to Update array
l_i                    NUMBER; -- index to Insert array

CURSOR c_get_access_id(c_resource_id NUMBER, c_group_id NUMBER,
                       c_sales_lead_id NUMBER) IS
    SELECT ACCESS_ID, TEAM_LEADER_FLAG
    FROM   AS_ACCESSES_ALL
    WHERE  SALESFORCE_ID = c_resource_id
    AND  ((SALES_GROUP_ID IS NULL AND c_group_id IS NULL)
       OR  SALES_GROUP_ID = c_group_id)
    AND    SALES_LEAD_ID = c_sales_lead_id
    AND    ROWNUM <= 1;

CURSOR c_get_new_access_id IS
    SELECT AS_ACCESSES_S.NEXTVAL
    FROM   SYS.DUAL;

BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'OPEN c_get_access_id');
    END IF;

    OPEN c_get_access_id(p_resource_id, p_group_id, p_sales_lead_id);
    FETCH c_get_access_id INTO l_access_id, l_full_access_flag;
    IF c_get_access_id%FOUND
    THEN
        l_id_found := 'Y';
    END IF;
    CLOSE c_get_access_id;

    -- based on the unique index, the above cursor will return
    -- 0 or 1 row only
    IF l_id_found = 'Y'
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'ID found, access_id=' || l_access_id);
        END IF;
        -- Search backward in array to see if update is already here
        l_u := g_u_count;
        l_found := 'N';
        WHILE l_found = 'N' AND l_u >= 1
        LOOP
            IF g_u_access_id(l_u) = l_access_id
            THEN
                l_found := 'Y';
            ELSE
                l_u := l_u - 1;
            END IF;
        END LOOP;

        IF l_found = 'Y'
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'update array found=Y');
            END IF;
            -- Check full_access_flag,
            -- Full access flag Y overrides N
            IF g_u_full_access_flag(l_u) = 'N' AND
               p_full_access_flag = 'Y'
            THEN
                g_u_full_access_flag(l_u) := 'Y';
            ELSE
                g_u_full_access_flag(l_u) := p_full_access_flag;
            END IF;
            Create_Territory_Accesses(
                p_access_id              => l_access_id,
                p_territory_id           => p_territory_id);
        ELSE -- l_found <> 'Y'
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'update array found<>Y, put in update array');
            END IF;
            -- Insert into Update array
            g_u_count := g_u_count + 1;
            g_u_access_id(g_u_count) := l_access_id;

            -- Team leader flag Y overrides N
            IF l_full_access_flag = 'Y' OR p_full_access_flag = 'Y'
            THEN
                g_u_full_access_flag(g_u_count) := 'Y';
            ELSE
                g_u_full_access_flag(g_u_count) := 'N';
            END IF;

            Create_Territory_Accesses(
                p_access_id              => l_access_id,
                p_territory_id           => p_territory_id);

        END IF;
    ELSE -- l_id_found <> 'Y'
        -- search backward in array to see if access record is already here
        l_i := g_i_count;
        l_found := 'N';
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'ID not found');
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_i_count=' || g_i_count);
        END IF;
        WHILE l_found = 'N' AND l_i >= 1
        LOOP
            IF g_i_resource_id(l_i) = p_resource_id
               AND NVL(g_i_group_id(l_i),-1) = NVL(p_group_id,-1)
               AND g_i_party_id(l_i) = p_party_id
               AND NVL(g_i_party_site_id(l_i), -1) = NVL(p_party_site_id, -1)
               AND NVL(g_i_sales_lead_id(l_i), -1) = NVL(p_sales_lead_id, -1)
            THEN
                l_found := 'Y';
            ELSE
                l_i := l_i - 1;
            END IF;
        END LOOP;

        IF l_found = 'Y'
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'l_found=Y');
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'l_i=' || l_i);
            END IF;
            -- Check full_access_flag,
            -- Full access flag Y overrides N
            IF g_i_full_access_flag(l_i) = 'N' AND p_full_access_flag = 'Y'
            THEN
                g_i_full_access_flag(l_i) := 'Y';
            ELSE
                g_i_full_access_flag(l_i) := p_full_access_flag;
            END IF;
            l_access_id := g_i_access_id(l_i);
            Create_Territory_Accesses(
                p_access_id              => l_access_id,
                p_territory_id           => p_territory_id);
        ELSE -- l_found <> 'Y'
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'l_found<>Y');
            END IF;
            OPEN c_get_new_access_id;
            FETCH c_get_new_access_id INTO l_access_id_new;
            CLOSE c_get_new_access_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'new acc_id=' || l_access_id_new);
            END IF;

            g_i_count := g_i_count + 1;
            g_i_access_id(g_i_count) := l_access_id_new;
            g_i_resource_id(g_i_count) := p_resource_id;
            g_i_group_id(g_i_count) := p_group_id;
            g_i_source(g_i_count) := p_source;
            g_i_full_access_flag(g_i_count) := p_full_access_flag;
--            g_i_person_id(g_i_count) := p_person_id;
            g_i_party_id(g_i_count) := p_party_id;
            g_i_party_site_id(g_i_count) := p_party_site_id;
            g_i_partner_cont_party_id(g_i_count) := p_partner_cont_party_id;
            g_i_partner_customer_id(g_i_count) := p_partner_customer_id;
            g_i_sales_lead_id(g_i_count) := p_sales_lead_id;
            g_i_territory_id(g_i_count) := p_territory_id;
            g_i_freeze_flag(g_i_count) := p_freeze_flag;

            Create_Territory_Accesses(
                p_access_id              => l_access_id_new,
                p_territory_id           => p_territory_id);

        END IF; -- l_found = 'Y'
    END IF; -- l_id_found = 'Y'

END Create_Access_Records;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Insert_Territory_Accesses
 |
 | PURPOSE
 |   Insert the records in an array prefixed with ti. These array will be
 |   inserted into database when calling Flush_Access_Records().
 |   If the array is full, flush the arrays by calling Flush_Access_Records()
 |
 | NOTES
 |
 | HISTORY
 |   01/17/02   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Insert_Territory_Accesses(
    p_access_id              IN     NUMBER,
    p_territory_id           IN     NUMBER)
IS
l_count             NUMBER;

l_found             VARCHAR2(1) := 'N';
l_i                 NUMBER;
l_u                 NUMBER;

BEGIN
    -- search backward in array to see if record is already here
    l_i := g_ti_count;
    l_found := 'N';
    WHILE l_found = 'N' AND l_i >= 1 LOOP
        IF g_ti_access_id(l_i) = p_access_id
        AND g_ti_territory_id(l_i) = p_territory_id
        THEN
            l_found := 'Y';
        ELSE
            l_i := l_i - 1;
        END IF;
    END LOOP;

    IF l_found = 'N'
    THEN
        g_ti_count := g_ti_count + 1;
        g_ti_access_id(g_ti_count) := p_access_id;
        g_ti_territory_id(g_ti_count) := p_territory_id;

    END IF; -- l_found = 'N'

END Insert_Territory_Accesses;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Create_Territory_Accesses
 |
 | PURPOSE
 |   Create the records in an array prefixed with ti.
 |   First check if the record is already in the database. If it is,
 |   ignore because territory access update statement will update
 |   the request ids of those records. If it is not, search the array
 |   itself. If it is not in the array, add the record in the array.
 |   If the array is full, flush the arrays by calling Flush_Access_Records()
 |
 | NOTES
 |
 | HISTORY
 |   06/19/01   SOLIN          Created
 *-------------------------------------------------------------------------*/

PROCEDURE Create_Territory_Accesses(
    p_access_id              IN     NUMBER,
    p_territory_id           IN     NUMBER)
IS
l_count             NUMBER;

l_found             VARCHAR2(1) := 'N';
l_i                 NUMBER;
l_u                 NUMBER;

CURSOR c_get_terracc_count(c_access_id NUMBER, c_territory_id NUMBER)
IS
    SELECT 1
    FROM   AS_TERRITORY_ACCESSES
    WHERE  ACCESS_ID = c_access_id
    AND    TERRITORY_ID = c_territory_id
    AND    ROWNUM <= 1;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        '*** Create_Territory_Accesses() ***');
    END IF;

    OPEN c_get_terracc_count(p_access_id, p_territory_id);
    FETCH c_get_terracc_count INTO l_count;
    CLOSE c_get_terracc_count;

    IF l_count > 0
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_count>0');
        END IF;
        -- search array to see if it is already there
        l_u := g_tu_count;
        l_found := 'N';
        WHILE l_found = 'N' AND l_u >= 1 LOOP
            IF g_tu_access_id(l_u) = p_access_id AND
               g_tu_territory_id(l_u) = p_territory_id
            THEN
                l_found := 'Y';
            ELSE
                l_u := l_u - 1;
            END IF;
        END LOOP;

        IF l_found = 'N'
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'access_id and terr_id are not in tu array');
            END IF;
            g_tu_count := g_tu_count + 1;
            g_tu_access_id(g_tu_count) := p_access_id;
            g_tu_territory_id(g_tu_count) := p_territory_id;

        END IF;
    ELSE -- l_count = 0
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_count=0');
        END IF;
        -- search backward in array to see if record is already here
        l_i := g_ti_count;
	   l_found := 'N';
	   WHILE l_found = 'N' AND l_i >= 1
        LOOP
            IF g_ti_access_id(l_i) = p_access_id
            AND g_ti_territory_id(l_i) = p_territory_id
            THEN
                l_found := 'Y';
            ELSE
                l_i := l_i - 1;
            END IF;
        END LOOP;

        IF l_found = 'N'
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'access_id and terr_id are not in tu array');
            END IF;
            g_ti_count := g_ti_count + 1;
            g_ti_access_id(g_ti_count) := p_access_id;
            g_ti_territory_id(g_ti_count) := p_territory_id;

        END IF; -- l_found = 'N'

    END IF; -- l_count > 0

END Create_Territory_Accesses;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Flush_Access_Records
 |
 | PURPOSE
 |   After all data are ready, call this procedure to do the insert
 |   and update statements.
 |
 | NOTES
 |
 | HISTORY
 |   06/19/01   SOLIN          Created
 |   11/21/01   SOLIN          Add for request_id
 *-------------------------------------------------------------------------*/

PROCEDURE Flush_Access_Records(
    p_request_id              IN     NUMBER)
IS
l_i             NUMBER;

l_i_num_rows    NUMBER;
l_u_num_rows    NUMBER;
l_ti_num_rows   NUMBER;
l_tu_num_rows   NUMBER;

l_open_status_flag VARCHAR2(1);
l_lead_rank_score  NUMBER;
l_creation_date    DATE;

-- Get whether status is open or not for the lead
-- Get lead_rank_score and lead creation_date
CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
  SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
         NVL(rk.min_score, 0), sl.creation_date
  FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
  WHERE sl.sales_lead_id = c_sales_lead_id
  AND   sl.status_code = sta.status_code
  AND   sl.lead_rank_id = rk.rank_id(+);
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        '*** Flush_Access_Records() ***');
    END IF;

    l_i_num_rows := g_i_count;
    l_u_num_rows := g_u_count;
    l_ti_num_rows := g_ti_count;
    l_tu_num_rows := g_tu_count;

    IF g_u_count > 0
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_u_count=' || g_u_count);

        FOR l_i IN 1..g_u_count LOOP
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                l_i
                || ',Upd Acc acc=' || g_u_access_id(l_i)
                || ' f_acc_f=' || g_u_full_access_flag(l_i));
        END LOOP;
        END IF;

        FORALL l_i IN 1..l_u_num_rows
            UPDATE AS_ACCESSES_ALL
            SET    LAST_UPDATE_DATE       = SYSDATE,
                   LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_LOGIN      = FND_GLOBAL.CONC_LOGIN_ID,
                   PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID,
                   PROGRAM_UPDATE_DATE    = SYSDATE,
                   TEAM_LEADER_FLAG       = g_u_full_access_flag(l_i),
                   REQUEST_ID             = p_request_id
            WHERE  ACCESS_ID = g_u_access_id(l_i);
    END IF;

    IF g_tu_count > 0
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_tu_count=' || g_tu_count);
        FOR l_i IN 1..g_tu_count LOOP
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                l_i
                || ',Upd Terr Acc acc=' || g_tu_access_id(l_i));
        END LOOP;
        END IF;

        FORALL l_i IN 1..l_tu_num_rows
            UPDATE AS_TERRITORY_ACCESSES
            SET    LAST_UPDATE_DATE       = SYSDATE,
                   LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
                   LAST_UPDATE_LOGIN      = FND_GLOBAL.CONC_LOGIN_ID,
                   PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID,
                   PROGRAM_UPDATE_DATE    = SYSDATE,
                   REQUEST_ID             = p_request_id
            WHERE  ACCESS_ID = g_tu_access_id(l_i)
            AND    TERRITORY_ID = g_tu_territory_id(l_i);
    END IF;

    IF g_i_count > 0
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_i_count=' || g_i_count);
        FOR l_i IN 1..g_i_count LOOP
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                l_i
                || ',Ins Acc acc=' || g_i_access_id(l_i)
                || ' rs=' || g_i_resource_id(l_i)
                || ' grp=' || g_i_group_id(l_i)
--                || ' per=' || g_i_person_id(l_i)
                || ' pty=' || g_i_party_id(l_i)
                || ' site=' || g_i_party_site_id(l_i));
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'sl=' || g_i_sales_lead_id(l_i)
                || ' f_acc_f=' || g_i_full_access_flag(l_i));
        END LOOP;
        END IF;

        OPEN c_get_open_status_flag(g_i_sales_lead_id(1));
        FETCH c_get_open_status_flag INTO l_open_status_flag,
            l_lead_rank_score, l_creation_date;
        CLOSE c_get_open_status_flag;

        FORALL l_i IN 1..l_i_num_rows
            INSERT INTO AS_ACCESSES_ALL
                  (ACCESS_ID,
                   ACCESS_TYPE,
                   SALESFORCE_ID,
                   SALES_GROUP_ID,
                   PERSON_ID,
                   CUSTOMER_ID,
                   ADDRESS_ID,
                   PARTNER_CONT_PARTY_ID,
                   PARTNER_CUSTOMER_ID,
                   SALES_LEAD_ID,
                   FREEZE_FLAG,
                   REASSIGN_FLAG,
                   TEAM_LEADER_FLAG,
                   OWNER_FLAG,
                   CREATED_BY_TAP_FLAG,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_UPDATE_DATE,
                   REQUEST_ID,
                   OPEN_FLAG,
                   LEAD_RANK_SCORE,
                   OBJECT_CREATION_DATE)
            SELECT g_i_access_id(l_i),
                   'X',
                   g_i_resource_id(l_i),
                   g_i_group_id(l_i),
                   DECODE(g_i_source(l_i), 'CREATOR', NULL, b.source_id),
                   g_i_party_id(l_i),
                   g_i_party_site_id(l_i),
                   g_i_partner_cont_party_id(l_i),
                   g_i_partner_customer_id(l_i),
                   g_i_sales_lead_id(l_i),
                   g_i_freeze_flag(l_i),
                   'N',
                   g_i_full_access_flag(l_i),
                   'N',
                   DECODE(g_i_source(l_i), 'TERRITORY', 'Y', 'N'),
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   FND_GLOBAL.CONC_LOGIN_ID,
                   FND_GLOBAL.PROG_APPL_ID,
                   SYSDATE,
                   p_request_id,
                   l_open_status_flag,
                   l_lead_rank_score,
                   l_creation_date
            FROM   jtf_rs_resource_extns b
            WHERE  b.resource_id = g_i_resource_id(l_i);
    END IF;

    IF g_ti_count > 0
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_ti_count=' || g_ti_count);
        FOR l_i IN 1..g_ti_count LOOP
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                l_i
                || ',Ins TA acc=' || g_ti_access_id(l_i)
                || ' terr=' || g_ti_territory_id(l_i));
        END LOOP;
        END IF;

        FORALL l_i IN 1..l_ti_num_rows
            INSERT INTO AS_TERRITORY_ACCESSES
                  (ACCESS_ID,
                   TERRITORY_ID,
                   USER_TERRITORY_ID,
                   LAST_UPDATE_DATE,
                   LAST_UPDATED_BY,
                   CREATION_DATE,
                   CREATED_BY,
                   LAST_UPDATE_LOGIN,
                   PROGRAM_APPLICATION_ID,
                   PROGRAM_UPDATE_DATE,
                   REQUEST_ID)
            VALUES
                  (g_ti_access_id(l_i),
                   g_ti_territory_id(l_i),
                   g_ti_territory_id(l_i),
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   SYSDATE,
                   FND_GLOBAL.USER_ID,
                   FND_GLOBAL.CONC_LOGIN_ID,
                   FND_GLOBAL.PROG_APPL_ID,
                   SYSDATE,
                   p_request_id);
    END IF;

END Flush_Access_Records;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Remove_Redundant_Accesses
 |
 | PURPOSE
 |   This procedure is called when profile AS_ENABLE_LEAD_ONLINE_TAP is
 |   set to 'N'.
 |
 | NOTES
 |
 | HISTORY
 |   11/21/01   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Remove_Redundant_Accesses(
    p_sales_lead_id          IN     NUMBER,
    p_request_id             IN     NUMBER)
IS
BEGIN
    DELETE FROM as_territory_accesses
    WHERE access_id IN (
        SELECT acc.access_id
        FROM as_accesses_all acc
        WHERE acc.sales_lead_id = p_sales_lead_id
        AND   acc.request_id = p_request_id
        AND   acc.owner_flag = 'N'
        AND   acc.created_by_tap_flag = 'Y');

    DELETE FROM as_accesses_all
    WHERE sales_lead_id = p_sales_lead_id
    AND   request_id = p_request_id
    AND   owner_flag = 'N'
    AND   created_by_tap_flag = 'Y';

END Remove_Redundant_Accesses;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Add_Creator_In_Sales_Team
 |
 | PURPOSE
 |   This procedure is to add lead creator in lead sales team.
 |
 | NOTES
 |
 | HISTORY
 |   03/12/01   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Add_Creator_In_Sales_Team(
    p_customer_id            IN     NUMBER,
    p_address_id             IN     NUMBER,
    p_sales_lead_id          IN     NUMBER,
    p_identity_salesforce_id IN     NUMBER,
    p_salesgroup_id          IN     NUMBER)
IS
    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category IN ('EMPLOYEE', 'PARTY')
      AND res.user_id = fnd_global.user_id;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- is this cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

    -- Check whether profile resource or login resource is in the sales
    -- team or not. Group_id is not necessary to check here because we don't
    -- care which group_id is in the sales team as long as this resource is
    -- in the sales team.
    CURSOR c_check_sales_team(c_resource_id NUMBER, c_sales_lead_id NUMBER) IS
      SELECT acc.access_id, team_leader_flag
      FROM as_accesses_all acc
      WHERE acc.salesforce_id = c_resource_id
      AND   acc.sales_lead_id = c_sales_lead_id;

    CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member VARCHAR2,
                           c_sales VARCHAR2, c_telesales VARCHAR2,
                           c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y VARCHAR2)
IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = c_rs_group_member --'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in (c_sales, c_telesales, c_fieldsales, c_prm) --'SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> c_y --'Y'
      AND rrel.delete_flag <> c_y --'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = c_resource_id
      AND mem.group_id = u.group_id
      AND u.usage = c_sales --'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             NVL(rk.min_score, 0), sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);

    l_rs_id             NUMBER;
    l_access_id         NUMBER;
    l_group_id          NUMBER;
    l_person_id         NUMBER;
    l_team_leader_flag  VARCHAR2(1);
    l_open_status_flag  VARCHAR2(1);
    l_lead_rank_score   NUMBER;
    l_creation_date     DATE;
BEGIN
      -- Check whether current user is in the sales team or not.
      -- If not, add as view only access.
      -- SOLIN, bug 4702335
      l_rs_id := p_identity_salesforce_id;
      IF p_identity_salesforce_id IS NULL
         OR p_identity_salesforce_id = FND_API.G_MISS_NUM
      THEN
          -- if login user's resource_id is not passed in, get from the system
          OPEN C_get_current_resource;
          FETCH C_get_current_resource INTO l_rs_id;
          IF (C_get_current_resource%NOTFOUND)
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
                 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'No current resource found!');
                 AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Creator won''t be in sales team');
             END IF;
             CLOSE C_get_current_resource;
             RETURN;
          END IF;
          CLOSE C_get_current_resource;
      ELSIF p_salesgroup_id IS NULL
      THEN
          IF (AS_DEBUG_LOW_ON) THEN
             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                 'grp_id null, res not added to sales team');
          END IF;
          RETURN;
      END IF;
          -- Check whether this resource is in sales team or not
          l_access_id := NULL;
          OPEN c_check_sales_team(l_rs_id, p_sales_lead_id);
          FETCH c_check_sales_team INTO l_access_id, l_team_leader_flag;
          CLOSE c_check_sales_team;

          IF l_access_id IS NULL
          THEN
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Add current user to sales team');
              END IF;

              IF p_salesgroup_id = fnd_api.g_miss_num
              THEN
                  OPEN c_get_group_id (l_rs_id, 'RS_GROUP_MEMBER', 'SALES',
                                   'TELESALES', 'FIELDSALES', 'PRM', 'Y');
                  FETCH c_get_group_id INTO l_group_id;
                  CLOSE c_get_group_id;
              ELSE
                  l_group_id := p_salesgroup_id;
              END IF;

              OPEN c_get_person_id (l_rs_id);
              FETCH c_get_person_id INTO l_person_id;
              CLOSE c_get_person_id;
              IF (AS_DEBUG_LOW_ON) THEN
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Cur User rs_id is:' || l_rs_id);
                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Cur User g_id is:' || l_group_id);
              END IF;
              OPEN c_get_open_status_flag (p_sales_lead_id);
              FETCH c_get_open_status_flag INTO l_open_status_flag,
                  l_lead_rank_score, l_creation_date;
              CLOSE c_get_open_status_flag;

              -- Current user is not in sales team, insert this
              -- resource as sales team member. Since this resource doesn't
              -- come from territory, don't insert into
              -- as_territory_accesses
              INSERT INTO as_accesses_all
                  (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
                  ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
                  ,PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
                  ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG
                  ,TEAM_LEADER_FLAG
                  ,OWNER_FLAG, CREATED_BY_TAP_FLAG
                  ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
                  ,PERSON_ID, SALES_GROUP_ID, OPEN_FLAG, LEAD_RANK_SCORE
                  ,OBJECT_CREATION_DATE)
              SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
                  SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID,
                  FND_GLOBAL.PROG_APPL_ID, SYSDATE,
                  'X', 'Y' ,'N', 'Y', 'N', 'N',
                  p_customer_id, p_address_id, p_sales_lead_id,
                  l_rs_id, l_person_id, l_group_id, l_open_status_flag,
                  l_lead_rank_score, l_creation_date
              FROM sys.dual;
          ELSIF l_team_leader_flag = 'N'
          THEN
              -- lead creator is in sales team, but no full access
              UPDATE as_accesses_all
              SET team_leader_flag = 'Y'
              WHERE access_id = l_access_id;
          END IF; -- l_access_id IS NULL

END Add_Creator_In_Sales_Team;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Set_Default_Lead_Owner
 |
 | PURPOSE
 |   This procedure is called when lead owner should be from the profile
 |   or current user.
 |
 | NOTES
 |   This procedure will get resource_id from the profile
 |   AS_DEFAULT_RESOURCE_ID. If this profile is not set, it will get
 |   current user's resource_id. Once resource_id is gotten
 |   AS_SALES_LEADS_LOG, AS_SALES_LEADS, AS_ACCESSES_ALL will be updated.
 |
 | HISTORY
 |   12/05/01   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Set_Default_Lead_Owner(
    p_sales_lead_id                  IN  NUMBER,
    p_salesgroup_id                  IN  NUMBER,
    p_request_id                     IN  NUMBER,
    X_Return_Status                  OUT NOCOPY VARCHAR2,
    X_Msg_Count                      OUT NOCOPY NUMBER,
    X_Msg_Data                       OUT NOCOPY VARCHAR2)
IS
    l_resource_id          NUMBER;
    l_group_id             NUMBER;
    l_person_id            NUMBER;
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_access_exist_flag    VARCHAR2(1);
--    l_routing_status       VARCHAR2(30);
    l_status_code          VARCHAR2(30);
    l_sales_lead_log_id    NUMBER;
    l_reject_reason_code   VARCHAR2(30);
    l_lead_rank_id         NUMBER;
    l_qualified_flag       VARCHAR2(1);
    l_freeze_flag          VARCHAR2(1);
    l_open_status_flag     VARCHAR2(1);
    l_lead_rank_score      NUMBER;
    l_creation_date        DATE;

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category IN ('EMPLOYEE', 'PARTY')
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
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

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

    CURSOR c_access_exist(c_sales_lead_id NUMBER, c_resource_id NUMBER,
                          c_group_id NUMBER) IS
      SELECT 'Y'
      FROM as_accesses_all
      WHERE sales_lead_id = c_sales_lead_id
      AND   salesforce_id = c_resource_id
      AND ((sales_group_id = c_group_id) OR
           (sales_group_id IS NULL AND c_group_id IS NULL));

    CURSOR c_sales_lead(c_sales_lead_id NUMBER) IS
      SELECT customer_id, address_id, reject_reason_code,
             lead_rank_id, qualified_flag, NVL(accept_flag, 'N'), status_code
      FROM as_sales_leads
      WHERE Sales_lead_id = c_sales_lead_id;

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             NVL(rk.min_score, 0), sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_resource_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
    IF l_resource_id IS NULL
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'profile not set');
        END IF;
        -- Profile is not set. hence going against the logged in user

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_resource_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(
                FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'No current resource found!');
            END IF;
        END IF;
        CLOSE C_get_current_resource;

        IF l_resource_id IS NOT NULL
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(
                FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users resource id is:' || l_resource_id);
            END IF;

            IF p_salesgroup_id = fnd_api.g_miss_num
            THEN
                OPEN c_get_group_id (l_resource_id);
                FETCH c_get_group_id INTO l_group_id;
                CLOSE c_get_group_id;
            ELSE
                l_group_id := p_salesgroup_id;
            END IF;

            OPEN c_get_person_id (l_resource_id);
            FETCH c_get_person_id INTO l_person_id;
            CLOSE c_get_person_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(
                FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users group id is:' || l_group_id);
            END IF;

        END IF; -- l_resource_id IS NOT NULL
    ELSE -- profile resource id is not null
        -- Profile was set with some resource id
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile resource id:'|| l_resource_id);
        END IF;
        OPEN c_get_group_id (l_resource_id);
        FETCH c_get_group_id INTO l_group_id;
        CLOSE c_get_group_id;
        OPEN c_get_person_id (l_resource_id);
        FETCH c_get_person_id INTO l_person_id;
        CLOSE c_get_person_id;
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile group id:' || l_group_id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile person id:' || l_person_id);
        END IF;

    END IF; -- l_resource_id IS NULL

    OPEN c_sales_lead(p_sales_lead_id);
    FETCH c_sales_lead INTO l_customer_id, l_address_id,
                            l_reject_reason_code, l_lead_rank_id,
                            l_qualified_flag, l_freeze_flag, l_status_code;
    CLOSE c_sales_lead;

    -- l_routing_status := fnd_profile.value('AS_LEAD_ROUTING_STATUS');
    -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
    --    'Lead Status on Routing:'|| l_routing_status); END IF;

    -- Call API to create log entry
    AS_SALES_LEADS_LOG_PKG.Insert_Row(
        px_log_id                 => l_sales_lead_log_id ,
        p_sales_lead_id           => p_sales_lead_id,
        p_created_by              => fnd_global.user_id,
        p_creation_date           => SYSDATE,
        p_last_updated_by         => fnd_global.user_id,
        p_last_update_date        => SYSDATE,
        p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
        p_request_id              => FND_GLOBAL.Conc_Request_Id,
        p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
        p_program_id              => FND_GLOBAL.Conc_Program_Id,
        p_program_update_date     => SYSDATE,
        p_status_code             => l_status_code, --l_routing_status,
        p_assign_to_person_id     => l_person_id,
        p_assign_to_salesforce_id => l_resource_id,
        p_reject_reason_code      => l_reject_reason_code,
        p_assign_sales_group_id   => l_group_id,
        p_lead_rank_id            => l_lead_rank_id,
        p_qualified_flag          => l_qualified_flag,
        p_category                => NULL);

    -- Call table handler directly, not calling Update_Sales_Lead,
    -- in case current user doesn't have update privilege.
    AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
        p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
        p_LAST_UPDATE_DATE  => SYSDATE,
        p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
        p_CREATION_DATE  => FND_API.G_MISS_DATE,
        p_CREATED_BY  => FND_API.G_MISS_NUM,
        p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
        p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
        p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
        p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
        p_PROGRAM_UPDATE_DATE  => SYSDATE,
        p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
        p_STATUS_CODE => FND_API.G_MISS_CHAR, --l_routing_status,
        p_CUSTOMER_ID  => l_CUSTOMER_ID,
        p_ADDRESS_ID  => l_ADDRESS_ID,
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
        p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
        p_ASSIGN_TO_PERSON_ID  => l_person_id,
        p_ASSIGN_TO_SALESFORCE_ID => l_resource_id,
        p_ASSIGN_SALES_GROUP_ID => l_group_id,
        p_ASSIGN_DATE  => SYSDATE,
        p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
        p_ACCEPT_FLAG  => 'N',
        p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
        p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
        p_SCORECARD_ID  => FND_API.G_MISS_NUM,
        p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
        p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
        p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
        p_REJECT_REASON_CODE  => NULL, --l_reject_reason_code,
        p_DELETED_FLAG => FND_API.G_MISS_CHAR,
        p_OFFER_ID  =>  FND_API.G_MISS_NUM,
        p_QUALIFIED_FLAG => l_qualified_flag,
        p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
        -- p_SECURITY_GROUP_ID    => FND_API.G_MISS_NUM,
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
        p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
        p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
        p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
        p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM,
        -- 11.5.10 new columns
        p_MARKETING_SCORE => FND_API.G_MISS_NUM,
        p_INTERACTION_SCORE => FND_API.G_MISS_NUM,
        p_SOURCE_PRIMARY_REFERENCE => FND_API.G_MISS_CHAR,
        p_SOURCE_SECONDARY_REFERENCE => FND_API.G_MISS_CHAR,
        p_SALES_METHODOLOGY_ID => FND_API.G_MISS_NUM,
        p_SALES_STAGE_ID => FND_API.G_MISS_NUM);

    -- Check whether this resource is in sales team or not
    l_access_exist_flag := 'N';
    OPEN c_access_exist(p_sales_lead_id, l_resource_id, l_group_id);
    FETCH c_access_exist INTO l_access_exist_flag;
    CLOSE c_access_exist;

    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'access exist?'|| l_access_exist_flag);
    END IF;
    IF l_reject_reason_code IS NOT NULL
    THEN
        -- Clear any owner for as_accesses_all
        -- If reject reason_code IS NULL, this workflow process must come
        -- from lead owner is null, owner in as_accesses_all is cleared
        -- already.
        UPDATE as_accesses_all
        SET owner_flag = 'N'
        WHERE sales_lead_id = p_sales_lead_id;
    END IF;

    IF l_access_exist_flag = 'N'
    THEN
        OPEN c_get_open_status_flag(p_sales_lead_id);
        FETCH c_get_open_status_flag INTO l_open_status_flag,
            l_lead_rank_score, l_creation_date;
        CLOSE c_get_open_status_flag;

        -- Default resource is not in sales team, insert this
        -- resource as sales team member. Since this resource doesn't
        -- come from territory, don't insert into
        -- as_territory_accesses
        INSERT INTO as_accesses_all
            (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
            ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
            ,PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
            ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG, TEAM_LEADER_FLAG
            ,OWNER_FLAG, CREATED_BY_TAP_FLAG
            ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
            ,PERSON_ID, SALES_GROUP_ID, REQUEST_ID, OPEN_FLAG
            ,LEAD_RANK_SCORE, OBJECT_CREATION_DATE)
        SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
            SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID,
            FND_GLOBAL.PROG_APPL_ID, SYSDATE,
            'X', l_freeze_flag ,'N','Y', 'Y', 'N',
            l_customer_id, l_address_id, p_sales_lead_id,
            l_resource_id, l_person_id, l_group_id, p_request_id,
            l_open_status_flag, l_lead_rank_score, l_creation_date
        FROM sys.dual;
    ELSE
        -- Default resource is in sales team, update this resource
        -- as owner.
        UPDATE as_accesses_all
        SET team_leader_flag = 'Y',
            owner_flag = 'Y',
            freeze_flag = l_freeze_flag,
            request_id = p_request_id
        WHERE sales_lead_id = p_sales_lead_id
        AND   salesforce_id = l_resource_id
        AND  (sales_group_id = l_group_id OR
             (sales_group_id IS NULL AND l_group_id IS NULL));
    END IF;

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );
END Set_Default_Lead_Owner;

/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Oracle_Internal_CUHK
 |
 | PURPOSE
 |   This procedure is called when profile ASF_IS_ORACLE_INTERNAL is
 |   set to 'Y'.
 |
 | NOTES
 |
 | HISTORY
 |   12/03/01   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Oracle_Internal_CUHK(
    p_sales_lead_id          IN            NUMBER,
    p_salesgroup_id          IN            NUMBER,
    p_request_id             IN            NUMBER,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_msg_count              OUT NOCOPY    NUMBER,
    x_msg_data               OUT NOCOPY    VARCHAR2)
IS
    l_sales_lead_rec       AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type;

    l_resource_id_tbl      AS_LEAD_ROUTING_WF.NUMBER_TABLE;
    l_group_id_tbl         AS_LEAD_ROUTING_WF.NUMBER_TABLE;
    l_person_id_tbl        AS_LEAD_ROUTING_WF.NUMBER_TABLE;
    l_resource_flag_tbl    AS_LEAD_ROUTING_WF.FLAG_TABLE;

    l_rs_id                NUMBER;
    l_resource_id          NUMBER;
    l_group_id             NUMBER;
    l_person_id            NUMBER;
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_access_exist_flag    VARCHAR2(1);
--    l_routing_status       VARCHAR2(30);
    l_status_code          VARCHAR2(30);
    l_sales_lead_log_id    NUMBER;
    l_reject_reason_code   VARCHAR2(30);
    l_lead_rank_id         NUMBER;
    l_qualified_flag       VARCHAR2(1);
    l_freeze_flag          VARCHAR2(1);
    l_open_status_flag     VARCHAR2(1);
    l_lead_rank_score      NUMBER;
    l_creation_date        DATE;

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category IN ('EMPLOYEE', 'PARTY')
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
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

    CURSOR c_access_exist(c_sales_lead_id NUMBER, c_resource_id NUMBER,
                          c_group_id NUMBER) IS
      SELECT 'Y'
      FROM as_accesses_all
      WHERE sales_lead_id = c_sales_lead_id
      AND   salesforce_id = c_resource_id
      AND ((sales_group_id = c_group_id) OR
           (sales_group_id IS NULL AND c_group_id IS NULL));

    CURSOR c_sales_lead(c_sales_lead_id NUMBER) IS
      SELECT customer_id, address_id, reject_reason_code,
             lead_rank_id, qualified_flag, NVL(accept_flag, 'N'), status_code
      FROM as_sales_leads
      WHERE Sales_lead_id = c_sales_lead_id;

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             NVL(rk.min_score, 0), sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);
BEGIN
    -- give sales_lead_id only for Oracle internal
    l_sales_lead_rec.sales_lead_id := p_sales_lead_id;

    AS_LEAD_ROUTING_WF_CUHK.Get_Owner_Pre(
        p_api_version_number    =>  2.0,
        p_init_msg_list         =>  FND_API.G_FALSE,
        p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
        p_commit                =>  FND_API.G_FALSE,
        p_resource_id_tbl       =>  l_resource_id_tbl,
        p_group_id_tbl          =>  l_group_id_tbl,
        p_person_id_tbl         =>  l_person_id_tbl,
        p_resource_flag_tbl     =>  l_resource_flag_tbl,
        p_sales_lead_rec        =>  l_sales_lead_rec,
        x_resource_id           =>  l_resource_id,
        x_group_id              =>  l_group_id,
        x_person_id             =>  l_person_id,
        x_return_status         =>  x_return_status,
        x_msg_count             =>  x_msg_count,
        x_msg_data              =>  x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_resource_id IS NULL
    THEN
        -- Customer user hook return l_resource_id = NULL means that
        -- user decides to use default resource.
        Set_Default_Lead_Owner(p_sales_lead_id, p_salesgroup_id,
            p_request_id, x_return_status, x_msg_count, x_msg_data);
    ELSE
        -- Customer return owner, update AS_SALES_LEADS_LOG and
        -- AS_ACCESSES_ALL, AS_SALES_LEADS
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'res id in upd=' || l_Resource_Id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'group id in upd='||l_group_id);
        END IF;

        OPEN c_sales_lead(p_sales_lead_id);
        FETCH c_sales_lead INTO l_customer_id, l_address_id,
                                l_reject_reason_code, l_lead_rank_id,
                                l_qualified_flag, l_freeze_flag, l_status_code;
        CLOSE c_sales_lead;

--        l_routing_status := fnd_profile.value('AS_LEAD_ROUTING_STATUS');

        -- Call API to create log entry
        AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                 => l_sales_lead_log_id ,
            p_sales_lead_id           => p_sales_lead_id,
            p_created_by              => fnd_global.user_id,
            p_creation_date           => SYSDATE,
            p_last_updated_by         => fnd_global.user_id,
            p_last_update_date        => SYSDATE,
            p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
            p_request_id              => FND_GLOBAL.Conc_Request_Id,
            p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
            p_program_id              => FND_GLOBAL.Conc_Program_Id,
            p_program_update_date     => SYSDATE,
            p_status_code             => l_status_code, --l_routing_status,
            p_assign_to_person_id     => l_person_id,
            p_assign_to_salesforce_id => l_resource_id,
            p_reject_reason_code      => l_reject_reason_code,
            p_assign_sales_group_id   => l_group_id,
            p_lead_rank_id            => l_lead_rank_id,
            p_qualified_flag          => l_qualified_flag,
            p_category                => NULL);

        -- Call table handler directly, not calling Update_Sales_Lead,
        -- in case current user doesn't have update privilege.
        AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
            p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => FND_API.G_MISS_DATE,
            p_CREATED_BY  => FND_API.G_MISS_NUM,
            p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
            p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
            p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
            p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
            p_PROGRAM_UPDATE_DATE  => SYSDATE,
            p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
            p_STATUS_CODE => FND_API.G_MISS_CHAR, --l_routing_status,
            p_CUSTOMER_ID  => l_CUSTOMER_ID,
            p_ADDRESS_ID  => l_ADDRESS_ID,
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
            p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
            p_ASSIGN_TO_PERSON_ID  => l_person_id,
            p_ASSIGN_TO_SALESFORCE_ID => l_resource_id,
            p_ASSIGN_SALES_GROUP_ID => l_group_id,
            p_ASSIGN_DATE  => SYSDATE,
            p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
            p_ACCEPT_FLAG  => 'N',
            p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
            p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
            p_SCORECARD_ID  => FND_API.G_MISS_NUM,
            p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
            p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
            p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
            p_REJECT_REASON_CODE  => NULL, --l_reject_reason_code,
            p_DELETED_FLAG => FND_API.G_MISS_CHAR,
            p_OFFER_ID  =>  FND_API.G_MISS_NUM,
            p_QUALIFIED_FLAG => l_qualified_flag,
            p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
            -- p_SECURITY_GROUP_ID    => FND_API.G_MISS_NUM,
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
            p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
            p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
            p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
            p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM,
            -- 11.5.10 new columns
            p_MARKETING_SCORE => FND_API.G_MISS_NUM,
            p_INTERACTION_SCORE => FND_API.G_MISS_NUM,
            p_SOURCE_PRIMARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SOURCE_SECONDARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SALES_METHODOLOGY_ID => FND_API.G_MISS_NUM,
            p_SALES_STAGE_ID => FND_API.G_MISS_NUM);


        l_access_exist_flag := 'N';
        OPEN c_access_exist(p_sales_lead_id, l_resource_id, l_group_id);
        FETCH c_access_exist INTO l_access_exist_flag;
        CLOSE c_access_exist;

        IF l_reject_reason_code IS NOT NULL
        THEN
            -- Clear any owner for as_accesses_all
            -- If reject reason_code IS NULL, this workflow process must come
            -- from lead owner is null, owner in as_accesses_all is cleared
            -- already.
            UPDATE as_accesses_all
            SET owner_flag = 'N'
            WHERE sales_lead_id = p_sales_lead_id;
        END IF;

        IF l_access_exist_flag = 'Y'
        THEN
            UPDATE as_accesses_all
            SET team_leader_flag = 'Y',
                owner_flag = 'Y',
                freeze_flag = l_freeze_flag,
                created_by_tap_flag = 'Y'
            WHERE sales_lead_id = p_sales_lead_id
            AND   salesforce_id = l_resource_id
            AND ((sales_group_id = l_group_id) OR
                 (sales_group_id IS NULL AND l_group_id IS NULL));
        ELSE
            OPEN c_get_open_status_flag(p_sales_lead_id);
            FETCH c_get_open_status_flag INTO l_open_status_flag,
                l_lead_rank_score, l_creation_date;
            CLOSE c_get_open_status_flag;

            INSERT INTO as_accesses_all
                (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
                ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
                ,PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
                ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG, TEAM_LEADER_FLAG
                ,OWNER_FLAG, CREATED_BY_TAP_FLAG
                ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
                ,PERSON_ID, SALES_GROUP_ID, OPEN_FLAG, LEAD_RANK_SCORE
                ,OBJECT_CREATION_DATE)
            SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
                SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID,
                FND_GLOBAL.PROG_APPL_ID, SYSDATE, 'X',
                l_freeze_flag ,'N', 'Y', 'Y', 'N',
                l_customer_id, l_address_id, p_sales_lead_id,
                l_resource_id, l_person_id, l_group_id, l_open_status_flag,
                l_lead_rank_score, l_creation_date
            FROM SYS.DUAL;

        END IF; -- l_access_exist_flag = 'Y'
    END IF; -- l_resource_id IS NULL
END Oracle_Internal_CUHK;


/*-------------------------------------------------------------------------*
 | PRIVATE ROUTINE
 |   Get_Partner_Lead_Owner
 |
 | PURPOSE
 |   This procedure is called to get partner lead owner.
 |
 | NOTES
 |
 | HISTORY
 |   01/21/02   SOLIN          Created
 *-------------------------------------------------------------------------*/
PROCEDURE Get_Partner_Lead_Owner(
    p_sales_lead_id          IN     NUMBER)
IS
    CURSOR c_access_exist(c_sales_lead_id NUMBER, c_resource_id NUMBER,
                          c_group_id NUMBER) IS
      SELECT 'Y'
      FROM as_accesses_all
      WHERE sales_lead_id = c_sales_lead_id
      AND   salesforce_id = c_resource_id
      AND ((sales_group_id = c_group_id) OR
           (sales_group_id IS NULL AND c_group_id IS NULL));

    CURSOR c_sales_lead(c_sales_lead_id NUMBER) IS
      SELECT customer_id, address_id, reject_reason_code,
             lead_rank_id, qualified_flag, status_code
      FROM as_sales_leads
      WHERE sales_lead_id = c_sales_lead_id;

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
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

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             NVL(rk.min_score, 0), sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);

    l_i                    NUMBER;
    l_found_flag           VARCHAR2(1);
    l_resource_id          NUMBER;
    l_person_id            NUMBER;
    l_group_id             NUMBER;
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_access_exist_flag    VARCHAR2(1);
--    l_routing_status       VARCHAR2(30);
    l_status_code          VARCHAR2(30);
    l_sales_lead_log_id    NUMBER;
    l_reject_reason_code   VARCHAR2(30);
    l_lead_rank_id         NUMBER;
    l_qualified_flag       VARCHAR2(1);
    l_open_status_flag     VARCHAR2(1);
    l_lead_rank_score      NUMBER;
    l_creation_date        DATE;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Get_Partner_Lead_Owner');
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'g_i_count=' || g_i_count);
    END IF;
    l_found_flag := 'N';
    IF g_i_count > 0
    THEN
        l_i := g_i_resource_id.first;
        WHILE l_i <= g_i_resource_id.last AND l_found_flag = 'N'
        LOOP
            IF g_i_owner_flag(l_i) = 'Y'
            THEN
                l_found_flag := 'Y';
                EXIT;
            END IF;
            l_i := l_i + 1;
        END LOOP;
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Owner found?' || l_found_flag);
    END IF;
    IF l_found_flag = 'Y'
    THEN
        l_resource_id := g_i_resource_id(l_i);
        l_group_id := g_i_group_id(l_i);
    ELSE
        -- no owner found, get owner from profile
        l_resource_id := fnd_profile.value('AS_DEFAULT_CM_FOR_LEAD');

        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'AS_DEFAULT_CM=' || l_resource_id);
        END IF;
        IF l_resource_id IS NULL
        THEN
            IF (AS_DEBUG_ERROR_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                'AS_NO_DEFAULT_CM');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN c_get_group_id(l_resource_id);
        FETCH c_get_group_id INTO l_group_id;
        CLOSE c_get_group_id;
    END IF;

    OPEN c_get_person_id(l_resource_id);
    FETCH c_get_person_id INTO l_person_id;
    CLOSE c_get_person_id;

    IF (AS_DEBUG_LOW_ON) THEN
    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'Owner sf_id=' || l_resource_id || ',g=' || l_group_id);
    END IF;
    OPEN c_sales_lead(p_sales_lead_id);
    FETCH c_sales_lead INTO l_customer_id, l_address_id,
                            l_reject_reason_code, l_lead_rank_id,
                            l_qualified_flag, l_status_code;
    CLOSE c_sales_lead;

--    l_routing_status := fnd_profile.value('AS_LEAD_ROUTING_STATUS');

    -- Call API to create log entry
    AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                 => l_sales_lead_log_id ,
            p_sales_lead_id           => p_sales_lead_id,
            p_created_by              => fnd_global.user_id,
            p_creation_date           => SYSDATE,
            p_last_updated_by         => fnd_global.user_id,
            p_last_update_date        => SYSDATE,
            p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
            p_request_id              => FND_GLOBAL.Conc_Request_Id,
            p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
            p_program_id              => FND_GLOBAL.Conc_Program_Id,
            p_program_update_date     => SYSDATE,
            p_status_code             => l_status_code, --l_routing_status,
            p_assign_to_person_id     => l_person_id,
            p_assign_to_salesforce_id => l_resource_id,
            p_reject_reason_code      => l_reject_reason_code,
            p_assign_sales_group_id   => l_group_id,
            p_lead_rank_id            => l_lead_rank_id,
            p_qualified_flag          => l_qualified_flag,
            p_category                => NULL);

    -- Call table handler directly, not calling Update_Sales_Lead,
    -- in case current user doesn't have update privilege.
    AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
            p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
            p_LAST_UPDATE_DATE  => SYSDATE,
            p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
            p_CREATION_DATE  => FND_API.G_MISS_DATE,
            p_CREATED_BY  => FND_API.G_MISS_NUM,
            p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
            p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
            p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
            p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
            p_PROGRAM_UPDATE_DATE  => SYSDATE,
            p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
            p_STATUS_CODE => FND_API.G_MISS_CHAR, --l_routing_status,
            p_CUSTOMER_ID  => l_CUSTOMER_ID,
            p_ADDRESS_ID  => l_ADDRESS_ID,
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
            p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
            p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
            p_ASSIGN_TO_PERSON_ID  => l_person_id,
            p_ASSIGN_TO_SALESFORCE_ID => l_resource_id,
            p_ASSIGN_SALES_GROUP_ID => l_group_id,
            p_ASSIGN_DATE  => SYSDATE,
            p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
            p_ACCEPT_FLAG  => 'N',
            p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
            p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
            p_SCORECARD_ID  => FND_API.G_MISS_NUM,
            p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
            p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
            p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
            p_REJECT_REASON_CODE  => NULL, --l_reject_reason_code,
            p_DELETED_FLAG => FND_API.G_MISS_CHAR,
            p_OFFER_ID  =>  FND_API.G_MISS_NUM,
            p_QUALIFIED_FLAG => l_qualified_flag,
            p_ORIG_SYSTEM_CODE => FND_API.G_MISS_CHAR,
            -- p_SECURITY_GROUP_ID    => FND_API.G_MISS_NUM,
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
            p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
            p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
            p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
            p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM,
            -- 11.5.10 new columns
            p_MARKETING_SCORE => FND_API.G_MISS_NUM,
            p_INTERACTION_SCORE => FND_API.G_MISS_NUM,
            p_SOURCE_PRIMARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SOURCE_SECONDARY_REFERENCE => FND_API.G_MISS_CHAR,
            p_SALES_METHODOLOGY_ID => FND_API.G_MISS_NUM,
            p_SALES_STAGE_ID => FND_API.G_MISS_NUM);

    l_access_exist_flag := 'N';
    OPEN c_access_exist(p_sales_lead_id, l_resource_id, l_group_id);
    FETCH c_access_exist INTO l_access_exist_flag;
    CLOSE c_access_exist;

    IF l_reject_reason_code IS NOT NULL
    THEN
        -- Clear any owner for as_accesses_all
        -- If reject reason_code IS NULL, this workflow process must come
        -- from lead owner is null, owner in as_accesses_all is cleared
        -- already.
        UPDATE as_accesses_all
        SET owner_flag = 'N'
        WHERE sales_lead_id = p_sales_lead_id;
    END IF;

    -- If referral_type IS NOT NULL, owner has freeze_flag = 'Y' always.
    -- Otherwise, owner's freeze_flag is the same as as_sales_leads.accept_flag
    IF l_access_exist_flag = 'Y'
    THEN
        UPDATE as_accesses_all
        SET team_leader_flag = 'Y',
            owner_flag = 'Y'
--            created_by_tap_flag = 'Y'
        WHERE sales_lead_id = p_sales_lead_id
        AND   salesforce_id = l_resource_id
        AND ((sales_group_id = l_group_id) OR
             (sales_group_id IS NULL AND l_group_id IS NULL));
    ELSE
        OPEN c_get_open_status_flag(p_sales_lead_id);
        FETCH c_get_open_status_flag INTO l_open_status_flag,
            l_lead_rank_score, l_creation_date;
        CLOSE c_get_open_status_flag;

        INSERT INTO as_accesses_all
            (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
            ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
            ,PROGRAM_APPLICATION_ID, PROGRAM_UPDATE_DATE
            ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG, TEAM_LEADER_FLAG
            ,OWNER_FLAG, CREATED_BY_TAP_FLAG
            ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
            ,PERSON_ID, SALES_GROUP_ID, OPEN_FLAG, LEAD_RANK_SCORE
            ,OBJECT_CREATION_DATE)
        SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
            SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID,
            FND_GLOBAL.PROG_APPL_ID, SYSDATE, 'X',
            'Y' ,'N', 'Y', 'Y', 'N',
            l_customer_id, l_address_id, p_sales_lead_id,
            l_resource_id, l_person_id, l_group_id, l_open_status_flag,
            l_lead_rank_score, l_creation_date
        FROM SYS.DUAL;
    END IF; -- l_access_exist_flag = 'Y'

END Get_Partner_Lead_Owner;

PROCEDURE Get_Alternate_Resource(
  p_salesgroup_id    IN  NUMBER) IS
    l_rs_id     NUMBER := NULL;

    CURSOR C_get_current_resource IS
      SELECT res.resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category = 'EMPLOYEE'
      AND res.user_id = fnd_global.user_id;

    CURSOR c_get_group_id(c_resource_id NUMBER) IS
      SELECT grp.group_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')
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

    -- A resource may not be in any group. Besides, jtf_rs_group_members
    -- may not have person_id for all resources. Therefore, get person_id
    -- in this cursor, instead of in the above cursor.
    CURSOR c_get_person_id(c_resource_id NUMBER) IS
      SELECT res.source_id
      FROM jtf_rs_resource_extns res
      WHERE res.resource_id = c_resource_id;

BEGIN
    l_rs_id := fnd_profile.value('AS_DEFAULT_RESOURCE_ID');
    IF l_rs_id IS NULL
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'profile not set');
        END IF;
        -- Profile is not set. hence going against the logged in user

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'No resource found for login user!');
            END IF;
            CLOSE C_get_current_resource;
            RETURN;
        END IF;
        CLOSE C_get_current_resource;

        IF l_rs_id IS NOT NULL
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'User''s resource id is:' || l_rs_id);
            END IF;
            IF p_salesgroup_id = fnd_api.g_miss_num
            THEN
                g_group_id_tbl(1) := NULL;
                OPEN c_get_group_id (l_rs_id);
                FETCH c_get_group_id INTO g_group_id_tbl(1);
                CLOSE c_get_group_id;
            ELSE
                g_group_id_tbl(1) := p_salesgroup_id;
            END IF;

            OPEN c_get_person_id (l_rs_id);
            FETCH c_get_person_id INTO g_person_id_tbl(1);
            CLOSE c_get_person_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users group id is:' || g_group_id_tbl(1));
            END IF;
            g_resource_id_tbl(1) := l_rs_id;
            g_resource_flag_tbl(1) := 'L';
        END IF;

    ELSE -- profile resource id is not null
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile resource id :'|| l_rs_id);
        END IF;
        g_group_id_tbl(1) := NULL;
        OPEN c_get_group_id (l_rs_id);
        FETCH c_get_group_id INTO g_group_id_tbl(1);
        CLOSE c_get_group_id;
        OPEN c_get_person_id (l_rs_id);
        FETCH c_get_person_id INTO g_person_id_tbl(1);
        CLOSE c_get_person_id;
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile group id :' || g_group_id_tbl(1));
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Profile person id :' || g_person_id_tbl(1));
        END IF;
        g_resource_id_tbl(1) := l_rs_id;
        g_resource_flag_tbl(1) := 'D';

        OPEN C_get_current_resource;
        FETCH C_get_current_resource INTO l_rs_id;
        IF (C_get_current_resource%NOTFOUND)
        THEN
            CLOSE C_get_current_resource;
            -- result := 'COMPLETE:ERROR';
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'No resource found!');
            END IF;
            RETURN;
        END IF;
        CLOSE C_get_current_resource;

        IF l_rs_id IS NOT NULL AND
           l_rs_id <> g_resource_id_tbl(1)
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'User''s resource id is:' || l_rs_id);
            END IF;
            IF p_salesgroup_id = fnd_api.g_miss_num
            THEN
                g_group_id_tbl(2) := NULL;
                OPEN c_get_group_id (l_rs_id);
                FETCH c_get_group_id INTO g_group_id_tbl(2);
                CLOSE c_get_group_id;
            ELSE
                g_group_id_tbl(2) := p_salesgroup_id;
            END IF;

            OPEN c_get_person_id (l_rs_id);
            FETCH c_get_person_id INTO g_person_id_tbl(2);
            CLOSE c_get_person_id;
            IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Users group id is:' || g_group_id_tbl(2));
            END IF;
            g_resource_id_tbl(2) := l_rs_id;
            g_resource_flag_tbl(2) := 'L';
        END IF;
    END IF; -- resource id from profile check

END Get_Alternate_Resource;

PROCEDURE Get_Available_Resource (
    p_sales_lead_id   IN  NUMBER,
    p_salesgroup_id   IN  NUMBER,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2)
IS
  l_sales_lead_id         NUMBER;
  l_resource_id_tbl       AS_LEAD_ROUTING_WF.NUMBER_TABLE;
  l_group_id_tbl          AS_LEAD_ROUTING_WF.NUMBER_TABLE;
  l_person_id_tbl         AS_LEAD_ROUTING_WF.NUMBER_TABLE;
  l_resource_flag_tbl     AS_LEAD_ROUTING_WF.FLAG_TABLE;
  l_check_calendar        VARCHAR2(1);
  l_index1                NUMBER; -- point to l_resource_id_tbl
  l_index2                NUMBER; -- point to g_resource_id_tbl
  l_last                  NUMBER; -- total number of rec in l_resource_id_tbl
  l_planned_start_date    DATE;
  l_planned_end_date      DATE;
  l_shift_construct_id    NUMBER;
  l_availability_type     VARCHAR2(60);

  -- SOLIN, enhancement for 11.5.9, 11/08/2002
  -- Leads re-route must not be routed back to a resource that has previously
  -- owned the lead before.
  CURSOR c_get_lead_resource(c_sales_lead_id NUMBER) IS
    SELECT ACC.SALESFORCE_ID, ACC.SALES_GROUP_ID, ACC.PERSON_ID, 'T'
    FROM AS_ACCESSES_ALL ACC
    WHERE ACC.SALES_LEAD_ID = c_sales_lead_id
    AND ACC.CREATED_BY_TAP_FLAG = 'Y'
    AND NOT EXISTS (
        SELECT 1
        FROM AS_SALES_LEADS_LOG LOG
        WHERE LOG.SALES_LEAD_ID = c_sales_lead_id
        AND   LOG.ASSIGN_TO_SALESFORCE_ID = ACC.SALESFORCE_ID
        AND  (LOG.ASSIGN_SALES_GROUP_ID = ACC.SALES_GROUP_ID
          OR  LOG.ASSIGN_SALES_GROUP_ID IS NULL AND ACC.SALES_GROUP_ID IS NULL))
    ORDER BY ACC.ACCESS_ID;
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Get_Available_Resource: Start');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get sales team for the sales lead
    OPEN c_get_lead_resource(p_sales_lead_id);
    FETCH c_get_lead_resource BULK COLLECT INTO
        l_resource_id_tbl, l_group_id_tbl, l_person_id_tbl,
        l_resource_flag_tbl;
    CLOSE c_get_lead_resource;

    l_check_calendar :=
        NVL(FND_PROFILE.Value('AS_SL_ASSIGN_CALENDAR_REQ'),'N');
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'l_resource_id_tbl.count=' || l_resource_id_tbl.count);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Check calendar?' || l_check_calendar);
    END IF;

    g_resource_id_tbl.delete;
    l_last := l_resource_id_tbl.last;
    IF l_check_calendar = 'Y' AND l_last > 0
    THEN
        l_index1 := 1;
        l_index2 := 0;
        WHILE l_index1 <= l_last
        LOOP
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(
                    FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'Check resource ' || l_resource_id_tbl(l_index1));
            END IF;
            -- Check the calendar for resource availability
            -- Call Calendar API
            JTF_CALENDAR_PUB.GET_AVAILABLE_SLOT(
                P_API_VERSION        => 1.0,
                P_INIT_MSG_LIST      => FND_API.G_FALSE,
                P_RESOURCE_ID        => l_resource_id_tbl(l_index1),
                P_RESOURCE_TYPE      => 'RS_EMPLOYEE',
                P_START_DATE_TIME    => SYSDATE-1,
                P_END_DATE_TIME      => SYSDATE+1,
                P_DURATION           => 8,
                X_RETURN_STATUS      => x_return_status,
                X_MSG_COUNT          => x_msg_count,
                X_MSG_DATA           => x_msg_data,
                X_SLOT_START_DATE    => l_planned_start_date,
                X_SLOT_END_DATE      => l_planned_end_date,
                X_SHIFT_CONSTRUCT_ID => l_shift_construct_id,
                X_AVAILABILITY_TYPE  => l_availability_type);

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE fnd_api.g_exc_error;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(
                    FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'l_shift_construct_id=' || l_shift_construct_id);
            END IF;
            IF l_shift_construct_id IS NOT NULL
            THEN
                l_index2 := l_index2 + 1;
                g_resource_id_tbl(l_index2) := l_resource_id_tbl(l_index1);
                g_group_id_tbl(l_index2) := l_group_id_tbl(l_index1);
                g_person_id_tbl(l_index2) := l_person_id_tbl(l_index1);
                g_resource_flag_tbl(l_index2) :=
                    l_resource_flag_tbl(l_index1);
            END IF;
            l_index1 := l_index1 + 1;
        END LOOP; -- l_index1 <= l_last
    ELSE
        g_resource_id_tbl := l_resource_id_tbl;
        g_group_id_tbl := l_group_id_tbl;
        g_person_id_tbl := l_person_id_tbl;
        g_resource_flag_tbl := l_resource_flag_tbl;
    END IF; -- l_check_calendar = 'Y' AND l_last > 0

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'g_resource_id_tbl.count=' || g_resource_id_tbl.count);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Get_Available_Resource: End');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
        END IF;
END Get_Available_Resource;


PROCEDURE Get_Owner(
    p_sales_lead_id      IN  NUMBER,
    p_salesgroup_id      IN  NUMBER,
    x_resource_id        OUT NOCOPY NUMBER,
    x_group_id           OUT NOCOPY NUMBER,
    x_person_id          OUT NOCOPY NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)
IS
  l_rs_id                 NUMBER := null;

  l_call_user_hook        BOOLEAN;
  l_sales_lead_rec        AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type;
  l_org_owner_id_tbl      NUMBER_TABLE;
  l_i                     NUMBER;

  l_resource_id           NUMBER;
  l_group_id              NUMBER;
  l_person_id             NUMBER;
  l_resource_avail_flag   VARCHAR2(1);

  CURSOR c_get_sales_lead(c_sales_lead_id NUMBER) IS
    SELECT SALES_LEAD_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
           CREATED_BY, LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
           PROGRAM_ID, PROGRAM_UPDATE_DATE, LEAD_NUMBER, STATUS_CODE,
           CUSTOMER_ID, ADDRESS_ID, SOURCE_PROMOTION_ID, INITIATING_CONTACT_ID,
           ORIG_SYSTEM_REFERENCE, CONTACT_ROLE_CODE, CHANNEL_CODE,
           BUDGET_AMOUNT, CURRENCY_CODE, DECISION_TIMEFRAME_CODE,
           CLOSE_REASON, LEAD_RANK_ID, LEAD_RANK_CODE, PARENT_PROJECT,
           DESCRIPTION, ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
           ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
           ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
           ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15, BUDGET_STATUS_CODE,
           ACCEPT_FLAG, VEHICLE_RESPONSE_CODE, TOTAL_SCORE, SCORECARD_ID,
           KEEP_FLAG, URGENT_FLAG, IMPORT_FLAG, REJECT_REASON_CODE,
           DELETED_FLAG, OFFER_ID, INCUMBENT_PARTNER_PARTY_ID,
           INCUMBENT_PARTNER_RESOURCE_ID, PRM_EXEC_SPONSOR_FLAG,
           PRM_PRJ_LEAD_IN_PLACE_FLAG, PRM_SALES_LEAD_TYPE,
           PRM_IND_CLASSIFICATION_CODE, QUALIFIED_FLAG, ORIG_SYSTEM_CODE,
           PRM_ASSIGNMENT_TYPE, AUTO_ASSIGNMENT_TYPE, PRIMARY_CONTACT_PARTY_ID,
           PRIMARY_CNT_PERSON_PARTY_ID, PRIMARY_CONTACT_PHONE_ID,
           REFERRED_BY, REFERRAL_TYPE, REFERRAL_STATUS, REF_DECLINE_REASON,
           REF_COMM_LTR_STATUS, REF_ORDER_NUMBER, REF_ORDER_AMT,
           REF_COMM_AMT, LEAD_DATE, SOURCE_SYSTEM, COUNTRY,
           TOTAL_AMOUNT, EXPIRATION_DATE, LEAD_ENGINE_RUN_DATE, LEAD_RANK_IND,
           CURRENT_REROUTES
    FROM AS_SALES_LEADS
    WHERE SALES_LEAD_ID = c_sales_lead_id;

  CURSOR c_get_resource_avail(c_sales_lead_id NUMBER) IS
    SELECT 'Y'
    FROM AS_ACCESSES_ALL ACC
    WHERE ACC.SALES_LEAD_ID = c_sales_lead_id
    AND ACC.CREATED_BY_TAP_FLAG = 'Y';
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Get_Owner: Start');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF g_resource_id_tbl.count = 0
    THEN
        Get_Alternate_Resource(p_salesgroup_id);
    END IF;

    l_call_user_hook := JTF_USR_HKS.Ok_to_execute('AS_LEAD_ROUTING_WF',
                        'GetOwner','B','C');

    -- USER HOOK standard : customer pre-processing section - mandatory
    IF l_call_user_hook
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Call user_hook is true');
        END IF;
        OPEN c_get_sales_lead(p_sales_lead_id);
        FETCH c_get_sales_lead INTO
            l_sales_lead_rec.SALES_LEAD_ID,
            l_sales_lead_rec.LAST_UPDATE_DATE,
            l_sales_lead_rec.LAST_UPDATED_BY,
            l_sales_lead_rec.CREATION_DATE,
            l_sales_lead_rec.CREATED_BY,
            l_sales_lead_rec.LAST_UPDATE_LOGIN,
            l_sales_lead_rec.REQUEST_ID,
            l_sales_lead_rec.PROGRAM_APPLICATION_ID,
            l_sales_lead_rec.PROGRAM_ID,
            l_sales_lead_rec.PROGRAM_UPDATE_DATE,
            l_sales_lead_rec.LEAD_NUMBER, l_sales_lead_rec.STATUS_CODE,
            l_sales_lead_rec.CUSTOMER_ID, l_sales_lead_rec.ADDRESS_ID,
            l_sales_lead_rec.SOURCE_PROMOTION_ID,
            l_sales_lead_rec.INITIATING_CONTACT_ID,
            l_sales_lead_rec.ORIG_SYSTEM_REFERENCE,
            l_sales_lead_rec.CONTACT_ROLE_CODE,
            l_sales_lead_rec.CHANNEL_CODE,
            l_sales_lead_rec.BUDGET_AMOUNT, l_sales_lead_rec.CURRENCY_CODE,
            l_sales_lead_rec.DECISION_TIMEFRAME_CODE,
            l_sales_lead_rec.CLOSE_REASON, l_sales_lead_rec.LEAD_RANK_ID,
            l_sales_lead_rec.LEAD_RANK_CODE,
            l_sales_lead_rec.PARENT_PROJECT,
            l_sales_lead_rec.DESCRIPTION,
            l_sales_lead_rec.ATTRIBUTE_CATEGORY,
            l_sales_lead_rec.ATTRIBUTE1, l_sales_lead_rec.ATTRIBUTE2,
            l_sales_lead_rec.ATTRIBUTE3, l_sales_lead_rec.ATTRIBUTE4,
            l_sales_lead_rec.ATTRIBUTE5, l_sales_lead_rec.ATTRIBUTE6,
            l_sales_lead_rec.ATTRIBUTE7, l_sales_lead_rec.ATTRIBUTE8,
            l_sales_lead_rec.ATTRIBUTE9, l_sales_lead_rec.ATTRIBUTE10,
            l_sales_lead_rec.ATTRIBUTE11, l_sales_lead_rec.ATTRIBUTE12,
            l_sales_lead_rec.ATTRIBUTE13, l_sales_lead_rec.ATTRIBUTE14,
            l_sales_lead_rec.ATTRIBUTE15,
            l_sales_lead_rec.BUDGET_STATUS_CODE,
            l_sales_lead_rec.ACCEPT_FLAG,
            l_sales_lead_rec.VEHICLE_RESPONSE_CODE,
            l_sales_lead_rec.TOTAL_SCORE, l_sales_lead_rec.SCORECARD_ID,
            l_sales_lead_rec.KEEP_FLAG, l_sales_lead_rec.URGENT_FLAG,
            l_sales_lead_rec.IMPORT_FLAG,
            l_sales_lead_rec.REJECT_REASON_CODE,
            l_sales_lead_rec.DELETED_FLAG, l_sales_lead_rec.OFFER_ID,
            l_sales_lead_rec.INCUMBENT_PARTNER_PARTY_ID,
            l_sales_lead_rec.INCUMBENT_PARTNER_RESOURCE_ID,
            l_sales_lead_rec.PRM_EXEC_SPONSOR_FLAG,
            l_sales_lead_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
            l_sales_lead_rec.PRM_SALES_LEAD_TYPE,
            l_sales_lead_rec.PRM_IND_CLASSIFICATION_CODE,
            l_sales_lead_rec.QUALIFIED_FLAG,
            l_sales_lead_rec.ORIG_SYSTEM_CODE,
            l_sales_lead_rec.PRM_ASSIGNMENT_TYPE,
            l_sales_lead_rec.AUTO_ASSIGNMENT_TYPE,
            l_sales_lead_rec.PRIMARY_CONTACT_PARTY_ID,
            l_sales_lead_rec.PRIMARY_CNT_PERSON_PARTY_ID,
            l_sales_lead_rec.PRIMARY_CONTACT_PHONE_ID,
            l_sales_lead_rec.REFERRED_BY,
            l_sales_lead_rec.REFERRAL_TYPE,
            l_sales_lead_rec.REFERRAL_STATUS,
            l_sales_lead_rec.REF_DECLINE_REASON,
            l_sales_lead_rec.REF_COMM_LTR_STATUS,
            l_sales_lead_rec.REF_ORDER_NUMBER,
            l_sales_lead_rec.REF_ORDER_AMT,
            l_sales_lead_rec.REF_COMM_AMT,
            l_sales_lead_rec.LEAD_DATE,
            l_sales_lead_rec.SOURCE_SYSTEM,
            l_sales_lead_rec.COUNTRY,
            l_sales_lead_rec.TOTAL_AMOUNT,
            l_sales_lead_rec.EXPIRATION_DATE,
            l_sales_lead_rec.LEAD_ENGINE_RUN_DATE,
            l_sales_lead_rec.LEAD_RANK_IND,
            l_sales_lead_rec.CURRENT_REROUTES;
        CLOSE c_get_sales_lead;
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'desc:' || l_sales_lead_rec.description);
        END IF;

        AS_LEAD_ROUTING_WF_CUHK.Get_Owner_Pre(
            p_api_version_number    =>  2.0,
            p_init_msg_list         =>  FND_API.G_FALSE,
            p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
            p_commit                =>  FND_API.G_FALSE,
            p_resource_id_tbl       =>  g_resource_id_tbl,
            p_group_id_tbl          =>  g_group_id_tbl,
            p_person_id_tbl         =>  g_person_id_tbl,
            p_resource_flag_tbl     =>  g_resource_flag_tbl,
            p_sales_lead_rec        =>  l_sales_lead_rec,
            x_resource_id           =>  l_resource_id,
            x_group_id              =>  l_group_id,
            x_person_id             =>  l_person_id,
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE fnd_api.g_exc_error;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
    END IF; -- call user hook

    IF (l_call_user_hook AND l_resource_id IS NULL) OR
        NOT l_call_user_hook
    THEN
        IF NOT l_call_user_hook
        THEN
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'There''s no customer user hook');
            END IF;
        ELSE
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'User hook doesn''t return resource');
            END IF;
        END IF;

        -- Set the first resource as owner
        -- If owner decline this sales lead and s/he is the only
        -- salesforce in the sales team, s/he will be stuck in it.
        l_resource_id := g_resource_id_tbl(1);
        l_group_id := g_group_id_tbl(1);
        l_person_id := g_person_id_tbl(1);

        IF g_resource_flag_tbl(1) = 'D'
        THEN
            OPEN c_get_resource_avail(p_sales_lead_id);
            FETCH c_get_resource_avail INTO l_resource_avail_flag;
            CLOSE c_get_resource_avail;
            IF (AS_DEBUG_LOW_ON) THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'res avail?' || l_resource_avail_flag);
            END IF;
            x_return_status := 'W';
            IF l_resource_avail_flag = 'Y'
            THEN
                -- There are resources available, but they were previous lead
                -- owners.
                AS_UTILITY_PVT.Set_Message(
                    p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name  => 'AS_WARN_DEF_RESOURCE_ID');
            ELSE
                AS_UTILITY_PVT.Set_Message(
                    p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                    p_msg_name  => 'AS_WARN_USING_DEF_RESOURCE_ID');
            END IF;
        ELSIF g_resource_flag_tbl(1) = 'L'
        THEN
            x_return_status := 'W';
            AS_UTILITY_PVT.Set_Message(
                p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name  => 'AS_WARN_USING_USER_RESOURCE_ID');
        END IF;
    END IF;
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Set owner rs_id=' || l_resource_id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            ' group_id=' || l_group_id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            ' person_id=' || l_person_id);
    END IF;

    x_resource_id := l_resource_id;
    x_group_id := l_group_id;
    x_person_id := l_person_id;
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Get_Owner: End');
    END IF;
    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );
EXCEPTION
    WHEN OTHERS THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SQLCODE:' || SQLCODE || ' SQLERRM: ' || SQLERRM);
        END IF;
END Get_Owner;


PROCEDURE Update_Sales_Leads (
    p_sales_lead_id      IN  NUMBER,
    p_resource_id        IN  NUMBER,
    p_group_id           IN  NUMBER,
    p_person_id          IN  NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2)
IS
    l_customer_id          NUMBER;
    l_address_id           NUMBER;
    l_access_exist_flag    VARCHAR2(1);
    l_status_code          VARCHAR2(30);
    l_sales_lead_log_id    NUMBER;
    l_reject_reason_code   VARCHAR2(30);
    l_lead_rank_id         NUMBER;
    l_qualified_flag       VARCHAR2(1);
    l_freeze_flag          VARCHAR2(1) := 'N';
    l_open_status_flag     VARCHAR2(1);
    l_lead_rank_score      NUMBER;
    l_creation_date        DATE;

    CURSOR c_access_exist(c_sales_lead_id NUMBER, c_resource_id NUMBER,
                        c_group_id NUMBER) IS
      SELECT freeze_flag
      FROM as_accesses_all
      WHERE sales_lead_id = c_sales_lead_id
      AND   salesforce_id = c_resource_id
      AND ((sales_group_id = c_group_id) OR
           (sales_group_id IS NULL AND c_group_id IS NULL));

    CURSOR c_sales_lead(c_sales_lead_id NUMBER) IS
      SELECT customer_id, address_id, reject_reason_code,
             lead_rank_id, qualified_flag, status_code
      FROM as_sales_leads
      WHERE Sales_lead_id = c_sales_lead_id;

    -- Get whether status is open or not for the lead
    -- Get lead_rank_score and lead creation_date
    CURSOR c_get_open_status_flag(c_sales_lead_id NUMBER) IS
      SELECT DECODE(sta.opp_open_status_flag, 'Y', 'Y', 'N', NULL),
             NVL(rk.min_score, 0), sl.creation_date
      FROM as_statuses_b sta, as_sales_leads sl, as_sales_lead_ranks_b rk
      WHERE sl.sales_lead_id = c_sales_lead_id
      AND   sl.status_code = sta.status_code
      AND   sl.lead_rank_id = rk.rank_id(+);
BEGIN
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Update_Sales_Leads: Start');
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'res id in upd=' || p_Resource_Id);
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'group id in upd='||p_group_id);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN c_sales_lead(p_sales_lead_id);
    FETCH c_sales_lead INTO l_customer_id, l_address_id,
                            l_reject_reason_code, l_lead_rank_id,
                            l_qualified_flag, l_status_code;
    CLOSE c_sales_lead;

    -- l_routing_status := fnd_profile.value('AS_LEAD_ROUTING_STATUS');

    -- Call API to create log entry
    AS_SALES_LEADS_LOG_PKG.Insert_Row(
        px_log_id                 => l_sales_lead_log_id ,
        p_sales_lead_id           => p_sales_lead_id,
        p_created_by              => fnd_global.user_id,
        p_creation_date           => SYSDATE,
        p_last_updated_by         => fnd_global.user_id,
        p_last_update_date        => SYSDATE,
        p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
        p_request_id              => FND_GLOBAL.Conc_Request_Id,
        p_program_application_id  => FND_GLOBAL.Prog_Appl_Id,
        p_program_id              => FND_GLOBAL.Conc_Program_Id,
        p_program_update_date     => SYSDATE,
        p_status_code             => l_status_code, --l_routing_status,
        p_assign_to_person_id     => p_person_id,
        p_assign_to_salesforce_id => p_resource_id,
        p_reject_reason_code      => l_reject_reason_code,
        p_assign_sales_group_id   => p_group_id,
        p_lead_rank_id            => l_lead_rank_id,
        p_qualified_flag          => l_qualified_flag,
        p_category                => NULL);

    -- Call table handler directly, not calling Update_Sales_Lead,
    -- in case current user doesn't have update privilege.
    AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
        p_SALES_LEAD_ID  => p_SALES_LEAD_ID,
        p_LAST_UPDATE_DATE  => SYSDATE,
        p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
        p_CREATION_DATE  => FND_API.G_MISS_DATE,
        p_CREATED_BY  => FND_API.G_MISS_NUM,
        p_LAST_UPDATE_LOGIN  => FND_API.G_MISS_NUM,
        p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
        p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
        p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
        p_PROGRAM_UPDATE_DATE  => SYSDATE,
        p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
        p_STATUS_CODE => FND_API.G_MISS_CHAR, --l_routing_status,
        p_CUSTOMER_ID  => l_CUSTOMER_ID,
        p_ADDRESS_ID  => l_ADDRESS_ID,
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
        p_ATTRIBUTE10 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE11 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE12 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE13 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE14 => FND_API.G_MISS_CHAR,
        p_ATTRIBUTE15 => FND_API.G_MISS_CHAR,
        p_ASSIGN_TO_PERSON_ID  => p_person_id,
        p_ASSIGN_TO_SALESFORCE_ID => p_resource_id,
        p_ASSIGN_SALES_GROUP_ID => p_group_id,
        p_ASSIGN_DATE  => SYSDATE,
        p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
        p_ACCEPT_FLAG  => 'N',
        p_VEHICLE_RESPONSE_CODE => FND_API.G_MISS_CHAR,
        p_TOTAL_SCORE  => FND_API.G_MISS_NUM,
        p_SCORECARD_ID  => FND_API.G_MISS_NUM,
        p_KEEP_FLAG  => FND_API.G_MISS_CHAR,
        p_URGENT_FLAG  => FND_API.G_MISS_CHAR,
        p_IMPORT_FLAG  => FND_API.G_MISS_CHAR,
        p_REJECT_REASON_CODE  => NULL, --l_reject_reason_code,
        p_DELETED_FLAG => FND_API.G_MISS_CHAR,
        p_OFFER_ID  =>  FND_API.G_MISS_NUM,
        p_QUALIFIED_FLAG => l_qualified_flag,
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
        p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE,
        p_CURRENT_REROUTES => FND_API.G_MISS_NUM,
        p_STATUS_OPEN_FLAG => FND_API.G_MISS_CHAR,
        p_LEAD_RANK_SCORE => FND_API.G_MISS_NUM,
        -- 11.5.10 new columns
        p_MARKETING_SCORE => FND_API.G_MISS_NUM,
        p_INTERACTION_SCORE => FND_API.G_MISS_NUM,
        p_SOURCE_PRIMARY_REFERENCE => FND_API.G_MISS_CHAR,
        p_SOURCE_SECONDARY_REFERENCE => FND_API.G_MISS_CHAR,
        p_SALES_METHODOLOGY_ID => FND_API.G_MISS_NUM,
        p_SALES_STAGE_ID => FND_API.G_MISS_NUM);


    OPEN c_access_exist(p_sales_lead_id, p_resource_id, p_group_id);
    FETCH c_access_exist INTO l_access_exist_flag;
    CLOSE c_access_exist;

    -- Clear any owner for as_accesses_all
    -- There may be more than one owner_flag='Y' for the lead in
    -- as_accesses_all:
    -- 1. When owner rejects the lead
    -- 2. When monitoring engine times out
    UPDATE as_accesses_all
    SET owner_flag = 'N'
    WHERE sales_lead_id = p_sales_lead_id;

    IF l_access_exist_flag IS NOT NULL
    THEN
        -- If the owner was frozen in the sales team, he is still frozen in
        -- the sales team. No matter whether he accept the lead or not.
        IF l_access_exist_flag = 'Y'
        THEN
            l_freeze_flag := 'Y';
        END IF;
        UPDATE as_accesses_all
        SET team_leader_flag = 'Y',
            owner_flag = 'Y',
            freeze_flag = l_freeze_flag,
            created_by_tap_flag = 'Y'
        WHERE sales_lead_id = p_sales_lead_id
        AND   salesforce_id = p_resource_id
        AND ((sales_group_id = p_group_id) OR
             (sales_group_id IS NULL AND p_group_id IS NULL));
    ELSE
        OPEN c_get_open_status_flag (p_sales_lead_id);
        FETCH c_get_open_status_flag INTO l_open_status_flag,
            l_lead_rank_score, l_creation_date;
        CLOSE c_get_open_status_flag;

        INSERT INTO as_accesses_all
            (ACCESS_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY
            ,CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN
            ,ACCESS_TYPE, FREEZE_FLAG, REASSIGN_FLAG, TEAM_LEADER_FLAG
            ,OWNER_FLAG, CREATED_BY_TAP_FLAG
            ,CUSTOMER_ID, ADDRESS_ID, SALES_LEAD_ID, SALESFORCE_ID
            ,PERSON_ID, SALES_GROUP_ID, OPEN_FLAG, LEAD_RANK_SCORE
            ,OBJECT_CREATION_DATE)
        SELECT as_accesses_s.nextval, SYSDATE, FND_GLOBAL.USER_ID,
            SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.CONC_LOGIN_ID, 'X',
            l_freeze_flag ,'N', 'Y', 'Y', 'N',
            l_customer_id, l_address_id, p_sales_lead_id,
            p_resource_id, p_person_id, p_group_id, l_open_status_flag,
            l_lead_rank_score, l_creation_date
        FROM SYS.DUAL;
    END IF; -- l_access_exist_flag IS NOT NULL

    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Update_Sales_Leads: End');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END Update_Sales_Leads;


PROCEDURE Find_Lead_Owner(
    p_sales_lead_id          IN     NUMBER,
    p_salesgroup_id          IN     NUMBER,
    p_request_id             IN     NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2)
IS
    CURSOR C_Get_Lead_Info(c_sales_lead_id NUMBER) IS
      SELECT referral_type
      FROM as_sales_leads
      WHERE sales_lead_id = c_sales_lead_id;

    l_resource_id               NUMBER;
    l_group_id                  NUMBER;
    l_person_id                 NUMBER;
    l_referral_type             VARCHAR2(30);
    l_assign_manual_flag        VARCHAR2(1);
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN C_Get_Lead_Info(p_sales_lead_id);
    FETCH C_Get_Lead_Info INTO l_referral_type;
    CLOSE C_Get_Lead_Info;

    IF l_referral_type IS NOT NULL
    THEN
        -- Referral type is not null, for CAPRI
        Get_Partner_Lead_Owner(p_sales_lead_id);
    ELSE
        l_assign_manual_flag :=
                nvl(FND_PROFILE.Value('AS_LEAD_ASSIGN_MANUAL'),'N');
        IF (AS_DEBUG_LOW_ON) THEN
            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'manual assign profile=' || l_assign_manual_flag);
        END IF;

        IF l_assign_manual_flag = 'N'
        THEN
            IF fnd_profile.value('ASF_IS_ORACLE_INTERNAL') = 'Y'
            THEN
                -- Debug Message
                IF (AS_DEBUG_LOW_ON) THEN
                    AS_UTILITY_PVT.Debug_Message(
                        FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Oracle internal, custom user hook');
                END IF;

                Oracle_Internal_CUHK(
                    p_sales_lead_id        => p_sales_lead_id,
                    p_salesgroup_id        => p_salesgroup_id,
                    p_request_id           => p_request_id,
                    x_return_status        => x_return_status,
                    x_msg_count            => l_msg_count,
                    x_msg_data             => l_msg_data);
            ELSE
                Get_Available_Resource(
                    p_sales_lead_id   =>  p_sales_lead_id,
                    p_salesgroup_id   =>  p_salesgroup_id,
                    x_return_status   =>  x_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE fnd_api.g_exc_error;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                Get_Owner(
                    p_sales_lead_id   =>  p_sales_lead_id,
                    p_salesgroup_id   =>  p_salesgroup_id,
                    x_resource_id     =>  l_resource_id,
                    x_group_id        =>  l_group_id,
                    x_person_id       =>  l_person_id,
                    x_return_status   =>  l_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data);

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE fnd_api.g_exc_error;
                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                Update_Sales_Leads (
                    p_sales_lead_id   =>  p_sales_lead_id,
                    p_resource_id     =>  l_resource_id,
                    p_group_id        =>  l_group_id,
                    p_person_id       =>  l_person_id,
                    x_return_status   =>  x_return_status,
                    x_msg_count       =>  x_msg_count,
                    x_msg_data        =>  x_msg_data);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE fnd_api.g_exc_error;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF l_return_status = 'W' THEN
                    x_return_status := 'W';
                END IF;
            END IF; -- Oracle internal
          ELSE -- l_assign_manual_flag = 'Y'
          Set_Default_Lead_Owner(p_sales_lead_id, p_salesgroup_id,
              p_request_id, x_return_status, x_msg_count, x_msg_data);
        END IF; -- Do system routing
    END IF; -- referral type IS NOT NULL

    -- If profile "OS: Enable Real Time Lead Assignment" is set to 'N',
    -- only owner will be left for this transaction.
    IF NVL(fnd_profile.value('AS_ENABLE_LEAD_ONLINE_TAP'), 'Y') = 'N'
    THEN
        IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'Lead Online TAP is disabled!');
        END IF;
        Remove_Redundant_Accesses(p_sales_lead_id, p_request_id);
    END IF;
    Process_Access_Record(p_sales_lead_id, p_request_id);

    -- Standard call to get message count and IF count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data );
END Find_Lead_Owner;


PROCEDURE Process_Access_Record(
    p_sales_lead_id          IN     NUMBER,
    p_request_id             IN     NUMBER)
IS
BEGIN
      UPDATE as_territory_accesses
      SET request_id = NULL
      WHERE access_id IN
          (SELECT a.access_id
           FROM as_accesses_all a
           WHERE a.sales_lead_id = p_sales_lead_id
           AND a.request_id = p_request_id)
      AND request_id = p_request_id;

      UPDATE as_accesses_all
      SET request_id = NULL
      WHERE request_id = p_request_id
      AND sales_lead_id = p_sales_lead_id;
END Process_Access_Record;

END AS_SALES_LEAD_ASSIGN_PVT;

/
