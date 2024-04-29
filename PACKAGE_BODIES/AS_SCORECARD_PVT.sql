--------------------------------------------------------
--  DDL for Package Body AS_SCORECARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCORECARD_PVT" AS
/* $Header: asxvscdb.pls 115.19 2003/03/28 20:34:53 solin ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SCORECARD_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvscdb.pls';


-- API_NAME Get_Score

-- this will be the main call of the scoreCard scoring engine
-- logic:
-- 1. validate for single Active Valid ScoreCard
-- 2. get sales_lead info
-- 3. get active scoreCard rules
-- 4. score the lead
-- 5. get rank based from score
-- 6. update the sales lead with the new score
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

Procedure Get_Score (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_sales_lead_id           IN  NUMBER,
    p_scorecard_id            IN  NUMBER,
 -- swkhanna Bug 2260459
    p_marketing_score         IN  NUMBER,
    p_identity_salesforce_id  IN  NUMBER, -- This is to be used by iStore, pass in user_id
    p_admin_flag              IN  Varchar2,
    p_admin_group_id          IN  NUMBER,
    x_rank_id                 OUT NOCOPY NUMBER,
    X_SCORE                   OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 )
IS

    CURSOR c_get_group_id (c_resource_id NUMBER) IS
      SELECT grp.group_id, jts.resource_id
      FROM JTF_RS_GROUP_MEMBERS mem,
           JTF_RS_ROLE_RELATIONS rrel,
           JTF_RS_ROLES_B role,
           JTF_RS_GROUP_USAGES u,
           JTF_RS_GROUPS_B grp,
           JTF_RS_RESOURCE_EXTNS jts
      WHERE mem.group_member_id = rrel.role_resource_id
      AND rrel.role_resource_type = 'RS_GROUP_MEMBER'
      AND rrel.role_id = role.role_id
      AND role.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
      AND mem.delete_flag <> 'Y'
      AND rrel.delete_flag <> 'Y'
      AND SYSDATE BETWEEN rrel.start_date_active AND
          NVL(rrel.end_date_active,SYSDATE)
      AND mem.resource_id = jts.resource_id
      AND jts.user_id = c_resource_id -- changed to support iStore.
      AND mem.group_id = u.group_id
      AND u.usage = 'SALES'
      AND mem.group_id = grp.group_id
      AND SYSDATE BETWEEN grp.start_date_active AND
          NVL(grp.end_date_active,SYSDATE)
      AND ROWNUM < 2;

    l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Score';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_salesgroup_id             NUMBER;
    l_resource_id               NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT GET_SCORE_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
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
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'PVT:' || l_api_name || ' start');
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API BODY
    --
    OPEN c_get_group_id(p_identity_salesforce_id);
    FETCH c_get_group_id INTO l_salesgroup_id, l_resource_id;
    CLOSE c_get_group_id;

    -- Call Lead_Process_After_Create, so iStore doesn't need to call it.
    -- iStore uses OSO 11.5.6 baseline.
    -- 1. If customer applies iStore 11.5.9, but OSO is still 11.5.6 to 11.5.8,
    --    real get_score will be called.
    -- 2. If customer applied iStore 11.5.9, and Leads is still 11.5.9,
    --    The following code will be called.
    AS_SALES_LEAD_ENGINE_PVT.Lead_Process_After_Create(
        P_Api_Version_Number      =>  2.0,
        P_Init_Msg_List           =>  FND_API.G_FALSE,
        p_Commit                  =>  FND_API.G_FALSE,
        p_Validation_Level        =>  p_validation_level,
        P_Check_Access_Flag       =>  p_check_access_flag,
        p_Admin_Flag              =>  p_admin_flag,
        P_Admin_Group_Id          =>  p_admin_group_id,
        P_identity_salesforce_id  =>  l_resource_id,
        P_Salesgroup_id           =>  l_salesgroup_id,
        P_Sales_Lead_Id           =>  p_sales_lead_id,
        X_Return_Status           =>  x_return_status,
        X_Msg_Count               =>  x_msg_count,
        X_Msg_Data                =>  x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS OR
       x_return_status = 'W'
    THEN
        -- For iStore, if return status is 'A', it's 11.5.9, don't call
        -- build_lead_sales_team.
        x_return_status := 'A';
    END IF;

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN
        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'PVT: ' || l_api_name || ' end');
    END IF;

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
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Get_Score;

-- Comment out the original code because Get_Score is not used in 11.5.9.
/*
Procedure Get_Score (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_sales_lead_id           IN  NUMBER,
    p_scorecard_id            IN  NUMBER,
 -- swkhanna Bug 2260459
    p_marketing_score         IN  NUMBER,
    p_identity_salesforce_id  IN  NUMBER,
    p_admin_flag              IN  Varchar2,
    p_admin_group_id          IN  NUMBER,
    x_rank_id                 OUT NOCOPY NUMBER,
    X_SCORE                   OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 )
IS

    -- ***** ffang 052201, these cursor is no longer needed
    -- for validation
--    CURSOR C_Validate_ScoreCards IS
--       SELECT Count(ScoreCarD_ID)
--       FROM AS_SALES_LEAD_SCORECARDS
--       WHERE start_date_active <= trunc(SYSDATE)
--       AND nvl(end_date_active,SYSDATE) >= trunc(SYSDATE);
       -- WHERE ENABLED_FLAG = 'Y';

    -- for validation
--    CURSOR C_Enabled_ScoreCard IS
--       SELECT ScoreCarD_ID
--       FROM AS_SALES_LEAD_SCORECARDS
--       WHERE start_date_active <= trunc(SYSDATE)
--       AND nvl(end_date_active,SYSDATE) >= trunc(SYSDATE);
       -- WHERE ENABLED_FLAG = 'Y';
--    *****

    -- kmahajan - 05/01/01 - for validation against profile
    CURSOR C_default_ScoreCard (x_scorecard_id NUMBER) IS
       SELECT 'X'   -- scorecard_id
       FROM AS_SALES_LEAD_SCORECARDS
       WHERE start_date_active <= trunc(SYSDATE)
	  AND nvl(end_date_active,SYSDATE) >= trunc(SYSDATE)
	  AND scorecard_id = x_scorecard_id;


    -- for rules information
    Cursor C_ScoreCard_Rules (IN_SCORECARD_ID NUMBER)  IS
        select  card_rule_id          CARD_RULE_ID,
                score                 SCORE,
                high_value_number     HIGH_VALUE_NUMBER,
                low_value_number      LOW_VALUE_NUMBER,
                high_value_char       HIGH_VALUE_CHAR,
                low_value_char        LOW_VALUE_CHAR,
                qual_value_id         QUAL_VALUE_ID,
                seed_qual_id          SEED_QUAL_ID,
                source_table_name     SOURCE_TABLE_NAME,
                source_column_name    SOURCE_COLUMN_NAME,
                substr(data_type,1,8) DATA_TYPE,
                range_flag            RANGE_FLAG,
                meaning               MEANING
        from AS_SCORECARD_RULES_V
        where scorecard_id = IN_SCORECARD_ID;

    -- get the lead info to compare to the rules
    -- this one has contacts
    Cursor C_Sales_lead_info_contact (IN_SALES_LEAD_ID NUMBER) IS
        select  a.LAST_UPDATE_DATE,
                party.party_name CUSTOMER_NAME,  --a.CUSTOMER_NAME,
                c.CONTACT_ROLE_CODE,
                a.CHANNEL_CODE,
                a.BUDGET_AMOUNT,
                a.CURRENCY_CODE,
                a.DECISION_TIMEFRAME_CODE,
                a.BUDGET_STATUS_CODE,
                AMSCT.CAMPAIGN_NAME SOURCE_PROMOTION_NAME,
                -- a.SOURCE_PROMOTION_NAME,
                a.LEAD_RANK_ID
        from as_sales_leads a,  -- as_sales_leads_v a,
             as_sales_lead_contacts c,
             AMS_CAMPAIGNS_ALL_B AMSCB,AMS_CAMPAIGNS_ALL_TL AMSCT,
             AMS_SOURCE_CODES AMSS,
             hz_parties party
        where a.sales_lead_id = IN_SALES_LEAD_ID
          and a.sales_lead_id = c.sales_lead_id
          and c.primary_contact_flag = 'Y'
          and AMSS.SOURCE_CODE = AMSCB.SOURCE_CODE(+)
          AND AMSCB.CAMPAIGN_ID = AMSCT.CAMPAIGN_ID(+)
          and AMSCT.LANGUAGE(+) = USERENV('LANG')
          and AMSS.SOURCE_CODE_ID(+) = a.source_promotion_id
          and party.party_id=a.customer_id;

-- *** ffang 091901, use base tables instead of as_sales_leads_v
--        select  a.LAST_UPDATE_DATE,
--                a.CUSTOMER_NAME,
--                c.CONTACT_ROLE_CODE,
--                a.CHANNEL_CODE,
--                a.BUDGET_AMOUNT,
--                a.CURRENCY_CODE,
--                a.DECISION_TIMEFRAME_CODE,
--                a.BUDGET_STATUS_CODE,
--                a.SOURCE_PROMOTION_NAME,
--                a.LEAD_RANK_ID
--        from as_sales_leads_v a,
--             as_sales_lead_contacts c
--        where a.sales_lead_id = IN_SALES_LEAD_ID AND
--              a.sales_lead_id = c.sales_lead_id  AND
--              c.primary_contact_flag = 'Y';
--*** end of ffang 091901

    -- this cursor is if the lead has no contacts
    Cursor C_Sales_lead_info (IN_SALES_LEAD_ID NUMBER) IS
        select  a.LAST_UPDATE_DATE,
                party.party_name CUSTOMER_NAME,  -- a.CUSTOMER_NAME,
                a.CHANNEL_CODE,
                a.BUDGET_AMOUNT,
                a.CURRENCY_CODE,
                a.DECISION_TIMEFRAME_CODE,
                a.BUDGET_STATUS_CODE,
                AMSCT.CAMPAIGN_NAME SOURCE_PROMOTION_NAME,
                -- a.SOURCE_PROMOTION_NAME,
                a.LEAD_RANK_ID
        from as_sales_leads a, -- as_sales_leads_v a
             hz_parties party,
             AMS_CAMPAIGNS_ALL_B AMSCB,AMS_CAMPAIGNS_ALL_TL AMSCT,
             AMS_SOURCE_CODES AMSS
        where a.sales_lead_id = IN_SALES_LEAD_ID
          and party.party_id = a.customer_id
          and AMSS.SOURCE_CODE = AMSCB.SOURCE_CODE(+)
          AND AMSCB.CAMPAIGN_ID = AMSCT.CAMPAIGN_ID(+)
          and AMSCT.LANGUAGE(+) = USERENV('LANG')
          and AMSS.SOURCE_CODE_ID(+) = a.source_promotion_id;

-- *** ffang 091901, use base tables instead of as_sales_leads_v
--         select  a.LAST_UPDATE_DATE,
--                 a.CUSTOMER_NAME,
--                 a.CHANNEL_CODE,
--                a.BUDGET_AMOUNT,
--                a.CURRENCY_CODE,
--                a.DECISION_TIMEFRAME_CODE,
--                a.BUDGET_STATUS_CODE,
--                a.SOURCE_PROMOTION_NAME,
--                a.LEAD_RANK_ID
--        from as_sales_leads_v a
--        where a.sales_lead_id = IN_SALES_LEAD_ID;
--*** end of ffang 091901

    -- cursor to find if lead has contacts
    Cursor c_lead_contacts(IN_SALES_LEAD_ID NUMBER) IS
        select count(1)
        from as_sales_Lead_contacts
        where sales_lead_id = IN_SALES_LEAD_ID AND
              primary_contact_flag = 'Y';

    -- cursor to see if rank is valid
    Cursor C_rank (IN_SCORE NUMBER) IS
        Select Rank_id
        from AS_SALES_LEAD_RANKS_B
        where min_score <= IN_SCORE AND
              max_score >= IN_SCORE
-- kmahajan 03/26/01 line below added for re-opened Bug 1687132
		AND enabled_flag = 'Y';

    Cursor C_Lead_Info (IN_SALES_LEAD_ID NUMBER) IS
        Select Lead_Rank_ID,
               ASSIGN_TO_SALESFORCE_ID,
               ASSIGN_TO_PERSON_ID,
               ASSIGN_SALES_GROUP_ID,
               last_update_date
        from   AS_SALES_LEADS
        Where  sales_lead_id = IN_SALES_LEAD_ID;


    --
    l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Score';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    -- l_card_rule_id            NUMBER := p_card_rule_id;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(32767);
    l_rowid                     VARCHAR2(50);
    l_num_scoreCards_enabled    NUMBER;  -- for validation
    l_scoreCard_id              NUMBER := p_scorecard_id;  -- active scorecard
    l_sales_lead_id             NUMBER := p_sales_lead_id;
    l_sales_lead_rec            AS_SALES_LEADS_PUB.sales_lead_rec_type
                                    := AS_API_RECORDS_PKG.get_p_sales_lead_rec;
    l_valid_level_full          NUMBER := 90;
    l_total_Score               NUMBER := 0;    -- the Final Score for the lead
    l_rank_id                   NUMBER;       -- will be output
    l_rank_Code                 VARCHAR2(25); -- will be output
    l_sales_lead_info           C_Sales_lead_info%rowtype;
    l_sales_lead_info_contact   C_Sales_lead_info_contact%rowtype;
    type t_rules_table is Table of
         C_ScoreCard_Rules%rowtype index by binary_integer;
    v_rules                     t_rules_table;

    --type t_lead_info C_Lead_Info%rowtype;
    v_lead_info      C_Lead_Info%rowtype;

    i                           NUMBER := 0;
    l_last_update_date          DATE;
    l_rule                      VARCHAR2(35); --for hardCoded Source_Column_Name
    l_contacts_count            NUMBER;
    l_CUSTOMER_NAME             VARCHAR2(360); -- for party_name
    l_CONTACT_ROLE_CODE         VARCHAR2(30);  -- contact role
    l_CHANNEL_CODE              VARCHAR2(80);  -- sales channel (lookup)
    l_BUDGET_AMOUNT             NUMBER; -- $ amount
    l_CURRENCY_CODE             VARCHAR2(15); -- currency
    l_DECISION_TIMEFRAME_CODE   VARCHAR2(80);  -- decision time frame
    l_BUDGET_STATUS_CODE        VARCHAR2(30); -- budget status
    l_SOURCE_PROMOTION_NAME     VARCHAR2(240); -- promotion name
    l_PREVIOUS_RANK_ID          NUMBER;

    l_default_scorecard_id      NUMBER;
    l_val                       VARCHAR2(1);
    l_call_user_hook            BOOLEAN;
 -- swkhanna 2260459
    l_marketing_score           NUMBER := p_marketing_score;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT GET_SCORE_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version,
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
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT:' || l_api_name || 'start');
    END IF;

    -- Initialize API return status to SUCCESS
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API BODY
    --

    -- ffang 052201, scorecard id should be past in, if not, error out
    IF (p_scorecard_id IS NOT NULL and p_scorecard_id<>FND_API.G_MISS_NUM)
    THEN
        l_scorecard_id := p_scorecard_id;

        -- validate scorecard_id
        OPEN c_default_scorecard(l_scorecard_id);
        FETCH c_default_scorecard INTO l_val;   -- l_scorecard_id;

        IF (AS_DEBUG_LOW_ON) THEN



        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'l_val: '||l_val);

        END IF;
        IF c_default_scorecard%NOTFOUND THEN
            -- ffang 082801, use a more meaning message
            -- note: It is assumed that if no valid scorecard id passed in, then
            -- the profile for default scorecard is not set.
            AS_UTILITY_PVT.Set_Message(
                p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name => 'AS_NO_DEFAULT_SCORECARD'); --'AS_INVALID_SCD_ID',
                --p_token1 => 'SCD_ID',
                --p_token1_value => l_scorecard_id);

            l_return_status := 'W';
            x_return_status := 'W';
        END IF;
        Close c_default_scorecard;
    ELSE
        -- ffang 082801, use a more meaning message
        -- note: It is assumed that if no valid scorecard id passed in, then
        -- the profile for default scorecard is not set.
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_NO_DEFAULT_SCORECARD');   --'API_MISSING_ID',
            --p_token1        => 'COLUMN',
            --p_token1_value  => 'SCORECARD_ID');

        l_return_status := 'W';   -- FND_API.G_RET_STS_ERROR;
        x_return_status := 'W';   -- FND_API.G_RET_STS_ERROR;

        -- l_default_scorecard_id:=fnd_profile.value('AS_DEFAULT_SCORECARD');
    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'scorecard_id : ' || l_scorecard_id);

    END IF;
    -- end ffang 052201

    -- ***** ffang 052201, these codes are no longer needed
    -- dbms_output.put_line('Validating scd');
    -- check the system to see how many scoreCards are enabled.
    -- if the number is != 1 then error out
    -- kmahajan - 05/01/01 - changed to check profile if number > 1
--    Open C_Validate_ScoreCards;
--    Fetch C_Validate_ScoreCards into l_num_scoreCards_enabled;

--    If ( C_Validate_ScoreCards%NOTFOUND) OR (l_num_ScoreCards_enabled < 1)
--    Then
     --dbms_output.put_line('No active or too many active scorecards enabled');
--       	Close C_Validate_ScoreCards;
--        FND_MESSAGE.Set_Name('AS', 'AS_NO_SCD_ENABLED');
--        FND_MSG_PUB.Add;
        --raise FND_API.G_EXC_ERROR;
        -- kmahajan 5/5/1
        -- want to return a Warning without any further processing
        l_return_status := 'W';
    -- kmahajan 05/01/01 - elsif added to check for the profile
--    elsif (l_num_scorecards_enabled > 1) then
--        l_default_scorecard_id := fnd_profile.value('AS_DEFAULT_SCORECARD');
--        if l_default_scorecard_id is not null then
--            open c_default_scorecard(l_default_scorecard_id);
--            fetch c_default_scorecard into l_scorecard_id;
--            if c_default_scorecard%NOTFOUND then
--                l_default_scorecard_id := null;
--            end if;
--            close c_default_scorecard;
--        end if;
--        if l_default_scorecard_id is null then
--            Close C_Validate_ScoreCards;
--            FND_MESSAGE.Set_Name('AS', 'MULTIPLE_SCD_ENABLED');
--            FND_MSG_PUB.Add;
            --raise FND_API.G_EXC_ERROR;
            -- kmahajan 5/5/1
            -- want to return a Warning without any further processing
--            l_return_status := 'W';
--        end if;
--    else
        -- get the enabled scorecard
--      	Open C_Enabled_ScoreCard;
--        Fetch C_Enabled_ScoreCard into l_scoreCard_id;
--        Close c_enabled_scorecard;
        --dbms_output.PUT_line('active scorecard is ' || l_scoreCard_id);
--    end if;
--    Close C_Validate_ScoreCards;
--    *****

    -- if-then-else below added to return a warning if no valid scorecard
    -- is found
    if l_return_status <> 'W' then -- kmahajan 5/5/1

        -- USER HOOK standard : customer pre-processing section - mandatory
        l_call_user_hook := JTF_USR_HKS.Ok_to_execute('AS_SCORECARD_PVT',
                            'GET_SCORE','B','C');

        IF l_call_user_hook
        THEN
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                'Call user_hook is true');
            END IF;
            AS_SCORECARD_CUHK.Get_Score_Pre(
                p_api_version_number    =>  2.0,
                p_init_msg_list         =>  FND_API.G_FALSE,
                p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL,
                p_commit                =>  FND_API.G_FALSE,
                p_sales_lead_id         =>  p_sales_lead_id,
                p_scorecard_id          =>  p_scorecard_id,
                x_score                 =>  l_total_score,
                x_return_status         =>  l_return_status,
                x_msg_count             =>  l_msg_count,
                x_msg_data              =>  l_msg_data);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        IF (l_call_user_hook AND l_total_score IS NULL) OR
            NOT l_call_user_hook
        THEN
            -- Compute total score, Oracle logic

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Getting lead info');

            END IF;
            -- get the information for this lead needed to calculate the score

            -- find out if we have contacts for this lead
            -- if so, contact_role code is a valid parameter
            Open c_lead_contacts (l_sales_lead_id);
            fetch c_lead_contacts into l_contacts_count;
            close c_lead_contacts;

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Contact Count = ' || l_contacts_count);

            END IF;
            if l_contacts_count = 1 then
                Open C_Sales_lead_info_contact (l_sales_lead_id);
                fetch c_sales_lead_info_contact into
                    l_sales_lead_info_contact.LAST_UPDATE_DATE,
                    l_sales_lead_info_contact.CUSTOMER_NAME,
                    l_sales_lead_info_contact.CONTACT_ROLE_CODE,
                    l_sales_lead_info_contact.CHANNEL_CODE,
                    l_sales_lead_info_contact.BUDGET_AMOUNT,
                    l_sales_lead_info_contact.CURRENCY_CODE,
                    l_sales_lead_info_contact.DECISION_TIMEFRAME_CODE,
                    l_sales_lead_info_contact.BUDGET_STATUS_CODE,
                    l_sales_lead_info_contact.SOURCE_PROMOTION_NAME,
                    l_sales_lead_info_contact.LEAD_RANK_ID;

                l_LAST_UPDATE_DATE := l_sales_lead_info_contact.LAST_UPDATE_DATE;
                l_CUSTOMER_NAME    := l_sales_lead_info_contact.CUSTOMER_NAME;
                l_CONTACT_ROLE_CODE:= l_sales_lead_info_contact.CONTACT_ROLE_CODE;
                l_CHANNEL_CODE     := l_sales_lead_info_contact.CHANNEL_CODE;
                l_BUDGET_AMOUNT    := l_sales_lead_info_contact.BUDGET_AMOUNT;
                l_CURRENCY_CODE    := l_sales_lead_info_contact.CURRENCY_CODE;
                l_DECISION_TIMEFRAME_CODE :=
                             l_sales_lead_info_contact.DECISION_TIMEFRAME_CODE;
                l_BUDGET_STATUS_CODE :=l_sales_lead_info_contact.BUDGET_STATUS_CODE;
                l_SOURCE_PROMOTION_NAME :=
                             l_sales_lead_info_contact.SOURCE_PROMOTION_NAME;
                l_PREVIOUS_RANK_ID := l_sales_lead_info_contact.LEAD_RANK_ID;
            else
                Open C_Sales_lead_info (l_sales_lead_id);
                fetch c_sales_lead_info into
                    l_sales_lead_info.LAST_UPDATE_DATE,
                    l_sales_lead_info.CUSTOMER_NAME,
                    l_sales_lead_info.CHANNEL_CODE,
                    l_sales_lead_info.BUDGET_AMOUNT,
                    l_sales_lead_info.CURRENCY_CODE,
                    l_sales_lead_info.DECISION_TIMEFRAME_CODE,
                    l_sales_lead_info.BUDGET_STATUS_CODE,
                    l_sales_lead_info.SOURCE_PROMOTION_NAME,
                    l_sales_lead_info.LEAD_RANK_ID;

                l_LAST_UPDATE_DATE        :=  l_sales_lead_info.LAST_UPDATE_DATE;
                l_CUSTOMER_NAME           :=  l_sales_lead_info.CUSTOMER_NAME;
                l_CHANNEL_CODE            :=  l_sales_lead_info.CHANNEL_CODE;
                l_BUDGET_AMOUNT           :=  l_sales_lead_info.BUDGET_AMOUNT;
                l_CURRENCY_CODE           :=  l_sales_lead_info.CURRENCY_CODE;
                l_DECISION_TIMEFRAME_CODE :=
                                    l_sales_lead_info.DECISION_TIMEFRAME_CODE;
                l_BUDGET_STATUS_CODE      :=  l_sales_lead_info.BUDGET_STATUS_CODE;
                l_SOURCE_PROMOTION_NAME :=  l_sales_lead_info.SOURCE_PROMOTION_NAME;
                l_PREVIOUS_RANK_ID        :=  l_sales_lead_info.LEAD_RANK_ID;

            end if;
            if l_contacts_count = 1 then
                Close C_Sales_lead_info_contact;
            else
                Close C_Sales_lead_info;
            end if;

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'LAST_UPDATE_DATE ' || l_LAST_UPDATE_DATE);

            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'CONTACT_ROLE_CODE = ' || l_CONTACT_ROLE_CODE);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'CUSTOMER_NAME = ' || l_CUSTOMER_NAME);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'CHANNEL_CODE = ' || l_CHANNEL_CODE);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'BUDGET_AMOUNT = ' || l_BUDGET_AMOUNT);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'CURRENCY_CODE = ' || l_CURRENCY_CODE);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'DECISION_TIMEFRAME_CODE = ' || l_DECISION_TIMEFRAME_CODE);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'BUDGET_STATUS_CODE = ' || l_BUDGET_STATUS_CODE);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'SOURCE_PROMOTION_NAME = ' || l_SOURCE_PROMOTION_NAME);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Previous Rank ID => ' || l_PREVIOUS_RANK_ID);
            END IF;
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Getting rules');
            END IF;
            -- get all the rules with their score(s) and values
            open C_ScoreCard_Rules(l_scoreCard_id);
            loop
                i := i + 1;
                fetch c_scoreCard_rules into
                    v_rules(i).CARD_RULE_ID,
                    v_rules(i).SCORE,
                    v_rules(i).HIGH_VALUE_NUMBER,
                    v_rules(i).LOW_VALUE_NUMBER,
                    v_rules(i).HIGH_VALUE_CHAR,
                    v_rules(i).LOW_VALUE_CHAR,
                    v_rules(i).QUAL_VALUE_ID,
                    v_rules(i).SEED_QUAL_ID,
                    v_rules(i).SOURCE_TABLE_NAME,
                    v_rules(i).SOURCE_COLUMN_NAME,
                    v_rules(i).DATA_TYPE,
                    v_rules(i).RANGE_FLAG,
                    v_rules(i).MEANING;
                exit when c_scoreCard_rules%notfound;

                IF (AS_DEBUG_LOW_ON) THEN



                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'v_rules(i).card_rule_id: '||v_rules(i).card_rule_id);

                END IF;

                --MEANING                 SOURCE_COLUMN_NAME
                ------------------------  ---------------------------
                --Status                  STATUS_CODE
                --Organization            CUSTOMER_ID
                --Campaign Code           SOURCE_PROMOTION_ID
                --Contact Role            CONTACT_ROLE
                --Sales Channel           CHANNEL_CODE
                --Budget Amount           BUDGET_AMOUNT
                --Timeframe               DECISION_TIMEFRAME_CODE
                --Budget Status           BUDGET_STATUS_CODE
                --Response Code           VEHICLE_RESPONSE_CODE
                --Urgent                  URGENT_FLAG
                --Offer Code              OFFER_ID
                --Purchase Type           INTEREST_TYPE_ID
                --Purchase Primary        PRIMARY_INTEREST_CODE_ID
                --Purchase Secondery      SECONDARY_INTEREST_CODE_ID

                -- this is a workaround to the problem of uniquely identifying
                -- table_name
                -- use source_column_name to identify the rule
                l_rule := v_rules(i).source_column_name;

                IF (AS_DEBUG_LOW_ON) THEN



                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'score pass ' || i || ' rule = ' || l_rule);

                END IF;
                IF (AS_DEBUG_LOW_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'high rule char value = ' || v_rules(i).high_value_char);
                END IF;
                IF (AS_DEBUG_LOW_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'low rule char value = ' || v_rules(i).low_value_char);
                END IF;

                -- customer_name
                if l_rule = 'CUSTOMER_ID' then
                    if v_rules(i).high_value_char like l_CUSTOMER_NAME OR
                       v_rules(i).low_value_char like l_CUSTOMER_NAME then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- contact_role
                elsif l_rule = 'CONTACT_ROLE' then
                    --  need to pull the contact_role_code in the AS_SALES_LEADS_V
                    if v_rules(i).high_value_char like l_CONTACT_ROLE_CODE OR
                       v_rules(i).low_value_char like l_CONTACT_ROLE_CODE then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- decision Time_Frame
                elsif l_rule = 'DECISION_TIMEFRAME_CODE' then
                    if v_rules(i).high_value_char like l_DECISION_TIMEFRAME_CODE OR
                       v_rules(i).low_value_char like l_DECISION_TIMEFRAME_CODE then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- source_promotion
                elsif l_rule = 'SOURCE_PROMOTION_ID' then
                    if v_rules(i).high_value_char = l_SOURCE_PROMOTION_NAME OR
                       v_rules(i).low_value_char = l_SOURCE_PROMOTION_NAME then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- channel
                elsif l_rule = 'CHANNEL_CODE' then
                    if v_rules(i).high_value_char like l_CHANNEL_CODE OR
                       v_rules(i).low_value_char like l_CHANNEL_CODE then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- budget status
                elsif l_rule = 'BUDGET_STATUS_CODE' then
                    if v_rules(i).high_value_char like l_BUDGET_STATUS_CODE OR
                       v_rules(i).low_value_char like l_BUDGET_STATUS_CODE then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- budget amount
                -- we must convert this to functional currency!!!!
                -- l_CURRENCY_CODE
                elsif l_rule = 'BUDGET_AMOUNT' then
	            -- kmahajan 04/26/01 - changed OR to AND
                    if v_rules(i).high_value_number >= l_BUDGET_AMOUNT AND
                       v_rules(i).low_value_number <= l_BUDGET_AMOUNT then
                        l_total_Score := l_total_Score + v_rules(i).SCORE;
                    end if;

                -- we have an invalid rule
                else
                    FND_MESSAGE.Set_Name('AS', 'AS_INVALID_RULE');
                    FND_MSG_PUB.Add;
                    IF (AS_DEBUG_LOW_ON) THEN

                    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                             'invalid rule');
                    END IF;
                    raise FND_API.G_EXC_ERROR;
                end if;

                --dbms_output.put_line('Running Score is = ' || l_total_score);
            end Loop;

            -- close any cursors needed
            Close C_ScoreCard_Rules;
        END IF; -- Compute total score
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Total Score = ' || l_total_score);
        END IF;
        x_score := l_total_score;
       l_total_score           := to_number(l_total_score) + to_number(nvl(l_marketing_score,0));

        IF (AS_DEBUG_LOW_ON) THEN



        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Total Score = ' || l_sales_lead_rec.total_score);

        END IF;
            x_score := l_total_score;


        -- find if score generated is in a valid rank range
        if l_total_score is not null then
            open C_rank(l_total_score);
            fetch c_rank into l_rank_id;
            if l_rank_id is null then
                FND_MESSAGE.Set_Name('AS', 'AS_INVALID_RANK');
                FND_MSG_PUB.Add;
            else
                x_rank_id := l_rank_id;
            end if;
            Close C_Rank;
        end if;
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Previous Rank_id = ' || l_previous_rank_id);
        END IF;
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Rank_id = ' || l_rank_id);
        END IF;

        -- get the sales lead information to pass into update API
        open C_Lead_Info(l_sales_lead_id);
        fetch C_Lead_Info into
            v_lead_info.Lead_Rank_ID,
            v_lead_info.ASSIGN_TO_SALESFORCE_ID,
            v_lead_info.ASSIGN_TO_PERSON_ID,
            v_lead_info.ASSIGN_SALES_GROUP_ID,
            l_last_update_date;
        close C_Lead_Info;

        -- bypass update if we've simply got the same rank again
        if (l_rank_id <> v_lead_info.Lead_Rank_ID) or
           (v_lead_info.Lead_Rank_ID is null) then
            -- this is for updating the sales lead
            -- assign the rank_code based on the total score.
            -- if the total score is not within a valid rank mix/max range,
            -- pass a null for rank_id

            l_sales_lead_rec.sales_lead_id           := l_sales_lead_id;
            l_sales_lead_rec.total_score             := l_total_score;
            l_sales_lead_rec.scorecard_id            := l_scoreCard_id;
            l_sales_lead_rec.lead_rank_id            := l_rank_id;
            l_sales_lead_rec.lead_rank_code          := null;
            l_sales_lead_rec.ASSIGN_TO_SALESFORCE_ID :=
                         v_lead_info.ASSIGN_TO_SALESFORCE_ID;
            l_sales_lead_rec.ASSIGN_TO_PERSON_ID     :=
                         v_lead_info.ASSIGN_TO_PERSON_ID;
            l_sales_lead_rec.ASSIGN_SALES_GROUP_ID   :=
                         v_lead_info.ASSIGN_SALES_GROUP_ID;
            l_sales_lead_rec.last_update_date        := l_LAST_UPDATE_DATE;

            -- begin raverma 01312001
            --   add params for security check
            --      p_identity_salesforce_id  IN  NUMBER,
            --      p_admin_flag              IN  Varchar2(1),
            --      p_admin_group_id          IN  NUMBER,
            --   always check update access = 'Y'

            -- ffang 050901, pass p_check_access_flag as it was past in
            AS_SALES_LEADS_PUB.update_sales_lead(
                 p_api_version_number     => 2.0
                ,p_init_msg_list          => fnd_api.g_false
                ,p_commit                 => fnd_api.g_false
                ,p_validation_level       => l_valid_level_full
                ,p_check_access_flag      => p_check_access_flag   -- 'Y'
                ,p_admin_flag             => p_admin_flag
                ,p_admin_group_id         => p_admin_group_id
                ,p_identity_salesforce_id => p_identity_salesforce_id
                ,p_sales_lead_rec         => l_sales_lead_rec
                ,x_return_status          => l_return_status
                ,x_msg_count              => l_msg_count
                ,x_msg_data               => l_msg_data
            );

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'update_lead status = ' || l_return_status);

            END IF;
        end if;

        IF l_return_status <> 'S' THEN
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Error=====> ' || l_msg_data);
            END IF;
            --AST_API.display_error(l_msg_count);
            x_return_status := l_return_status;
            raise FND_API.G_EXC_ERROR;
        END IF;

    end if; -- kmahajan 5/5/1 - if-then-else for l_return_status <> 'W'

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                 'PVT: ' || l_api_name || ' end');
    END IF;
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
                ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                ,X_MSG_COUNT => X_MSG_COUNT
                ,X_MSG_DATA => X_MSG_DATA
                ,X_RETURN_STATUS => X_RETURN_STATUS);
END Get_Score;
*/

END AS_SCORECARD_PVT;

/
