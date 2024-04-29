--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEADS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEADS_PVT" as
/* $Header: asxvslmb.pls 120.1 2006/03/25 04:27:46 savadhan noship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEADS_PVT
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--      06/05/2000 FFANG  Created.
--      06/06/2000 FFANG  ModIFied according data schema changes.
--      08/30/2000 FFANG  Add assign_to_salesforce_id to AS_SALES_LEADS
--      08/31/2000 FFANG  Add assign_to_salesforce_id to AS_SALES_LEADS_LOG
--      09/20/2000 FFANG  For bug 1406777, add different logics to
--                        validate_sales_lead_id when calling from create or
--                        update
--      09/20/2000 FFANG  For bug 1406761, add different logics to
--                        validate_contact_party_id when calling from create or
--                        update
--      09/20/2000 FFANG  For bug 1400244, add a procedure: set_default_values
--                        to set currency_code as user default value, if
--                        budget_amount is entered but not currency_code
--      09/21/2000 FFANG  For bug 1400264, add two lines to others exception
--                        handling to meet the coding standard
--      09/26/2000 FFANG  Correct procedure 'Validate_PRM_IND_CLS_CODE':
--                        lookup_type should be 'PRM_IND_CLASSIFICATION_TYPE'
--      09/27/2000 FFANG  Use AS_INTEREST_PVT.Validate_Interest_Fields instead
--                        of Validate_Intrst_Type_Sec_CODE
--      09/28/2000 FFANG  Modify validate_phone_id
--      09/28/2000 FFANG  Fix some minor bugs
--      10/02/2000 FFANG  For bug 1416170, do auto-qualify only when keep_flag
--                        <> 'Y'
--      10/02/2000 FFANG  For bug 1417373, l_qualified length set to 30.
--      10/09/2000 FFANG	 For bug 1448995, use two new error messages instead
--                        of API_INVALID_ID in "Link_Lead_To_Opportunity"
--      10/12/2000 FFANG  1. For bug 1449308, in Link_Lead_To_Opportunity,
--                        Should not use sales_lead_line_id as lead_line_id to
--                        create an opportunity line.
--                        2. For bug 1449308, in Link_Lead_To_Opportunity,
--                        l_Lead_Opp_Line_Id should be initialized.
--      10/26/2000 FFANG  for BUG 1478517, in create_opportunity_for_lead,
--                        pass budget_amount to opportunity's customer_budget
--                        instead of total_amount, since
--                        create_opp_lines will update total_amount according
--                        to lines' total amount
--      10/27/2000 FFANG  for bug 1478517, in Link_Lead_To_Opportunity and
--                        create_opportunity_for_lead, copy sales lead contacts
--                        information to opportunity contact table
--      10/30/2000 FFANG  for bug 1475407, when checking if do auto-qualify,
--                        also need to check if keep_flag is null
--      10/30/2000 FFANG  for bug 1479671, in Link_Lead_To_Opportunity and
--                        create_opportunity_for_lead, copy source_promotion_id
--                        and offer_id in sales lead lines to opportunity lines
--      10/31/2000 FFANG  when creating opportunity for sales leads, some
--                        columns are missing to be copied. Added them.
--      11/06/2000 FFANG  For bug 1423478:
--                        1. Add procedure CALL_WF_TO_ASSIGN to kick off
--                           sales lead assignment workflow
--                        2. In Update_Sales_Lead, call CALL_WF_TO_ASSIGN after
--                           calling update table handler
--      11/17/2000 FFANG  Workflow will call update_sales_lead, if we kick-off
--                        workflow within update_sales_lead, it will cause
--                        infinite recursive calls. => Take out calling
--                        CALL_WF_TO_ASSIGN from Update_Sales_Lead.
--      11/19/2000 FFANG  For bug 1501336, check profile option
--                        AS_CUSTOMER_ADDRESS_REQUIRED to see if address_id is
--                        required or not
--      11/19/2000 FFANG  for bug 1475568, if status is changed to 'DECLINED',
--                        don't do auto-qualify
--      11/29/2000 FFANG  for bug 1518684, if JTF assignment manager got no
--                        resource_id back, don't error out, put error message
--                        but return status remains 'S'
--      12/09/2000 FFANG  for bug 1504040, when creating a sales lead, only
--                        when status is "New" or "Unqualified" then launch
--                        auto-qualification
--      12/11/2000 FFANG  for bug 1504040, when updating a sales lead, only
--                        when orginal status is "New" or "Unqualified" then
--                        launch auto-qualification
--      12/12/2000 FFANG  For bug 1529866, add one parameter P_OPP_STATUS in
--                        create_opportunity_for_lead to get opportunity status
--                        when creating opportunity
--      12/19/2000 SOLIN  For bug 1530383, tune C_Get_Sales_Lead in
--                        Assign_Sales_Lead API and add creation_date and
--                        source_promotion_id in the cursor.
--      12/19/2000 SOLIN  For bug 1514981, set default values for accept_flag,
--                        keep_flag, urgent_flag,import_flag, deleted_flag,
--                        currency_code.
--      01/03/2001 SOLIN  For bug 1568056, Validate_address_id shouldn't raise
--                        exception when address_id is g_miss in update_sales_
--                        lead.
--      01/05/2001 SOLIN  Changed Assign_Sales_Lead because l_assignresources_tbl
--                        may start from 1.
--      01/08/2001 SOLIN  For bug 1558460, only customer_id is required to get
--                        potential opportunities.
--      01/08/2001 SOLIN  For bug 1570991, change validation procedure to
--                        assign_to_person_id, assign_to_salesforce_id
--      01/13/2001 FFANG  For bug 1582747, when calling Get_CurrentUser,
--                        pass p_identity_salesforce_id into p_salesforce_id
--                        instead of passing NULL
--      02/02/2001 FFANG  Instead of using views, use base tables.
--                        But as_sf_ptr_v and as_opportunity_details_v haven't
--                        been replaced yet.
--      02/06/2001 FFANG  For bug 1628894, check if opp contact has already
--                        existed before calling create_opp_contacts
--      12/17/2002 SOLIN  Populate column lead_rank_ind:
--                        'U':  lead is upgraded.
--                        'D':  lead is downgraded.
--                        'N':  none of above.
--                        Set as_sales_leads_log.manual_rank_flag:
--                        'Y':  user manually sets rank
--                        'N':  rating engine sets rank
--                        null: rank is not updated
--      11/08/2004 BMUTHUKR  Modified validate_status_close_reason procedure to fix bug 3931489.
--
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SALES_LEADS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvslmb.pls';


-- ffang 092000 for bug 1400244
-- solin 122000 for bug 1514981
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Set_default_values (
    p_mode                IN       VARCHAR2,
    px_SALES_LEAD_rec     IN OUT NOCOPY   AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
    )
 IS
BEGIN


    -- for 11.5.8 HP enhancement, removing channel_code as mandatory from UI.
    -- If no channel code is passed / null, then also let it be as is.
    -- Channel selection engine will assign an appropriate channel

    /* IF (px_SALES_LEAD_rec.channel_code IS NULL) OR
        (px_SALES_LEAD_rec.channel_code = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.channel_code := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_CHANNEL');
     END IF; */

     IF (px_SALES_LEAD_rec.status_code IS NULL) OR
        (px_SALES_LEAD_rec.status_code = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.status_code := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_STATUS');
     END IF;


     IF (px_SALES_LEAD_rec.vehicle_response_code IS NULL) OR
        (px_SALES_LEAD_rec.vehicle_response_code = FND_API.G_MISS_CHAR
        AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        px_SALES_LEAD_rec.vehicle_response_code := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE');
     END IF;


     IF (px_SALES_LEAD_rec.budget_status_code IS NULL) OR
        (px_SALES_LEAD_rec.budget_status_code = FND_API.G_MISS_CHAR
        AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        px_SALES_LEAD_rec.budget_status_code := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_BUDGET_STATUS');
     END IF;



     IF (px_SALES_LEAD_rec.decision_timeframe_code IS NULL) OR
        (px_SALES_LEAD_rec.decision_timeframe_code = FND_API.G_MISS_CHAR
        AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        px_SALES_LEAD_rec.decision_timeframe_code := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_DECISION_TIMEFRAME');
     END IF;





     IF (px_SALES_LEAD_rec.auto_assignment_type IS NULL) OR
             (px_SALES_LEAD_rec.auto_assignment_type = FND_API.G_MISS_CHAR
              AND p_mode = AS_UTILITY_PVT.G_CREATE)
          THEN
              px_SALES_LEAD_rec.auto_assignment_type := 'TAP';
     END IF;

     IF (px_SALES_LEAD_rec.prm_assignment_type IS NULL) OR
	 (px_SALES_LEAD_rec.prm_assignment_type = FND_API.G_MISS_CHAR
	  AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
	  px_SALES_LEAD_rec.prm_assignment_type := 'UNASSIGNED';
     END IF;




     IF (px_SALES_LEAD_rec.ACCEPT_FLAG IS NULL) OR
        (px_SALES_LEAD_rec.ACCEPT_FLAG = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.ACCEPT_FLAG := 'N';
     END IF;

     IF (px_SALES_LEAD_rec.KEEP_FLAG IS NULL) OR
        (px_SALES_LEAD_rec.KEEP_FLAG = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.KEEP_FLAG := 'N';
     END IF;

     IF (px_SALES_LEAD_rec.URGENT_FLAG IS NULL) OR
        (px_SALES_LEAD_rec.URGENT_FLAG = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.URGENT_FLAG := 'N';
     END IF;

     IF (px_SALES_LEAD_rec.IMPORT_FLAG IS NULL) OR
        (px_SALES_LEAD_rec.IMPORT_FLAG = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.IMPORT_FLAG := 'N';
     END IF;

     IF (px_SALES_LEAD_rec.DELETED_FLAG IS NULL) OR
        (px_SALES_LEAD_rec.DELETED_FLAG = FND_API.G_MISS_CHAR
         AND p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         px_SALES_LEAD_rec.DELETED_FLAG := 'N';
     END IF;


     IF (px_SALES_LEAD_rec.QUALIFIED_FLAG IS NULL) OR
             (px_SALES_LEAD_rec.QUALIFIED_FLAG = FND_API.G_MISS_CHAR
              AND p_mode = AS_UTILITY_PVT.G_CREATE)
          THEN
              px_SALES_LEAD_rec.QUALIFIED_FLAG := 'N';
     END IF;
     IF (px_SALES_LEAD_rec.LEAD_RANK_IND IS NULL) OR
             (px_SALES_LEAD_rec.LEAD_RANK_IND = FND_API.G_MISS_CHAR
              AND p_mode = AS_UTILITY_PVT.G_CREATE)
          THEN
              px_SALES_LEAD_rec.LEAD_RANK_IND := 'N';
     END IF;


     --IF (px_SALES_LEAD_rec.budget_amount is not NULL) and
     --   (px_SALES_LEAD_rec.budget_amount <> FND_API.G_MISS_NUM)
     --THEN
         If (px_SALES_LEAD_rec.currency_code IS NULL) or
            (px_SALES_LEAD_rec.currency_code = FND_API.G_MISS_CHAR
             and p_mode = AS_UTILITY_PVT.G_CREATE)
         THEN
            px_SALES_LEAD_rec.currency_code :=
                         FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY');
         End If;
     --END IF;

End Set_default_values;
--end ffang 092000 for bug 1400244
-- end solin 122000 for bug 1514981



-- *************************
--   Validation Procedures
-- *************************
--
-- Item level validation procedures
--

/* Since this column is not required, this validation procedure
is not needed any more. ffang 05/15/00
PROCEDURE Validate_LEAD_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_NUMBER                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Validate Lead Number
      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE) THEN
        IF (p_LEAD_NUMBER is NULL OR p_LEAD_NUMBER = FND_API.G_MISS_CHAR) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'LEAD_NUMBER', FALSE);
              FND_MSG_PUB.ADD;
           END IF;
        END IF;
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE) THEN
        IF p_LEAD_NUMBER IS NULL  THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
              FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'LEAD_NUMBER', FALSE);
              FND_MSG_PUB.ADD;
           END IF;
        END IF;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_LEAD_NUMBER;
*/


PROCEDURE Validate_SALES_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Lead_Id              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Sales_Lead_Id_Exists (X_Sales_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_sales_leads
      WHERE sales_lead_id = X_Sales_Lead_Id;

  l_val	VARCHAR2(1);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate Sales Lead Id'); END IF;

      -- ffang 092000 for bug 1406777
      -- Calling from Create API
      IF(p_validation_mode = AS_UTILITY_PVT.G_CREATE)
      THEN
          IF (p_SALES_LEAD_ID is NOT NULL) and
             (p_SALES_LEAD_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Sales_Lead_Id_Exists (p_Sales_Lead_Id);
              FETCH C_Sales_Lead_Id_Exists into l_val;

              IF C_Sales_Lead_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name => 'API_INVALID_ID',
                      p_token1 => 'SALES_LEAD_ID',
                      p_token1_value => p_Sales_Lead_Id);

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;
              CLOSE C_Sales_Lead_Id_Exists ;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_sales_lead_id is NULL) or (p_sales_lead_id = FND_API.G_MISS_NUM)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Sales_Lead_Id_Exists (p_sales_lead_id);
              FETCH C_Sales_Lead_Id_Exists into l_val;

              IF C_Sales_Lead_Id_Exists%NOTFOUND
              THEN
                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_LEAD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_sales_lead_id );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Sales_Lead_Id_Exists;
          END IF;
      END IF;
      -- end ffang 092000 for bug 1306777

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_SALES_LEAD_ID;



PROCEDURE Validate_Sales_Methodology_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Methodology_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

-- 11.5.10 ckapoor
-- This cursor validates if the sales methodology passed in
-- corresponds to an active sales methodology with an active sales stage associated with it

    CURSOR C_Methodology_Exists (X_Sales_Methodology_ID NUMBER) IS
     select 'X'
      from as_sales_methodology_b asmb
      --, as_sales_methodology_tl asmt
      where trunc(nvl(asmb.start_date_active, sysdate)) <= trunc(sysdate)
      and trunc(nvl(asmb.end_date_active, sysdate)) >= trunc(sysdate)
      --and asmb.sales_methodology_id = asmt.sales_methodology_id
      --and asmt.language = userenv('LANG')
      and asmb.sales_methodology_id = X_Sales_Methodology_ID;

      -- ckapoor 05/11/04 bug 3621389 - change validation sql for sales methodology id

      --and exists (select 1 from as_sales_meth_stage_map b, as_sales_stages_all_b c
      --              where asmb.sales_methodology_id = b.sales_methodology_id
      --              and b.sales_stage_id = c.sales_stage_id
      --              and c.applicability in ('LEAD', 'BOTH')
      --              and c.enabled_flag = 'Y'
      --              and trunc(nvl(c.start_date_active, sysdate)) <= trunc(sysdate)
      --              and trunc(nvl(c.end_date_active, sysdate)) >= trunc(sysdate)
      --              and rownum = 1);



    l_val	VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
      	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Validate SALES methodology id'); END IF;

     IF (p_validation_mode=AS_UTILITY_PVT.G_CREATE and (P_Sales_Methodology_ID IS NOT NULL) and
         (P_Sales_Methodology_ID <> FND_API.G_MISS_NUM))
--            OR
--         (p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
        OPEN C_Methodology_Exists ( p_Sales_Methodology_ID);
        FETCH C_Methodology_Exists into l_val;
        IF C_Methodology_Exists%NOTFOUND
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'SALES METHODOLOGY',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_Sales_Methodology_ID );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Methodology_Exists;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_Sales_Methodology_ID;



PROCEDURE Validate_Sales_Stage_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Sales_Methodology_ID        IN   NUMBER,
    P_Sales_Stage_ID		 IN    NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

-- 11.5.10 ckapoor
-- This cursor validates if the sales stage corresponds to the sales meth id passed in

    CURSOR C_Sales_Stage_Exists(X_Sales_Methodology_ID NUMBER, X_Sales_Stage_ID NUMBER) IS
     SELECT 'X'
      FROM AS_SALES_METH_STAGE_MAP asms
      , AS_SALES_STAGES_ALL_B assa
      WHERE asms.sales_stage_id = assa.sales_stage_id
        AND TRUNC(NVL(assa.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
       AND TRUNC(NVL(assa.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
       AND sales_methodology_id = X_Sales_Methodology_ID
       AND assa.applicability IN ('LEAD', 'BOTH')
       -- ckapoor 05/11/04 bug 3621389 -
       -- adding new additional condition as per AUYU
       AND assa.enabled_flag = 'Y'
       -- end ckapoor
       AND asms.sales_stage_id = X_Sales_Stage_ID

       ;
   -- ORDER BY asms.stage_sequence



    l_val	VARCHAR2(1);

BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN
      	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Validate SALES Stage id');

      END IF;

     IF (p_validation_mode=AS_UTILITY_PVT.G_CREATE and (P_Sales_Stage_ID IS NOT NULL) and
         (P_Sales_Stage_ID <> FND_API.G_MISS_NUM))
--            OR
--         (p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
        OPEN C_Sales_Stage_Exists ( p_Sales_Methodology_ID, p_Sales_Stage_ID);
        FETCH C_Sales_Stage_Exists into l_val;
        IF C_Sales_Stage_Exists%NOTFOUND
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'SALES STAGE',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_Sales_Stage_ID );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Sales_Stage_Exists;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_Sales_Stage_ID;





PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMER_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
-- solin, 02/01/2001, replace view AS_PARTY_CUSTOMERS_V with table HZ_PARTIES
  CURSOR 	C_Customer_Id_Exists (c_Customer_Id NUMBER) IS
     SELECT 'X'
     FROM  HZ_PARTIES
     WHERE PARTY_TYPE IN ('PERSON', 'ORGANIZATION')
     AND   PARTY_ID = c_Customer_Id;

  CURSOR        C_Customer_is_active(c_Customer_Id NUMBER) IS
        SELECT status
        FROM  hz_parties
        WHERE PARTY_TYPE IN ('PERSON', 'ORGANIZATION')
     	AND   PARTY_ID = c_Customer_Id;

  l_val   VARCHAR2(1);
  l_status VARCHAR2(1);
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ((p_CUSTOMER_ID is NULL) or (p_CUSTOMER_ID = FND_API.G_MISS_NUM)
		AND p_validation_mode = AS_UTILITY_PVT.G_CREATE)
         OR
         (p_CUSTOMER_ID is NULL AND p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API: Violate NOT NULL constraint(CUSTOMER_ID)');
          END IF;

          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'CUSTOMER_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF(p_CUSTOMER_ID is not NULL) AND (p_CUSTOMER_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_Customer_Id_Exists (p_Customer_Id);
          FETCH C_Customer_Id_Exists into l_val;
          IF C_Customer_Id_Exists%NOTFOUND
          THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Private API: CUSTOMER_ID is not valid:' ||
                                  p_Customer_Id);
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_CUSTOMER_ID',
                  p_token1        => 'COLUMN',
      		      p_token1_value  => 'CUSTOMER_ID',
	   	          p_token2        => 'VALUE',
		          p_token2_value  =>  p_CUSTOMER_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Customer_Id_Exists;

	 -- do the customer is inactive check only at time of create. allow updates.
	 IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) THEN
          OPEN  C_Customer_is_active (p_Customer_Id);
	    FETCH C_Customer_is_active into l_status;
	    --IF (l_status = 'I')
	    IF (l_status <> 'A') -- take care of party merge
	    THEN
		IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				    'Private API: CUSTOMER_ID is not active:' ||
				    p_Customer_Id);
		END IF;

		AS_UTILITY_PVT.Set_Message(
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		    p_msg_name      => 'API_INACTIVE_CUSTOMER_ID');


		x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
	    CLOSE C_Customer_is_active;
	  END IF;


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
    P_CUSTOMER_ID                IN   NUMBER,
    P_ADDRESS_ID                 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_check_address  VARCHAR2(1);

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_ADDRESS_ID is not NULL) and (p_ADDRESS_ID <> FND_API.G_MISS_NUM)
      THEN
          IF (p_CUSTOMER_ID is NULL) or (p_CUSTOMER_ID = FND_API.G_MISS_NUM)
          THEN
              -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              --             'Private API: Violate NOT NULL(CUSTOMER_ID)'); END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'CUSTOMER_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              AS_TCA_PVT.validate_party_site_id(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_party_id               => P_CUSTOMER_ID,
                  p_party_site_id          => P_ADDRESS_ID,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  IF (AS_DEBUG_LOW_ON) THEN

                  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'Private API: ADDRESS_ID is invalid');
                  END IF;

                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_ID',
                      p_token1        => 'COLUMN',
                      p_token1_value  => 'ADDRESS_ID',
                      p_token2        => 'VALUE',
                      p_token2_value  =>  p_ADDRESS_ID );
              END IF;
          END IF;
      -- For bug 1544448
      ELSIF p_ADDRESS_ID = FND_API.G_MISS_NUM AND
            p_validation_mode = AS_UTILITY_PVT.G_UPDATE
      THEN
 	     NULL;
      ELSE  -- address_id is NULL or g_miss_num
          -- For bug 1501336, check profile option AS_CUSTOMER_ADDRESS_REQUIRED
          -- to check if address_id is required or not
          -- AS_CUSTOMER_ADDRESS_REQUIRED is obsoleted. Use AS_LEAD_ADDRESS_REQUIRED
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'ADDRESS_ID is not entered');
          END IF;
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'ADDRESS_REQUIRED: ' || FND_PROFILE.Value('AS_LEAD_ADDRESS_REQUIRED'));
                  --FND_PROFILE.Value('AS_CUSTOMER_ADDRESS_REQUIRED'));
          END IF;

          l_check_address :=
                    --nvl(FND_PROFILE.Value('AS_CUSTOMER_ADDRESS_REQUIRED'),'Y');
                    nvl(FND_PROFILE.Value('AS_LEAD_ADDRESS_REQUIRED'),'Y');
          IF (l_check_address = 'Y')
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_ADDRESS_ID');


              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ADDRESS_ID;


PROCEDURE Validate_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS_CODE                IN   VARCHAR2,
    P_Sales_Lead_Id		 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Status_Exists (X_Lookup_Code VARCHAR2) IS
      SELECT 'X'
      FROM  as_statuses_b
      WHERE lead_flag = 'Y' and enabled_flag = 'Y'
            and status_code = X_Lookup_Code;
            -- ffang 012501, add more criteria
            -- sync up with validation used in status dropdown
            --and usage_indicator in ('ALL', 'OS', 'PRM');

  CURSOR C_Opp_Exists (X_Sales_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_sales_lead_opportunity
      WHERE sales_lead_id = X_Sales_Lead_Id;

  Cursor C_GET_STATUS_CODE (c_sales_lead_id NUMBER) IS
        SELECT status_code
        FROM as_sales_leads
        WHERE sales_lead_id = c_sales_lead_id;


  l_val	VARCHAR2(1);
  l_status_code   VARCHAR2(30);

  l_newStateTransition VARCHAR2(1);
  l_linkStatus VARCHAR2(30);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate status code'); END IF;
      -- Validate status code
      IF ((p_status_code is NULL or p_status_code = FND_API.G_MISS_CHAR)
		AND p_validation_mode=AS_UTILITY_PVT.G_CREATE)
	    OR
         (p_status_code IS NULL AND p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'STATUS_CODE' );

          x_return_status := FND_API.G_RET_STS_ERROR;

      ELSIF (p_status_code <> FND_API.G_MISS_CHAR)
	 THEN
        OPEN C_Status_Exists ( p_status_code);
        FETCH C_Status_Exists into l_val;

        IF C_Status_Exists%NOTFOUND
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'STATUS_CODE',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_STATUS_CODE );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Status_Exists ;
      END IF;

	-- 11.5.9 additional validation.If the user is changing status to
	-- OS: Lead Link Status profile (e.g Converted to Opportunity) then
        -- first check lead link table to make sure an opportunity exists
	-- This check will be dependent on a profile.
	--l_val := 'N';
	l_newStateTransition := FND_PROFILE.VALUE('AS_LEAD_STATE_TRANSITION');
	l_linkStatus := FND_PROFILE.VALUE('AS_LEAD_LINK_STATUS');

      OPEN C_GET_STATUS_CODE (p_sales_lead_id);
      FETCH C_GET_STATUS_CODE INTO l_status_code;
      CLOSE C_GET_STATUS_CODE;


	if p_status_code <> FND_API.G_MISS_CHAR and l_status_code <> p_status_code and p_validation_mode = AS_UTILITY_PVT.G_update and l_newStateTransition = 'Y' and l_linkStatus = l_status_code
	  then
	  AS_UTILITY_PVT.Set_Message(
		   			p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		   			p_msg_name      => 'AS_INVALID_STATUS_TRANSITION'
			);

	   x_return_status := FND_API.G_RET_STS_ERROR;

	end if;


	-- ckapoor Lead state transition fixes for 11.5.10

	if ((l_newStateTransition = 'Y') AND (p_validation_mode = AS_UTILITY_PVT.G_CREATE)
	     AND (p_status_code = l_linkStatus) )
	then
		   AS_UTILITY_PVT.Set_Message(
			   			p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			   			p_msg_name      => 'AS_NO_LEAD_CREATE_STATUS'
				);

			   x_return_status := FND_API.G_RET_STS_ERROR;

	 end if;

	 -- end ckapoor




/*	if (l_newStateTransition = 'Y') then

		if (p_validation_mode = AS_UTILITY_PVT.G_CREATE) then

		  if (p_status_code = l_linkStatus) then

		   AS_UTILITY_PVT.Set_Message(
		   			p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		   			p_msg_name      => 'AS_NO_LEAD_CREATE_STATUS'
			);

		   x_return_status := FND_API.G_RET_STS_ERROR;

		  end if;

		elsif (p_validation_mode=AS_UTILITY_PVT.G_UPDATE) then

		if (p_status_code = l_linkStatus) then

		OPEN C_opp_exists (p_sales_lead_id);
		FETCH C_opp_exists into l_val;

		IF C_opp_exists%NOTFOUND
		THEN
		    AS_UTILITY_PVT.Set_Message(
			p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
			p_msg_name      => 'AS_NO_LEAD_UPDATE_NO_OPP'
			);

		        x_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
        	CLOSE C_opp_exists ;

        	end if;



        	end if;


	end if; */



      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_STATUS_CODE;

PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Promotion_Exists (X_Promotion_Id NUMBER) IS
     SELECT 'X'
     FROM ams_p_source_codes_v
     WHERE source_code_id = X_promotion_id
     and source_type in ('CAMP','CSCH','EONE', 'EVEH','EVEO')
     and status in ('ACTIVE','ONHOLD', 'COMPLETED');


     --SELECT  'X'
     --	FROM  ams_source_codes
     --	WHERE source_code_id = X_promotion_id
     --	and active_flag = 'Y';

    l_val	VARCHAR2(1);
    l_source_promotion_id VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate source promotion id'); END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'SOURCE CODE REQUIRED: ' ||
                        FND_PROFILE.Value('AS_SOURCE_CODE_MANDATORY_LEADS'));

      END IF;

      l_source_promotion_id :=
                          nvl(FND_PROFILE.Value('AS_SOURCE_CODE_MANDATORY_LEADS'),'Y');


      -- validate SOURCE_PROMOTION_ID (NOT NULL column)
     IF (l_source_promotion_id='Y' AND ( p_source_promotion_id is NULL or
           p_source_promotion_id  =FND_API.G_MISS_NUM)
                AND p_validation_mode=AS_UTILITY_PVT.G_CREATE)
            OR
         (l_source_promotion_id='Y' AND p_source_promotion_id IS NULL
                AND p_validation_mode=AS_UTILITY_PVT.G_UPDATE)
      THEN
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'API_MISSING_ID',
            p_token1        => 'COLUMN',
            p_token1_value  => 'SOURCE NAME');

        x_return_status := FND_API.G_RET_STS_ERROR;

      ELSIF (p_source_promotion_id <> FND_API.G_MISS_NUM)
            and (p_validation_mode <> AS_UTILITY_PVT.G_UPDATE) -- added by bmuthukr for fixing bug 3817333. val not reqd during updates.
      --IF ((p_source_promotion_id is NOT NULL AND
      --     p_source_promotion_id  <> FND_API.G_MISS_NUM))
   	  THEN
        OPEN C_Promotion_Exists ( p_source_promotion_id);
        FETCH C_Promotion_Exists into l_val;
        IF C_Promotion_Exists%NOTFOUND
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'SOURCE PROMOTION',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_SOURCE_PROMOTION_ID );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Promotion_Exists;
      END IF;


      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_SOURCE_PROMOTION_ID;


PROCEDURE Validate_CHANNEL_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CHANNEL_CODE               IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Aso_Channel_Exists (X_Lookup_Code VARCHAR2) IS
	 SELECT  'X'
      FROM  aso_i_sales_channels_v
      WHERE sales_channel_code = X_Lookup_Code
            -- ffang 012501, add more criteria
            and nvl(start_date_active, sysdate) <= sysdate
            and nvl(end_date_active, sysdate) >= sysdate
            and enabled_flag = 'Y';

    l_val VARCHAR2(1);
BEGIN
	 -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

	 -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate channel code'); END IF;

      -- Validate channel code
      IF (p_channel_code is NOT NULL
          AND p_channel_code <> FND_API.G_MISS_CHAR)
      THEN
        OPEN C_Aso_Channel_Exists (p_channel_code);
        FETCH C_Aso_Channel_Exists into l_val;
        IF C_Aso_Channel_Exists%NOTFOUND
        THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'LEAD CHANNEL',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_CHANNEL_CODE );

            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Aso_Channel_Exists;
      END IF;

	 -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_CHANNEL_CODE;


PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Currency_Exists (X_Currency_Code VARCHAR2) IS
      SELECT  'X'
      FROM  FND_LOOKUP_VALUES
      WHERE lookup_code = X_Currency_Code
	    and LOOKUP_TYPE = 'REPORTING_CURRENCY'
	    and	VIEW_APPLICATION_ID = 279
            -- ffang 012501
            and nvl(start_date_active, sysdate) <= sysdate
            and nvl(end_date_active, sysdate) >= sysdate
            and enabled_flag = 'Y';

    l_val VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate currency code'); END IF;

      -- Validate Currency Code
      IF (p_currency_code is NOT NULL
          AND p_currency_code <> FND_API.G_MISS_CHAR)
      THEN
	    OPEN C_Currency_Exists ( p_currency_code );
         FETCH C_Currency_Exists into l_val;
         IF C_Currency_Exists%NOTFOUND THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'CURRENCY',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_CURRENCY_CODE );

            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
         CLOSE C_Currency_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_CURRENCY_CODE;


PROCEDURE Validate_DECN_TIMEFRAME_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val  VARCHAR2(1);
BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate decision tf code'); END IF;

      -- Validate decision timeframe code
      IF (p_decision_timeframe_code is NOT NULL
          AND p_decision_timeframe_code <> FND_API.G_MISS_CHAR) THEN
        OPEN C_Lookup_Exists ( p_decision_timeframe_code, 'DECISION_TIMEFRAME');
        FETCH C_Lookup_Exists into l_val;

        IF C_Lookup_Exists%NOTFOUND
        THEN
           AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_ID',
               p_token1        => 'COLUMN',
               p_token1_value  => 'DECISION TIMEFRAME_CODE',
               p_token2        => 'VALUE',
               p_token2_value  =>  p_DECISION_TIMEFRAME_CODE );

           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_DECN_TIMEFRAME_CODE;


PROCEDURE Validate_CLOSE_REASON (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CLOSE_REASON               IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val  VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate close reason'); END IF;

      -- Validate Close Reason
      IF (p_close_reason is NOT NULL AND p_close_reason <> FND_API.G_MISS_CHAR)
	 THEN
        OPEN C_Lookup_Exists ( p_close_reason, 'CLOSE_REASON' );
        FETCH C_Lookup_Exists into l_val;

        IF C_Lookup_Exists%NOTFOUND
        THEN
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
             AS_UTILITY_PVT.Set_Message(
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_INVALID_ID',
                 p_token1        => 'COLUMN',
                 p_token1_value  => 'CLOSE REASON',
                 p_token2        => 'VALUE',
                 p_token2_value  =>  p_CLOSE_REASON );
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;
      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_CLOSE_REASON;


PROCEDURE Validate_LEAD_RANK_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_RANK_ID               IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Rank_Exists (X_Rank_id NUMBER) IS
      SELECT  'X'
      FROM  as_sales_lead_ranks_b
      WHERE rank_id = X_Rank_id
            and enabled_flag = 'Y';
    l_val  VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate rank id'); END IF;

      -- Validate rank id
      IF (p_LEAD_RANK_ID is NOT NULL
          AND p_LEAD_RANK_ID <> FND_API.G_MISS_NUM)
      THEN
        OPEN C_Rank_Exists ( p_LEAD_RANK_ID );
        FETCH C_Rank_Exists into l_val;

        IF C_Rank_Exists%NOTFOUND
        THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'LEAD_RANK_ID',
              p_token2        => 'VALUE',
              p_token2_value  =>  p_LEAD_RANK_ID );
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Rank_Exists;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_LEAD_RANK_ID;

-- FFANG 08-30-00 For bug#1391034
-- Assign_to_person_id keep person_id; should be validated against
-- per_all_people_f
PROCEDURE Validate_ASSIGN_TO_PERSON_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ASSIGN_TO_PERSON_ID        IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    -- solin, bug 1570991, change to consider effective start and end date
    Cursor C_Check_Assign_Person (X_person_id NUMBER) IS
      SELECT 'X'
      FROM   per_all_people_f per,
             jtf_rs_resource_extns res
      WHERE  per.person_id = X_person_id
      AND    TRUNC(SYSDATE) BETWEEN per.effective_start_date
             AND per.effective_end_date
      AND    res.category = 'EMPLOYEE'
      AND    res.source_id = per.person_id;

    l_val	VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate assign to person id'); END IF;

	 -- Validate ASSIGN_TO_PERSON_ID
	 IF (p_assign_to_person_id IS NOT NULL
          AND p_assign_to_person_id <> FND_API.G_MISS_NUM)
	 THEN
        OPEN C_Check_Assign_Person (p_assign_to_person_id);
        FETCH C_Check_Assign_Person INTO l_val;
        IF (C_Check_Assign_Person%NOTFOUND)
        THEN
          AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'ASSIGN_TO_PERSON_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_ASSIGN_TO_PERSON_ID );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Check_Assign_Person;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_ASSIGN_TO_PERSON_ID;


-- FFANG 08-30-00 For bug#1391034
-- Assign_to_salesforce_id keep salesforce_id (resource_id); should be validated
-- against jtf_rs_resource_extns
PROCEDURE Validate_ASSIGN_TO_SF_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ASSIGN_TO_SALESFORCE_ID    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    -- solin, bug 1570991, change to consider category
    Cursor C_Check_Assign_Salesforce (X_Assign_Id NUMBER) IS
      SELECT 'X'
      FROM   per_all_people_f per,
             jtf_rs_resource_extns res,
             jtf_rs_role_relations rrel,
             jtf_rs_roles_b role
      WHERE  TRUNC(SYSDATE) BETWEEN per.effective_start_date
             AND per.effective_end_date
      AND    res.resource_id = rrel.role_resource_id
      AND    rrel.role_resource_type = 'RS_INDIVIDUAL'
      AND    rrel.role_id = role.role_id
      AND    role.role_type_code IN ('SALES', 'TELESALES', 'FIELDSALES', 'PRM')
--changing for bug 2877597 ckapoor adding nvl since the role table contains
-- Y/N and null
      AND    nvl(role.admin_flag, 'N') = 'N'
      AND    res.source_id = per.person_id
      AND    res.resource_id = X_Assign_Id
      -- ffang 012501
      AND    res.category = 'EMPLOYEE';


    l_val	VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate assign to salesforce id'); END IF;

	 -- Validate ASSIGN_TO_SALESFORCE_ID
	 IF (p_assign_to_salesforce_id IS NOT NULL
          AND p_assign_to_salesforce_id <> FND_API.G_MISS_NUM)
	 THEN
        OPEN C_Check_Assign_Salesforce (p_assign_to_salesforce_id);
        FETCH C_Check_Assign_Salesforce INTO l_val;
        IF (C_Check_Assign_Salesforce%NOTFOUND)
        THEN
          AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'ASSIGN_TO_SALESFORCE_ID',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_ASSIGN_TO_SALESFORCE_ID );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Check_Assign_Salesforce;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_ASSIGN_TO_SF_ID;


PROCEDURE Validate_BUDGET_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_BUDGET_STATUS_CODE         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val	VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate budget status code'); END IF;

      -- Validate budget status code
      IF (p_budget_status_code is NOT NULL
          AND p_budget_status_code <> FND_API.G_MISS_CHAR)
      THEN
        OPEN C_Lookup_Exists ( p_budget_status_code, 'BUDGET_STATUS');
        FETCH C_Lookup_Exists into l_val;

        IF C_Lookup_Exists%NOTFOUND
        THEN
           AS_UTILITY_PVT.Set_Message(
               p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
               p_msg_name      => 'API_INVALID_ID',
               p_token1        => 'COLUMN',
               p_token1_value  => 'BUDGET_STATUS_CODE',
               p_token2        => 'VALUE',
               p_token2_value  =>  p_BUDGET_STATUS_CODE );
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;

	 -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_BUDGET_STATUS_CODE;


PROCEDURE Validate_VEHICLE_RESPONSE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VEHICLE_RESPONSE_CODE      IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate Vehicle Response Code'); END IF;

      -- Validate Vehicle Response Code
      IF (P_VEHICLE_RESPONSE_CODE is NOT NULL
          AND P_VEHICLE_RESPONSE_CODE <> FND_API.G_MISS_CHAR)
      THEN
        OPEN C_Lookup_Exists (P_VEHICLE_RESPONSE_CODE, 'VEHICLE_RESPONSE_CODE');
        FETCH C_Lookup_Exists into l_val;
        IF C_Lookup_Exists%NOTFOUND
        THEN
          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_INVALID_ID',
              p_token1        => 'COLUMN',
              p_token1_value  => 'VEHICLE_RESPONSE_CODE',
              p_token2        => 'VALUE',
              p_token2_value  =>  p_VEHICLE_RESPONSE_CODE );

          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE C_Lookup_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_VEHICLE_RESPONSE_CODE;


PROCEDURE Validate_REJECT_REASON_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REJECT_REASON_CODE         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Lookup_Exists (X_Lookup_Code VARCHAR2, X_Lookup_Type VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = X_Lookup_Type
            and lookup_code = X_Lookup_Code
            -- ffang 012501
            and enabled_flag = 'Y';

    l_val VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate reject reason Code'); END IF;

      -- Validate Reject Reason Code
      IF (P_REJECT_REASON_CODE is NOT NULL
		AND P_REJECT_REASON_CODE <> FND_API.G_MISS_CHAR)
      THEN
          OPEN C_Lookup_Exists ( P_REJECT_REASON_CODE, 'REJECT_REASON_CODE');
          FETCH C_Lookup_Exists into l_val;
          IF C_Lookup_Exists%NOTFOUND
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => 'REJECT_REASON_CODE',
                p_token2        => 'VALUE',
                p_token2_value  =>  p_REJECT_REASON_CODE );

            x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_Lookup_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_REJECT_REASON_CODE;


PROCEDURE Validate_Flags (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Flag_Value                 IN   VARCHAR2,
    P_Flag_Type                  IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate ' || p_flag_type); END IF;

      -- Validate IF the flag value is 'Y' or 'N'
      IF (P_FLAG_VALUE is NOT NULL
          AND P_FLAG_VALUE <> FND_API.G_MISS_CHAR)
      THEN
          IF (P_FLAG_VALUE <>'Y' AND P_FLAG_VALUE <> 'N')
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'API_INVALID_ID',
                p_token1        => 'COLUMN',
                p_token1_value  => P_FLAG_TYPE,
                p_token2        => 'VALUE',
                p_token2_value  => p_FLAG_VALUE );
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_FLAGS;



PROCEDURE Validate_ACCEPT_REJECT_REASON (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_Accept_Flag                IN   VARCHAR2,
    P_Reject_Reason_Code         IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate accept flag reject reason'); END IF;

      -- Validate if ACCEPT_FLAG = 'Y' then REJECT_REASON_CODE should be null
      --          if REJECT_REASON_CODE is NOT NULL  then ACCEPT_FLAG should not be 'Y'

      IF (P_ACCEPT_FLAG = 'Y')
      THEN
          IF (P_REJECT_REASON_CODE IS NOT NULL AND
              P_REJECT_REASON_CODE <> FND_API.G_MISS_CHAR )
          THEN
            AS_UTILITY_PVT.Set_Message(
                p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                p_msg_name      => 'AS_ACCEPT_FLAG_REJECT_REASON'
                );
             x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_ACCEPT_REJECT_REASON;



PROCEDURE Validate_STATUS_CLOSE_REASON (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_STATUS_CODE                IN   VARCHAR2,
    P_CLOSE_REASON_CODE          IN OUT NOCOPY  VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Status_Exists (X_Lookup_Code VARCHAR2) IS
      SELECT opp_open_status_flag
      FROM  as_statuses_b
      WHERE lead_flag = 'Y' and enabled_flag = 'Y'
            and status_code = X_Lookup_Code;
  l_val   VARCHAR2(1);
  l_profile_opp_lead_link VARCHAR2(200);
  l_profile_def_close_reason VARCHAR2(200);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate status close reason'); END IF;

       -- IF opp_open_status_flag = 'N' (closed status) then close_reason_code
      -- can not be NULL
      OPEN C_Status_Exists ( p_status_code);
      FETCH C_Status_Exists into l_val;


      l_profile_opp_lead_link :=  FND_PROFILE.Value('AS_LEAD_LINK_STATUS');
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'l_profile_opp_lead_link: ' || l_profile_opp_lead_link);
      END IF;


      IF l_val = 'N' and (P_CLOSE_REASON_CODE is NULL or P_CLOSE_REASON_CODE = fnd_api.G_MISS_CHAR)
      THEN
	IF (AS_DEBUG_LOW_ON) THEN

	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'close check');
	END IF;

	IF l_profile_opp_lead_link <> P_STATUS_CODE
	THEN
		IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'not lead link');
		END IF;
	        AS_UTILITY_PVT.Set_Message(
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	            p_msg_name      => 'API_MISSING_ID',
		    p_token1        => 'COLUMN',
	            p_token1_value  => 'CLOSE_REASON');
		x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'yes lead link');
		END IF;
		l_profile_def_close_reason := FND_PROFILE.Value('AS_DEFAULT_LEAD_CLOSE_REASON');
		IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'def_close: ' || l_profile_def_close_reason);
		END IF;
                --bmuthukr modified the if condition to include g_miss_char to fix bug 3931489.
		--if P_CLOSE_REASON_CODE is NULL then
		if ((P_CLOSE_REASON_CODE is NULL) or (P_CLOSE_REASON_CODE = fnd_api.G_MISS_CHAR)) then
	  	   P_CLOSE_REASON_CODE := l_profile_def_close_reason;
		end if;
	end IF;
      END IF;

      IF (l_val = 'Y' and P_CLOSE_REASON_CODE is NOT NULL and P_CLOSE_REASON_CODE <> FND_API.G_MISS_CHAR)
      THEN

	IF l_profile_opp_lead_link <> P_STATUS_CODE
	THEN
	        AS_UTILITY_PVT.Set_Message(
		    p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
	            p_msg_name      => 'AS_NO_CLOSE_REASON'
		    );
        x_return_status := FND_API.G_RET_STS_ERROR;
	ELSE
		P_CLOSE_REASON_CODE := null;
	END IF;
      END IF;
      CLOSE C_Status_Exists ;



      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_STATUS_CLOSE_REASON;


PROCEDURE Validate_REF_BY_REF_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_REF_BY_ID                  IN   NUMBER,
    P_REF_TYPE_CODE              IN   VARCHAR2,
    P_OLD_REF_BY_ID		 IN   NUMBER,
    P_OLD_REF_TYPE_CODE		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  l_val   VARCHAR2(1);
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate status close reason'); END IF;

      IF p_validation_mode = AS_UTILITY_PVT.G_CREATE
      THEN

      IF (P_REF_BY_ID IS NULL or  P_REF_BY_ID =  FND_API.G_MISS_NUM) and  (P_REF_TYPE_CODE IS NOT NULL and  P_REF_TYPE_CODE <>  FND_API.G_MISS_NUM)
      THEN
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_REF_TYPE_REF_BY');

        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;


      IF (P_REF_TYPE_CODE IS NULL or  P_REF_TYPE_CODE  =  FND_API.G_MISS_NUM) and  (P_REF_BY_ID IS NOT NULL and  P_REF_BY_ID <>  FND_API.G_MISS_NUM)
      THEN
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_REF_TYPE_REF_BY');

        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

     ELSIF p_validation_mode = AS_UTILITY_PVT.G_UPDATE
     THEN

	IF (P_REF_TYPE_CODE IS NULL and P_REF_BY_ID IS NOT NULL) or
	   (P_REF_TYPE_CODE IS NOT NULL and P_REF_BY_ID IS NULL) or
	   (P_REF_TYPE_CODE = FND_API.G_MISS_CHAR and P_REF_BY_ID IS NOT NULL and P_OLD_REF_TYPE_CODE IS NULL) or
	   (P_REF_BY_ID = FND_API.G_MISS_NUM and P_REF_TYPE_CODE IS NOT NULL and P_OLD_REF_BY_ID IS NULL) or
	   (P_REF_BY_ID IS NULL and P_REF_TYPE_CODE = FND_API.G_MISS_CHAR and P_OLD_REF_TYPE_CODE IS NOT NULL) or
	   (P_REF_BY_ID = FND_API.G_MISS_NUM and P_REF_TYPE_CODE IS NULL and P_OLD_REF_BY_ID IS NOT NULL)

	THEN

  	    AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_REF_TYPE_REF_BY');

            x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;



     END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_REF_BY_REF_TYPE;


PROCEDURE Validate_OFFER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID        IN   NUMBER,
    P_OFFER_ID                   IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_OFFER_ID_Exists (c_OFFER_ID NUMBER) IS
  -- the validation logic for offer_id has changed. Bug # 1915617
     SELECT  'X'
       FROM  ams_source_codes
       WHERE source_code_id = c_offer_id
         and   ARC_SOURCE_CODE_FOR = 'OFFR';

     --SELECT  'X'
     --FROM  ams_act_offers
     --WHERE activity_offer_id = c_offer_id
     --      and nvl(start_date, sysdate) <= sysdate
     --      and nvl(end_date, sysdate) >= sysdate
     --       ffang 012501
     --      and ARC_ACT_OFFER_USED_BY = 'CAMP'
     --      and ACT_OFFER_USED_BY_ID =
     --                  (SELECT CAMPAIGN_ID
     --                   FROM AMS_CAMPAIGNS_VL c, AMS_SOURCE_CODES s
     --                   WHERE c.SOURCE_CODE = s.SOURCE_CODE
     --                      AND s.SOURCE_CODE_ID = P_SOURCE_PROMOTION_ID);


  l_val VARCHAR2(1);

BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate offer id'); END IF;

      IF (p_OFFER_ID is NOT NULL) and (p_OFFER_ID <> FND_API.G_MISS_NUM)
      THEN
          -- OFFER_ID should exist in ams_act_offers
          OPEN  C_OFFER_ID_Exists (p_OFFER_ID);
          FETCH C_OFFER_ID_Exists into l_val;

          IF C_OFFER_ID_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Private API: OFFER_ID is invalid');
              END IF;
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'OFFER',
                  p_token2        => 'VALUE',
                  p_token2_value  => p_OFFER_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_OFFER_ID_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OFFER_ID;


PROCEDURE Validate_INC_PARTNER_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INC_PARTNER_PARTY_ID       IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_INC_PRTN_PARTY_ID_Exist (c_inc_parn_party_id NUMBER) IS
      SELECT  'X'
	 FROM as_sf_ptr_v
	 WHERE partner_customer_id = c_inc_parn_party_id;
  l_val VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (P_INC_PARTNER_PARTY_ID is NOT NULL) and
         (P_INC_PARTNER_PARTY_ID <> FND_API.G_MISS_NUM)
      THEN
          OPEN  C_INC_PRTN_PARTY_ID_Exist (P_INC_PARTNER_PARTY_ID);
          FETCH C_INC_PRTN_PARTY_ID_Exist into l_val;

          IF C_INC_PRTN_PARTY_ID_Exist%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                         'Private API: INCUMBENT_PARTNER_PARTY_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'INCUMBENT_PARTNER_PARTY_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  => p_INC_PARTNER_PARTY_ID );
          END IF;

          -- ffang 092800: Forgot to close cursor?
          CLOSE C_INC_PRTN_PARTY_ID_Exist;
          -- end ffang 092800
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INC_PARTNER_PARTY_ID;


PROCEDURE Validate_INC_PRTNR_RESOURCE_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_INC_PARTNER_RESOURCE_ID    IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

  CURSOR C_RESOURCE_ID_Exists (c_INC_PARTNER_RESOURCE_ID VARCHAR2) IS
      SELECT  'X'
	 FROM as_sf_ptr_v
	 WHERE SALESFORCE_ID = c_INC_PARTNER_RESOURCE_ID;
      --FROM  jtf_rs_resource_extns
      --WHERE RESOURCE_ID = c_INC_PARTNER_RESOURCE_ID;
  l_val VARCHAR2(1);

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_INC_PARTNER_RESOURCE_ID is NOT NULL) and
         (p_INC_PARTNER_RESOURCE_ID <> FND_API.G_MISS_NUM)
      THEN
          -- INCUMBENT_PARTNER_RESOURCE_ID should exist in as_sf_ptr_v
          OPEN  C_RESOURCE_ID_Exists (p_INC_PARTNER_RESOURCE_ID);
          FETCH C_RESOURCE_ID_Exists into l_val;

          IF C_RESOURCE_ID_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Private API: INCUMBENT_PARTNER_RESOURCE_ID is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'INCUMBENT_PARTNER_RESOURCE_ID',
                  p_token2        => 'VALUE',
                  p_token2_value  => p_INC_PARTNER_RESOURCE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_RESOURCE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INC_PRTNR_RESOURCE_ID;


PROCEDURE Validate_PRM_EXEC_SPONSOR_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_EXEC_SPONSOR_FLAG      IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate PRM_EXEC_SPONSOR_FLAG'); END IF;

      IF (p_PRM_EXEC_SPONSOR_FLAG is NOT NULL) and
         (p_PRM_EXEC_SPONSOR_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_PRM_EXEC_SPONSOR_FLAG) <> 'Y') and
             (UPPER(p_PRM_EXEC_SPONSOR_FLAG) <> 'N')
          THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Private API: PRM_EXEC_SPONSOR_FLAG is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PRM_EXEC_SPONSOR_FLAG',
                  p_token2        => 'VALUE',
                  p_token2_value  => p_PRM_EXEC_SPONSOR_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_EXEC_SPONSOR_FLAG;


PROCEDURE Validate_PRM_PRJ_LDINPLE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_PRJ_LEAD_IN_PLACE_FLAG IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate PRM_PRJ_LDINPLE_FLAG'); END IF;

      IF (p_PRM_PRJ_LEAD_IN_PLACE_FLAG is NOT NULL) and
         (p_PRM_PRJ_LEAD_IN_PLACE_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_PRM_PRJ_LEAD_IN_PLACE_FLAG) <> 'Y') and
             (UPPER(p_PRM_PRJ_LEAD_IN_PLACE_FLAG) <> 'N')
          THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                        'Private API: PRM_PRJ_LEAD_IN_PLACE_FLAG is invalid');
              END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PRM_PRJ_LEAD_IN_PLACE_FLAG',
                  p_token2        => 'VALUE',
                  p_token2_value  => p_PRM_PRJ_LEAD_IN_PLACE_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_PRJ_LDINPLE_FLAG;


PROCEDURE Validate_PRM_LEAD_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_LEAD_TYPE              IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_PRM_LEAD_TYPE_Exists (c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = 'PRM_LEAD_TYPE'
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);

BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate PRM_LEAD_TYPE'); END IF;

      IF (p_PRM_LEAD_TYPE is NOT NULL) and
         (p_PRM_LEAD_TYPE <> FND_API.G_MISS_CHAR)
      THEN
          -- PRM_LEAD_TYPE should exist in as_lookups
          OPEN  C_PRM_LEAD_TYPE_Exists (p_PRM_LEAD_TYPE);
          FETCH C_PRM_LEAD_TYPE_Exists into l_val;

          IF C_PRM_LEAD_TYPE_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Private API: PRM_LEAD_TYPE is invalid');
              END IF;
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PRM_LEAD_TYPE',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  p_PRM_LEAD_TYPE );
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PRM_LEAD_TYPE_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_LEAD_TYPE;


PROCEDURE Validate_PRM_IND_CLS_CODE (
    P_Init_Msg_List               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode             IN   VARCHAR2,
    P_PRM_IND_CLASSIFICATION_CODE IN   VARCHAR2,
    x_Item_Property_Rec           OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status               OUT NOCOPY  VARCHAR2,
    X_Msg_Count                   OUT NOCOPY  NUMBER,
    X_Msg_Data                    OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_PRM_IND_CLS_CODE_Exists (c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = 'PRM_IND_CLASSIFICATION_TYPE'
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);

BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate PRM_IND_CLS_CODE'); END IF;

      IF (p_PRM_IND_CLASSIFICATION_CODE is NOT NULL) and
         (p_PRM_IND_CLASSIFICATION_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- PRM_IND_CLASSIFICATION_CODE should exist in as_lookups
          OPEN  C_PRM_IND_CLS_CODE_Exists (p_PRM_IND_CLASSIFICATION_CODE);
          FETCH C_PRM_IND_CLS_CODE_Exists into l_val;

          IF C_PRM_IND_CLS_CODE_Exists%NOTFOUND THEN
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'Private API: PRM_IND_CLASSIFICATION_CODE is invalid');
              END IF;
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ID',
                  p_token1        => 'COLUMN',
                  p_token1_value  => 'PRM_IND_CLASSIFICATION_CODE',
                  p_token2        => 'VALUE',
                  p_token2_value  =>  p_PRM_IND_CLASSIFICATION_CODE );
              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          CLOSE C_PRM_IND_CLS_CODE_Exists;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_IND_CLS_CODE;



PROCEDURE Validate_AUTO_ASSIGNMENT_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_AUTO_ASSIGNMENT_TYPE       IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_AUTO_ASGN_TYPE_Exists (c_lookup_type VARCHAR2,
                                  c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_AUTO_ASSIGNMENT_TYPE is NOT NULL) and
         (p_AUTO_ASSIGNMENT_TYPE <> FND_API.G_MISS_CHAR)
     THEN
          -- AUTO_ASSIGNMENT_TYPE should exist in as_lookups
          OPEN  C_AUTO_ASGN_TYPE_Exists ('AUTO_ASSIGNMENT_TYPE',
                                         p_AUTO_ASSIGNMENT_TYPE);
          FETCH C_AUTO_ASGN_TYPE_Exists into l_val;

          IF C_AUTO_ASGN_TYPE_Exists%NOTFOUND THEN
              -- IF (AS_DEBUG_ERROR_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --              'Private API: AUTO_ASSIGNMENT_TYPE is invalid'); END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_AUTO_ASGN_TYPE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_AUTO_ASSIGNMENT_TYPE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_AUTO_ASGN_TYPE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_AUTO_ASSIGNMENT_TYPE;


PROCEDURE Validate_PRM_ASSIGNMENT_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRM_ASSIGNMENT_TYPE        IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_PRM_ASGN_TYPE_Exists (c_lookup_type VARCHAR2,
                                 c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRM_ASSIGNMENT_TYPE is NOT NULL) and
         (p_PRM_ASSIGNMENT_TYPE <> FND_API.G_MISS_CHAR)
      THEN
          -- PRM_ASSIGNMENT_TYPE should exist in as_lookups
          OPEN  C_PRM_ASGN_TYPE_Exists ('PRM_ASSIGNMENT_TYPE',
                                        p_PRM_ASSIGNMENT_TYPE);
          FETCH C_PRM_ASGN_TYPE_Exists into l_val;

          IF C_PRM_ASGN_TYPE_Exists%NOTFOUND THEN
              -- IF (AS_DEBUG_ERROR_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --              'Private API: PRM_ASSIGNMENT_TYPE is invalid'); END IF;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRM_ASGN_TYPE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRM_ASSIGNMENT_TYPE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_PRM_ASGN_TYPE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_ASSIGNMENT_TYPE;


--
-- Record Level Validation
--


--
--  Inter-record level validation
--

PROCEDURE Validate_Budget_Amounts(
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_ID              IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_Header_Amount (X_Sales_Lead_ID NUMBER) IS
      SELECT budget_amount
      FROM as_sales_leads
      where sales_lead_id = X_Sales_Lead_ID;

    CURSOR C_Lines_Amounts (X_Sales_Lead_ID NUMBER) IS
      SELECT sum (budget_amount)
      FROM as_sales_lead_lines
      where sales_lead_id = X_Sales_Lead_ID;

    l_header_amount  NUMBER;
    l_lines_amounts  NUMBER;
BEGIN
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate budget amount'); END IF;

      -- The summary of lines' budget_amount should be equal to header's
      -- budget_amount
      OPEN C_Header_Amount (P_SALES_LEAD_ID);
      FETCH C_Header_Amount into l_header_amount;
      CLOSE C_Header_Amount;

      OPEN C_Lines_Amounts (P_SALES_LEAD_ID);
      FETCH C_Lines_Amounts into l_lines_amounts;
      CLOSE C_Lines_Amounts;

      IF l_header_amount <> l_lines_amounts
      THEN
        AS_UTILITY_PVT.Set_Message(
            p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
            p_msg_name      => 'AS_BUDGET_AMOUNT_NOT_MATCH');
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );
END Validate_Budget_Amounts;


--  validation procedures

PROCEDURE Validate_sales_lead(
    P_Init_Msg_List              IN   VARCHAR2   := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_SALES_LEAD_Rec             IN OUT NOCOPY  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    P_Referral_Type		         IN   VARCHAR2,
    P_Referred_By                IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    l_api_name   CONSTANT VARCHAR2(30) := 'Validate_sales_lead';
    l_item_property_rec   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
    l_return_status       VARCHAR2(1);
    l_close_reason_code VARCHAR2(50);

BEGIN
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
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
	 THEN
          -- Perform item level validation
          Validate_CUSTOMER_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CUSTOMER_ID            => P_SALES_LEAD_Rec.CUSTOMER_ID,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ADDRESS_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMER_ID            => P_SALES_LEAD_Rec.CUSTOMER_ID,
              p_ADDRESS_ID             => P_SALES_LEAD_Rec.ADDRESS_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          /* This column is not required anymore
          Validate_LEAD_NUMBER(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_NUMBER            => P_SALES_LEAD_Rec.LEAD_NUMBER,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
          */

          Validate_STATUS_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_STATUS_CODE            => P_SALES_LEAD_Rec.STATUS_CODE,
              p_sales_lead_id	 	=>P_SALES_LEAD_Rec.SALES_LEAD_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_SOURCE_PROMOTION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_SOURCE_PROMOTION_ID    => P_SALES_LEAD_Rec.SOURCE_PROMOTION_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          -- 11.5.10 ckapoor Adding validation for sales methodology ID

          Validate_Sales_Methodology_ID(
	                p_init_msg_list          => FND_API.G_FALSE,
	                p_validation_mode        => p_validation_mode,
	                p_Sales_Methodology_ID   => P_SALES_LEAD_Rec.SALES_METHODOLOGY_ID,
	                x_return_status          => x_return_status,
	                x_msg_count              => x_msg_count,
	                x_msg_data               => x_msg_data);
	            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	                l_return_status := FND_API.G_RET_STS_ERROR;
	                -- raise FND_API.G_EXC_ERROR;
          END IF;



          Validate_Sales_Stage_ID(
	  	                p_init_msg_list          => FND_API.G_FALSE,
	  	                p_validation_mode        => p_validation_mode,
	  	                p_Sales_Methodology_ID   => P_SALES_LEAD_Rec.SALES_METHODOLOGY_ID,
	  	                p_Sales_Stage_ID	 => p_sales_lead_rec.SALES_STAGE_ID,
	  	                x_return_status          => x_return_status,
	  	                x_msg_count              => x_msg_count,
	  	                x_msg_data               => x_msg_data);
	  	            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  	                l_return_status := FND_API.G_RET_STS_ERROR;
	  	                -- raise FND_API.G_EXC_ERROR;
	            END IF;



          /* This column is obsoleted in 11i
          Validate_CONTACT_ROLE_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CONTACT_ROLE_CODE      => P_SALES_LEAD_Rec.CONTACT_ROLE_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;
          */

          Validate_CHANNEL_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CHANNEL_CODE           => P_SALES_LEAD_Rec.CHANNEL_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CURRENCY_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CODE          => P_SALES_LEAD_Rec.CURRENCY_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_DECN_TIMEFRAME_CODE(
              p_init_msg_list             => FND_API.G_FALSE,
              p_validation_mode           => p_validation_mode,
              p_DECISION_TIMEFRAME_CODE
						 => P_SALES_LEAD_Rec.DECISION_TIMEFRAME_CODE,
              x_return_status             => x_return_status,
              x_msg_count                 => x_msg_count,
              x_msg_data                  => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CLOSE_REASON(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CLOSE_REASON           => P_SALES_LEAD_Rec.CLOSE_REASON,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_LEAD_RANK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LEAD_RANK_ID           => P_SALES_LEAD_Rec.LEAD_RANK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ASSIGN_TO_PERSON_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_ASSIGN_TO_PERSON_ID    => P_SALES_LEAD_Rec.ASSIGN_TO_PERSON_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ASSIGN_TO_SF_ID(
              p_init_msg_list           => FND_API.G_FALSE,
              p_validation_mode         => p_validation_mode,
              p_ASSIGN_TO_SALESFORCE_ID =>
							    P_SALES_LEAD_Rec.ASSIGN_TO_SALESFORCE_ID,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_BUDGET_STATUS_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_BUDGET_STATUS_CODE     => P_SALES_LEAD_Rec.BUDGET_STATUS_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_VEHICLE_RESPONSE_CODE(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_VEHICLE_RESPONSE_CODE => P_SALES_LEAD_Rec.VEHICLE_RESPONSE_CODE,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_REJECT_REASON_CODE(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_REJECT_REASON_CODE    => P_SALES_LEAD_Rec.REJECT_REASON_CODE,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_OFFER_ID(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              P_SOURCE_PROMOTION_ID   => P_SALES_LEAD_Rec.source_promotion_id,
              p_OFFER_ID              => P_SALES_LEAD_Rec.OFFER_ID,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              --
              raise FND_API.G_EXC_ERROR;
          END IF;



          Validate_INC_PARTNER_PARTY_ID(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_INC_PARTNER_PARTY_ID  =>
                               P_SALES_LEAD_Rec.INCUMBENT_PARTNER_PARTY_ID,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_INC_PRTNR_RESOURCE_ID(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_INC_PARTNER_RESOURCE_ID =>
                               P_SALES_LEAD_Rec.INCUMBENT_PARTNER_RESOURCE_ID,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRM_EXEC_SPONSOR_FLAG(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_PRM_EXEC_SPONSOR_FLAG => P_SALES_LEAD_Rec.PRM_EXEC_SPONSOR_FLAG,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRM_PRJ_LDINPLE_FLAG(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_PRM_PRJ_LEAD_IN_PLACE_FLAG  =>
                               P_SALES_LEAD_Rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRM_LEAD_TYPE(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_PRM_LEAD_TYPE         => P_SALES_LEAD_Rec.Prm_Sales_Lead_Type,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRM_IND_CLS_CODE(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_PRM_IND_CLASSIFICATION_CODE =>
                               P_SALES_LEAD_Rec.PRM_IND_CLASSIFICATION_CODE,
              x_item_property_rec     => l_item_property_rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PRM_ASSIGNMENT_TYPE(
	                p_init_msg_list         => FND_API.G_FALSE,
	                p_validation_mode       => p_validation_mode,
	                p_PRM_ASSIGNMENT_TYPE   =>
	                                 P_SALES_LEAD_Rec.PRM_ASSIGNMENT_TYPE,
	                x_item_property_rec     => l_item_property_rec,
	                x_return_status         => x_return_status,
	                x_msg_count             => x_msg_count,
	                x_msg_data              => x_msg_data);
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    	 l_return_status := FND_API.G_RET_STS_ERROR;
	  -- raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_AUTO_ASSIGNMENT_TYPE(
			p_init_msg_list         => FND_API.G_FALSE,
			p_validation_mode       => p_validation_mode,
			p_AUTO_ASSIGNMENT_TYPE   =>
					 P_SALES_LEAD_Rec.AUTO_ASSIGNMENT_TYPE,
			x_item_property_rec     => l_item_property_rec,
			x_return_status         => x_return_status,
			x_msg_count             => x_msg_count,
			x_msg_data              => x_msg_data);
   	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;
  	  -- raise FND_API.G_EXC_ERROR;
          END IF;


          Validate_FLAGS(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_Flag_Value            => P_SALES_LEAD_Rec.ACCEPT_FLAG,
              p_Flag_Type             => 'ACCEPT_FLAG',
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FLAGS(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_Flag_Value            => P_SALES_LEAD_Rec.KEEP_FLAG,
              p_Flag_Type             => 'KEEP_FLAG',
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FLAGS(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_Flag_Value            => P_SALES_LEAD_Rec.URGENT_FLAG,
              p_Flag_Type             => 'URGENT_FLAG',
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FLAGS(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_mode       => p_validation_mode,
              p_Flag_Value            => P_SALES_LEAD_Rec.IMPORT_FLAG,
              p_Flag_Type             => 'IMPORT_FLAG',
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FLAGS(
		p_init_msg_list         => FND_API.G_FALSE,
		p_validation_mode       => p_validation_mode,
		p_Flag_Value            => P_SALES_LEAD_Rec.QUALIFIED_FLAG,
		p_Flag_Type             => 'QUALIFIED_FLAG',
		x_return_status         => x_return_status,
		x_msg_count             => x_msg_count,
		x_msg_data              => x_msg_data);
	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_return_status := FND_API.G_RET_STS_ERROR;
		-- raise FND_API.G_EXC_ERROR;
          END IF;


      END IF;

    -- Requirement has changed. Close reason is associated with lead.
      -- Close reason is for opportunity. We don't have to validate it.
      l_close_reason_code := P_SALES_LEAD_Rec.CLOSE_REASON;
      IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD)
      THEN
          -- Perform record level validation
          Validate_STATUS_CLOSE_REASON (
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Validation_mode            => p_validation_mode,
              P_STATUS_CODE                => P_SALES_LEAD_Rec.STATUS_CODE,
              P_CLOSE_REASON_CODE          => l_close_reason_code,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;


	P_SALES_LEAD_Rec.CLOSE_REASON := l_close_reason_code;


          -- referral type and referred by columns are related for CAPRI
          /*Validate_REF_BY_REF_TYPE (
              P_Init_Msg_List              => FND_API.G_FALSE,
              P_Validation_mode            => p_validation_mode,
              P_REF_BY_ID                  => P_SALES_LEAD_Rec.REFERRED_BY,
              P_REF_TYPE_CODE              => P_SALES_LEAD_Rec.REFERRAL_TYPE,
              P_OLD_REF_BY_ID              => P_REFERRED_BY,
              P_OLD_REF_TYPE_CODE          => P_REFERRAL_TYPE,
              X_Return_Status              => x_return_status,
              X_Msg_Count                  => x_msg_count,
              X_Msg_Data                   => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_RET_STS_ERROR;
              -- raise FND_API.G_EXC_ERROR;
          END IF;*/


      END IF;

      -- Accept flag is related to decline reason Bug # 1953469
     /* IF ( P_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD)
            THEN
                -- Perform record level validation
                Validate_ACCEPT_REJECT_REASON (
                    P_Init_Msg_List              => FND_API.G_FALSE,
                    P_Validation_mode            => p_validation_mode,
                    P_ACCEPT_FLAG                => P_SALES_LEAD_Rec.ACCEPT_FLAG,
                    P_REJECT_REASON_CODE         => P_SALES_LEAD_Rec.REJECT_REASON_CODE,
                    X_Return_Status              => x_return_status,
                    X_Msg_Count                  => x_msg_count,
                    X_Msg_Data                   => x_msg_data);
                IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    l_return_status := FND_API.G_RET_STS_ERROR;
                    -- raise FND_API.G_EXC_ERROR;
                END IF;
            END IF;*/



      -- FFANG 112700 For bug 1512008, instead of erroring out once a invalid
	 -- column was found, raise the exception after all validation procedures
	 -- have been gone through.
	 x_return_status := l_return_status;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
      END IF;
	 -- END FFANG 112700

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');
      END IF;
END Validate_sales_lead;




-- **************************
--   Sales Lead Header APIs
-- **************************

PROCEDURE Create_sales_lead(
    P_Api_Version_Number      IN  NUMBER,
    P_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
    P_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    P_Validation_Level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    P_Admin_Flag              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id          IN  NUMBER   := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id  IN  NUMBER   := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl  IN  AS_UTILITY_PUB.Profile_Tbl_Type
                            := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec          IN  AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                            := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    P_SALES_LEAD_LINE_Tbl     IN  AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Tbl_type
                            := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_LINE_Tbl,
    P_SALES_LEAD_CONTACT_Tbl  IN  AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Tbl_Type
                            := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_CONTACT_Tbl,
    X_SALES_LEAD_ID           OUT NOCOPY NUMBER,
    X_SALES_LEAD_LINE_OUT_Tbl OUT
                            AS_SALES_LEADS_PUB.SALES_LEAD_LINE_OUT_Tbl_type,
    X_SALES_LEAD_CNT_OUT_Tbl  OUT
                            AS_SALES_LEADS_PUB.SALES_LEAD_CNT_OUT_Tbl_Type,
    X_Return_Status           OUT NOCOPY VARCHAR2,
    X_Msg_Count               OUT NOCOPY NUMBER,
    X_Msg_Data                OUT NOCOPY VARCHAR2
    )

 IS

    CURSOR C_Lines_Amounts (X_Sales_Lead_ID NUMBER) IS
      SELECT sum (budget_amount)
      FROM as_sales_lead_lines
      where sales_lead_id = X_Sales_Lead_ID;

    l_api_name                  CONSTANT VARCHAR2(30) := 'Create_sales_lead';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_SALES_LEAD_ID             NUMBER;
    l_sales_lead_line_id        NUMBER;
    l_lead_contact_id           NUMBER;
    l_SALES_LEAD_Rec            AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                    := p_sales_lead_rec;
    p_sales_lead_line_rec       AS_SALES_LEADS_PUB.SALES_LEAD_LINE_Rec_Type;
    p_sales_lead_contact_rec    AS_SALES_LEADS_PUB.SALES_LEAD_CONTACT_Rec_Type;
    l_Sales_Team_Rec            AS_ACCESS_PUB.Sales_Team_Rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_Sales_Lead_Log_ID         NUMBER;
    l_access_id                 NUMBER;
    l_access_flag               VARCHAR2(1);
    l_member_role               VARCHAR2(5);
    l_member_access             VARCHAR2(5);
    l_line_count                NUMBER    := p_sales_lead_line_tbl.count;
    l_contact_count             NUMBER    := p_sales_lead_contact_tbl.count;
    l_lines_amount              NUMBER    := 0;
    l_isQualified               VARCHAR2(1);
    l_qualified                 VARCHAR2(30);

    l_accept_flag               VARCHAR2(1);
    l_keep_flag                 VARCHAR2(1);
    l_urgent_flag               VARCHAR2(1);
    l_import_flag               VARCHAR2(1);
    l_deleted_flag              VARCHAR2(1);
    l_auto_qualify_profile	VARCHAR2(1);
    l_referral_status_profile VARCHAR2(30);
    l_exp_date 			DATE;
    l_timeframe_days 		NUMBER;
    l_manual_rank_flag          VARCHAR2(1);
    l_status_open_flag          VARCHAR2(1);
    l_lead_rank_score           NUMBER;

    l_country_code		VARCHAR2(60);


    -- 11.5.10 ckapoor Lead name rivendell change

    l_default_lead_name		VARCHAR2(2000);
    l_default_sales_stage	NUMBER;

    l_default_address_profile	VARCHAR2(1) := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_ADDRESS');

-- Bug 3385646 - MKTU3R10:COUNTRY IS NOT POPULATED WHEN THE LEAD IS CREATED THROUGH HTML
    CURSOR c_get_country_code (X_CUSTOMER_ID NUMBER, X_ADDRESS_ID NUMBER) IS
          select LOC.COUNTRY
	  FROM HZ_PARTY_SITES SITE,HZ_LOCATIONS LOC
	  WHERE SITE.PARTY_ID = X_CUSTOMER_ID
	  AND SITE.PARTY_SITE_ID = X_ADDRESS_ID
	  AND SITE.STATUS IN ('A','I')
	  AND SITE.LOCATION_ID = LOC.LOCATION_ID;


    CURSOR C_timeframe_days (X_DECISION_TIMEFRAME_CODE VARCHAR2) IS
          SELECT timeframe_days
          FROM aml_sales_lead_timeframes
          where decision_timeframe_code = X_DECISION_TIMEFRAME_CODE
	  and enabled_flag='Y';


     CURSOR C_Get_Status_open_flag(X_Lookup_Code VARCHAR2) IS
          SELECT opp_open_status_flag
          FROM  as_statuses_b
          WHERE lead_flag = 'Y' and enabled_flag = 'Y'
            and status_code = X_Lookup_Code;



    CURSOR C_Get_Lead_Rank_Score (X_Rank_ID  NUMBER) IS
          SELECT min_score
          FROM   as_sales_lead_ranks_b
          WHERE  rank_id = X_Rank_ID;


    -- 11.5.10 ckapoor Lead Name changes for Rivendell

    CURSOR C_get_primary_contact_name(X_sales_lead_id NUMBER) IS
          SELECT hzp.party_name
          FROM  hz_parties hzp, as_sales_leads sl
          WHERE hzp.party_id = sl.primary_cnt_person_party_id
          and sl.sales_lead_id = X_sales_lead_id;
          -- this works since contacts API would have already updated the
          -- primary contacts party id information in as_sales_leads.


    CURSOR C_get_customer_name (X_party_id NUMBER) IS
          SELECT party_name
          FROM  hz_parties
          WHERE party_id = X_party_id;

    ----  bug 2533638 - TST1158.7:MSTR:ORG. ADDRESS IS NOT PICKED WHEN CREATING LEAD FROM PARTNER DETAIL

	CURSOR primary_address ( p_customer_id NUMBER) IS
	select party_site_id
	from hz_party_sites
	where party_id = p_customer_id
	and IDENTIFYING_ADDRESS_FLAG = 'Y';
    ----


    CURSOR C_default_sales_stage(X_Sales_Meth_ID NUMBER) IS

    SELECT sales_stage_id
    FROM (
      SELECT asms.sales_stage_id
	     FROM AS_SALES_METH_STAGE_MAP asms
	         , AS_SALES_STAGES_ALL_B assa
	     WHERE asms.sales_stage_id = assa.sales_stage_id
	       AND TRUNC(NVL(assa.start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
	       AND TRUNC(NVL(assa.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
	       AND sales_methodology_id = X_Sales_Meth_ID
	       AND assa.applicability IN ('LEAD', 'BOTH')
	       -- ckapoor 05/11/04 bug 3621389 -
	       -- adding new additional condition as per AUYU
	       AND assa.enabled_flag = 'Y'
                -- end ckapoor
		   ORDER BY asms.stage_sequence
	)
    WHERE ROWNUM = 1 ;



    -- 11.5.10 end ckapoor Rivendell changes







BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SALES_LEAD_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME )
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

      AS_UTILITY_PVT.Debug_Message( FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                    'PVT: ' || l_api_name || ' Start');
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

      -- Set default value to accept_flag, keep_flag, urgent_flag,
      -- import_flag, deleted_flag, and currency_code as profile values.
      If (l_SALES_LEAD_rec.ACCEPT_FLAG IS NULL) or
         (l_SALES_LEAD_rec.ACCEPT_FLAG= FND_API.G_MISS_CHAR) or
         (l_SALES_LEAD_rec.KEEP_FLAG IS NULL) or
         (l_SALES_LEAD_rec.KEEP_FLAG = FND_API.G_MISS_CHAR) or
         (l_SALES_LEAD_rec.URGENT_FLAG IS NULL) or
         (l_SALES_LEAD_rec.URGENT_FLAG = FND_API.G_MISS_CHAR) or
         (l_SALES_LEAD_rec.IMPORT_FLAG IS NULL) or
         (l_SALES_LEAD_rec.IMPORT_FLAG = FND_API.G_MISS_CHAR) or
         (l_SALES_LEAD_rec.DELETED_FLAG IS NULL) or
         (l_SALES_LEAD_rec.DELETED_FLAG = FND_API.G_MISS_CHAR) or
         (l_SALES_LEAD_rec.currency_code IS NULL) or
         (l_SALES_LEAD_rec.currency_code = FND_API.G_MISS_CHAR)
      THEN
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Set_default_values');
          END IF;

          Set_default_values(
                p_mode               => AS_UTILITY_PVT.G_CREATE,
                px_SALES_LEAD_rec    => l_SALES_LEAD_Rec);

      End If;

      -----
      -- Default the customer address to primary address if necessary
      IF nvl(l_default_address_profile, 'N') = 'Y' AND
         ((l_SALES_LEAD_rec.address_id IS NULL) OR
          (l_SALES_LEAD_rec.address_id = FND_API.G_MISS_NUM))
      THEN
	  open primary_address(l_SALES_LEAD_rec.customer_id );
	  fetch  primary_address into l_SALES_LEAD_rec.address_id;
	  close  primary_address;

	  If (l_SALES_LEAD_rec.address_id IS NULL OR
	      l_SALES_LEAD_rec.address_id = FND_API.G_MISS_NUM )
	  THEN
          IF (AS_DEBUG_LOW_ON) THEN
	      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'No primary address for customer');
	      END IF;

	  END IF;
      END IF;

      -----


      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Validate_sales_lead');
      END IF;

      -- Invoke validation procedures
      Validate_sales_lead(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
              P_SALES_LEAD_Rec   => l_SALES_LEAD_Rec,
	          p_referral_type    => FND_API.G_MISS_CHAR,
              p_referred_by      => FND_API.G_MISS_NUM,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF(P_Check_Access_Flag = 'Y') THEN
          -- Call Get_Access_Profiles to get access_profile_rec
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Get_Access_Profiles');
          END IF;

          AS_SALES_LEADS_PUB.Get_Access_Profiles(
              p_profile_tbl         => p_sales_lead_profile_tbl,
              x_access_profile_rec  => l_access_profile_rec);

          IF (AS_DEBUG_LOW_ON) THEN



          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_viewCustomerAccess');

          END IF;

          AS_ACCESS_PUB.Has_viewCustomerAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_customer_id            => l_sales_lead_rec.customer_id,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_view_access_flag       => l_access_flag);

          IF l_access_flag <> 'Y' THEN
              IF (AS_DEBUG_ERROR_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_CREATE_PRIVILEGE');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                  'Calling Sales_Lead_Insert_Row');
      END IF;

      -- auto qualify lead

      -- ffang 120900, for bug 1504040
      -- only when the status is "New" or "Unqualified" then launch
      -- auto-qualification.

      -- ffang 100200: for bug 1416170
      -- Do auto-qualify only when keep_flag <> 'Y' or keep_flag is NULL
      -- IF (AS_DEBUG_LOW_ON) THEN  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --                        'keep_flag : ' || l_sales_lead_rec.keep_flag); END IF;
      -- IF (l_sales_lead_rec.keep_flag <> 'Y') or
      --    (l_sales_lead_rec.keep_flag is NULL)



      /*
      l_auto_qualify_profile :=  nvl(FND_PROFILE.Value('AS_AUTO_QUALIFY'),'N');
      IF(l_sales_lead_rec.qualified_flag = 'N' and
      		l_auto_qualify_profile = 'Y')

      --IF (l_sales_lead_rec.status_code = 'NEW' or
      --    l_sales_lead_rec.status_code = 'UNQUALIFIED')
      THEN
          -- Launch auto-qualification
          if P_SALES_LEAD_CONTACT_Tbl.exists(1) then
            l_isQualified := IS_LEAD_QUALIFIED(l_SALES_LEAD_Rec,
                                         P_SALES_LEAD_CONTACT_Tbl(1).phone_id ,
                                         P_SALES_LEAD_CONTACT_Tbl(1).contact_role_code);
          else
            l_isQualified := IS_LEAD_QUALIFIED(l_SALES_LEAD_Rec, null,null);
          end if;

          --if l_isQualified = 'Y' then
          --    l_qualified := 'QUALIFIED';
          --else
          --    -- ffang 120900, for bug 1504040
          --    -- If the lead fails qualification, at anytime the status
          --    -- should be "Unqualified".
          --    -- l_qualified := l_sales_lead_rec.STATUS_CODE;
          --    l_qualified := 'UNQUALIFIED';
          --end if;
          l_qualified := l_isQualified;
      ELSE
      	  -- Qualification does not affect status 11.5.4.09
          --l_qualified := l_sales_lead_rec.STATUS_CODE;
          l_qualified := l_sales_lead_rec.QUALIFIED_FLAG;
      END IF; */
      -- end ffang 100200

      l_qualified := l_sales_lead_rec.QUALIFIED_FLAG;

      -- do check on referral type. If a non null referral type is being passed in,
      -- then make sure referral status is set to the profile of REF_STATUS_FOR_NEW_LEAD
      -- of course use the profile for setting referral status only if referral status is not being manually passed in

      if ((l_SALES_LEAD_rec.REFERRAL_STATUS is null or l_SALES_LEAD_rec.REFERRAL_STATUS = FND_API.G_MISS_CHAR )
          and l_SALES_LEAD_rec.REFERRAL_TYPE is not null and l_sales_lead_rec.REFERRAL_TYPE <> FND_API.G_MISS_CHAR)
      then
          l_referral_status_profile :=  FND_PROFILE.Value('REF_STATUS_FOR_NEW_LEAD');
      else
          l_referral_status_profile := l_sales_lead_rec.REFERRAL_STATUS;
      end if;

      if (l_SALES_LEAD_rec.LEAD_DATE is null) then
        l_SALES_LEAD_rec.LEAD_DATE := SYSDATE;
      end if;

     if (l_SALES_LEAD_rec.SOURCE_SYSTEM is null) then
        l_SALES_LEAD_rec.SOURCE_SYSTEM := 'USER';
      end if;


     -- expiration date is calculated as creation_date + time frame days (for a smart timeframe)
     -- if no smart timeframe, then exp date is null.

     l_exp_date := null;
     l_timeframe_days := 0;


      OPEN  C_timeframe_days (l_sales_lead_rec.DECISION_TIMEFRAME_CODE);
      FETCH C_timeframe_days into l_timeframe_days;

      IF C_timeframe_days%NOTFOUND
      THEN
       	l_exp_date := null;

      ELSE
      	l_exp_date := sysdate + l_timeframe_days;
      END IF;


      CLOSE C_timeframe_days ;



            --Denorm fix 04/30/03 ckapoor
            --Get the open status flag for status

            OPEN  C_Get_Status_open_flag ( l_sales_lead_rec.STATUS_CODE);
            FETCH C_Get_Status_open_flag into l_status_open_flag;
            Close C_Get_Status_open_flag;

            -- now this open status flag will be logged in the sales lead table.

	    -- Bug 3385646 - MKTU3R10:COUNTRY IS NOT POPULATED WHEN THE LEAD IS CREATED THROUGH HTML

	    OPEN  c_get_country_code ( l_sales_lead_rec.customer_id, l_sales_lead_rec.address_id);
            FETCH c_get_country_code into l_country_code;
            Close c_get_country_code;

	    --Get the score for the rank

            OPEN  C_Get_Lead_Rank_Score ( l_sales_lead_rec.LEAD_RANK_ID);
            FETCH C_Get_Lead_Rank_Score into l_lead_rank_score;
            Close C_Get_Lead_Rank_Score;

            -- now this lead rank score will be logged in the sales lead table.
            IF (AS_DEBUG_LOW_ON) THEN

	    	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'lead_rank_score : ' || l_lead_rank_score);

	   END IF;

	   if (l_sales_lead_rec.lead_rank_id is null)
	   then
	 	 l_lead_rank_score :=0;
	   end if;


            -- End Denorm fix



	-- 11.5.10 ckapoor sales methodology fix
	-- if sales methodology is not null and not g_miss, and if sales stage is missing
	-- then default sales stage

	l_default_sales_stage := null;

	    IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
		                       'sales meth'|| l_sales_lead_rec.SALES_METHODOLOGY_ID);
	    END IF;

	    IF (AS_DEBUG_LOW_ON) THEN

		AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
			                       'sales stage'|| l_sales_lead_rec.SALES_STAGE_ID);
	    END IF;



	if ( ((l_sales_lead_rec.sales_methodology_id is not null) and (l_sales_lead_rec.sales_methodology_id <> FND_API.G_MISS_NUM))
	       and ((l_sales_lead_rec.SALES_STAGE_ID is null) or (l_sales_lead_rec.sales_stage_id = FND_API.G_MISS_NUM)))
	then


		IF (AS_DEBUG_LOW_ON) THEN


	        	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                       'CK:: defaulting sales stage');

		end if;

		OPEN  C_default_sales_stage (l_sales_lead_rec.sales_methodology_id);
		      FETCH C_default_sales_stage into l_default_sales_stage;

		      if (C_default_sales_stage%NOTFOUND) then
		      	l_default_sales_stage := l_sales_lead_rec.sales_stage_id;
		      end if;


	              CLOSE C_default_sales_stage ;
	else
		l_default_sales_stage :=  l_sales_lead_rec.sales_stage_id;

	end if;






      -- Invoke table handler(Sales_Lead_Insert_Row)
      x_SALES_LEAD_ID := l_SALES_LEAD_rec.SALES_LEAD_ID;

      AS_SALES_LEADS_PKG.Sales_Lead_Insert_Row(
          px_SALES_LEAD_ID  => x_SALES_LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
          p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
          p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
          p_PROGRAM_UPDATE_DATE  => SYSDATE,
          p_LEAD_NUMBER  => x_SALES_LEAD_ID,
          --p_STATUS_CODE  => l_qualified,
          p_STATUS_CODE => l_SALES_LEAD_rec.STATUS_CODE,
          p_CUSTOMER_ID  => l_SALES_LEAD_rec.CUSTOMER_ID,
          p_ADDRESS_ID  => l_SALES_LEAD_rec.ADDRESS_ID,
          p_SOURCE_PROMOTION_ID  => l_SALES_LEAD_rec.SOURCE_PROMOTION_ID,
          p_INITIATING_CONTACT_ID  => l_SALES_LEAD_rec.INITIATING_CONTACT_ID,
          p_ORIG_SYSTEM_REFERENCE  => l_SALES_LEAD_rec.ORIG_SYSTEM_REFERENCE,
          p_CONTACT_ROLE_CODE  => l_SALES_LEAD_rec.CONTACT_ROLE_CODE,
          p_CHANNEL_CODE  => l_SALES_LEAD_rec.CHANNEL_CODE,
          p_BUDGET_AMOUNT  => l_SALES_LEAD_rec.BUDGET_AMOUNT,
          p_CURRENCY_CODE  => l_SALES_LEAD_rec.CURRENCY_CODE,
          p_DECISION_TIMEFRAME_CODE => l_SALES_LEAD_rec.DECISION_TIMEFRAME_CODE,
          p_CLOSE_REASON  => l_SALES_LEAD_rec.CLOSE_REASON,
          p_LEAD_RANK_ID  => l_SALES_LEAD_rec.LEAD_RANK_ID,
          p_LEAD_RANK_CODE  => l_SALES_LEAD_rec.LEAD_RANK_CODE,
          p_PARENT_PROJECT  => l_SALES_LEAD_rec.PARENT_PROJECT,
          p_DESCRIPTION  => l_SALES_LEAD_rec.DESCRIPTION,
          p_ATTRIBUTE_CATEGORY  => l_SALES_LEAD_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_SALES_LEAD_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_SALES_LEAD_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_SALES_LEAD_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_SALES_LEAD_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_SALES_LEAD_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_SALES_LEAD_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_SALES_LEAD_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_SALES_LEAD_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_SALES_LEAD_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_SALES_LEAD_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_SALES_LEAD_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_SALES_LEAD_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_SALES_LEAD_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_SALES_LEAD_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_SALES_LEAD_rec.ATTRIBUTE15,
          p_ASSIGN_TO_PERSON_ID  => l_SALES_LEAD_rec.ASSIGN_TO_PERSON_ID,
          p_ASSIGN_TO_SALESFORCE_ID => l_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID,
          p_ASSIGN_SALES_GROUP_ID => l_SALES_LEAD_rec.ASSIGN_SALES_GROUP_ID,
          --p_ASSIGN_DATE  => l_SALES_LEAD_rec.ASSIGN_DATE,
          p_ASSIGN_DATE  => SYSDATE,
          p_BUDGET_STATUS_CODE  => l_SALES_LEAD_rec.BUDGET_STATUS_CODE,
          p_ACCEPT_FLAG  => l_SALES_LEAD_rec.ACCEPT_FLAG,
          p_VEHICLE_RESPONSE_CODE  => l_SALES_LEAD_rec.VEHICLE_RESPONSE_CODE,
          p_TOTAL_SCORE   => l_SALES_LEAD_rec.TOTAL_SCORE,
          p_SCORECARD_ID  => l_SALES_LEAD_rec.SCORECARD_ID,
          p_KEEP_FLAG     => l_SALES_LEAD_rec.KEEP_FLAG,
          p_URGENT_FLAG   => l_SALES_LEAD_rec.URGENT_FLAG,
          p_IMPORT_FLAG   => l_SALES_LEAD_rec.IMPORT_FLAG,
          p_REJECT_REASON_CODE  => l_SALES_LEAD_rec.REJECT_REASON_CODE,
          p_DELETED_FLAG => l_SALES_LEAD_rec.DELETED_FLAG,
          p_OFFER_ID  => l_SALES_LEAD_rec.OFFER_ID,
          --p_QUALIFIED_FLAG => l_SALES_LEAD_rec.QUALIFIED_FLAG,
          p_QUALIFIED_FLAG => l_qualified,
          p_ORIG_SYSTEM_CODE => l_SALES_LEAD_rec.ORIG_SYSTEM_CODE,
--        p_SECURITY_GROUP_ID    => l_SALES_LEAD_rec.SECURITY_GROUP_ID,
          p_INC_PARTNER_PARTY_ID => l_SALES_LEAD_rec.INCUMBENT_PARTNER_PARTY_ID,
          p_INC_PARTNER_RESOURCE_ID =>
                              l_SALES_LEAD_rec.INCUMBENT_PARTNER_RESOURCE_ID,
          p_PRM_EXEC_SPONSOR_FLAG   => l_SALES_LEAD_rec.PRM_EXEC_SPONSOR_FLAG,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG =>
                              l_SALES_LEAD_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
          p_PRM_SALES_LEAD_TYPE     => l_SALES_LEAD_rec.PRM_SALES_LEAD_TYPE,
          p_PRM_IND_CLASSIFICATION_CODE =>
                              l_SALES_LEAD_rec.PRM_IND_CLASSIFICATION_CODE,
	  p_PRM_ASSIGNMENT_TYPE => l_SALES_LEAD_rec.PRM_ASSIGNMENT_TYPE,
	  p_AUTO_ASSIGNMENT_TYPE => l_SALEs_LEAD_rec.AUTO_ASSIGNMENT_TYPE,
	  p_PRIMARY_CONTACT_PARTY_ID => l_SALES_LEAD_rec.PRIMARY_CONTACT_PARTY_ID,
	  p_PRIMARY_CNT_PERSON_PARTY_ID => l_SALES_LEAD_rec.PRIMARY_CNT_PERSON_PARTY_ID,
	  p_PRIMARY_CONTACT_PHONE_ID => l_SALES_LEAD_rec.PRIMARY_CONTACT_PHONE_ID,
	  -- new columns for CAPRI lead referral

	  p_REFERRED_BY => l_SALES_LEAD_rec.REFERRED_BY,
	  p_REFERRAL_TYPE => l_SALES_LEAD_rec.REFERRAL_TYPE,
	  p_REFERRAL_STATUS => l_referral_status_profile,
	  p_REF_DECLINE_REASON => l_SALES_LEAD_rec.REF_DECLINE_REASON,
	  p_REF_COMM_LTR_STATUS => l_SALES_LEAD_rec.REF_COMM_LTR_STATUS,
	  p_REF_ORDER_NUMBER => l_SALES_LEAD_rec.REF_ORDER_NUMBER,
	  p_REF_ORDER_AMT => l_SALES_LEAD_rec.REF_ORDER_AMT,
	  p_REF_COMM_AMT => l_SALES_LEAD_rec.REF_COMM_AMT,

	  p_LEAD_DATE => l_SALES_LEAD_rec.LEAD_DATE,
	  p_SOURCE_SYSTEM => l_SALES_LEAD_rec.SOURCE_SYSTEM,

	  -- Bug 3385646 - MKTU3R10:COUNTRY IS NOT POPULATED WHEN THE LEAD IS CREATED THROUGH HTML

	  p_COUNTRY => l_country_code, --l_SALES_LEAD_rec.COUNTRY,

	  p_TOTAL_AMOUNT => l_SALES_LEAD_rec.TOTAL_AMOUNT,
	  p_EXPIRATION_DATE => l_exp_date, --l_SALES_LEAD_rec.EXPIRATION_DATE,

	  p_LEAD_RANK_IND => l_SALES_LEAD_rec.LEAD_RANK_IND,
	  p_LEAD_ENGINE_RUN_DATE => l_SALES_LEAD_rec.LEAD_ENGINE_RUN_DATE,

	  p_CURRENT_REROUTES => l_SALES_LEAD_rec.CURRENT_REROUTES

          -- new columns for appsperf CRMAP denorm project bug 2928041

          ,p_STATUS_OPEN_FLAG =>   l_status_open_flag
                                 --FND_API.G_MISS_CHAR
          ,p_LEAD_RANK_SCORE => l_lead_rank_score
          			 --FND_API.G_MISS_NUM


	  -- ckapoor 11.5.10 New columns

	  , p_MARKETING_SCORE	=> l_SALES_LEAD_rec.MARKETING_SCORE
	, p_INTERACTION_SCORE	=> l_SALES_LEAD_rec.INTERACTION_SCORE
	, p_SOURCE_PRIMARY_REFERENCE	=> l_SALES_LEAD_rec.SOURCE_PRIMARY_REFERENCE
	, p_SOURCE_SECONDARY_REFERENCE	=> l_SALES_LEAD_rec.SOURCE_SECONDARY_REFERENCE
	, p_SALES_METHODOLOGY_ID	=> l_SALES_LEAD_rec.SALES_METHODOLOGY_ID
	, p_SALES_STAGE_ID		=> l_default_sales_stage
	--l_SALES_LEAD_rec.SALES_STAGE_ID

          );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_SALES_LEAD_ID := x_SALES_LEAD_ID;

      IF l_SALES_LEAD_rec.LEAD_RANK_ID IS NOT NULL
      THEN
          l_manual_rank_flag := 'Y';
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'xSalesLeadID is '||l_sales_lead_id);

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling AS_SALES_LEADS_LOG_PKG.Insert_Row');
      END IF;

      -- Call API to create log entry

      AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                => l_sales_lead_log_id ,
            p_sales_lead_id          => l_sales_lead_id,
            p_created_by             => fnd_global.user_id,
            p_creation_date          => sysdate,
            p_last_updated_by        => fnd_global.user_id,
            p_last_update_date       => sysdate,
            p_last_update_login      =>  FND_GLOBAL.CONC_LOGIN_ID,
            -- using standard parameters for program who columns
            p_request_id             => FND_GLOBAL.Conc_Request_Id,
            p_program_application_id => FND_GLOBAL.Prog_Appl_Id,
            p_program_id             => FND_GLOBAL.Conc_Program_Id,
            p_program_update_date    => sysdate,
            p_status_code            => l_sales_lead_rec.status_code,
            p_assign_to_person_id    => l_sales_lead_rec.assign_to_person_id,
            p_assign_to_salesforce_id=>l_sales_lead_rec.assign_to_salesforce_id,
            p_reject_reason_code     => l_sales_lead_rec.reject_reason_code,
            p_assign_sales_group_id  => l_sales_lead_rec.assign_sales_group_id,
            p_lead_rank_id           => l_sales_lead_rec.lead_rank_id,
            p_qualified_flag         => l_qualified,
            p_category		     => fnd_api.g_miss_char,
            p_manual_rank_flag       => l_manual_rank_flag
            );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


       -- For referral leads, create another entry in the logs table so that it is tracked as a referral lead also

       if ( l_SALES_LEAD_rec.REFERRAL_TYPE is not null and l_sales_lead_rec.REFERRAL_TYPE <> FND_API.G_MISS_CHAR) then

               l_sales_lead_log_id := null;

               AS_SALES_LEADS_LOG_PKG.Insert_Row(
                  px_log_id                => l_sales_lead_log_id ,
                  p_sales_lead_id          => l_sales_lead_id,
                  p_created_by             => fnd_global.user_id,
                  p_creation_date          => sysdate,
                  p_last_updated_by        => fnd_global.user_id,
                  p_last_update_date       => sysdate,
                  p_last_update_login      =>  FND_GLOBAL.CONC_LOGIN_ID,
                  -- using standard parameters for program who columns
                  p_request_id             => FND_GLOBAL.Conc_Request_Id,
                  p_program_application_id => FND_GLOBAL.Prog_Appl_Id,
                  p_program_id             => FND_GLOBAL.Conc_Program_Id,
                  p_program_update_date    => sysdate,
                  p_status_code            => l_referral_status_profile, -- for referral log, we use referral status
                  p_assign_to_person_id    => l_sales_lead_rec.assign_to_person_id,
                  p_assign_to_salesforce_id=>l_sales_lead_rec.assign_to_salesforce_id,
                  p_reject_reason_code     => l_sales_lead_rec.reject_reason_code,
                  p_assign_sales_group_id  => l_sales_lead_rec.assign_sales_group_id,
                  p_lead_rank_id           => l_sales_lead_rec.lead_rank_id,
                  p_qualified_flag        => l_qualified,
                  p_category		    => 'REFERRAL'
                  );


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

/*            IF (AS_DEBUG_LOW_ON) THEN                        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Before notify party');            END IF;

            AS_SALES_LEAD_REFERRAL.Notify_Party (
                  p_api_version        => 1.0 ,
                  p_init_msg_list    => FND_API.g_false ,
                  p_commit            => FND_API.g_false ,
                  p_validation_level  => FND_API.g_valid_level_full ,
                  p_lead_id     => l_sales_lead_id ,
                  p_lead_status     => l_referral_status_profile ,
                  p_salesforce_id    => P_identity_salesforce_id ,
                  p_overriding_usernames => AS_SALES_LEAD_REFERRAL.G_MISS_OVER_USERNAMES_TBL ,
                  x_Msg_Count        => x_msg_count,
                  x_Msg_Data          => x_msg_data ,
                  x_Return_Status    => x_return_status
            );

             IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                IF (AS_DEBUG_LOW_ON) THEN

                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                                'Private API: Notification for creating referral lead failed');
                END IF;
           END IF;

            IF (AS_DEBUG_LOW_ON) THEN



            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'After notify party');

            END IF;  */
      end if;



      -- Create access record
      IF l_sales_lead_rec.assign_to_salesforce_id IS NOT NULL AND
         l_sales_lead_rec.assign_to_salesforce_id <> FND_API.G_MISS_NUM THEN
        -- Create access security in as_accesses_all
        -- l_Sales_Team_Rec.access_id            := FND_API.G_MISS_NUM;
        l_Sales_Team_Rec.last_update_date     := SYSDATE;
        l_Sales_Team_Rec.last_updated_by      := FND_GLOBAL.USER_ID;
        l_Sales_Team_Rec.creation_date	      := SYSDATE;
        l_Sales_Team_Rec.created_by           := FND_GLOBAL.USER_ID;
        l_Sales_Team_Rec.last_update_login    := FND_GLOBAL.CONC_LOGIN_ID;
        -- l_Sales_Team_Rec.team_leader_flag     := FND_API.G_MISS_CHAR;
        l_Sales_Team_Rec.customer_id          := l_SALES_LEAD_rec.Customer_Id;
        l_Sales_Team_Rec.address_id           := l_SALES_LEAD_rec.Address_Id;
        l_Sales_Team_Rec.salesforce_id        :=
                                    l_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID;
        l_Sales_Team_Rec.person_id            :=
                                    l_SALES_LEAD_rec.ASSIGN_TO_PERSON_ID;
        l_Sales_Team_Rec.sales_group_id       :=
                                    l_SALES_LEAD_rec.ASSIGN_SALES_GROUP_ID;
        l_Sales_Team_Rec.sales_lead_id        := x_sales_lead_id;

	l_Sales_Team_Rec.team_leader_flag     := 'Y';

	l_Sales_Team_Rec.owner_flag           := 'Y';
    l_Sales_Team_Rec.freeze_flag          := 'Y';


    l_Sales_Team_Rec.created_by_TAP_flag := 'N';


        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Create_SalesTeam');
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
          ,p_sales_team_rec             => l_Sales_Team_Rec
          ,X_Return_Status              => x_Return_Status
          ,X_Msg_Count                  => X_Msg_Count
          ,X_Msg_Data                   => X_Msg_Data
          ,x_access_id                  => l_Access_Id
        );

        -- Debug Message

        IF (AS_DEBUG_LOW_ON) THEN



        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'access_id : ' || l_Access_Id);

        END IF;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- Create Sales Lead Lines
      IF p_SALES_LEAD_LINE_tbl.COUNT >= 1 THEN
        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Create_sales_lead_lines');
        END IF;

        -- ffang020201, if sales lead isn't assigned, access record hasn't been
	   -- created. P_check_access_flag should pass 'N' to avoid checking
	   -- has_updateLeadAccess
        AS_SALES_LEAD_LINES_PVT.Create_sales_lead_lines(
                P_Api_Version_Number  => 2.0 ,
                P_Init_Msg_List       => FND_API.G_FALSE,
                P_Commit              => FND_API.G_FALSE,
                p_validation_level    => P_Validation_Level,
                P_Check_Access_Flag   => 'N',
                -- P_Check_Access_Flag   => P_Check_Access_Flag,
                P_Admin_Flag          => P_Admin_Flag,
                P_Admin_Group_Id      => P_Admin_Group_Id,
                P_identity_salesforce_id => P_identity_salesforce_id,
                P_Sales_Lead_Profile_Tbl => P_Sales_Lead_Profile_Tbl,
                P_SALES_LEAD_LINE_Tbl => p_SALES_LEAD_LINE_Tbl,
                P_SALES_LEAD_ID       => x_SALES_LEAD_ID,
                X_SALES_LEAD_LINE_OUT_Tbl => x_SALES_LEAD_LINE_OUT_Tbl,
                X_Return_Status       => x_Return_Status,
                X_Msg_Count           => X_Msg_Count,
                X_Msg_Data            => X_Msg_Data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- OPEN C_Lines_Amounts (X_SALES_LEAD_ID);
      -- FETCH C_Lines_Amounts into l_lines_amount;
      -- CLOSE C_Lines_Amounts;

      -- IF l_SALES_LEAD_rec.BUDGET_AMOUNT <> l_lines_amount
      -- THEN
      --   AS_UTILITY_PVT.Set_Message(
      --       p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
      --       p_msg_name      => 'AS_BUDGET_AMOUNT_NOT_MATCH');
      --   RAISE FND_API.G_EXC_ERROR;
      -- END IF;

      -- Create sales lead contacts
      IF p_SALES_LEAD_CONTACT_tbl.COUNT >= 1 THEN
        -- Debug Message
        IF (AS_DEBUG_LOW_ON) THEN

        AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Calling Create_sales_lead_contacts');
        END IF;

        -- ffang020201, if sales lead isn't assigned, access record hasn't been
	   -- created. P_check_access_flag should pass 'N' to avoid checking
	   -- has_updateLeadAccess
        AS_SALES_LEAD_CONTACTS_PVT.Create_sales_lead_contacts(
                P_Api_Version_Number     => 2.0,
                P_Init_Msg_List          => FND_API.G_FALSE,
                P_Commit                 => FND_API.G_FALSE,
                p_validation_level       => P_Validation_Level,
                P_Check_Access_Flag      => 'N',
                -- P_Check_Access_Flag      => P_Check_Access_Flag,
                P_Admin_Flag             => P_Admin_Flag,
                P_Admin_Group_Id         => P_Admin_Group_Id,
                P_identity_salesforce_id => P_identity_salesforce_id,
                P_Sales_Lead_Profile_Tbl => P_Sales_Lead_Profile_Tbl,
                P_SALES_LEAD_CONTACT_Tbl => P_SALES_LEAD_CONTACT_Tbl,
                P_SALES_LEAD_ID          => l_SALES_LEAD_ID,
                X_SALES_LEAD_CNT_OUT_Tbl => x_SALES_LEAD_CNT_OUT_Tbl,
                X_Return_Status          => x_Return_Status,
                X_Msg_Count              => X_Msg_Count,
                X_Msg_Data               => X_Msg_Data );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Check_primary_contact');
      END IF;

      -- Check IF there is only one primary contact
      AS_SALES_LEAD_CONTACTS_PVT.Check_primary_contact (
         P_Api_Version_Number         => 2.0
        ,P_Init_Msg_List              => FND_API.G_FALSE
        ,P_Commit                     => FND_API.G_FALSE
        ,p_validation_level           => P_Validation_Level
        -- ,P_Check_Access_Flag           => P_Check_Access_Flag
        ,P_Check_Access_Flag          => 'N'
        ,P_Admin_Flag                 => P_Admin_Flag
        ,P_Admin_Group_Id             => P_Admin_Group_Id
        ,P_identity_salesforce_id     => P_identity_salesforce_id
        ,P_Sales_Lead_Profile_Tbl     => P_Sales_Lead_Profile_Tbl
        ,P_SALES_LEAD_ID              => l_SALES_LEAD_ID
        ,X_Return_Status              => x_Return_Status
        ,X_Msg_Count                  => X_Msg_Count
        ,X_Msg_Data                   => X_Msg_Data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- 11.5.10 ckapoor Rivendell lead name changes

      if ( l_sales_lead_rec.description is null OR l_sales_lead_rec.description=FND_API.G_MISS_CHAR) then

        IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'CK:Desc null');
        END IF;

       OPEN  C_get_primary_contact_name(l_sales_lead_id);
       FETCH C_get_primary_contact_name into l_default_lead_name;

       IF C_get_primary_contact_name%NOTFOUND THEN

       	OPEN C_get_customer_name(l_sales_lead_rec.customer_id) ;

       	FETCH C_get_customer_name into l_default_lead_name;

       	CLOSE C_get_customer_name;

       END IF;

       CLOSE C_get_primary_contact_name ;

         IF (AS_DEBUG_LOW_ON) THEN

             AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                          'CK:def name:'||l_default_lead_name);
      END IF;

      update as_sales_leads set description = l_default_lead_name where sales_lead_id =
      l_SALES_LEAD_ID;

      end if ;


      -- 11.5.10 ckapoor



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

END Create_sales_lead;


PROCEDURE Update_sales_lead(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    P_Validation_Level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_MISS_CHAR,
    P_Admin_Group_Id             IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Identity_Salesforce_Id     IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Sales_Lead_Profile_Tbl     IN   AS_UTILITY_PUB.Profile_Tbl_Type
                                       := AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    P_SALES_LEAD_Rec             IN   AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type,
    -- P_Calling_From_WF_Flag	 IN   VARCHAR2 := 'N',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
 IS
    Cursor C_Get_Access (X_Sales_Lead_Id NUMBER , c_salesforce_id NUMBER, c_sales_group_id NUMBER) IS
       Select
          access_id
         ,last_update_date
         ,last_updated_by
         ,creation_date
         ,created_by
         ,last_update_login
         ,freeze_flag
         ,reassign_flag
         ,team_leader_flag
         ,customer_id
         ,address_id
         ,salesforce_id
         ,person_id
         ,partner_customer_id
         ,partner_address_id
         ,created_person_id
         ,lead_id
         ,freeze_date
         ,reassign_reason
         ,downloadable_flag
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
         ,salesforce_role_code
         ,salesforce_relationship_code
         ,sales_group_id
 --      ,reassign_requested_person_id
 --      ,reassign_request_date
 --      ,internal_update_access
         ,sales_lead_id
       From as_accesses_all
       Where sales_lead_id = X_Sales_Lead_Id
       and   salesforce_id = c_salesforce_id
       and nvl(sales_group_id, -99) = nvl(c_sales_group_id, -99);

    Cursor C_Get_sales_leads(P_SALES_LEAD_ID Number) IS
       Select last_update_date,
         customer_id,
         assign_to_salesforce_id,
         assign_sales_group_id,
         assign_to_person_id,
         status_code,
         reject_reason_code,
         qualified_flag,
         lead_rank_id,
	referral_type,
        referred_by,
        referral_status,
        accept_flag,
        decision_timeframe_code,
        creation_date
       From  AS_SALES_LEADS
         Where SALES_LEAD_ID = p_Sales_Lead_ID
         For Update NOWAIT;
-- Denorm fix  2928041

     CURSOR C_Get_Status_open_flag(X_Lookup_Code VARCHAR2) IS
          SELECT opp_open_status_flag
          FROM  as_statuses_b
          WHERE lead_flag = 'Y' and enabled_flag = 'Y'
            and status_code = X_Lookup_Code;

    CURSOR C_Get_Lead_Rank_Score (X_Rank_ID  NUMBER) IS
          SELECT min_score
          FROM   as_sales_lead_ranks_b
          WHERE  rank_id = X_Rank_ID;

-- End denorm fix  2928041



    -- added for auto qualification of sales_lead
    -- changing query
    --CURSOR  C_PHONE_ID_Exists(c_sales_lead_id NUMBER) IS
    --   SELECT hz.contact_point_id
    --    FROM    AS_SALES_LEADS SL, HZ_CONTACT_POINTS HZ
    --    WHERE   hz.owner_table_id = sl.customer_id
    --            AND  hz.owner_table_name = 'HZ_PARTIES'
    --            AND  hz.contact_point_type = 'PHONE'
    --            AND  hz.primary_flag = 'Y'
    --            AND  sl.sales_lead_id = c_sales_lead_id;

    CURSOR  C_PHONE_ID_Exists(c_sales_lead_id NUMBER) IS
       SELECT phone_id
        FROM    AS_SALES_LEAD_CONTACTS
        WHERE   sales_lead_id = c_sales_lead_id;

     CURSOR  C_CONTACT_ROLE_Exists(c_sales_lead_id NUMBER) IS
       SELECT contact_role_code
        FROM    AS_SALES_LEAD_CONTACTS
        WHERE   sales_lead_id = c_sales_lead_id ;
    -- Cursor C_Get_Keep_Flag (c_sales_lead_id NUMBER) IS
    --     SELECT keep_flag
    --     FROM as_sales_leads
    --     WHERE sales_lead_id = c_sales_lead_id;

    -- ffang 121100, for bug 1504040, auto-qualification has nothing to do with
    -- keep_flag but previous status_code
    Cursor C_GET_STATUS_CODE (c_sales_lead_id NUMBER) IS
        SELECT status_code
        FROM as_sales_leads
        WHERE sales_lead_id = c_sales_lead_id;

    CURSOR c_get_person_id(x_resource_id NUMBER) IS
        SELECT source_id
        FROM   jtf_rs_resource_extns
        WHERE  category = 'EMPLOYEE'
               and resource_id = x_resource_id;

   CURSOR c_check_owner(c_sales_lead_id NUMBER , c_identity_salesforce_id NUMBER) IS
    select 'Y'
    from as_accesses_all a
    where a.sales_lead_id = c_sales_lead_id
      and   a.owner_flag = 'Y'
      and   a.salesforce_id = c_identity_salesforce_id;


-- Bug 3385646 - MKTU3R10:COUNTRY IS NOT POPULATED WHEN THE LEAD IS CREATED THROUGH HTML
    CURSOR c_get_country_code (X_CUSTOMER_ID NUMBER, X_ADDRESS_ID NUMBER) IS
          select LOC.COUNTRY
	  FROM HZ_PARTY_SITES SITE,HZ_LOCATIONS LOC
	  WHERE SITE.PARTY_ID = X_CUSTOMER_ID
	  AND SITE.PARTY_SITE_ID = X_ADDRESS_ID
	  AND SITE.STATUS IN ('A','I')
	  AND SITE.LOCATION_ID = LOC.LOCATION_ID;


   CURSOR c_check_salesteam(c_sales_lead_id NUMBER , c_salesforce_id NUMBER, c_sales_group_id NUMBER) IS
    select 'Y'
    from as_accesses_all a
    where a.sales_lead_id = c_sales_lead_id
      and   a.salesforce_id = c_salesforce_id
      and nvl(a.sales_group_id, -99) = nvl(c_sales_group_id,-99);


CURSOR C_timeframe_days (X_DECISION_TIMEFRAME_CODE VARCHAR2) IS
	SELECT timeframe_days
	FROM aml_sales_lead_timeframes
  where decision_timeframe_code = X_DECISION_TIMEFRAME_CODE and enabled_flag = 'Y';

    CURSOR C_get_last_system_rank (c_sales_lead_id NUMBER) IS
        SELECT lead_rank_id
        FROM as_sales_leads_log
        WHERE sales_lead_id = c_sales_lead_id
        AND   manual_rank_flag = 'N'
        ORDER BY log_id DESC;

    CURSOR C_get_rank_score (c_lead_rank_id NUMBER) IS
        SELECT min_score
        FROM as_sales_lead_ranks_b
        WHERE rank_id = c_lead_rank_id;

-- ckapoor 11.5.10 bug 3225643 cursor to find salesgroup id given the salesforce id

 CURSOR c_get_group_id (c_resource_id NUMBER, c_rs_group_member
VARCHAR2, c_sales VARCHAR2, c_telesales VARCHAR2,  c_fieldsales VARCHAR2, c_prm VARCHAR2, c_y
VARCHAR2)
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
      AND role.role_type_code in (c_sales, c_telesales, c_fieldsales,
c_prm) --'SALES','TELESALES','FIELDSALES','PRM')
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

-- end ckapoor


    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_sales_lead';
    l_api_version_number        CONSTANT NUMBER   := 2.0;
    -- Local Variables
    l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
    l_tar_SALES_LEAD_rec        AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                                := P_SALES_LEAD_Rec;
    l_rowid                     ROWID;
    l_Sales_Team_Rec            AS_ACCESS_PUB.Sales_Team_Rec_Type;
    l_access_profile_rec        AS_ACCESS_PUB.Access_Profile_Rec_Type;
    l_customer_id               NUMBER;
    l_last_update_date          DATE;
    l_assign_to_salesforce_id   NUMBER;
    l_assign_sales_group_id     NUMBER;
    l_assign_to_person_id 	NUMBER;
    l_Sales_Lead_Log_ID         NUMBER;
    l_access_id                 NUMBER;
    l_update_access_flag        VARCHAR2(1);
    l_member_role               VARCHAR2(5);
    l_member_access             VARCHAR2(5);
    l_isQualified               VARCHAR2(1);
    l_qualified                 VARCHAR2(30);
    l_auto_qualify_profile	VARCHAR2(1);
    l_phone_id                  NUMBER := NULL;
    l_contact_role              VARCHAR2(30);
    l_keep_flag                 VARCHAR2(1);
    l_status_code               VARCHAR2(30);
    l_old_status_code		VARCHAR2(30);
    l_qualified_flag		VARCHAR2(1);
    l_lead_rank_id		NUMBER;
    l_reject_reason_code	VARCHAR2(30);

    l_Return_Status             VARCHAR2(10) := FND_API.G_RET_STS_SUCCESS;
    l_Msg_Count                 NUMBER := 0;
    l_Msg_Data                  VARCHAR2(4000);
    l_check_owner		VARCHAR2(1);
    l_lead_owner_privilege VARCHAR2(1);
    l_check_salesteam  VARCHAR2(1);
    l_referral_type    VARCHAR2(30);
    l_referred_by      NUMBER;
    l_referral_status_profile VARCHAR2(30);
    l_current_ref_status VARCHAR2(30);
    l_log_status_code VARCHAR2(30);
    l_log_lead_rank_id NUMBER ;
    l_log_assign_to_sf_id  NUMBER;
    l_log_assign_sg_id NUMBER;
    l_log_assign_to_person_id NUMBER;
    l_log_reject_reason_code VARCHAR2(30);
    l_log_qualified VARCHAR2(1);
    l_accept_flag VARCHAR2(1);
    l_decision_timeframe_code VARCHAR2(30);
    l_timeframe_code VARCHAR2(30);

    l_creation_date       DATE;
    l_exp_date            DATE;
    l_timeframe_days      NUMBER;

    -- SOLIN
    l_manual_rank_flag    VARCHAR2(1);
    l_lead_rank_ind       VARCHAR2(1);
    l_last_system_rank_id NUMBER;
    l_current_score       NUMBER;
    l_last_score          NUMBER;
    -- SOLIN end

    l_old_status_flag VARCHAR2(1);
    l_new_status_flag VARCHAR2(1);
    l_old_lead_rank_score NUMBER;
    l_new_lead_rank_score NUMBER;


    -- ckapoor 11.5.10
    l_login_user_sg_id NUMBER;
    l_login_user_in_st VARCHAR2(1);
    l_login_salesteam_rec  AS_ACCESS_PUB.Sales_Team_Rec_Type;
    l_login_access_id NUMBER;
    l_login_user_person_id NUMBER;


    -- end ckapoor

    --l_country_code		VARCHAR2(60);
    l_country_code		VARCHAR2(60) := FND_API.G_MISS_CHAR; --Default value added by bmuthukr for bug 3675566


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SALES_LEAD_PVT;

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
                                   'PVT: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IF (p_validation_level = fnd_api.g_valid_level_full)
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

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Open Cursor C_Get_sales_leads');
      END IF;

      Open C_Get_sales_leads( l_tar_SALES_LEAD_rec.SALES_LEAD_ID);

      Fetch C_Get_sales_leads into l_last_update_date,
                                   l_customer_id,
                                   l_assign_to_salesforce_id,
                                   l_assign_sales_group_id,
                                   l_assign_to_person_id,
                                   l_old_status_code,
                                   l_reject_reason_code,
                                   l_qualified_flag,
                                   l_lead_rank_id,
				   l_referral_type,
				   l_referred_by,
				   l_current_ref_status,
                   l_accept_flag,
                   l_decision_timeframe_code,
                   l_creation_date;

      IF ( C_Get_sales_leads%NOTFOUND) THEN
           Close C_Get_sales_leads;

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'SALES_LEAD', FALSE);
               FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                'Close Cursor C_Get_sales_leads');
      END IF;
      Close C_Get_sales_leads;

      -- Check Whether record has been changed by someone else
      IF (l_tar_SALES_LEAD_rec.last_update_date is NULL or
          l_tar_SALES_LEAD_rec.last_update_date = FND_API.G_MISS_Date )
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
               FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
               FND_MESSAGE.Set_Token('COLUMN', 'LAST_UPDATE_DATE', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;

      IF (l_tar_SALES_LEAD_rec.last_update_date <> l_last_update_date)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              FND_MESSAGE.Set_Token('INFO', 'SALES_LEAD', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Bug 1514981
      -- Set default value to accept_flag, keep_flag, urgent_flag,
      -- import_flag, deleted_flag, and currency_code as profile values.
      If (l_tar_SALES_LEAD_rec.ACCEPT_FLAG IS NULL) or
         (l_tar_SALES_LEAD_rec.KEEP_FLAG IS NULL) or
         (l_tar_SALES_LEAD_rec.URGENT_FLAG IS NULL) or
         (l_tar_SALES_LEAD_rec.IMPORT_FLAG IS NULL) or
         (l_tar_SALES_LEAD_rec.DELETED_FLAG IS NULL) or
         (l_tar_SALES_LEAD_rec.currency_code IS NULL)or
	 (l_tar_SALES_LEAD_rec.lead_rank_ind is NULL)
      THEN
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Set_default_values');
          END IF;

          Set_default_values(
                p_mode               => AS_UTILITY_PVT.G_UPDATE,
                px_SALES_LEAD_rec    => l_tar_SALES_LEAD_Rec);

      End If;

      -- Debug message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Validate_sales_lead');
      END IF;

      -- Invoke validation procedures
      Validate_sales_lead(
              p_init_msg_list    => FND_API.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
              P_SALES_LEAD_Rec   => l_tar_SALES_LEAD_Rec,
	      p_referral_type    => l_referral_type,
	      p_referred_by     =>  l_referred_by,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


          -- Call Get_Access_Profiles to get access_profile_rec
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Get_Access_Profiles');
          END IF;

          AS_SALES_LEADS_PUB.Get_Access_Profiles(
              p_profile_tbl         => p_sales_lead_profile_tbl,
              x_access_profile_rec  => l_access_profile_rec);



      IF(P_Check_Access_Flag = 'Y') THEN

          IF (AS_DEBUG_LOW_ON) THEN



          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_updateLeadAccess');

          END IF;

          AS_ACCESS_PUB.Has_updateLeadAccess(
              p_api_version_number     => 2.0
             ,p_init_msg_list          => FND_API.G_FALSE
             ,p_validation_level       => p_validation_level
             ,p_access_profile_rec     => l_access_profile_rec
             ,p_admin_flag             => p_admin_flag
             ,p_admin_group_id         => p_admin_group_id
             ,p_person_id              =>
                              l_identity_sales_member_rec.employee_person_id
             ,p_sales_lead_id          => p_sales_lead_rec.sales_lead_id
              -- ffang 012501, p_check_access_flag should always be 'Y'
             ,p_check_access_flag      => p_check_access_flag    -- 'Y'
             ,p_identity_salesforce_id => p_identity_salesforce_id
                ,p_partner_cont_party_id  => NULL
             ,x_return_status          => x_return_status
             ,x_msg_count              => x_msg_count
             ,x_msg_data               => x_msg_data
             ,x_update_access_flag     => l_update_access_flag);

          IF l_update_access_flag <> 'Y' THEN
              IF (AS_DEBUG_ERROR_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_UPDATE_PRIVILEGE');
              END IF;
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              RAISE FND_API.G_EXC_ERROR;
          END IF;



      END IF; -- end of P_Check_Access = 'Y'


      -- moving check owner code outside p_check_access loop. OTS does not pass p_check_access as 'Y'
      -- but they still need check owner code to be called. OTS calls update lead access code themselves.

      -- check for whether the current user is owner or not

      -- in the pre 11.5.8 scenario, all leads had to have an owner. Now it might happen that
      -- a lead has no owner. The creator will be on salesteam so he should be able to update the lead
      -- based on access. We can skip the change owner access check in that case.


    if (l_assign_to_salesforce_id is not null)
    then


      l_check_owner := 'N';
      --Open c_check_owner(p_sales_lead_rec.sales_lead_id, p_identity_salesforce_id );

	  --Fetch c_check_owner into l_check_owner;
	  --Close c_check_owner;
	  IF (AS_DEBUG_LOW_ON) THEN

	  AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Has_leadOwnerAccess');
	  END IF;
	  AS_ACCESS_PVT.has_leadOwnerAccess(
	  		       p_api_version_number     => 2.0
	               ,p_init_msg_list          => FND_API.G_FALSE
	               ,p_validation_level       => p_validation_level
	               ,p_access_profile_rec     => l_access_profile_rec
	               ,p_admin_flag             => p_admin_flag
	               ,p_admin_group_id         => p_admin_group_id
	               ,p_person_id              =>
	                                l_identity_sales_member_rec.employee_person_id
	               ,p_sales_lead_id          => p_sales_lead_rec.sales_lead_id
	                -- ffang 012501, p_check_access_flag should always be 'Y'
	               ,p_check_access_flag      => p_check_access_flag    -- 'Y'
	               ,p_identity_salesforce_id => p_identity_salesforce_id
	               ,p_partner_cont_party_id  => NULL
	               ,x_return_status          => x_return_status
	               ,x_msg_count              => x_msg_count
	               ,x_msg_data               => x_msg_data
             	       ,x_update_access_flag     => l_check_owner);


          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

              RAISE FND_API.G_EXC_ERROR;
          END IF;




       l_lead_owner_privilege := fnd_profile.value('AS_ALLOW_CHANGE_LEAD_OWNER');
	  IF l_check_owner <> 'Y'
	     AND ((l_assign_to_salesforce_id <> p_sales_lead_rec.assign_to_salesforce_id) OR
               (p_sales_lead_rec.assign_to_salesforce_id is null))
         AND l_lead_owner_privilege <> 'Y'  -- exception made, even if not owner but if profile is set then lets you
                                            -- change owner. Update access checking in security API
            THEN
	  	IF (AS_DEBUG_ERROR_ON) THEN

	  	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_LEAD_UPDATE_PRIVILEGE');
	  	END IF;
	  	RAISE FND_API.G_EXC_ERROR;
	  END IF;

      end if; -- if current owner is not null

      -- else if current owner is null, u can skip the owner check

      -- if user is declining , then if not owner AND profile not set then throw error
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'l_check_owner is'|| l_check_owner);
    END IF;

     IF (AS_DEBUG_LOW_ON) THEN



     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'l_lead_owner_privilege is'|| l_lead_owner_privilege);

     END IF;


      IF (l_tar_SALES_LEAD_Rec.reject_reason_code is not null AND l_tar_SALES_LEAD_Rec.reject_reason_code <> FND_API.G_MISS_CHAR)
         AND l_check_owner <> 'Y'
	     AND l_lead_owner_privilege <> 'Y'  -- exception made, even if not owner but if profile is set then lets you
                                            -- change owner. Update access checking in security API
        THEN
	  	IF (AS_DEBUG_ERROR_ON) THEN

	  	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_DECLINE_PRIVILEGE');
	  	END IF;
	  	RAISE FND_API.G_EXC_ERROR;
	  END IF;


     IF (l_tar_SALES_LEAD_Rec.accept_flag <> l_accept_flag) AND (l_tar_SALES_LEAD_rec.accept_flag <> FND_API.G_MISS_CHAR)
         AND l_check_owner <> 'Y'
	     AND l_lead_owner_privilege <> 'Y'  -- exception made, even if not owner but if profile is set then lets you
                                            -- change owner. Update access checking in security API
        THEN
	  	IF (AS_DEBUG_ERROR_ON) THEN

	  	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_ACCEPT_PRIVILEGE');
	  	END IF;
	  	RAISE FND_API.G_EXC_ERROR;
	  END IF;


      -- auto qualify lead

      -- ffang 121100, for bug 1504040
      -- when original stauts_code is 'NEW' or 'UNQUALIFIED' and UI didn't
      -- pass in any status_code, then launch auto-qulification.

      -- ffang 100200: for bug 1416170
      -- Do auto-qualify only when keep_flag <> 'Y' or keep_flag is NULL

      -- IF (P_SALES_LEAD_Rec.keep_flag = FND_API.G_MISS_CHAR)
      -- THEN
      --     OPEN C_Get_Keep_Flag (P_SALES_LEAD_Rec.sales_lead_id);
      --     FETCH C_Get_Keep_Flag into l_keep_flag;
      --     CLOSE C_Get_Keep_Flag;
      -- ELSE
      --     l_keep_flag := P_SALES_LEAD_Rec.keep_flag;
      -- END IF;

      -- IF ((l_keep_flag <> 'Y') or (l_keep_flag is NULL))
         -- 111900 FFANG for bug 1475568, if status is changed to 'DECLINED',
         -- don't do auto-qualify
      --    and (P_SALES_LEAD_Rec.status_code <> 'DECLINED')

      OPEN C_GET_STATUS_CODE (P_SALES_LEAD_Rec.sales_lead_id);
      FETCH C_GET_STATUS_CODE INTO l_status_code;
      CLOSE C_GET_STATUS_CODE;


/*      l_auto_qualify_profile :=  nvl(FND_PROFILE.Value('AS_AUTO_QUALIFY'),'N');

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'l_auto_qualify_profile is '|| l_auto_qualify_profile);

      END IF;

      IF(P_SALES_LEAD_Rec.qualified_flag = 'N' and
      		l_auto_qualify_profile = 'Y')
      --IF (l_status_code = 'NEW' or l_status_code = 'UNQUALIFIED')
      --   and (P_SALES_LEAD_Rec.status_code is null
      --        or P_SALES_LEAD_Rec.status_code = FND_API.G_MISS_CHAR)
      THEN
          -- Launch auto-qualification
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Launch auto-qualification');
          END IF;

          OPEN  C_PHONE_ID_Exists (P_SALES_LEAD_Rec.sales_lead_id);
          FETCH C_PHONE_ID_Exists into l_phone_id;

          -- ffang 092800: Forgot to close cursor?
          CLOSE C_PHONE_ID_Exists;
          -- end ffang 092800

          OPEN  C_CONTACT_ROLE_Exists (P_SALES_LEAD_Rec.sales_lead_id);
          FETCH C_CONTACT_ROLE_Exists into l_contact_role;

          -- ffang 092800: Forgot to close cursor?
          CLOSE C_CONTACT_ROLE_Exists;


          l_isQualified := IS_LEAD_QUALIFIED(P_SALES_LEAD_Rec, l_phone_id, l_contact_role);

          -- compute the qualified flag and assign to l_qualified
          --if l_isQualified = 'Y' then
          --    l_qualified := 'QUALIFIED';
          --else
          --    -- l_qualified := p_sales_lead_rec.STATUS_CODE;
          --     l_qualified := 'UNQUALIFIED';
          --end if;
          l_qualified := l_isQualified;
      ELSE
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Doing manual qualification');
          END IF;


          -- now status code independent of qualified flag
          --l_qualified := p_sales_lead_rec.STATUS_CODE;
          l_qualified := p_sales_lead_rec.QUALIFIED_FLAG;
      END IF;*/
      -- end ffang 100200

      l_qualified := p_sales_lead_rec.QUALIFIED_FLAG;

      OPEN c_get_person_id(l_tar_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID);
      FETCH c_get_person_id INTO l_tar_SALES_LEAD_rec.ASSIGN_TO_PERSON_ID;
      CLOSE c_get_person_id;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Sales_Lead_Update_Row');
      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'p_sf_id:'||p_sales_lead_rec.assign_to_salesforce_id);

      END IF;
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'sf_id:'||l_tar_SALES_LEAD_rec.assign_to_salesforce_id);
      END IF;


	-- if decline reason code is not null i.e user is declining lead
	-- then clear accept flag and make sure assign to doesnt get changed
	-- even if user has changed it while declining

	if l_tar_SALES_LEAD_rec.REJECT_REASON_CODE IS NOT NULL AND
	   l_tar_SALES_LEAD_rec.REJECT_REASON_CODE <> FND_API.G_MISS_CHAR
	THEN
	      l_tar_SALES_LEAD_rec.accept_flag := 'N';

	      IF (l_assign_to_salesforce_id IS NOT NULL AND
	         l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
	                                                  FND_API.G_MISS_NUM AND
	         l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
                                                  l_assign_to_salesforce_id)
                 OR
		 (l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NULL)

	      THEN
	      	l_tar_SALES_LEAD_rec.assign_to_salesforce_id := l_assign_to_salesforce_id;
	      	l_tar_SALES_LEAD_rec.assign_to_person_id := l_assign_to_person_id;
	      	l_tar_SALES_LEAD_rec.assign_sales_group_id := l_assign_sales_group_id;
          END IF;

	END IF;

	-- this code is ok since noone else modifies assign_date
	 l_tar_SALES_LEAD_rec.assign_date := FND_API.G_MISS_DATE;

      -- If assign_to_salesforce_id is being set to someone else (manual routing)
      -- then, the status should be set from profile and accept_flag = 'N'

       IF l_assign_to_salesforce_id IS NOT NULL AND
          l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NOT NULL AND
          l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
                                                  FND_API.G_MISS_NUM AND
          l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
                                                  l_assign_to_salesforce_id
       THEN

            -- as per bug 2238553 routing shud not change status of lead hence commenting out the next line.
            --l_tar_SALES_LEAD_rec.status_code := fnd_profile.value('AS_LEAD_ROUTING_STATUS');
            l_tar_SALES_LEAD_rec.accept_flag := 'N';
            l_tar_SALES_LEAD_rec.assign_date := SYSDATE;

       END IF;

      -- do check on referral type. If a non null referral type is being passed in,
      -- then make sure referral status is set to the profile of REF_STATUS_FOR_NEW_LEAD

      l_referral_status_profile := l_tar_SALES_LEAD_rec.REFERRAL_STATUS;

      if (l_tar_SALES_LEAD_rec.REFERRAL_STATUS is null or l_tar_SALES_LEAD_rec.REFERRAL_STATUS = FND_API.G_MISS_CHAR)
      then
        if (l_tar_SALES_LEAD_rec.REFERRAL_TYPE is not null and l_tar_sales_lead_rec.REFERRAL_TYPE <> FND_API.G_MISS_CHAR)
        -- if referral type lead and the current referral status in database is null then need to do something.
        then
            if (l_current_ref_status is null) then
                l_referral_status_profile :=  FND_PROFILE.Value('REF_STATUS_FOR_NEW_LEAD');
            else
                l_referral_status_profile := FND_API.G_MISS_CHAR; -- you dont want to change the non null referral status
            end if ;  -- if l_current_ref_status is null
        end if; -- if  a referral type lead
      end if; -- if incoming referral status is null/G_MISS


      --bmuthukr modified the following code to fix bug 3675566.
      /*IF (l_tar_SALES_LEAD_rec.address_id is not NULL) and
      (l_tar_SALES_LEAD_rec.address_id <> FND_API.G_MISS_NUM)
      THEN
		OPEN  c_get_country_code ( l_customer_id, l_tar_SALES_LEAD_rec.address_id);
		FETCH c_get_country_code into l_country_code;
		Close c_get_country_code;
      ELSE
      l_country_code := null;
      END If;*/
      IF (nvl(l_tar_SALES_LEAD_rec.address_id,0) <> FND_API.G_MISS_NUM) THEN
         IF (l_tar_SALES_LEAD_rec.address_id is not NULL) THEN
		OPEN  c_get_country_code ( l_customer_id, l_tar_SALES_LEAD_rec.address_id);
		FETCH c_get_country_code into l_country_code;
		Close c_get_country_code;
         ELSE
                l_country_code := null;
         END If;
      END IF;
      --Ends changes for bug 3675566

      -- Moving code here, since we need common code for logging into  as_sales_leads (status_open_flag
      -- and lead_rank_score)

      --Denorm fix 04/30/03 ckapoor
      --Get the open status flag for both old status and new status

      OPEN  C_Get_Status_open_flag ( l_old_status_code);
      FETCH C_Get_Status_open_flag into l_old_status_flag;
      Close C_Get_Status_open_flag;

      -- by default the new status flag shud be same as old status flag

      l_new_status_flag := l_old_status_flag;

      -- if status is null (shud not happen since status is non null alwiz), we
      -- dont want to fix the status flag
      -- if status is g_miss , means anyways the status is not changing so flag is not changing.

     if (l_tar_sales_lead_rec.STATUS_CODE IS NOT NULL AND l_tar_sales_lead_rec.STATUS_CODE <> FND_API.G_MISS_CHAR ) THEN

     OPEN  C_Get_Status_open_flag ( l_tar_SALES_LEAD_rec.STATUS_CODE);
     FETCH C_Get_Status_open_flag into l_new_status_flag;
     Close C_Get_Status_open_flag;

     END IF;


     -- We can simply log the l_new_status_flag into the STATUS_OPEN_FLAG field.
     -- These values l_new/old_status_open_flag will be used later in API to update AS_ACCESSES_ALL


     -- Update lead_rank_score as well.


     OPEN  C_Get_Lead_Rank_Score ( l_lead_rank_id);
     FETCH C_Get_Lead_Rank_Score into l_old_lead_rank_score;
     Close C_Get_Lead_Rank_Score;

     -- by default the new score is g_miss i.e do not change the old score in db.

     l_new_lead_rank_score := FND_API.G_MISS_NUM;

     -- if new rank is null, we  want to fix the score since old might have been non null.
     -- if new rank is g_miss , means anyways the rank is not changing so score is not changing.

     if ( l_tar_sales_lead_rec.LEAD_RANK_ID <> FND_API.G_MISS_NUM ) THEN

     	OPEN  C_Get_Lead_Rank_Score ( l_tar_SALES_LEAD_rec.LEAD_RANK_ID);
        FETCH C_Get_Lead_Rank_Score into l_new_lead_rank_score;
        Close C_Get_Lead_Rank_Score;

        END IF;

     IF (AS_DEBUG_LOW_ON) THEN

	     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                       'lead_rank_score : ' || l_new_lead_rank_score);
     END IF;

     -- if new rank score is null, make it 0
    if ( l_tar_sales_lead_rec.lead_rank_id is NULL) then
	   l_new_lead_rank_score := 0;
    end if;
    -- We can simply log the l_new_lead_rank_score into the LEAD_RANK_SCORE field.

  -- End Denorm fix.






      IF (AS_DEBUG_LOW_ON) THEN


      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Just before AS_SALES_LEADS_PKG.Sales_Lead_Update_Row');


      END IF;


-- what should the new expiration date be.

	if (l_tar_sales_lead_rec.DECISION_TIMEFRAME_CODE = FND_API.G_MISS_CHAR) then
		l_timeframe_code := l_decision_timeframe_code; -- same as the db value
	else
		l_timeframe_code := l_tar_sales_lead_rec.DECISION_TIMEFRAME_CODE; -- same as the target value

	end if;

	 -- expiration date is calculated as creation_date + time frame days (for a smart timeframe)
	     -- if no smart timeframe, then exp date is null.

	     l_exp_date := null;
	     l_timeframe_days := 0;


	      OPEN  C_timeframe_days (l_timeframe_code);
	      FETCH C_timeframe_days into l_timeframe_days;

	      IF C_timeframe_days%NOTFOUND
	      THEN
	       	l_exp_date := null;

	      ELSE
	      	l_exp_date := l_creation_date + l_timeframe_days;
	      END IF;


      CLOSE C_timeframe_days ;

      -- SOLIN, 12/17/2002, populate column lead_rank_ind
      -- 'U': lead is upgraded.
      -- 'D': lead is downgraded.
      -- 'N': none of above.
      IF l_tar_sales_lead_rec.lead_rank_id <> l_lead_rank_id AND
         l_tar_sales_lead_rec.lead_rank_id <> FND_API.G_MISS_NUM
      THEN
          l_manual_rank_flag := 'Y';
          OPEN C_get_last_system_rank(l_tar_SALES_LEAD_rec.SALES_LEAD_ID);
          FETCH C_get_last_system_rank INTO l_last_system_rank_id;
          CLOSE C_get_last_system_rank;

          OPEN c_get_rank_score(l_tar_sales_lead_rec.lead_rank_id);
          FETCH c_get_rank_score INTO l_current_score;
          CLOSE c_get_rank_score;

          OPEN c_get_rank_score(l_last_system_rank_id);
          FETCH c_get_rank_score INTO l_last_score;
          CLOSE c_get_rank_score;

          IF (AS_DEBUG_LOW_ON) THEN
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'current_score=' || l_current_score);
              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'last_score=' || l_last_score);
          END IF;
          IF l_current_score > l_last_score
          THEN
              l_lead_rank_ind := 'U';
          ELSIF l_current_score < l_last_score
          THEN
              l_lead_rank_ind := 'D';
          ELSE
              l_lead_rank_ind := 'N';
          END IF;
      ELSE
          --l_lead_rank_ind := FND_API.G_MISS_CHAR;
          l_lead_rank_ind := l_tar_SALES_LEAD_rec.LEAD_RANK_IND;
      END IF;
      -- SOLIN, end

      -- Invoke table handler(Sales_Lead_Update_Row)
      AS_SALES_LEADS_PKG.Sales_Lead_Update_Row(
           p_SALES_LEAD_ID  => l_tar_SALES_LEAD_rec.SALES_LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => l_tar_SALES_LEAD_rec.CREATION_DATE,
          p_CREATED_BY  => l_tar_SALES_LEAD_rec.CREATED_BY,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => FND_GLOBAL.Conc_Request_Id,
          p_PROGRAM_APPLICATION_ID  => FND_GLOBAL.Prog_Appl_Id,
          p_PROGRAM_ID  => FND_GLOBAL.Conc_Program_Id,
          p_PROGRAM_UPDATE_DATE  => SYSDATE,
          p_LEAD_NUMBER  => l_tar_SALES_LEAD_rec.LEAD_NUMBER,
          --p_STATUS_CODE  => l_qualified,
          p_STATUS_CODE => l_tar_SALES_LEAD_rec.STATUS_CODE,
          p_CUSTOMER_ID  => l_tar_SALES_LEAD_rec.CUSTOMER_ID,
          p_ADDRESS_ID  => l_tar_SALES_LEAD_rec.ADDRESS_ID,
          p_SOURCE_PROMOTION_ID  => l_tar_SALES_LEAD_rec.SOURCE_PROMOTION_ID,
          p_INITIATING_CONTACT_ID => l_tar_SALES_LEAD_rec.INITIATING_CONTACT_ID,
          p_ORIG_SYSTEM_REFERENCE => l_tar_SALES_LEAD_rec.ORIG_SYSTEM_REFERENCE,
          p_CONTACT_ROLE_CODE  => l_tar_SALES_LEAD_rec.CONTACT_ROLE_CODE,
          p_CHANNEL_CODE  => l_tar_SALES_LEAD_rec.CHANNEL_CODE,
          p_BUDGET_AMOUNT  => l_tar_SALES_LEAD_rec.BUDGET_AMOUNT,
          p_CURRENCY_CODE  => l_tar_SALES_LEAD_rec.CURRENCY_CODE,
          p_DECISION_TIMEFRAME_CODE =>
                              l_tar_SALES_LEAD_rec.DECISION_TIMEFRAME_CODE,
          p_CLOSE_REASON  => l_tar_SALES_LEAD_rec.CLOSE_REASON,
          p_LEAD_RANK_ID  => l_tar_SALES_LEAD_rec.LEAD_RANK_ID,
          p_LEAD_RANK_CODE  => l_tar_SALES_LEAD_rec.LEAD_RANK_CODE,
          p_PARENT_PROJECT  => l_tar_SALES_LEAD_rec.PARENT_PROJECT,
          p_DESCRIPTION  => l_tar_SALES_LEAD_rec.DESCRIPTION,
          p_ATTRIBUTE_CATEGORY  => l_tar_SALES_LEAD_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_tar_SALES_LEAD_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_tar_SALES_LEAD_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_tar_SALES_LEAD_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_tar_SALES_LEAD_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_tar_SALES_LEAD_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_tar_SALES_LEAD_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_tar_SALES_LEAD_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_tar_SALES_LEAD_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_tar_SALES_LEAD_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_tar_SALES_LEAD_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_tar_SALES_LEAD_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_tar_SALES_LEAD_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_tar_SALES_LEAD_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_tar_SALES_LEAD_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_tar_SALES_LEAD_rec.ATTRIBUTE15,
          p_ASSIGN_TO_PERSON_ID  => l_tar_SALES_LEAD_rec.ASSIGN_TO_PERSON_ID,
          p_ASSIGN_TO_SALESFORCE_ID =>
                                   l_tar_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID,
          p_ASSIGN_SALES_GROUP_ID => l_tar_SALES_LEAD_rec.ASSIGN_SALES_GROUP_ID,
          --p_ASSIGN_DATE  => l_tar_SALES_LEAD_rec.ASSIGN_DATE,
          p_ASSIGN_DATE  => l_tar_SALES_LEAD_rec.ASSIGN_DATE,--SYSDATE
          p_BUDGET_STATUS_CODE  => l_tar_SALES_LEAD_rec.BUDGET_STATUS_CODE,
          p_ACCEPT_FLAG  => NVL(l_tar_SALES_LEAD_rec.ACCEPT_FLAG, 'N'),
          p_VEHICLE_RESPONSE_CODE => l_tar_SALES_LEAD_rec.VEHICLE_RESPONSE_CODE,
          p_TOTAL_SCORE  => l_tar_SALES_LEAD_rec.TOTAL_SCORE,
          p_SCORECARD_ID  => l_tar_SALES_LEAD_rec.SCORECARD_ID,
          p_KEEP_FLAG  => NVL(l_tar_SALES_LEAD_rec.KEEP_FLAG, 'N'),
          p_URGENT_FLAG  => NVL(l_tar_SALES_LEAD_rec.URGENT_FLAG, 'N'),
          p_IMPORT_FLAG  => NVL(l_tar_SALES_LEAD_rec.IMPORT_FLAG, 'N'),
          p_REJECT_REASON_CODE  => l_tar_SALES_LEAD_rec.REJECT_REASON_CODE,
          p_DELETED_FLAG => NVL(l_tar_SALES_LEAD_rec.DELETED_FLAG, 'N'),
          p_OFFER_ID  =>  p_SALES_LEAD_rec.OFFER_ID,
          --p_QUALIFIED_FLAG => p_SALES_LEAD_rec.QUALIFIED_FLAG,
          p_QUALIFIED_FLAG => l_qualified,
          p_ORIG_SYSTEM_CODE => p_SALES_LEAD_rec.ORIG_SYSTEM_CODE,
          -- p_SECURITY_GROUP_ID    => p_SALES_LEAD_rec.SECURITY_GROUP_ID,
          p_INC_PARTNER_PARTY_ID => p_SALES_LEAD_rec.INCUMBENT_PARTNER_PARTY_ID,
          p_INC_PARTNER_RESOURCE_ID =>
                                 p_SALES_LEAD_rec.INCUMBENT_PARTNER_RESOURCE_ID,
          p_PRM_EXEC_SPONSOR_FLAG   => p_SALES_LEAD_rec.PRM_EXEC_SPONSOR_FLAG,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG =>
                                 p_SALES_LEAD_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
          p_PRM_SALES_LEAD_TYPE     => p_SALES_LEAD_rec.PRM_SALES_LEAD_TYPE,
          p_PRM_IND_CLASSIFICATION_CODE =>
                                 p_SALES_LEAD_rec.PRM_IND_CLASSIFICATION_CODE,
	  p_PRM_ASSIGNMENT_TYPE => p_SALES_LEAD_rec.PRM_ASSIGNMENT_TYPE,
	  p_AUTO_ASSIGNMENT_TYPE => p_SALES_LEAD_rec.AUTO_ASSIGNMENT_TYPE,
	  p_PRIMARY_CONTACT_PARTY_ID => p_SALES_LEAD_rec.PRIMARY_CONTACT_PARTY_ID,
	  p_PRIMARY_CNT_PERSON_PARTY_ID => p_SALES_LEAD_rec.PRIMARY_CNT_PERSON_PARTY_ID,
	  p_PRIMARY_CONTACT_PHONE_ID => p_SALES_LEAD_rec.PRIMARY_CONTACT_PHONE_ID,

	  -- new columns for CAPRI lead referral
	  p_REFERRED_BY => p_SALES_LEAD_rec.REFERRED_BY,
	  p_REFERRAL_TYPE => p_SALES_LEAD_rec.REFERRAL_TYPE,
	  p_REFERRAL_STATUS => l_referral_status_profile,
	  p_REF_DECLINE_REASON => p_SALES_LEAD_rec.REF_DECLINE_REASON,
	  p_REF_COMM_LTR_STATUS => p_SALES_LEAD_rec.REF_COMM_LTR_STATUS,
	  p_REF_ORDER_NUMBER => p_SALES_LEAD_rec.REF_ORDER_NUMBER,
	  p_REF_ORDER_AMT => p_SALES_LEAD_rec.REF_ORDER_AMT,
	  p_REF_COMM_AMT => p_SALES_LEAD_rec.REF_COMM_AMT,

	  p_LEAD_DATE => p_SALES_LEAD_rec.LEAD_DATE,
	  p_SOURCE_SYSTEM => p_SALES_LEAD_rec.SOURCE_SYSTEM,
	  p_COUNTRY => l_country_code,

	  p_TOTAL_AMOUNT => p_SALES_LEAD_rec.TOTAL_AMOUNT,
	  p_EXPIRATION_DATE => l_exp_date, -- p_SALES_LEAD_rec.EXPIRATION_DATE,
	  p_LEAD_RANK_IND =>  l_lead_rank_ind,
	  p_LEAD_ENGINE_RUN_DATE => FND_API.G_MISS_DATE, --p_SALES_LEAD_rec.LEAD_ENGINE_RUN_DATE,
	  p_CURRENT_REROUTES => p_SALES_LEAD_rec.CURRENT_REROUTES

           -- new columns for appsperf CRMAP denorm project bug 2928041

          ,p_STATUS_OPEN_FLAG =>   l_new_status_flag
          			--FND_API.G_MISS_CHAR
          ,p_LEAD_RANK_SCORE =>  l_new_lead_rank_score
          			--FND_API.G_MISS_NUM

          -- ckapoor 11.5.10 New columns

	  	  , p_MARKETING_SCORE	=> l_tar_SALES_LEAD_rec.MARKETING_SCORE
	  	, p_INTERACTION_SCORE	=> l_tar_SALES_LEAD_rec.INTERACTION_SCORE
	  	, p_SOURCE_PRIMARY_REFERENCE	=> l_tar_SALES_LEAD_rec.SOURCE_PRIMARY_REFERENCE
	  	, p_SOURCE_SECONDARY_REFERENCE	=> l_tar_SALES_LEAD_rec.SOURCE_SECONDARY_REFERENCE
	  	, p_SALES_METHODOLOGY_ID	=> l_tar_SALES_LEAD_rec.SALES_METHODOLOGY_ID
	  	, p_SALES_STAGE_ID		=> l_tar_SALES_LEAD_rec.SALES_STAGE_ID




      );

/*
      -- Workflow will call update_sales_lead, if we kick-off workflow within
	 -- update_sales_lead, it will cause infinite recursive calls

      -- Kick off Lead Assignment Workflow
      CALL_WF_TO_ASSIGN (
         P_Api_Version_Number   => 2.0,
         P_Init_Msg_List        => FND_API.G_FALSE,
         P_Sales_Lead_Id        => l_tar_SALES_LEAD_rec.SALES_LEAD_ID,
         P_assigned_resource_id => l_tar_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID,
         X_Return_Status        => l_Return_Status,
         X_Msg_Count            => l_Msg_Count,
         X_Msg_Data             => l_Msg_Data
          );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF (AS_DEBUG_ERROR_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                                       'AS_LEAD_ASSIGN_FAIL');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/






  /*  IF   ((l_tar_sales_lead_rec.status_code<> FND_API.G_MISS_CHAR) AND (l_tar_sales_lead_rec.status_code <> l_old_status_code)) OR
          ((l_tar_sales_lead_rec.assign_to_salesforce_id <> FND_API.G_MISS_NUM) AND (l_tar_sales_lead_rec.assign_to_salesforce_id <> l_assign_to_salesforce_id)) OR
          ((l_tar_sales_lead_rec.assign_sales_group_id <> FND_API.G_MISS_NUM) AND (l_tar_sales_lead_rec.assign_sales_group_id <> l_assign_sales_group_id)) OR
          ((l_tar_sales_lead_rec.assign_to_person_id <> FND_API.G_MISS_NUM) AND (l_tar_sales_lead_rec.assign_to_person_id <> l_assign_to_person_id)) OR
          ((l_tar_sales_lead_rec.lead_rank_id <> FND_API.G_MISS_NUM) AND (l_tar_sales_lead_rec.lead_rank_id <> l_lead_rank_id)) OR
          ((l_tar_sales_lead_rec.qualified_flag <> FND_API.G_MISS_CHAR) AND (l_tar_sales_lead_rec.qualified_flag <> l_qualified_flag))
*/

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Just after AS_SALES_LEADS_PKG.Sales_Lead_Update_Row');

      END IF;


l_log_status_code := l_tar_sales_lead_rec.status_code;
l_log_assign_to_sf_id := l_tar_sales_lead_rec.assign_to_salesforce_id;
l_log_assign_sg_id := l_tar_sales_lead_rec.assign_sales_group_id;
l_log_assign_to_person_id := l_tar_sales_lead_rec.assign_to_person_id;
l_log_lead_rank_id := l_tar_sales_lead_rec.lead_rank_id;
l_log_reject_reason_code := l_tar_sales_lead_rec.reject_reason_code;
l_log_qualified := l_qualified;



/*IF   (
      (
          (l_tar_sales_lead_rec.status_code <> FND_API.G_MISS_CHAR)
       OR (l_tar_sales_lead_rec.assign_to_salesforce_id <> FND_API.G_MISS_NUM)
       OR (l_tar_sales_lead_rec.assign_sales_group_id <> FND_API.G_MISS_NUM)
       OR (l_tar_sales_lead_rec.assign_to_person_id <>  FND_API.G_MISS_NUM)
       OR (l_tar_sales_lead_rec.lead_rank_id <> FND_API.G_MISS_NUM)
       OR (l_tar_sales_lead_rec.qualified_flag <> FND_API.G_MISS_CHAR)
       OR (l_tar_sales_lead_rec.reject_reason_code <> FND_API.G_MISS_CHAR)
      )
      AND
      (
          (l_tar_sales_lead_rec.status_code <> l_old_status_code)
       OR (l_tar_sales_lead_rec.assign_to_salesforce_id <> l_assign_to_salesforce_id)
       OR (l_tar_sales_lead_rec.assign_sales_group_id <> l_assign_sales_group_id)
       OR (l_tar_sales_lead_rec.assign_to_person_id  <> l_assign_to_person_id)
       OR (l_tar_sales_lead_rec.lead_rank_id <> l_lead_rank_id)
       OR (l_tar_sales_lead_rec.qualified_flag <> l_qualified_flag)
       OR (l_tar_sales_lead_rec.reject_reason_code <>  l_reject_reason_code)
      )
      )

     THEN */

          IF
           (
                ( (l_tar_sales_lead_rec.status_code = l_old_status_code)
                   or (l_tar_sales_lead_rec.status_code is null and l_old_status_code is null)
                  or (l_tar_sales_lead_rec.status_code = FND_API.G_MISS_CHAR) )
            AND ( (l_tar_sales_lead_rec.assign_to_salesforce_id = l_assign_to_salesforce_id)
                  or (l_tar_sales_lead_rec.assign_to_salesforce_id is null and l_assign_to_salesforce_id is null)
                  or (l_tar_sales_lead_rec.assign_to_salesforce_id = FND_API.G_MISS_NUM) )
            AND ( (l_tar_sales_lead_rec.assign_sales_group_id = l_assign_sales_group_id)
                or (l_tar_sales_lead_rec.assign_sales_group_id is null and l_assign_sales_group_id is null)
                or  (l_tar_sales_lead_rec.assign_sales_group_id = FND_API.G_MISS_NUM))
            AND ( (l_tar_sales_lead_rec.assign_to_person_id  = l_assign_to_person_id)
               or (l_tar_sales_lead_rec.assign_to_person_id is null and l_assign_to_person_id is null)
               or  (l_tar_sales_lead_rec.assign_to_person_id = FND_API.G_MISS_NUM))
            AND ( (l_tar_sales_lead_rec.lead_rank_id = l_lead_rank_id)
               or ( l_tar_sales_lead_rec.lead_rank_id is null and l_lead_rank_id is null)
               or  (l_tar_sales_lead_rec.lead_rank_id = FND_API.G_MISS_NUM))
            AND ( (l_tar_sales_lead_rec.qualified_flag = l_qualified_flag)
                 or (l_tar_sales_lead_rec.qualified_flag is null and l_qualified_flag is null )
                or  (l_tar_sales_lead_rec.qualified_flag = FND_API.G_MISS_CHAR))

            AND ( (l_tar_sales_lead_rec.reject_reason_code =  l_reject_reason_code)
                 or (l_tar_sales_lead_rec.reject_reason_code is null and l_reject_reason_code is null)
                or  (l_tar_sales_lead_rec.reject_reason_code = FND_API.G_MISS_CHAR))
           )

     THEN
           IF (AS_DEBUG_LOW_ON) THEN

           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                          'Nothing to log ');
           END IF;

    ELSE
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                     'Just after AS_SALES_LEADS_PKG.Sales_Lead_Update_Row');
      END IF;


        if (l_tar_sales_lead_rec.status_code = FND_API.G_MISS_CHAR) then
            l_log_status_code := l_old_status_code;
        end if;


      --IF (AS_DEBUG_LOW_ON) THENAS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --               'marker 1');END IF;

        if (l_tar_sales_lead_rec.assign_to_salesforce_id = FND_API.G_MISS_NUM) then
            l_log_assign_to_sf_id := l_assign_to_salesforce_id;
        end if;

--      IF (AS_DEBUG_LOW_ON) THEN            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
  --                   'marker 2');      END IF;

        if (l_tar_sales_lead_rec.assign_sales_group_id = FND_API.G_MISS_NUM) then
            l_log_assign_sg_id := l_assign_sales_group_id;
        end if;

--      IF (AS_DEBUG_LOW_ON) THEN            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
  --                   'marker 3');      END IF;

        if (l_tar_sales_lead_rec.assign_to_person_id = FND_API.G_MISS_NUM) then
            l_log_assign_to_person_id := l_assign_to_person_id;
        end if;
--      IF (AS_DEBUG_LOW_ON) THEN            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
  --                   'marker 4');      END IF;


        if (l_tar_sales_lead_rec.lead_rank_id = FND_API.G_MISS_NUM) then
            l_log_lead_rank_id := l_lead_rank_id;
        end if;

--      IF (AS_DEBUG_LOW_ON) THEN            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
  --                   'marker 5');      END IF;

        if (l_tar_sales_lead_rec.reject_reason_code = FND_API.G_MISS_CHAR) then
            l_log_reject_reason_code := l_reject_reason_code;
        end if;

        if (l_qualified = FND_API.G_MISS_CHAR) then
                 l_log_qualified := l_qualified_flag;
        end if;


      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling AS_SALES_LEADS_LOG_PKG.Insert_Row');
      END IF;

      -- Call API to create log entry
      AS_SALES_LEADS_LOG_PKG.Insert_Row(
            px_log_id                 => l_sales_lead_log_id ,
            p_sales_lead_id           => l_tar_sales_lead_rec.sales_lead_id,
            p_created_by             => fnd_global.user_id,
            p_creation_date           => sysdate,
            p_last_updated_by         => fnd_global.user_id,
            p_last_update_date        => sysdate,
            p_last_update_login       => FND_GLOBAL.CONC_LOGIN_ID,
            -- using standard parameters for program who columns
            p_request_id             => FND_GLOBAL.Conc_Request_Id,
            p_program_application_id => FND_GLOBAL.Prog_Appl_Id,
            p_program_id             => FND_GLOBAL.Conc_Program_Id,
            p_program_update_date    => sysdate,
            p_status_code             =>
                                   --l_tar_sales_lead_rec.status_code,
                                   l_log_status_code,
            p_assign_to_person_id     =>
                                    --l_tar_sales_lead_rec.assign_to_person_id,
                                    l_log_assign_to_person_id,
            p_assign_to_salesforce_id =>
                                    --l_tar_sales_lead_rec.assign_to_salesforce_id,
                                    l_log_assign_to_sf_id,
            p_reject_reason_code      =>
                                    --l_tar_sales_lead_rec.reject_reason_code,
                                    l_log_reject_reason_code,
            p_assign_sales_group_id   =>
                                    --l_tar_sales_lead_rec.assign_sales_group_id,
                                    l_log_assign_sg_id,
            p_lead_rank_id            =>
                                    --l_tar_sales_lead_rec.lead_rank_id,
                                    l_log_lead_rank_id,
            p_qualified_flag        => l_log_qualified,
            p_category		    => fnd_api.g_miss_char,
            p_manual_rank_flag      => l_manual_rank_flag

            );

/*      ELSE

       -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Not Calling AS_SALES_LEADS_LOG_PKG.Insert_Row');
      END IF;

*/
      END IF;



       -- For referral leads, create another entry in the logs table so that it is tracked as a referral lead also
       -- This is to be done only for the first time, the referral type is updated from null to non null.

       if ( l_tar_SALES_LEAD_rec.REFERRAL_TYPE is not null and l_tar_sales_lead_rec.REFERRAL_TYPE <> FND_API.G_MISS_CHAR
            and l_referral_type is null )

         then

               l_sales_lead_log_id := null;

               AS_SALES_LEADS_LOG_PKG.Insert_Row(
                  px_log_id                => l_sales_lead_log_id ,
                  p_sales_lead_id          => l_tar_sales_lead_rec.sales_lead_id,
                  p_created_by             => fnd_global.user_id,
                  p_creation_date          => sysdate,
                  p_last_updated_by        => fnd_global.user_id,
                  p_last_update_date       => sysdate,
                  p_last_update_login      =>  FND_GLOBAL.CONC_LOGIN_ID,
                  -- using standard parameters for program who columns
                  p_request_id             => FND_GLOBAL.Conc_Request_Id,
                  p_program_application_id => FND_GLOBAL.Prog_Appl_Id,
                  p_program_id             => FND_GLOBAL.Conc_Program_Id,
                  p_program_update_date    => sysdate,
                  p_status_code            => l_referral_status_profile, -- for referral log, we use referral status
                  p_assign_to_person_id    =>
                                              --l_tar_sales_lead_rec.assign_to_person_id,
                                              l_log_assign_to_person_id,

                  p_assign_to_salesforce_id=>
                                              --l_tar_sales_lead_rec.assign_to_salesforce_id,
                                              l_log_assign_to_sf_id,
                  p_reject_reason_code     =>
                                              --l_tar_sales_lead_rec.reject_reason_code,
                                              l_log_reject_reason_code,

                  p_assign_sales_group_id  =>
                                              --l_tar_sales_lead_rec.assign_sales_group_id,
                                              l_log_assign_sg_id,

                  p_lead_rank_id           =>
                                              --l_tar_sales_lead_rec.lead_rank_id,
                                              l_log_lead_rank_id,
                  p_qualified_flag        => l_log_qualified,
                  p_category		    => 'REFERRAL'
                  );


            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

      end if;





      IF (AS_DEBUG_LOW_ON) THEN











      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'x_return_status: '|| x_return_status);





      END IF;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                    'l_assign_sf_id:' ||l_assign_to_salesforce_id);

      END IF;
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
        'l_tar.assign_sf_id:' || l_tar_SALES_LEAD_rec.assign_to_salesforce_id);
      END IF;

      -- Call Create, Update or Delete Sales Team
      IF l_assign_to_salesforce_id IS NULL AND
         l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NOT NULL AND
         l_tar_SALES_LEAD_rec.assign_to_salesforce_id <> FND_API.G_MISS_NUM
      THEN
          -- Create access security in as_accesses_all
          -- l_Sales_Team_Rec.access_id         := FND_API.G_MISS_NUM;
          l_Sales_Team_Rec.last_update_date  := SYSDATE;
          l_Sales_Team_Rec.last_updated_by   := FND_GLOBAL.USER_ID;
          l_Sales_Team_Rec.creation_date     := SYSDATE;
          l_Sales_Team_Rec.created_by        := FND_GLOBAL.USER_ID;
          l_Sales_Team_Rec.last_update_login := FND_GLOBAL.CONC_LOGIN_ID;

          -- l_Sales_Team_Rec.team_leader_flag  := FND_API.G_MISS_CHAR;
          l_Sales_Team_Rec.customer_id      := l_tar_SALES_LEAD_rec.Customer_Id;
          l_Sales_Team_Rec.address_id       := l_tar_SALES_LEAD_rec.Address_Id;
          l_Sales_Team_Rec.salesforce_id    :=
						    l_tar_SALES_LEAD_rec.ASSIGN_TO_SALESFORCE_ID;
          l_Sales_Team_Rec.person_id        :=
						    l_tar_SALES_LEAD_rec.ASSIGN_TO_PERSON_ID;
          l_Sales_Team_Rec.sales_group_id   :=
						    l_tar_SALES_LEAD_rec.ASSIGN_SALES_GROUP_ID;
          l_Sales_Team_Rec.sales_lead_id    :=
						    l_tar_SALES_LEAD_rec.Sales_Lead_Id;

	  l_Sales_Team_Rec.owner_flag := 'Y';
	  l_Sales_Team_Rec.freeze_flag := 'Y';


	  l_Sales_Team_Rec.team_leader_flag := 'Y';

	  -- Change since update_sales_lead is not called from workflow any longer.
	  --IF (P_Calling_From_WF_flag = 'Y')
	  --THEN
	  --   l_Sales_Team_Rec.created_by_TAP_flag := 'Y';
	  --ELSE

	     l_Sales_Team_Rec.created_by_TAP_flag := 'N';

	  --END IF;


          -- Debug Message
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
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
          IF (AS_DEBUG_LOW_ON) THEN

          AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Create_SalesTeam:x_access_id > ' ||
                                       l_access_id);
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;

      ELSIF l_assign_to_salesforce_id IS NOT NULL  -- AND
         -- l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NOT NULL AND
         -- l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
         --                                         FND_API.G_MISS_NUM AND
         -- l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
         --                                         l_assign_to_salesforce_id
      THEN
          -- Get access record in as_accesses_all by sales_lead_id

          -- if the assign to is being cleared, then the cursor will not work if use null
          -- use the old assign to (database value) instead.

          IF (l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NOT NULL and l_tar_SALES_LEAD_rec.assign_to_salesforce_id <> FND_API.G_MISS_NUM) THEN

          OPEN  C_Get_Access  (l_tar_SALES_LEAD_rec.Sales_Lead_Id, l_tar_SALES_LEAD_rec.assign_to_salesforce_id, l_tar_SALES_LEAD_rec.assign_sales_group_id);

          ELSE

          OPEN  C_Get_Access  (l_tar_SALES_LEAD_rec.Sales_Lead_Id, l_assign_to_salesforce_id, l_assign_sales_group_id);

          END IF;

          FETCH C_Get_Access Into
                l_Sales_Team_Rec.access_id
               ,l_Sales_Team_Rec.last_update_date
               ,l_Sales_Team_Rec.last_updated_by
               ,l_Sales_Team_Rec.creation_date
               ,l_Sales_Team_Rec.created_by
               ,l_Sales_Team_Rec.last_update_login
               ,l_Sales_Team_Rec.freeze_flag
               ,l_Sales_Team_Rec.reassign_flag
               ,l_Sales_Team_Rec.team_leader_flag
               ,l_Sales_Team_Rec.customer_id
               ,l_Sales_Team_Rec.address_id
               ,l_Sales_Team_Rec.salesforce_id
               ,l_Sales_Team_Rec.person_id
               ,l_Sales_Team_Rec.partner_customer_id
               ,l_Sales_Team_Rec.partner_address_id
               ,l_Sales_Team_Rec.created_person_id
               ,l_Sales_Team_Rec.lead_id
               ,l_Sales_Team_Rec.freeze_date
               ,l_Sales_Team_Rec.reassign_reason
               ,l_Sales_Team_Rec.downloadable_flag
               ,l_Sales_Team_Rec.attribute_category
               ,l_Sales_Team_Rec.attribute1
               ,l_Sales_Team_Rec.attribute2
               ,l_Sales_Team_Rec.attribute3
               ,l_Sales_Team_Rec.attribute4
               ,l_Sales_Team_Rec.attribute5
               ,l_Sales_Team_Rec.attribute6
               ,l_Sales_Team_Rec.attribute7
               ,l_Sales_Team_Rec.attribute8
               ,l_Sales_Team_Rec.attribute9
               ,l_Sales_Team_Rec.attribute10
               ,l_Sales_Team_Rec.attribute11
               ,l_Sales_Team_Rec.attribute12
               ,l_Sales_Team_Rec.attribute13
               ,l_Sales_Team_Rec.attribute14
               ,l_Sales_Team_Rec.attribute15
               ,l_Sales_Team_Rec.salesforce_role_code
               ,l_Sales_Team_Rec.salesforce_relationship_code
               ,l_Sales_Team_Rec.sales_group_id
               -- ,l_Sales_Team_Rec.reassign_requested_person_id
               -- ,l_Sales_Team_Rec.reassign_request_date
               -- ,l_Sales_Team_Rec.internal_update_access
               ,l_Sales_Team_Rec.sales_lead_id;

          CLOSE C_Get_Access;


	-- ckapoor 11.5.10 - bug 3225643 - change keep flag for logged in user not the owner

          if (l_tar_SALES_LEAD_rec.accept_flag = 'Y' and l_accept_flag = 'N') then
           -- earlier we were changing the owner's keep flag .now for bug 3225643 , we have to change
           -- keep flag for logged in user
           -- l_Sales_Team_Rec.freeze_flag := 'Y';

           -- first determine if the logged in user is already present in the sales team or not


           IF (AS_DEBUG_LOW_ON) THEN

	   	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   	   				       'CK:bef grp');
	   END IF;


            Open c_get_group_id (p_identity_salesforce_id, 'RS_GROUP_MEMBER' , 'SALES','TELESALES','FIELDSALES','PRM','Y');
	    Fetch c_get_group_id into l_login_user_sg_id;
	    Close c_get_group_id;

	               IF (AS_DEBUG_LOW_ON) THEN

	    	   	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	    	   	   				       'CK:usgid:'||l_login_user_sg_id);
	    	   END IF;



	    Open c_get_person_id(p_identity_salesforce_id);
	    Fetch c_get_person_id into l_login_user_person_id;
	    Close c_get_person_id;


	    IF (AS_DEBUG_LOW_ON) THEN

	    	    	   	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	    	    	   	   				       'CK:uspid:'||l_login_user_person_id);
	    	    	   END IF;



	    OPEN  C_Get_Access  (l_tar_SALES_LEAD_rec.Sales_Lead_Id, p_identity_salesforce_id, l_login_user_sg_id);

	              FETCH C_Get_Access Into
	                    l_login_salesteam_rec.access_id
	                   ,l_login_salesteam_rec.last_update_date
	                   ,l_login_salesteam_rec.last_updated_by
	                   ,l_login_salesteam_rec.creation_date
	                   ,l_login_salesteam_rec.created_by
	                   ,l_login_salesteam_rec.last_update_login
	                   ,l_login_salesteam_rec.freeze_flag
	                   ,l_login_salesteam_rec.reassign_flag
	                   ,l_login_salesteam_rec.team_leader_flag
	                   ,l_login_salesteam_rec.customer_id
	                   ,l_login_salesteam_rec.address_id
	                   ,l_login_salesteam_rec.salesforce_id
	                   ,l_login_salesteam_rec.person_id
	                   ,l_login_salesteam_rec.partner_customer_id
	                   ,l_login_salesteam_rec.partner_address_id
	                   ,l_login_salesteam_rec.created_person_id
	                   ,l_login_salesteam_rec.lead_id
	                   ,l_login_salesteam_rec.freeze_date
	                   ,l_login_salesteam_rec.reassign_reason
	                   ,l_login_salesteam_rec.downloadable_flag
	                   ,l_login_salesteam_rec.attribute_category
	                   ,l_login_salesteam_rec.attribute1
	                   ,l_login_salesteam_rec.attribute2
	                   ,l_login_salesteam_rec.attribute3
	                   ,l_login_salesteam_rec.attribute4
	                   ,l_login_salesteam_rec.attribute5
	                   ,l_login_salesteam_rec.attribute6
	                   ,l_login_salesteam_rec.attribute7
	                   ,l_login_salesteam_rec.attribute8
	                   ,l_login_salesteam_rec.attribute9
	                   ,l_login_salesteam_rec.attribute10
	                   ,l_login_salesteam_rec.attribute11
	                   ,l_login_salesteam_rec.attribute12
	                   ,l_login_salesteam_rec.attribute13
	                   ,l_login_salesteam_rec.attribute14
	                   ,l_login_salesteam_rec.attribute15
	                   ,l_login_salesteam_rec.salesforce_role_code
	                   ,l_login_salesteam_rec.salesforce_relationship_code
	                   ,l_login_salesteam_rec.sales_group_id
	                   -- ,l_Sales_Team_Rec.reassign_requested_person_id
	                   -- ,l_Sales_Team_Rec.reassign_request_date
	                   -- ,l_Sales_Team_Rec.internal_update_access
	                   ,l_login_salesteam_rec.sales_lead_id;

	              CLOSE C_Get_Access;



           -- now check if the logged in user is already in the salesteam or not.
           -- If already there, call update_sales_team otherwise call create_sales_team

	     --l_login_salesteam_rec.last_update_date  := SYSDATE;
	     l_login_salesteam_rec.last_updated_by   := FND_GLOBAL.USER_ID;
	     --l_login_salesteam_rec.creation_date     := SYSDATE;
	     --l_login_salesteam_rec.created_by        := FND_GLOBAL.USER_ID;
	     l_login_salesteam_rec.last_update_login := FND_GLOBAL.CONC_LOGIN_ID;

	     -- l_Sales_Team_Rec.team_leader_flag  := FND_API.G_MISS_CHAR;
	     l_login_salesteam_rec.salesforce_id    :=
						    p_identity_salesforce_id;

	     l_login_salesteam_rec.sales_group_id   :=
						    l_login_user_sg_id;

	     l_login_salesteam_rec.sales_lead_id    :=
						    l_tar_SALES_LEAD_rec.Sales_Lead_Id;

	     l_login_salesteam_rec.person_id := l_login_user_person_id;


	     --l_login_salesteam_rec.owner_flag := 'Y';

	     -- THIS IS THE IMPORTANT STEP OF MAKING SURE THAT THE LOGIN USER IS FROZEN

	     l_login_salesteam_rec.freeze_flag := 'Y';

             --l_login_salesteam_rec.team_leader_flag := 'Y';
	     --l_login_salesteam_rec.created_by_TAP_flag := 'N';


	   l_login_user_in_st := 'N';
	   Open c_check_salesteam(l_Sales_Team_Rec.sales_lead_id,  p_identity_salesforce_id ,  l_login_user_sg_id);
	   Fetch c_check_salesteam into l_login_user_in_st;
	   Close c_check_salesteam;

	   IF (l_login_user_in_st = 'Y' ) THEN

	             	   -- Debug Message
	   	           IF (AS_DEBUG_LOW_ON) THEN

	   	           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   				       'CK:Calling Update_SalesTeam');
	   	           END IF;

	                  AS_ACCESS_PUB.Update_SalesTeam (
	                   p_api_version_number         => 2.0
	                  ,p_init_msg_list              => FND_API.G_FALSE
	                  ,p_commit                     => FND_API.G_FALSE
	                  ,p_validation_level           => P_Validation_Level
	                  ,p_check_access_flag          => p_check_access_flag   -- 'Y'
	                  ,p_access_profile_rec         => l_access_profile_rec
	                  ,p_admin_flag                 => p_admin_flag
	                  ,p_admin_group_id             => p_admin_group_id
	                  ,p_identity_salesforce_id     => p_identity_salesforce_id
	                  ,p_sales_team_rec             => l_login_salesteam_rec
	                  ,X_Return_Status              => x_Return_Status
	                  ,X_Msg_Count                  => X_Msg_Count
	                  ,X_Msg_Data                   => X_Msg_Data
	                  ,x_access_id                  => l_login_Access_Id
	                 );
	   ELSE


	   	      -- Debug Message
	   	      IF (AS_DEBUG_LOW_ON) THEN

	   	      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   				       'CK:Calling Create_SalesTeam');
	   	      END IF;

	             l_login_salesteam_rec.last_update_date     := SYSDATE;
	             l_login_salesteam_rec.creation_date     := SYSDATE;
	   	     l_login_salesteam_rec.created_by        := FND_GLOBAL.USER_ID;
	             l_login_salesteam_rec.created_by_TAP_flag := 'N';
	             l_login_salesteam_rec.customer_id      := l_customer_id  ; --l_tar_SALES_LEAD_rec.Customer_Id;
		     l_login_salesteam_rec.address_id       := l_tar_SALES_LEAD_rec.Address_Id;
		     l_login_salesteam_rec.person_id 	    := l_login_user_person_id;


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
	   	       ,p_sales_team_rec             => l_login_salesteam_rec
	   	       ,X_Return_Status              => x_Return_Status
	   	       ,X_Msg_Count                  => X_Msg_Count
	   	       ,X_Msg_Data                   => X_Msg_Data
	   	       ,x_access_id                  => l_login_Access_Id
	   	     );

	   	     -- Debug Message
	   	     IF (AS_DEBUG_LOW_ON) THEN

	   	     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	   				       'CK:Create_SalesTeam:x_access_id > ' ||
	          	   			       l_login_Access_Id);
	   	     END IF;
	            END IF;




          end if;

          -- END ckapoor 11.5.10 - bug 3225643 - change keep flag for logged in user not the owner


          -- ffang 012501, if blank out the assign_to_salesforce_id, access
          -- record should be deleted
          IF l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NULL or
             l_tar_SALES_LEAD_rec.assign_to_salesforce_id = FND_API.G_MISS_NUM
          THEN
            -- Call update_salesteam to update the owner

              l_Sales_Team_Rec.last_updated_by      := FND_GLOBAL.USER_ID;
              l_Sales_Team_Rec.last_update_login    := FND_GLOBAL.CONC_LOGIN_ID;
              --l_Sales_Team_Rec.last_update_date     := SYSDATE;
              -- l_Sales_Team_Rec.team_leader_flag     := FND_API.G_MISS_CHAR;
              l_Sales_Team_Rec.customer_id := l_Customer_Id;
              l_Sales_Team_Rec.address_id  := l_tar_SALES_LEAD_rec.Address_Id;
              -- only need to update the owner flag for the existing entry (owner)
              l_Sales_Team_Rec.salesforce_id        :=
                                   l_assign_to_salesforce_id;
              l_Sales_Team_Rec.sales_group_id       :=
                                   l_assign_sales_group_id;
              l_Sales_Team_Rec.sales_lead_id        :=
                                   l_tar_SALES_LEAD_rec.SALES_LEAD_ID;
              l_Sales_Team_Rec.owner_flag        := 'N';
  	      --    l_Sales_Team_Rec.created_by_TAP_flag := 'N';

              IF (AS_DEBUG_LOW_ON) THEN



              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Access id is'|| l_sales_team_rec.access_id);

              END IF;


              -- Debug Message
              IF (AS_DEBUG_LOW_ON) THEN

              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Calling Update_SalesTeam');
              END IF;

              AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => P_Validation_Level
               ,p_check_access_flag          => p_check_access_flag   -- 'Y'
               ,p_access_profile_rec         => l_access_profile_rec
               ,p_admin_flag                 => p_admin_flag
               ,p_admin_group_id             => p_admin_group_id
               ,p_identity_salesforce_id     => p_identity_salesforce_id
               ,p_sales_team_rec             => l_Sales_Team_Rec
               ,X_Return_Status              => x_Return_Status
               ,X_Msg_Count                  => X_Msg_Count
               ,X_Msg_Data                   => X_Msg_Data
               ,x_access_id                  => l_Access_Id
              );


              -- Call Delete_SalesTeam to delete access record
            /*  AS_ACCESS_PUB.Delete_SalesTeam(
                  p_api_version_number     =>  2.0,
                  p_init_msg_list          =>  FND_API.G_FALSE,
                  p_commit                 =>  FND_API.G_FALSE,
                  p_validation_level       =>  FND_API.G_VALID_LEVEL_FULL,
                  p_access_profile_rec     =>  l_access_profile_rec,
                  p_check_access_flag      =>  'Y',
                  p_admin_flag             =>  p_admin_flag,
                  p_admin_group_id         =>  p_admin_group_id,
                  p_identity_salesforce_id =>  p_identity_salesforce_id,
                  p_sales_team_rec         =>  l_sales_team_rec,
                  x_return_status          =>  x_return_status,
                  x_msg_count              =>  x_msg_count,
                  x_msg_data               =>  x_msg_data
              ); */

              IF (AS_DEBUG_LOW_ON) THEN



              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Delete_SalesTeam:x_access_id > ' || l_access_id);

              END IF;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

          ELSIF l_tar_SALES_LEAD_rec.assign_to_salesforce_id IS NOT NULL AND
                l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
                                                  FND_API.G_MISS_NUM AND
                l_tar_SALES_LEAD_rec.assign_to_salesforce_id <>
                                                  l_assign_to_salesforce_id
          THEN

              l_Sales_Team_Rec.last_updated_by      := FND_GLOBAL.USER_ID;
              l_Sales_Team_Rec.last_update_login    := FND_GLOBAL.CONC_LOGIN_ID;
              --l_Sales_Team_Rec.last_update_date     := SYSDATE;
              -- l_Sales_Team_Rec.team_leader_flag     := FND_API.G_MISS_CHAR;
              l_Sales_Team_Rec.customer_id := l_Customer_Id;
              l_Sales_Team_Rec.address_id  := l_tar_SALES_LEAD_rec.Address_Id;

              -- only need to update the owner flag for the existing entry (owner)

              l_Sales_Team_Rec.salesforce_id        :=
                                   l_assign_to_salesforce_id;

              l_Sales_Team_Rec.sales_group_id       :=
                                   l_assign_sales_group_id;

              l_Sales_Team_Rec.sales_lead_id        :=
                                   l_tar_SALES_LEAD_rec.SALES_LEAD_ID;

              /*AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => P_Validation_Level
               ,p_check_access_flag          => p_check_access_flag   -- 'Y'
               ,p_access_profile_rec         => l_access_profile_rec
               ,p_admin_flag                 => p_admin_flag
               ,p_admin_group_id             => p_admin_group_id
               ,p_identity_salesforce_id     => p_identity_salesforce_id
               ,p_sales_team_rec             => l_Sales_Team_Rec
               ,X_Return_Status              => x_Return_Status
               ,X_Msg_Count                  => X_Msg_Count
               ,X_Msg_Data                   => X_Msg_Data
               ,x_access_id                  => l_Access_Id
              );

              IF (AS_DEBUG_LOW_ON) THEN



              AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                            'Update_SalesTeam:x_access_id > ' || l_access_id);

              END IF;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

              */


              -- Create another entry in the as_accesses_all for the new owner
              -- use some of the fields from those already set in the record.

              -- this needs to be done only is doing new create_sales_team
              --l_Sales_Team_Rec.last_update_date     := SYSDATE;


              l_Sales_Team_Rec.salesforce_id        :=
                                   l_tar_SALES_LEAD_rec.assign_to_salesforce_id;

              l_Sales_Team_Rec.sales_group_id       :=
                                   l_tar_SALES_LEAD_rec.assign_sales_group_id;

              l_Sales_Team_Rec.person_id       :=
                                   l_tar_SALES_LEAD_rec.assign_to_person_id;

              l_Sales_Team_Rec.owner_flag        := 'Y';
              l_Sales_Team_Rec.freeze_flag        := 'Y';



   	      --l_Sales_Team_Rec.created_by_TAP_flag := 'N';

	      l_Sales_Team_Rec.team_leader_flag := 'Y';

          -- Call duplicate check API to make sure that the new assign to is
          -- not already present in the accesses table. If already there, call
          -- update_sales_team otherwise call create_sales_team

          -- check for whether the current user is owner or not
          l_check_salesteam := 'N';
          Open c_check_salesteam(l_Sales_Team_Rec.sales_lead_id, l_Sales_Team_Rec.salesforce_id ,  l_Sales_Team_Rec.sales_group_id  );

	      Fetch c_check_salesteam into l_check_salesteam;
	      Close c_check_salesteam;

          IF (l_check_salesteam = 'Y' ) THEN

          	   -- Debug Message
	           IF (AS_DEBUG_LOW_ON) THEN

	           AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				       'Calling Update_SalesTeam');
	           END IF;

               AS_ACCESS_PUB.Update_SalesTeam (
                p_api_version_number         => 2.0
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => P_Validation_Level
               ,p_check_access_flag          => p_check_access_flag   -- 'Y'
               ,p_access_profile_rec         => l_access_profile_rec
               ,p_admin_flag                 => p_admin_flag
               ,p_admin_group_id             => p_admin_group_id
               ,p_identity_salesforce_id     => p_identity_salesforce_id
               ,p_sales_team_rec             => l_Sales_Team_Rec
               ,X_Return_Status              => x_Return_Status
               ,X_Msg_Count                  => X_Msg_Count
               ,X_Msg_Data                   => X_Msg_Data
               ,x_access_id                  => l_Access_Id
              );
        ELSE


	      -- Debug Message
	      IF (AS_DEBUG_LOW_ON) THEN

	      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				       'Calling Create_SalesTeam');
	      END IF;

          l_Sales_Team_Rec.last_update_date     := SYSDATE;
          l_Sales_Team_Rec.creation_date     := SYSDATE;
	      l_Sales_Team_Rec.created_by        := FND_GLOBAL.USER_ID;
          l_Sales_Team_Rec.created_by_TAP_flag := 'N';

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
	     IF (AS_DEBUG_LOW_ON) THEN

	     AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
				       'Create_SalesTeam:x_access_id > ' ||
       	   			       l_access_id);
	     END IF;
         END IF;

	     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	          RAISE FND_API.G_EXC_ERROR;
	     END IF;


          END IF;
      END IF;






	    -- if we are changing status from open to closed or closed to open,
	    -- then the denormed flag in as_accesses_all needs to change for all
	    -- records for this sales_lead_id

	    if (l_old_status_flag = 'Y' AND l_new_status_flag = 'N') then

	    update as_accesses_all
	    set open_flag = null , last_update_date = sysdate,
	    last_updated_by = fnd_global.user_id,
	    last_update_login = fnd_global.conc_login_id
	    where sales_lead_id = l_tar_SALES_LEAD_rec.SALES_LEAD_ID;

	    elsif ( l_old_status_flag = 'N' AND l_new_status_flag = 'Y') then

	    update as_accesses_all
		  set open_flag = 'Y', last_update_date = sysdate,
		  last_updated_by = fnd_global.user_id,
		  last_update_login = fnd_global.conc_login_id
	    where sales_lead_id = l_tar_SALES_LEAD_rec.SALES_LEAD_ID;

	    end if;


	         -- Update lead_rank_score as well.



	   -- fixing problem found during testing that if u updated lead e.g from Cold Lead to
	   -- null rank, then lead_rank_score in as_accesses_all was not getting updated.


	    -- if new rank is null, we  want to fix the score since old might have been non null.
	    -- if new rank is g_miss , means anyways the rank is not changing so score is not changing.
	    -- since we are re-using code from denorming for as_sales_leads, if l_new_lead_rank_score
	    -- is g_miss then dont update as_accesses_all, basically simulate table handler

       	   if ( l_new_lead_rank_score <> FND_API.G_MISS_NUM ) THEN
		-- update the as_accesses_all.lead_rank_score if the rank has been changed i.e not g_miss
		update as_accesses_all
			    set lead_rank_score = l_new_lead_rank_score , last_update_date = sysdate,
			    last_updated_by = fnd_global.user_id,
			    last_update_login = fnd_global.conc_login_id
		where sales_lead_id = l_tar_SALES_LEAD_rec.SALES_LEAD_ID;

           END IF;

	  -- End denorm fix


/*
      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                     'Validate BUDGET_AMOUNT');
      END IF;

      Validate_BUDGET_AMOUNTS(
          p_init_msg_list         => FND_API.G_FALSE,
          p_validation_mode       => AS_UTILITY_PVT.G_CREATE,
          p_SALES_LEAD_ID         => l_tar_SALES_LEAD_rec.Sales_Lead_Id,
          x_return_status         => x_return_status,
          x_msg_count             => x_msg_count,
          x_msg_data              => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;
*/

      --
      -- END of API body.
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
END Update_sales_lead;


/*
This function is decomissioned
-- function determines whether the Sales_Lead Is Qualified Or NOT.
FUNCTION IS_LEAD_QUALIFIED(
    P_Sales_lead_rec     IN AS_SALES_LEADS_PUB.SALES_LEAD_Rec_Type
                              := AS_SALES_LEADS_PUB.G_MISS_SALES_LEAD_REC,
    p_phone_id           IN NUMBER := FND_API.G_MISS_NUM,
    p_contact_role_code  IN VARCHAR2 := FND_API.G_MISS_CHAR
    ) RETURN VARCHAR
 IS
    l_api_name           CONSTANT VARCHAR2(30) := 'Is_Lead_Qualified';
    l_project_name_req   varchar2(1);
    l_channel_req        varchar2(1);
    l_time_frame_req     varchar2(1);
    l_total_budget_req   varchar2(1);
    l_contact_phone_req  varchar2(1);
    l_contact_role_req   varchar2(1);
    l_budget_status_req  varchar2(1);
    l_campaign_code_req  varchar2(1);
    l_isQualified        varchar2(1) := 'Y';
begin

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'p_phone_id is '||p_phone_id);

    END IF;
    IF (AS_DEBUG_LOW_ON) THEN

    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'p_contact_role_code is '||p_contact_role_code);
    END IF;

    -- get all of the required variables for a Lead to be qualified
    l_project_name_req  := fnd_profile.value('AS_SALES_LEAD_PROJECT_NAME_REQ');
    l_channel_req       := fnd_profile.value('AS_SALES_LEAD_CHANNEL_REQ');
    l_time_frame_req    := fnd_profile.value('AS_SALES_LEAD_TIME_FRAME_REQ');
    l_total_budget_req  := fnd_profile.value('AS_SALES_LEAD_TOTAL_BUDGET_REQ');
    l_contact_phone_req := fnd_profile.value('AS_SALES_LEAD_CONTACT_PHONE_REQ');
    l_contact_role_req  := fnd_profile.value('AS_SALES_LEAD_CONTACT_ROLE_REQ');
    l_budget_status_req := fnd_profile.value('AS_SALES_LEAD_BUDGET_STATUS_REQ');
    l_campaign_code_req := fnd_profile.value('AS_SALES_LEAD_CAMPAIGN_CODE_REQ');


    IF (AS_DEBUG_LOW_ON) THEN





    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - parent_project'||l_project_name_req);


    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - channel'||l_channel_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - time frame'||l_time_frame_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - total budget'||l_total_budget_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - contact phone'||l_contact_phone_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - contact role'||l_contact_role_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - budget_status'||l_budget_status_req);

    END IF;

    IF (AS_DEBUG_LOW_ON) THEN



    AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'profile - campaign code'||l_campaign_code_req);

    END IF;



    if l_project_name_req = 'Y' then
        if (p_sales_lead_rec.parent_project is null) or
           (p_sales_lead_rec.parent_project = FND_API.G_MISS_CHAR) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - parent_project');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_channel_req = 'Y' then
        if (P_Sales_lead_rec.CHANNEL_CODE is null) or
           (p_sales_lead_rec.CHANNEL_CODE = FND_API.G_MISS_CHAR) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - CHANNEL_CODE');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_time_frame_req = 'Y' then
        if (P_Sales_lead_rec.DECISION_TIMEFRAME_CODE is null) or
           (p_sales_lead_rec.DECISION_TIMEFRAME_CODE = FND_API.G_MISS_CHAR) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Qualification - DECISION_TIMEFRAME_CODE');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_total_budget_req = 'Y' then
        if (P_Sales_lead_rec.BUDGET_AMOUNT is null) or
           (p_sales_lead_rec.BUDGET_AMOUNT = FND_API.G_MISS_NUM) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - BUDGET_AMOUNT');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_contact_phone_req = 'Y' then
        if (p_phone_id is null) or
           (p_phone_id = FND_API.G_MISS_NUM) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - p_phone_id');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    -- change this to make sure contact role from as_sales_leads_contacts table is used
    if l_contact_role_req = 'Y' then
        if (p_contact_role_code is null) or
           (p_contact_role_code = FND_API.G_MISS_CHAR) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - CONTACT_ROLE_CODE');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_budget_status_req = 'Y' then
        if (P_Sales_lead_rec.BUDGET_STATUS_CODE is null) or
           (p_sales_lead_rec.BUDGET_STATUS_CODE = FND_API.G_MISS_CHAR) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - BUDGET_STATUS_CODE');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    if l_campaign_code_req = 'Y' then
        if (P_Sales_lead_rec.SOURCE_PROMOTION_ID is null) or
           (p_sales_lead_rec.SOURCE_PROMOTION_ID = FND_API.G_MISS_NUM) then
            IF (AS_DEBUG_LOW_ON) THEN

            AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                         'Qualification - SOURCE_PROMOTION_ID');
            END IF;
            l_isQualified := 'N';
            return l_isQualified;
        end if;
    end if;

    -- if we get this far we're qualified!
    return l_isQualified;

      IF (AS_DEBUG_LOW_ON) THEN



      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PVT: ' || l_api_name || ' End');

      END IF;

END IS_LEAD_QUALIFIED;


*/

END AS_SALES_LEADS_PVT;

/
