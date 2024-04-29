--------------------------------------------------------
--  DDL for Package Body AS_OPP_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPP_HEADER_PVT" as
/* $Header: asxvldhb.pls 120.10 2006/01/16 01:38:20 subabu ship $ */
-- Start of Comments
-- Package name     : AS_OPP_HEADER_PVT
-- Purpose          :
-- History          :
--    06-30-00 XDING  Created by using API Generator
--    06-30-00 FFANG  Modified it as compile-able
--    07-27-00 FFANG  1. Add item level validation procedures
--                    2. Add record level validation procedures
--                    3. Add security checking
--                    4. Modifiy error messages
--    08-01-00 FFANG  Add: create notes in update_opp_header
--    08-02-00 FFANG  1. Remove lead_number validation
--                    2. pass in g_miss_char for lead_number when calling
--                       update_row
--    08-14-00 FFANG  Call as_access_pub.create_salesteam in create_opp_header
--    08-15-00 FFANG  CLOSE_REASON_TYPE -> CLOSE_REASON
--    08-18-00 FFANG  Add: Validate_BudgetAmt_Currency
--    08-21-00 FFANG  Add: set default currency code
--    08-22-00 FFANG  Remove: Validate_Status_DecisionDate
--    08-23-00 FFANG  Add Set_opp_default_values to update_opp_header
--    08-24-00 FFANG  Modify OTHERS exception hanlder calling arguments.
--    08-30-00 FFANG  Use AS_SF_PTR_V instead of pv_partners_v when validating
--                    incumbent_partner_party_id and
--                    incumbent_partner_resource_id
--    09-08-00 FFANG  For bug 1397389, checking profile
--                    AS_CUSTOMER_ADDRESS_REQUIRED to see if address_id is
--                    mandatory or not
--    09-11-00 FFANG  For bug 1401095, create_opp_header add a parameter:
--                    p_salesgroup_id to accept sales group id for creating
--                    sales team.
--    09-12-00 FFANG  For bug 1403865, using start_date_active and
--                    end_date_active instead of enabled_flag on validating
--                    sales_stage_id, channel_code, currency_code, and
--                    win_probability
--    09-12-00 FFANG  For bug 1402449, validate whether description is NULL
--    09-14-00 FFANG  For bug 1407007,
--                    1. add default value ('TAP') to auto_assignment_type
--                       if it is NULL or G_MISS_CHAR (when creating)
--                    2. add parameter p_mode to Set_opp_default_values to
--                       tell if calling by create or update
--    01-11-01 SOLIN  For bug 1554330,
--                    Add freeze_flag in as_leads_all and do relevant change.
--    03-sep-03 NKAMBLE Validate_DecisionDate procedure added as an enhancement# 3125485
--    12-sep-03 NKAMBLE FOR Bug#3133993, changed VALIDATE_SOURCE_PROMOTION_ID procedure cursor
--                        c_source_promotion_id_exists
-- NOTE             :
-- End of Comments
--


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_OPP_HEADER_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxvldhb.pls';

FUNCTION Is_Employee ( p_salesforce_id IN NUMBER) return boolean IS

CURSOR category IS
	select category
	from jtf_rs_resource_extns
	where resource_id = p_salesForce_id;

l_category 	JTF_RS_RESOURCE_EXTNS.Category%Type;
BEGIN
	open category;
	fetch category into l_category;
	close category;

	IF nvl(l_category, 'PARTNER') = 'EMPLOYEE' THEN
	  return TRUE;
	ELSE
	  return FALSE;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	  return FALSE;
END Is_Employee;


-- ffang 091400, Add p_mode and checking g_miss_xxx
PROCEDURE Set_opp_default_values (
    p_mode                IN       VARCHAR2,
    p_opp_rec             IN       AS_OPPORTUNITY_PUB.Header_Rec_Type,
    x_opp_rec             OUT NOCOPY      AS_OPPORTUNITY_PUB.Header_Rec_Type
    )

 IS
   l_opp_rec    AS_OPPORTUNITY_PUB.Header_Rec_Type := p_opp_rec;

BEGIN
     IF nvl(fnd_profile.value('AS_ACTIVATE_SALES_INTEROP'), 'N') <> 'Y'  THEN -- Added for ASNB
       If (l_opp_rec.sales_stage_id IS NULL) or
          (l_opp_rec.sales_stage_id = FND_API.G_MISS_NUM
           and p_mode = AS_UTILITY_PVT.G_CREATE)
       THEN
          l_opp_rec.sales_stage_id :=
               to_number(FND_PROFILE.VALUE ('AS_OPP_SALES_STAGE'));
       End If;
     END IF;

     If (l_opp_rec.win_probability IS NULL) or
        (l_opp_rec.win_probability = FND_API.G_MISS_NUM
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.win_probability :=
             to_number(FND_PROFILE.VALUE ('AS_OPP_WIN_PROBABILITY'));
     End If;

     If (l_opp_rec.channel_code IS NULL) or
        (l_opp_rec.channel_code = FND_API.G_MISS_CHAR
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.channel_code := FND_PROFILE.VALUE ('AS_OPP_SALES_CHANNEL');
     End If;

     If (l_opp_rec.status_code IS NULL) or
        (l_opp_rec.status_code = FND_API.G_MISS_CHAR
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.status_code := FND_PROFILE.VALUE ('AS_OPP_STATUS');
     End If;

     If (l_opp_rec.decision_date IS NULL) or
        (l_opp_rec.decision_date = FND_API.G_MISS_DATE
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.decision_date :=
             trunc(sysdate) + to_number(FND_PROFILE.VALUE('AS_OPP_CLOSING_DATE_DAYS'));
     End If;

     If (l_opp_rec.currency_code IS NULL) or
        (l_opp_rec.currency_code = FND_API.G_MISS_CHAR
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.currency_code :=
				 FND_PROFILE.VALUE('JTF_PROFILE_DEFAULT_CURRENCY');
     End If;

     -- ffang 091400 for bug 1407007
     If (l_opp_rec.auto_assignment_type IS NULL) or
        (l_opp_rec.auto_assignment_type = FND_API.G_MISS_CHAR
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.auto_assignment_type := 'TAP';
     End If;
     -- end ffang 091400

     If (l_opp_rec.prm_assignment_type IS NULL) or
        (l_opp_rec.prm_assignment_type = FND_API.G_MISS_CHAR
         and p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
        l_opp_rec.prm_assignment_type := 'UNASSIGNED';
     End If;

     -- Default delete_flag bug 1512162
     If (l_opp_rec.deleted_flag IS NULL or
         l_opp_rec.deleted_flag = FND_API.G_MISS_CHAR ) AND
         p_mode = AS_UTILITY_PVT.G_CREATE
     then
	l_opp_rec.deleted_flag := 'N';
     end if;

     -- solin, default freeze_flag for bug 1554330
     IF (l_opp_rec.freeze_flag IS NULL) or
        (l_opp_rec.freeze_flag = FND_API.G_MISS_CHAR AND
         p_mode = AS_UTILITY_PVT.G_CREATE)
     THEN
         l_opp_rec.freeze_flag := 'N';
     END IF;
     -- solin

     x_opp_rec := l_opp_rec;

End Set_opp_default_values;


PROCEDURE HEADER_CREATE_NOTE(
    p_validation_level IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_header_rec       IN  AS_OPPORTUNITY_PUB.Header_Rec_Type,
    p_lead_number      IN  VARCHAR2,
    p_win_prob         IN  NUMBER,
    p_status           IN  VARCHAR2,
    p_sales_stage_id   IN  NUMBER,
    p_decision_date    IN  DATE,
    x_note_id          OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
    )
 IS

CURSOR status_name(c_status_code VARCHAR2) IS
	select meaning
	from as_statuses_vl
	where STATUS_CODE = c_status_code;

CURSOR stage_name(c_sales_stage_id NUMBER) IS
 	SELECT name
	from as_sales_stages_all_vl
	where sales_stage_id = c_sales_stage_id;

Note_Message            VARCHAR2(2000);
l_status_name		VARCHAR2(240);
l_old_status_name	VARCHAR2(240);
l_stage_name 		VARCHAR2(60);
l_old_stage_name	VARCHAR2(60);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.HEADER_CREATE_NOTE';

 BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- If status has been changed; then generate a note to show the change
      --
      IF (p_header_rec.status_code <> p_status)
      THEN
   	   open status_name(p_status);
	   fetch status_name into l_old_status_name;
	   close status_name;

	   open status_name(p_header_rec.status_code);
	   fetch status_name into l_status_name;
	   close status_name;


           FND_MESSAGE.Set_Name('AS', 'AS_NOTE_OPP_STATUS_CHANGED');
           FND_MESSAGE.Set_Token('STATUS',l_status_name , FALSE);
           FND_MESSAGE.Set_Token('OLD_STATUS', l_old_status_name, FALSE);
           FND_MESSAGE.Set_Token('LEAD_NUM', p_lead_number, FALSE);
           Note_Message := FND_MESSAGE.Get;

           IF l_debug THEN
	           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                        Note_Message);
	   END IF;

           JTF_NOTES_PUB.Create_note (
               p_api_version          =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_commit               =>  FND_API.G_FALSE,
               p_validation_level     =>  p_validation_level,
               x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data,
               p_source_object_id     =>  p_header_rec.lead_id,
               p_source_object_code   =>  'OPPORTUNITY',
               p_notes                =>  Note_Message,
               p_note_status          =>  'E',
               p_note_type	      =>  'AS_SYSTEM',
               p_entered_by           =>  FND_GLOBAL.USER_ID,
               p_entered_date         =>  SYSDATE,
               x_jtf_note_id          =>  x_note_id,
               p_last_update_date     =>  SYSDATE,
               p_last_updated_by      =>  FND_GLOBAL.USER_ID,
               p_creation_date        =>  SYSDATE,
               p_created_by           =>  FND_GLOBAL.USER_ID,
               p_last_update_login    =>  FND_GLOBAL.LOGIN_ID
           );
      END IF;

      --
      -- If sales stage has been changed; then generate a note for it.
      --
      IF (p_header_rec.sales_stage_id <> p_sales_stage_id)
      THEN

	   OPEN stage_name(p_header_rec.sales_stage_id);
	   fetch stage_name into l_stage_name;
	   close stage_name;

       	   open stage_name(p_sales_stage_id);
	   fetch stage_name into l_old_stage_name;
	   close stage_name;

           FND_MESSAGE.Set_Name('AS', 'AS_NOTE_OPP_STAGE_CHANGED');
           FND_MESSAGE.Set_Token('STAGE',l_stage_name , FALSE);
           FND_MESSAGE.Set_Token('OLD_STAGE', l_old_stage_name, FALSE);
           FND_MESSAGE.Set_Token('LEAD_NUM', p_lead_number, FALSE);
           Note_Message := FND_MESSAGE.Get;

           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                        Note_Message);
	   END IF;

           JTF_NOTES_PUB.Create_note (
               p_api_version          =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_commit               =>  FND_API.G_FALSE,
               p_validation_level     =>  p_validation_level,
               x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data,
               p_source_object_id     =>  p_header_rec.lead_id,
               p_source_object_code   =>  'OPPORTUNITY',
               p_notes                =>  Note_Message,
               p_note_status          =>  'E',
               p_note_type	      =>  'AS_SYSTEM',
               p_entered_by           =>  FND_GLOBAL.USER_ID,
               p_entered_date         =>  SYSDATE,
               x_jtf_note_id          =>  x_note_id,
               p_last_update_date     =>  SYSDATE,
               p_last_updated_by      =>  FND_GLOBAL.USER_ID,
               p_creation_date        =>  SYSDATE,
               p_created_by           =>  FND_GLOBAL.USER_ID,
               p_last_update_login    =>  FND_GLOBAL.LOGIN_ID
           );
      END IF;

      --
      -- If win probability has been changed; then generate a note for it.
      --
      IF (p_header_rec.win_probability <> p_win_prob)
      THEN
           FND_MESSAGE.Set_Name('AS', 'AS_NOTE_OPP_PROB_CHANGED');
           FND_MESSAGE.Set_Token('PROBABILITY', p_header_rec.win_probability,
                                 FALSE);
           FND_MESSAGE.Set_Token('OLD_PROBABILITY', p_win_prob, FALSE);
           FND_MESSAGE.Set_Token('LEAD_NUM', p_lead_number, FALSE);
           Note_Message := FND_MESSAGE.Get;

           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                        Note_Message);
	   END IF;


           JTF_NOTES_PUB.Create_note (
               p_api_version          =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_commit               =>  FND_API.G_FALSE,
               p_validation_level     =>  p_validation_level,
               x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data,
               p_source_object_id     =>  p_header_rec.lead_id,
               p_source_object_code   =>  'OPPORTUNITY',
               p_notes                =>  Note_Message,
               p_note_status          =>  'E',
               p_note_type	      =>  'AS_SYSTEM',
               p_entered_by           =>  FND_GLOBAL.USER_ID,
               p_entered_date         =>  SYSDATE,
               x_jtf_note_id          =>  x_note_id,
               p_last_update_date     =>  SYSDATE,
               p_last_updated_by      =>  FND_GLOBAL.USER_ID,
               p_creation_date        =>  SYSDATE,
               p_created_by           =>  FND_GLOBAL.USER_ID,
               p_last_update_login    =>  FND_GLOBAL.LOGIN_ID
           );
      END IF;

      --
      -- If decision date has been changed; then generate a note for it.
      --
      IF (p_header_rec.decision_date <> p_decision_date)
      THEN
           FND_MESSAGE.Set_Name('AS', 'AS_NOTE_OPP_DATE_CHANGED');
           FND_MESSAGE.Set_Token('DATE', p_header_rec.decision_date, FALSE);
           FND_MESSAGE.Set_Token('OLD_DATE', p_decision_date, FALSE);
           FND_MESSAGE.Set_Token('LEAD_NUM', p_lead_number, FALSE);
           Note_Message := FND_MESSAGE.Get;

           IF l_debug THEN
           AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                        Note_Message);
	   END IF;

           JTF_NOTES_PUB.Create_note (
               p_api_version          =>  1.0,
               p_init_msg_list        =>  FND_API.G_FALSE,
               p_commit               =>  FND_API.G_FALSE,
               p_validation_level     =>  p_validation_level,
               x_return_status        =>  x_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data,
               p_source_object_id     =>  p_header_rec.lead_id,
               p_source_object_code   =>  'OPPORTUNITY',
               p_notes                =>  Note_Message,
               p_note_status          =>  'E',
               p_note_type	      =>  'AS_SYSTEM',
               p_entered_by           =>  FND_GLOBAL.USER_ID,
               p_entered_date         =>  SYSDATE,
               x_jtf_note_id          =>  x_note_id,
               p_last_update_date     =>  SYSDATE,
               p_last_updated_by      =>  FND_GLOBAL.USER_ID,
               p_creation_date        =>  SYSDATE,
               p_created_by           =>  FND_GLOBAL.USER_ID,
               p_last_update_login    =>  FND_GLOBAL.LOGIN_ID
           );
      END IF;

END HEADER_CREATE_NOTE;

-- Local procedure

PROCEDURE Recreate_tasks(
    p_LEAD_ID			IN  NUMBER,
    p_RESOURCE_ID		IN  NUMBER,
    p_OLD_SALES_METHODOLOGY_ID	IN  NUMBER,
    p_OLD_SALES_STAGE_ID	IN  NUMBER,
    p_SALES_METHODOLOGY_ID	IN  NUMBER,
    p_SALES_STAGE_ID		IN  NUMBER,
    x_return_status 		OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    X_Warning_Message		OUT NOCOPY VARCHAR2 )
IS

CURSOR template ( c_sales_methodology_id number, c_sales_stage_id number) IS
    select TASK_TEMPLATE_GROUP_ID
    from as_sales_meth_stage_map
    where SALES_METHODOLOGY_ID = c_sales_methodology_id
    and SALES_STAGE_ID = c_sales_stage_id;

l_tmplate_group_id NUMBER;

l_return_status varchar2(10);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Recreate_tasks';

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      X_Warning_Message	:= NULL;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'LEAD_ID/RS_ID: '||p_LEAD_ID || ',' ||p_RESOURCE_ID );
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'OLD_SM/SS_ID: '|| p_OLD_SALES_METHODOLOGY_ID||',' || p_OLD_SALES_STAGE_ID);
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
            'SM/SS_ID: ' || p_SALES_METHODOLOGY_ID ||',' || p_SALES_STAGE_ID  );
      END IF;

      IF (p_SALES_METHODOLOGY_ID IS NOT NULL) AND
	 (p_SALES_METHODOLOGY_ID <> FND_API.G_MISS_NUM ) THEN

	  IF ((nvl(p_OLD_SALES_METHODOLOGY_ID, -99) <> p_SALES_METHODOLOGY_ID) OR
              (nvl(p_OLD_SALES_STAGE_ID, -99) <> p_SALES_STAGE_ID) ) AND
	     nvl(FND_PROFILE.VALUE ('AS_SM_CREATE_TASKS'), 'N') = 'Y' THEN

		open template(p_sales_methodology_id, p_sales_stage_id);
	  	fetch template into l_tmplate_group_id ;
		close template;

		IF(l_tmplate_group_id IS NOT NULL) THEN
      			IF l_debug THEN
      			AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                	               'Lunching workflow for autotask creation');
			END IF;
	        -- lunch workflow
		as_sales_meth_wf.start_methodology(
 			P_SOURCE_OBJECT_TYPE_CODE 	=> 'OPPORTUNITY',
 			P_SOURCE_OBJECT_ID		=> p_lead_id,
 			P_SOURCE_OBJECT_NAME           	=> to_char(p_lead_id),
 			P_OWNER_ID                     	=> p_resource_id,
 			P_OWNER_TYPE_CODE              	=> 'RS_EMPLOYEE',
 			P_OBJECT_TYPE_CODE             	=> 'SALES_STAGE',
 			P_CURRENT_STAGE_ID             	=> p_OLD_SALES_STAGE_ID,
 			P_NEXT_STAGE_ID                	=> p_SALES_STAGE_ID,
 			P_TEMPLATE_GROUP_ID            	=> to_char(l_tmplate_group_id),
 			ITEM_TYPE                      	=> 'SAL_MET3',
 			WORKFLOW_PROCESS               	=> 'SAL_MET3',
 			X_RETURN_STATUS                	=> l_return_status,
                  	X_Msg_Count                     => X_Msg_Count,
                	X_Msg_Data                      => X_Msg_Data,
			X_Warning_Message		=> X_Warning_Message);

		END IF;

          END IF;
      END IF;

      if (l_return_status is not null) then
          x_return_status := substr(l_return_status, 1, 1);
      end if;

      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'x_return_status: ' || x_return_status );
      END IF;

EXCEPTION
      WHEN OTHERS
      THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Recreate_tasks;


PROCEDURE Update_Competitor_Products(
    p_LEAD_ID			IN  NUMBER,
    p_STATUS_CODE		IN VARCHAR2,
    x_return_status 		OUT NOCOPY VARCHAR2)
IS

CURSOR c_WIN_LOSS_INDICATOR(c_STATUS_CODE VARCHAR2) IS
	select WIN_LOSS_INDICATOR
	from as_statuses_b
	where status_code = c_STATUS_CODE;

l_indicator  varchar2(1);

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      open c_WIN_LOSS_INDICATOR( p_STATUS_CODE);
      fetch c_WIN_LOSS_INDICATOR into l_indicator;
      close c_WIN_LOSS_INDICATOR;

      IF ( nvl(l_indicator, 'L') = 'W') THEN
	  UPDATE AS_LEAD_COMP_PRODUCTS
	  SET object_version_number =  nvl(object_version_number,0) + 1, WIN_LOSS_STATUS = 'LOST'
	  WHERE LEAD_ID = p_LEAD_ID;
      END IF;


EXCEPTION
      WHEN no_data_found THEN NULL;

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Competitor_Products;


/*

PROCEDURE Create_lead_competitor(
    p_api_version_number    IN     NUMBER,
    p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN     NUMBER   := 0,
    p_check_access_flag     IN 	   VARCHAR2,
    p_admin_flag	    IN 	   VARCHAR2,
    p_admin_group_id	    IN	   NUMBER,
    p_identity_salesforce_id IN    NUMBER   := NULL,
    p_partner_cont_party_id   IN     NUMBER,
    p_profile_tbl	    IN     AS_UTILITY_PUB.Profile_Tbl_Type
				   :=AS_UTILITY_PUB.G_MISS_PROFILE_TBL,
    p_LEAD_ID		    IN     NUMBER,
    p_COMPETITOR_ID	    IN     NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2)
IS

CURSOR  competitor_exist IS
	select 'Y'
	from as_lead_competitors
	where lead_id = p_lead_id
	and competitor_id = p_competitor_id;

l_competitor_exist  VARCHAR2(1);

l_competitor_rec	AS_OPPORTUNITY_PUB.Competitor_rec_Type;
l_competitor_tbl        AS_OPPORTUNITY_PUB.Competitor_tbl_Type;
x_competitor_out_tbl    AS_OPPORTUNITY_PUB.Competitor_Out_Tbl_Type;

BEGIN

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open competitor_exist;
    fetch competitor_exist into l_competitor_exist;
    close competitor_exist;
    IF l_competitor_exist is null THEN

        l_Competitor_rec.last_update_date 	:= SYSDATE;
        l_Competitor_rec.last_updated_by        := FND_GLOBAL.USER_ID;
        l_Competitor_rec.creation_Date 	        := SYSDATE;
        l_Competitor_rec.created_by 		:= FND_GLOBAL.USER_ID;
        l_Competitor_rec.last_update_login 	:= FND_GLOBAL.CONC_LOGIN_ID;
	l_Competitor_rec.LEAD_ID                := p_lead_id;
	l_Competitor_rec.COMPETITOR_ID          := p_competitor_id;

	l_competitor_tbl(1) := l_Competitor_rec;

        AS_OPP_competitor_PVT.Create_competitors(
        	P_Api_Version_Number         => 2.0,
        	P_Init_Msg_List              => FND_API.G_FALSE,
        	P_Commit                     => p_commit,
        	P_Validation_Level           => P_Validation_Level,
        	P_Check_Access_Flag          => p_check_access_flag,
        	P_Admin_Flag                 => P_Admin_Flag,
        	P_Admin_Group_Id             => P_Admin_Group_Id,
        	P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
        	P_Partner_Cont_Party_Id	     => p_partner_cont_party_id,
        	P_Profile_Tbl                => P_Profile_tbl,
        	P_Competitor_Tbl             => l_competitor_tbl,
        	X_Competitor_Out_Tbl         => x_competitor_out_tbl,
        	X_Return_Status              => x_return_status,
        	X_Msg_Count                  => x_msg_count,
        	X_Msg_Data                   => x_msg_data);
    END IF;

END Create_lead_competitor;
*/

PROCEDURE Set_Owner( p_access_id NUMBER)
IS

CURSOR c_acc IS
	select lead_id, salesforce_id, sales_group_id
	from as_accesses_all
	where access_id = p_access_id;

BEGIN
    FOR acr IN c_acc LOOP

	UPDATE AS_ACCESSES_ALL
	SET object_version_number =  nvl(object_version_number,0) + 1, OWNER_FLAG = 'Y'
	WHERE ACCESS_ID = p_access_id;

	UPDATE AS_LEADS_ALL
	SET object_version_number =  nvl(object_version_number,0) + 1, owner_salesforce_id = acr.salesforce_id,
	    owner_sales_group_id = acr.sales_group_id
	WHERE lead_id = acr.lead_id;

    END LOOP;

END Set_Owner;




PROCEDURE Create_opp_header(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag        IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag               IN   VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id           IN   NUMBER,
    P_Identity_Salesforce_Id   IN   NUMBER       := NULL,
    P_salesgroup_id            IN   NUMBER       := NULL,
    P_profile_tbl              IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id    IN   NUMBER       := FND_API.G_MISS_NUM,
    P_Header_Rec               IN   AS_OPPORTUNITY_PUB.Header_Rec_Type
                                      := AS_OPPORTUNITY_PUB.G_MISS_Header_REC,
    X_LEAD_ID                  OUT NOCOPY  NUMBER,
    X_Return_Status            OUT NOCOPY  VARCHAR2,
    X_Msg_Count                OUT NOCOPY  NUMBER,
    X_Msg_Data                 OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_opp_header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
l_return_status_full      VARCHAR2(1);
l_identity_sales_member_rec AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_LEAD_ID                 NUMBER;
l_header_rec              AS_OPPORTUNITY_PUB.Header_Rec_Type
						:= P_Header_Rec;
l_header_rec1             AS_OPPORTUNITY_PUB.Header_Rec_Type;

l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_access_id               NUMBER;
l_Sales_Team_Rec          AS_ACCESS_PUB.Sales_Team_Rec_Type
                              := AS_ACCESS_PUB.G_MISS_SALES_TEAM_REC;

l_old_sales_methodology_id NUMBER := null;
l_old_sales_stage_id NUMBER := null;

l_is_owner	VARCHAR2(1) := 'N';

l_warning_msg 		VARCHAR2(2000) := '';
l_winprob_warning_msg 	VARCHAR2(2000) := '';

l_default_address_profile	VARCHAR2(1) := FND_PROFILE.VALUE ('AS_OPP_DEFAULT_ADDRESS');

CURSOR get_person_id_csr(c_salesforce_id NUMBER) is
     select employee_person_id
     from as_salesforce_v
     where salesforce_id = c_salesforce_id;

/* ffang 091100 for bug 1401095
CURSOR c_salesgroup_id(p_resource_id number) IS
     SELECT group_id
     FROM JTF_RS_GROUP_MEMBERS
     WHERE resource_id = p_resource_id
     ORDER BY GROUP_ID;
l_salesgroup_id Number:=Null;
*/
l_salesgroup_id Number := p_salesgroup_id;
l_person_id 		NUMBER;


CURSOR primary_address ( p_customer_id NUMBER) IS
	select party_site_id
	from hz_party_sites
	where party_id = p_customer_id
	and IDENTIFYING_ADDRESS_FLAG = 'Y';
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Create_opp_header';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_OPP_HEADER_PVT;

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

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y',
      -- callout procedure is invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_opp_header_BC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Header_Rec           =>  l_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          -- relationship.
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
              -- FND_MESSAGE.Set_Name(' + appShortName +',
              --                   'UT_CANNOT_GET_PROFILE_VALUE');
              -- FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              -- FND_MSG_PUB.ADD;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');

          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Before Get_CurrentUser '|| x_return_status);
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

      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'After Get_CurrentUser '|| x_return_status);
      END IF;

      -- Set default value to decision_date, channel_code, status_code,
      -- sales_stage_id, win_probability, freeze_flag, and currency_code
      -- as profile values.
      If (l_Header_Rec.decision_date IS NULL) or
         (l_Header_Rec.decision_date = FND_API.G_MISS_DATE) or
         (l_Header_Rec.channel_code IS NULL) or
         (l_Header_Rec.channel_code = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.STATUS_CODE IS NULL) or
         (l_Header_Rec.STATUS_CODE = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.sales_stage_id IS NULL) or
         (l_Header_Rec.sales_stage_id = FND_API.G_MISS_NUM) or
         (l_Header_Rec.win_probability IS NULL) or
         (l_Header_Rec.win_probability = FND_API.G_MISS_NUM) or
         (l_Header_Rec.currency_code IS NULL) or
         (l_Header_Rec.currency_code = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.deleted_flag IS NULL) or
         (l_Header_Rec.deleted_flag = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.auto_assignment_type IS NULL) or  -- acng, bug 2044908
         (l_Header_Rec.auto_assignment_type = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.prm_assignment_type IS NULL) or   -- acng, bug 2044908
         (l_Header_Rec.prm_assignment_type = FND_API.G_MISS_CHAR) or
         (l_Header_Rec.freeze_flag IS NULL) or            -- solin, bug 1554330
         (l_Header_Rec.freeze_flag = FND_API.G_MISS_CHAR) -- solin, bug 1554330
      THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       	'Calling Set_opp_default_values');
	  END IF;

	  l_header_rec1 := l_header_rec;
          Set_opp_default_values(
                p_mode       => AS_UTILITY_PVT.G_CREATE,
                p_opp_rec    => l_Header_Rec1,
                x_opp_rec    => l_Header_Rec );

      End If;

      -- Deafult the customer address to primary address if necessary
      IF nvl(l_default_address_profile, 'N') = 'Y' AND
         ((l_Header_Rec.address_id IS NULL) OR
          (l_Header_Rec.address_id = FND_API.G_MISS_NUM))
      THEN
	  open primary_address(l_Header_Rec.customer_id );
	  fetch  primary_address into l_Header_Rec.address_id;
	  close  primary_address;

	  If (l_Header_Rec.address_id IS NULL OR
	      l_Header_Rec.address_id = FND_API.G_MISS_NUM )
	  THEN
	      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'No primary address for customer');
	      END IF;

	  END IF;
      END IF;

      -- Trunc desidion date
      l_Header_Rec.decision_date := trunc(l_Header_Rec.decision_date);

      -- Debug message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Validate_opp_header');
      END IF;


      -- Invoke validation procedures
      Validate_opp_header(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_CREATE,
          P_Header_Rec       => l_Header_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          l_winprob_warning_msg := x_msg_data;
      END IF;




      -- Access checking
      IF p_check_access_flag = 'Y'
      THEN
          -- Call Get_Access_Profiles to get access_profile_rec
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Calling Get_Access_Profiles');
	  END IF;

          AS_OPPORTUNITY_PUB.Get_Access_Profiles(
              p_profile_tbl         => p_profile_tbl,
              x_access_profile_rec  => l_access_profile_rec);

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
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
              p_customer_id            => P_Header_Rec.customer_id,
              p_check_access_flag      => 'Y',
              p_identity_salesforce_id => p_identity_salesforce_id,
              p_partner_cont_party_id  => NULL,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              x_view_access_flag       => l_access_flag);

          IF l_access_flag <> 'Y' THEN
              AS_UTILITY_PVT.Set_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
                                           'API_NO_CREATE_PRIVILEGE');
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;



      END IF;


      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling create table handler');
      END IF;


      l_LEAD_ID := l_Header_Rec.LEAD_ID;

	 IF l_debug THEN
	 	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'OFFER_ID: ' || p_header_rec.OFFER_ID);
	 END IF;

      -- Hardcoding to NULL for R12 since it will be filled in when
      -- Lines are created
      l_header_rec.TOTAL_REVENUE_OPP_FORECAST_AMT := NULL;

      -- Invoke table handler(AS_LEADS_PKG.Insert_Row)
      AS_LEADS_PKG.Insert_Row(
          px_LEAD_ID  => l_LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => l_Header_Rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_Header_Rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_Header_Rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_Header_Rec.PROGRAM_UPDATE_DATE,
          p_LEAD_NUMBER  => l_Header_Rec.LEAD_NUMBER,
          p_STATUS  => l_Header_Rec.STATUS_CODE,
          p_CUSTOMER_ID  => l_Header_Rec.CUSTOMER_ID,
          p_ADDRESS_ID  => l_Header_Rec.ADDRESS_ID,
          p_SALES_STAGE_ID  => l_header_rec.SALES_STAGE_ID,
          p_INITIATING_CONTACT_ID  => l_header_rec.INITIATING_CONTACT_ID,
          p_CHANNEL_CODE  => l_header_rec.CHANNEL_CODE,
          p_TOTAL_AMOUNT  => l_header_rec.TOTAL_AMOUNT,
          p_CURRENCY_CODE  => l_header_rec.CURRENCY_CODE,
          p_DECISION_DATE  => l_header_rec.DECISION_DATE,
          p_WIN_PROBABILITY  => l_header_rec.WIN_PROBABILITY,
          p_CLOSE_REASON  => l_header_rec.CLOSE_REASON,
          p_CLOSE_COMPETITOR_CODE  => l_header_rec.CLOSE_COMPETITOR_CODE,
          p_CLOSE_COMPETITOR  => l_header_rec.CLOSE_COMPETITOR,
          p_CLOSE_COMMENT  => l_header_rec.CLOSE_COMMENT,
          p_DESCRIPTION  => l_header_rec.DESCRIPTION,
          p_RANK  => l_header_rec.RANK,
          p_SOURCE_PROMOTION_ID  => l_header_rec.SOURCE_PROMOTION_ID,
          p_END_USER_CUSTOMER_ID  => l_header_rec.END_USER_CUSTOMER_ID,
          p_END_USER_ADDRESS_ID  => l_header_rec.END_USER_ADDRESS_ID,
          p_OWNER_SALESFORCE_ID  => l_header_rec.OWNER_SALESFORCE_ID,
          p_OWNER_SALES_GROUP_ID => l_header_rec.OWNER_SALES_GROUP_ID,
          --p_OWNER_ASSIGN_DATE  => l_header_rec.OWNER_ASSIGN_DATE,
          p_ORG_ID  => l_header_rec.ORG_ID,
          p_NO_OPP_ALLOWED_FLAG  => l_header_rec.NO_OPP_ALLOWED_FLAG,
          p_DELETE_ALLOWED_FLAG  => l_header_rec.DELETE_ALLOWED_FLAG,
          p_ATTRIBUTE_CATEGORY  => l_header_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_header_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_header_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_header_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_header_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_header_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_header_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_header_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_header_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_header_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_header_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_header_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_header_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_header_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_header_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_header_rec.ATTRIBUTE15,
          p_PARENT_PROJECT  => l_header_rec.PARENT_PROJECT,
          p_LEAD_SOURCE_CODE  => l_header_rec.LEAD_SOURCE_CODE,
          p_ORIG_SYSTEM_REFERENCE  => l_header_rec.ORIG_SYSTEM_REFERENCE,
          p_CLOSE_COMPETITOR_ID  => l_header_rec.CLOSE_COMPETITOR_ID,
          p_END_USER_CUSTOMER_NAME  => l_header_rec.END_USER_CUSTOMER_NAME,
          p_PRICE_LIST_ID  => l_header_rec.PRICE_LIST_ID,
          p_DELETED_FLAG  => l_header_rec.DELETED_FLAG,
          p_AUTO_ASSIGNMENT_TYPE  => l_header_rec.AUTO_ASSIGNMENT_TYPE,
          p_PRM_ASSIGNMENT_TYPE  => l_header_rec.PRM_ASSIGNMENT_TYPE,
          p_CUSTOMER_BUDGET  => l_header_rec.CUSTOMER_BUDGET,
          p_METHODOLOGY_CODE  => l_header_rec.METHODOLOGY_CODE,
          p_SALES_METHODOLOGY_ID  => l_header_rec.SALES_METHODOLOGY_ID,
          p_ORIGINAL_LEAD_ID  => l_header_rec.ORIGINAL_LEAD_ID,
          p_DECISION_TIMEFRAME_CODE  => l_header_rec.DECISION_TIMEFRAME_CODE,
          p_INC_PARTNER_RESOURCE_ID=>l_header_rec.INCUMBENT_PARTNER_RESOURCE_ID,
          p_INC_PARTNER_PARTY_ID  => l_header_rec.INCUMBENT_PARTNER_PARTY_ID,
          p_OFFER_ID  => l_header_rec.OFFER_ID,
          p_VEHICLE_RESPONSE_CODE  => l_header_rec.VEHICLE_RESPONSE_CODE,
          p_BUDGET_STATUS_CODE  => l_header_rec.BUDGET_STATUS_CODE,
          p_FOLLOWUP_DATE  => l_header_rec.FOLLOWUP_DATE,
          p_PRM_EXEC_SPONSOR_FLAG  => l_header_rec.PRM_EXEC_SPONSOR_FLAG,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG=>l_header_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
          p_PRM_IND_CLASSIFICATION_CODE =>
                                  l_header_rec.PRM_IND_CLASSIFICATION_CODE,
          p_PRM_LEAD_TYPE => l_header_rec.PRM_LEAD_TYPE,
          p_FREEZE_FLAG => l_header_rec.FREEZE_FLAG,
          p_PRM_REFERRAL_CODE => l_header_rec.PRM_REFERRAL_CODE,
          p_TOT_REVENUE_OPP_FORECAST_AMT => l_header_rec.TOTAL_REVENUE_OPP_FORECAST_AMT); -- Added for ASNB

      x_LEAD_ID := l_LEAD_ID;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      /* ffang 091100 for bug 1401095
      -- Get the salesgroup_id
      l_salesgroup_id := null;
      OPEN c_salesgroup_id(P_Identity_Salesforce_Id);
        FETCH c_salesgroup_id INTO l_salesgroup_id;
      CLOSE c_salesgroup_id;
      */

      l_Sales_Team_Rec.last_update_date      := SYSDATE;
      l_Sales_Team_Rec.last_updated_by       := FND_GLOBAL.USER_ID;
      l_Sales_Team_Rec.creation_date         := SYSDATE;
      l_Sales_Team_Rec.created_by            := FND_GLOBAL.USER_ID;
      l_Sales_Team_Rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;
      l_Sales_Team_Rec.team_leader_flag      := FND_API.G_MISS_CHAR;
      l_Sales_Team_Rec.customer_id           := l_header_rec.Customer_Id;
      l_Sales_Team_Rec.address_id            := l_header_rec.Address_Id;
      l_Sales_Team_Rec.salesforce_id         := P_Identity_Salesforce_Id;
      --l_Sales_Team_Rec.partner_cont_party_id := p_partner_cont_party_id;
      l_Sales_Team_Rec.lead_id               := x_lead_id;
      l_Sales_Team_Rec.team_leader_flag      := 'Y';
      l_Sales_Team_Rec.reassign_flag         := 'N';
      l_Sales_Team_Rec.freeze_flag           :=
                         nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');

      l_sales_team_rec.sales_group_id        := l_salesgroup_id;
      l_sales_team_rec.salesforce_role_code  := FND_PROFILE.Value('AS_DEF_OPP_ST_ROLE');

      OPEN get_person_id_csr(P_Identity_Salesforce_Id);
      FETCH get_person_id_csr into l_Sales_Team_Rec.person_id;

      IF (get_person_id_csr%NOTFOUND)
      THEN
          l_Sales_Team_Rec.person_id := NULL;
      END IF;
      CLOSE get_person_id_csr;

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'owner_sf_id: '||l_header_rec.owner_salesforce_id );
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'owner_sg_id: '||l_header_rec.owner_sales_group_id );
      END IF;


      -- If owner = creater = employee then set the owner_flag for the salesteam record.
      IF (l_header_rec.owner_salesforce_id IS NOT NULL) AND
	 (l_header_rec.owner_sales_group_id IS NOT NULL) AND
	 (l_header_rec.owner_salesforce_id = P_Identity_Salesforce_Id ) AND
	 (l_header_rec.owner_sales_group_id = l_salesgroup_id ) AND
	 Is_Employee(l_header_rec.owner_salesforce_id)
      THEN
	  --l_sales_team_rec.owner_flag := 'Y';
          l_Sales_Team_Rec.freeze_flag := 'Y';
	  l_is_owner := 'Y';
      END IF;

      -- If owner is not selected and creator is employee
      -- then set the owner_flag for the creater salesteam record.
      IF (l_header_rec.owner_salesforce_id IS NULL OR
	  l_header_rec.owner_salesforce_id = FND_API.G_MISS_NUM ) AND
	 (l_header_rec.owner_sales_group_id IS NULL OR
	  l_header_rec.owner_sales_group_id = FND_API.G_MISS_NUM ) AND
 	 Is_Employee(P_Identity_Salesforce_Id)
      THEN
	  --l_sales_team_rec.owner_flag := 'Y';
          --l_Sales_Team_Rec.freeze_flag := 'Y';
	  l_Sales_Team_Rec.freeze_flag := nvl(FND_PROFILE.Value('AS_DEFAULT_FREEZE_FLAG'), 'Y');
	  l_is_owner := 'Y';
      END IF;

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
        ,p_check_access_flag          => 'O' -- P_Check_Access_flag
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
                           'Create_SalesTeam:l_access_id = ' || l_access_id);
      END IF;



      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( l_is_owner = 'Y' ) THEN
	  Set_owner(l_access_id );
      END IF;

      -- Create salesteam record for owner if different from creater
      IF (l_header_rec.owner_salesforce_id IS NOT NULL) AND
 	 (l_header_rec.owner_salesforce_id <> FND_API.G_MISS_NUM ) AND
	 (l_header_rec.owner_salesforce_id <> P_Identity_Salesforce_Id OR
	  l_header_rec.owner_sales_group_id <>l_salesgroup_id )
      THEN
	  l_Sales_Team_Rec.salesforce_id  := l_header_rec.owner_salesforce_id;
	  l_sales_team_rec.sales_group_id := l_header_rec.owner_sales_group_id;

      	  OPEN get_person_id_csr(l_header_rec.owner_salesforce_id);
      	  FETCH get_person_id_csr into l_Sales_Team_Rec.person_id;
      	  CLOSE get_person_id_csr;

	  --l_sales_team_rec.owner_flag := 'Y';
          l_Sales_Team_Rec.freeze_flag := 'Y';
	  l_is_owner := 'Y';

      	  -- Debug Message
      	  IF l_debug THEN
      	  AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Calling Create_SalesTeam for owner');
	  END IF;

      	  AS_ACCESS_PUB.Create_SalesTeam (
         	p_api_version_number         => 2.0
        	,p_init_msg_list              => FND_API.G_FALSE
         	,p_commit                     => FND_API.G_FALSE
        	,p_validation_level           => p_Validation_Level
        	,p_access_profile_rec         => l_access_profile_rec
        	,p_check_access_flag          => 'O' -- P_Check_Access_flag
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
      	  	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Create_Owner_ST:l_access_id = ' || l_access_id);
      	  END IF;



      	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           	RAISE FND_API.G_EXC_ERROR;
      	  END IF;

    	  IF ( l_is_owner = 'Y' ) THEN
	      Set_owner(l_access_id );
      	  END IF;

      END IF;

      -- Assign/Reassign the territory resources for the opportunity
      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Calling Opportunity Real Time API');
      END IF;


      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
    	  P_Api_Version_Number         => 1.0,
    	  P_Init_Msg_List              => FND_API.G_FALSE,
    	  P_Commit                     => FND_API.G_FALSE,
    	  p_lead_id		       => l_lead_id,
     	  X_Return_Status              => x_return_status,
    	  X_Msg_Count                  => x_msg_count,
    	  X_Msg_Data                   => x_msg_data
    	);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Opportunity Real Time API fail');
	    END IF;
            RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Calling Recreate_tasks');
      END IF;

      Recreate_tasks(
    		p_LEAD_ID		 	=> l_lead_id,
    		p_RESOURCE_ID			=> p_identity_salesforce_id,
    		p_OLD_SALES_METHODOLOGY_ID	=> l_old_sales_methodology_id,
    		p_OLD_SALES_STAGE_ID		=> l_old_sales_stage_id,
    		p_SALES_METHODOLOGY_ID		=> l_header_rec.SALES_METHODOLOGY_ID,
    		p_SALES_STAGE_ID		=> l_header_rec.SALES_STAGE_ID,
    		x_return_status 		=> x_return_status,
                X_Msg_Count                     => X_Msg_Count,
                X_Msg_Data                      => X_Msg_Data,
		X_Warning_Message		=> l_warning_msg );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Recreate_tasks fail');
	    END IF;

            RAISE FND_API.G_EXC_ERROR;
      END IF;


/*
      -- Create lead competitor
      IF (l_header_rec.CLOSE_COMPETITOR_ID  IS NOT NULL) AND
	 (l_header_rec.CLOSE_COMPETITOR_ID  <> FND_API.G_MISS_NUM ) THEN

          Create_lead_competitor(
      		P_Api_Version_Number         => 2.0,
      		P_Init_Msg_List              => FND_API.G_FALSE,
      		P_Commit                     => p_commit,
      		P_Validation_Level           => P_Validation_Level,
      		P_Check_Access_Flag          => p_check_access_flag,
      		P_Admin_Flag                 => P_Admin_Flag,
      		P_Admin_Group_Id             => P_Admin_Group_Id,
      		P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      		P_Partner_Cont_Party_Id	     => p_partner_cont_party_id,
      		P_Profile_Tbl                => P_Profile_tbl,
    		p_LEAD_ID		     => l_lead_id,
		p_COMPETITOR_ID		     => l_header_rec.CLOSE_COMPETITOR_ID,
      		X_Return_Status              => x_return_status,
      		X_Msg_Count                  => x_msg_count,
      		X_Msg_Data                   => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug THEN
                	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Create lead competitor fail');
		END IF;

                RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
*/

      -- Update competitor Products for the win/loss status
      IF (l_lead_id IS NOT NULL)AND
         (l_header_rec.STATUS_CODE IS NOT NULL) AND
	 (l_header_rec.STATUS_CODE <> FND_API.G_MISS_CHAR ) THEN

	  Update_Competitor_Products(
    		p_LEAD_ID		=> l_lead_id,
    		p_STATUS_CODE		=> l_header_rec.STATUS_CODE,
    		x_return_status 	=> x_return_status);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug THEN
                	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Update competitor Products  fail');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
          END IF;

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
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: ' || l_api_name || ' end');
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_msg_data := l_winprob_warning_msg || '#####'|| l_warning_msg;
	--x_msg_data := l_warning_msg;
      END IF;



-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Create_opp_header_AC(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  P_Header_Rec           =>  l_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          -- relationship.
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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Create_opp_header;


PROCEDURE Update_opp_header(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_Msg_List              IN  VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN  VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Flag                 IN  VARCHAR2     := FND_API.G_FALSE,
    P_Admin_Group_Id             IN  NUMBER,
    P_Identity_Salesforce_Id     IN  NUMBER       := NULL,
    P_profile_tbl                IN  AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN  NUMBER       := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN  AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_opp_header(c_LEAD_ID Number) IS
    Select LAST_UPDATE_DATE, DELETED_FLAG,
           WIN_PROBABILITY, nvl(TOTAL_REVENUE_OPP_FORECAST_AMT, 0), STATUS,
           SALES_STAGE_ID, DECISION_DATE, LEAD_NUMBER, FREEZE_FLAG,
           sales_methodology_id, sales_stage_id, customer_id, address_id,
           owner_salesforce_id, owner_sales_group_id
    FROM AS_LEADS_ALL
    WHERE LEAD_ID = c_LEAD_ID
    For Update NOWAIT;

cursor c_close_reason(p_lead_id NUMBER) IS
 	select close_reason
	from as_leads_all
	where lead_id = p_lead_id;

cursor close_competitor_exist(p_lead_id NUMBER) IS
	select 'Y'
	from as_leads_all
	where lead_id = p_lead_id
	and close_competitor_id is not null;

cursor comp_required ( p_status_profile VARCHAR2, p_lead_id NUMBER) IS
	select 'Y'
	from 	as_leads_all ld,
		as_statuses_b st
	where 	ld.status = st.status_code
	and     ld.lead_id = p_lead_id
	and 	(( p_status_profile = 'BOTH' and
			( st.OPP_OPEN_STATUS_FLAG <> 'Y' or st.FORECAST_ROLLUP_FLAG = 'Y')) OR
		 ( p_status_profile = 'CLOSED' and st.OPP_OPEN_STATUS_FLAG <> 'Y') OR
		 ( p_status_profile = 'FORECASTED' and st.OPP_OPEN_STATUS_FLAG <> 'Y') );

CURSOR get_person_id_csr(c_salesforce_id NUMBER) is
     select employee_person_id
     from as_salesforce_v
     where salesforce_id = c_salesforce_id;

CURSOR c_sales_credit_amount (p_lead_id as_leads_all.lead_id%type) IS
	Select sales_credit_id, credit_type_id,credit_amount
	From as_sales_credits
	Where lead_id = p_lead_id;

CURSOR c_get_status_flags (p_status_code VARCHAR2) IS
    Select status.win_loss_indicator,
           status.forecast_rollup_flag
    From as_statuses_vl status
    Where status.status_code = p_status_code;

l_api_name                CONSTANT VARCHAR2(30) := 'Update_opp_header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
--l_tar_Header_rec        AS_OPPORTUNITY_PUB.Header_Rec_Type := P_Header_Rec;
l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_deleted_flag            VARCHAR2(1);
l_access_id               NUMBER;
l_last_update_date        DATE;
l_win_prob                NUMBER;
l_status                  VARCHAR2(30);
l_sales_stage_id          NUMBER;
l_decision_date           DATE;
l_lead_number             VARCHAR2(30);
l_freeze_flag             VARCHAR2(1); -- solin, bug 1554330
l_note_id                 NUMBER;
l_header_rec              AS_OPPORTUNITY_PUB.Header_Rec_Type := P_Header_Rec;
l_header_rec1             AS_OPPORTUNITY_PUB.Header_Rec_Type;
l_allow_flag              VARCHAR2(1); -- solin, bug 1554330

l_old_sales_methodology_id 	NUMBER := null;
l_old_sales_stage_id 		NUMBER := null;
l_new_SALES_METHODOLOGY_ID 		NUMBER := null;
l_new_SALES_STAGE_ID 		NUMBER := null;

l_comp_required_profile		VARCHAR2(1) := FND_PROFILE.VALUE ('AS_COMPETITOR_REQUIRED');

l_warning_msg 		VARCHAR2(2000) := '';
l_winprob_warning_msg 	VARCHAR2(2000) := '';

-- for owner update
l_customer_id		NUMBER;
l_address_id		NUMBER;
l_owner_salesforce_id   NUMBER;
l_owner_sales_group_id	NUMBER;
l_Sales_Team_Rec        AS_ACCESS_PUB.Sales_Team_Rec_Type
                              := AS_ACCESS_PUB.G_MISS_SALES_TEAM_REC;
l_opp_worst_forecast_amount NUMBER;
l_opp_forecast_amount       NUMBER;
l_opp_best_forecast_amount  NUMBER;
l_win_probability       NUMBER;
l_win_loss_indicator    as_statuses_b.win_loss_indicator%Type;
l_forecast_rollup_flag  as_statuses_b.forecast_rollup_flag%Type;
l_old_win_probability       NUMBER;
l_old_win_loss_indicator    as_statuses_b.win_loss_indicator%Type;
l_old_forecast_rollup_flag  as_statuses_b.forecast_rollup_flag%Type;
l_old_tot_rev_opp_forecast_amt NUMBER; -- Added for ASNB
l_tot_rev_opp_forecast_amt NUMBER; -- Added for R12
l_update_count             NUMBER;
l_count NUMBER;
l_forecast_credit_type_id CONSTANT NUMBER := FND_PROFILE.VALUE('AS_FORECAST_CREDIT_TYPE_ID');
l_temp_bool     BOOLEAN;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
x_lead_id		NUMBER;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Update_opp_header';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_OPP_HEADER_PVT;

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
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_opp_header_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Header_Rec      =>  l_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          -- relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

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
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');
      END IF;


      Open C_Get_opp_header( l_Header_rec.LEAD_ID);
      Fetch C_Get_opp_header into l_last_update_date, l_deleted_flag,
        l_win_prob, l_old_tot_rev_opp_forecast_amt, l_status,
        l_sales_stage_id, l_decision_date, l_lead_number, l_freeze_flag,
		l_old_sales_methodology_id, l_old_sales_stage_id,
		l_customer_id, l_address_id,
		l_owner_salesforce_id, l_owner_sales_group_id;

      -- Basic info for forecast defaulting, includes l_old_tot_rev_opp_forecast_amt and l_status from
      -- above cursor
      l_old_win_probability := l_win_prob;

      -- If deleted_flag is 'Y', this opportunity header has been soft deleted.
      IF (UPPER(l_deleted_flag) = 'Y')
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_DELETED_OPP_HEADER');

          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Moved the following section for bug 2407000
      -- solin, for bug 1554330
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

      IF ( C_Get_opp_header%NOTFOUND)
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              -- FND_MESSAGE.Set_Token ('INFO', 'opp_header', FALSE);
              -- FND_MSG_PUB.Add;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_OPP_HEADER_UPDATE');

          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
      END IF;
      close     C_Get_opp_header;

      If (l_Header_rec.last_update_date is NULL or
          l_Header_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              -- FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              -- FND_MSG_PUB.ADD;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LAST_UPDATE_DATE');

          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_Header_rec.last_update_date <> l_last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              -- FND_MESSAGE.Set_Token('INFO', 'opp_header', FALSE);
              -- FND_MSG_PUB.ADD;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_OPP_HEADER_CHANGED');

          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Set default value to decision_date, channel_code, status_code,
      -- sales_stage_id, win_probability, freeze_flag, and currency_code as
      -- profile values.
      If (l_Header_Rec.decision_date IS NULL) or
         (l_Header_Rec.channel_code IS NULL) or
         (l_Header_Rec.STATUS_CODE IS NULL) or
         (l_Header_Rec.sales_stage_id IS NULL) or
         (l_Header_Rec.win_probability IS NULL) or
         (l_Header_Rec.currency_code IS NULL) or
         (l_Header_Rec.freeze_flag IS NULL) or -- solin for B1554330
         (l_Header_Rec.auto_assignment_type IS NULL) or --ffang 091500 for B1407007
         (l_Header_Rec.prm_assignment_type IS NULL) --ffang 091500 for B1407007
      THEN
          IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Calling Set_opp_default_values');
          END IF;

	  l_header_rec1 := l_header_rec;
          Set_opp_default_values(
                p_mode       => AS_UTILITY_PVT.G_UPDATE,
                p_opp_rec    => l_Header_Rec1,
                x_opp_rec    => l_Header_Rec );

      End If;

      -- Trunc desidion date
      l_Header_Rec.decision_date := trunc(l_Header_Rec.decision_date);


      If(l_Header_Rec.close_reason = FND_API.G_MISS_CHAR) THEN
	open c_close_reason(l_Header_Rec.lead_id);
	fetch c_close_reason into l_Header_Rec.close_reason;
	close c_close_reason;
      END IF;

      -- Debug message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_opp_header');
      END IF;


      -- Invoke validation procedures
      Validate_opp_header(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_Header_Rec       => l_Header_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_winprob_warning_msg := x_msg_data;
      END IF;

/*
      -- Validate required close_competitor_id
      IF nvl(l_comp_required_profile, 'N') = 'Y' THEN
          open close_competitor_exist(l_Header_Rec.lead_id);
          fetch close_competitor_exist into l_close_competitor_exist;
          close close_competitor_exist;

          IF (nvl(l_close_competitor_exist, 'N') = 'N' AND
	     l_Header_Rec.CLOSE_COMPETITOR_ID = FND_API.G_MISS_NUM ) OR
	     l_Header_Rec.CLOSE_COMPETITOR_ID IS NULL
          THEN
	      open comp_required(l_comp_required_status, l_Header_Rec.lead_id);
	      fetch comp_required into l_comp_required;
	      close comp_required;

	      IF l_Header_Rec.win_probability >= to_number ( nvl(l_comp_required_prob, '101')) THEN
	 	l_comp_required := 'Y';
	      END IF;

	      IF nvl(l_comp_required, 'N') = 'Y' THEN
		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          	THEN
              	    AS_UTILITY_PVT.Set_Message(
                  	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	p_msg_name      => 'API_CLOSE_COMPETITOR_REQUIRED');
          	END IF;
          	raise FND_API.G_EXC_ERROR;
	      END IF;
          END IF;
      END IF;

*/
      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);


      -- Access checking
      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
          AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_opportunity_id         => l_Header_Rec.lead_id,
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
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- Create notes

      -- if profile AS_OPPTY_GENERATE_NOTES is Y;
      -- when status, decision_date, sales_stage_id, or win prob. changes,
      -- note will be created automatically.

      IF NVL(FND_PROFILE.Value('AS_OPPTY_GENERATE_NOTES'),'N') = 'Y'
      THEN

	  IF l_header_rec.status_code = FND_API.G_MISS_CHAR THEN
	      l_header_rec.status_code := l_status;
	  END IF;
	  IF l_header_rec.decision_date = FND_API.G_MISS_DATE THEN
	      l_header_rec.decision_date := l_decision_date;
	  END IF;
	  IF l_header_rec.sales_stage_id = FND_API.G_MISS_NUM THEN
	      l_header_rec.sales_stage_id := l_sales_stage_id;
	  END IF;
   	  IF l_header_rec.win_probability = FND_API.G_MISS_NUM THEN
	      l_header_rec.win_probability := l_win_prob;
	  END IF;

          IF (l_header_rec.status_code <> l_status) or
             (l_header_rec.decision_date <> l_decision_date) or
             (l_header_rec.sales_stage_id <> l_sales_stage_id) or
             (l_header_rec.win_probability <> l_win_prob)
          THEN
              -- Debug message
              IF l_debug THEN
              	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Create notes');
              END IF;

              IF (l_header_rec.lead_number is NOT NULL) and
                 (l_header_rec.lead_number <> FND_API.G_MISS_CHAR)
              THEN
                  l_lead_number := l_header_rec.lead_number;
              END IF;

              HEADER_CREATE_NOTE(
                  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                  p_header_rec       => l_header_rec,
                  p_lead_number      => l_lead_number,
                  p_win_prob         => l_win_prob,
                  p_status           => l_status,
                  p_sales_stage_id   => l_sales_stage_id,
                  p_decision_date    => l_decision_date,
                  x_note_id          => l_note_id,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data
              );

              IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSE
                  IF l_debug THEN
                  	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Notes created. note_id=' || l_note_id);
                  END IF;
              END IF;
          END IF;
      END IF;

      -- check the priviledge to change owner.

      IF ( nvl(l_header_rec.owner_salesforce_id, -99) <> FND_API.G_MISS_NUM AND
           nvl(l_header_rec.owner_salesforce_id, -99) <> nvl(l_owner_salesforce_id, -99)) OR
	 ( nvl(l_header_rec.owner_sales_group_id, -99) <> FND_API.G_MISS_NUM AND
	   nvl(l_header_rec.owner_sales_group_id, -99) <> nvl(l_owner_sales_group_id, -99))
      THEN
 	  -- check priviledge
      	  AS_ACCESS_PVT.has_oppOwnerAccess
	  (    p_api_version_number     => 2.0
	      ,p_init_msg_list          => p_init_msg_list
	      ,p_validation_level       => p_validation_level
	      ,p_access_profile_rec     => l_access_profile_rec
	      ,p_admin_flag             => p_admin_flag
	      ,p_admin_group_id         => p_admin_group_id
	      ,p_person_id              => l_identity_sales_member_rec.employee_person_id
	      ,p_lead_id         	=> l_Header_Rec.lead_id
	      ,p_check_access_flag      => 'Y'
	      ,p_identity_salesforce_id => p_identity_salesforce_id
	      ,p_partner_cont_party_id  => Null
	      ,x_return_status          => x_return_status
	      ,x_msg_count              => x_msg_count
	      ,x_msg_data               => x_msg_data
	      ,x_update_access_flag     => l_access_flag
   	  );

	  IF (l_access_flag <> 'Y') THEN
                IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.Set_Name('AS', 'API_NO_OPP_OWNER_PRIVILEGE');
		    FND_MSG_PUB.ADD;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
		    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'has_oppOwnerAccess fail');
		END IF;
                RAISE FND_API.G_EXC_ERROR;
	  END IF;
      END IF;



      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling update table handler');

      END IF;

      -- Begin get old and new values for forecast defaulting
      Open c_get_status_flags(l_status);
      Fetch c_get_status_flags Into l_old_win_loss_indicator, l_old_forecast_rollup_flag;
      IF c_get_status_flags%NOTFOUND THEN
          l_old_win_loss_indicator := NULL;
          l_old_forecast_rollup_flag := NULL;
      END IF;
      Close c_get_status_flags;

      l_win_probability := l_header_rec.WIN_PROBABILITY;
      IF l_win_probability = FND_API.G_MISS_NUM THEN
        l_win_probability := l_old_win_probability;
      END IF;

      IF l_status = l_header_rec.STATUS_CODE OR l_header_rec.STATUS_CODE = FND_API.G_MISS_CHAR THEN
        l_win_loss_indicator := l_old_win_loss_indicator;
        l_forecast_rollup_flag := l_old_forecast_rollup_flag;
      ELSE
        Open c_get_status_flags(l_header_rec.STATUS_CODE);
        Fetch c_get_status_flags Into l_win_loss_indicator, l_forecast_rollup_flag;
        IF c_get_status_flags%NOTFOUND THEN
            l_win_loss_indicator := NULL;
            l_forecast_rollup_flag := NULL;
        END IF;
        Close c_get_status_flags;
      END IF;

      l_tot_rev_opp_forecast_amt :=
        nvl(l_header_rec.TOTAL_REVENUE_OPP_FORECAST_AMT, FND_API.G_MISS_NUM);

      IF nvl(l_forecast_rollup_flag, 'N') <> 'Y' THEN
        l_tot_rev_opp_forecast_amt := FND_API.G_MISS_NUM;
      END IF;
      -- End get old and new values for forecast defaulting

      -- Invoke table handler(AS_LEADS_PKG.Update_Row)
      AS_LEADS_PKG.Update_Row(
          p_LEAD_ID  => l_Header_rec.LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_CREATED_BY  => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => l_Header_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => l_Header_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID  => l_Header_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE  => l_Header_rec.PROGRAM_UPDATE_DATE,
          p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,  -- l_Header_rec.LEAD_NUMBER,
          p_STATUS  => l_HEADER_REC.STATUS_CODE,
          p_CUSTOMER_ID  => l_Header_rec.CUSTOMER_ID,
          p_ADDRESS_ID  => l_Header_rec.ADDRESS_ID,
          p_SALES_STAGE_ID  => l_Header_rec.SALES_STAGE_ID,
          p_INITIATING_CONTACT_ID  => l_Header_rec.INITIATING_CONTACT_ID,
          p_CHANNEL_CODE  => l_Header_rec.CHANNEL_CODE,
          p_TOTAL_AMOUNT  => l_Header_rec.TOTAL_AMOUNT,
          p_CURRENCY_CODE  => l_Header_rec.CURRENCY_CODE,
          p_DECISION_DATE  => l_Header_rec.DECISION_DATE,
          p_WIN_PROBABILITY  => l_Header_rec.WIN_PROBABILITY,
          p_CLOSE_REASON  => l_Header_rec.CLOSE_REASON,
          p_CLOSE_COMPETITOR_CODE  => l_Header_rec.CLOSE_COMPETITOR_CODE,
          p_CLOSE_COMPETITOR  => l_Header_rec.CLOSE_COMPETITOR,
          p_CLOSE_COMMENT  => l_Header_rec.CLOSE_COMMENT,
          p_DESCRIPTION  => l_Header_rec.DESCRIPTION,
          p_RANK  => l_Header_rec.RANK,
          p_SOURCE_PROMOTION_ID  => l_Header_rec.SOURCE_PROMOTION_ID,
          p_END_USER_CUSTOMER_ID  => l_Header_rec.END_USER_CUSTOMER_ID,
          p_END_USER_ADDRESS_ID  => l_Header_rec.END_USER_ADDRESS_ID,
          p_OWNER_SALESFORCE_ID  => l_header_rec.OWNER_SALESFORCE_ID,
          p_OWNER_SALES_GROUP_ID => l_header_rec.OWNER_SALES_GROUP_ID,
          --p_OWNER_ASSIGN_DATE  => l_header_rec.OWNER_ASSIGN_DATE,
          p_ORG_ID  => l_Header_rec.ORG_ID,
          p_NO_OPP_ALLOWED_FLAG  => l_Header_rec.NO_OPP_ALLOWED_FLAG,
          p_DELETE_ALLOWED_FLAG  => l_Header_rec.DELETE_ALLOWED_FLAG,
          p_ATTRIBUTE_CATEGORY  => l_Header_rec.ATTRIBUTE_CATEGORY,
          p_ATTRIBUTE1  => l_Header_rec.ATTRIBUTE1,
          p_ATTRIBUTE2  => l_Header_rec.ATTRIBUTE2,
          p_ATTRIBUTE3  => l_Header_rec.ATTRIBUTE3,
          p_ATTRIBUTE4  => l_Header_rec.ATTRIBUTE4,
          p_ATTRIBUTE5  => l_Header_rec.ATTRIBUTE5,
          p_ATTRIBUTE6  => l_Header_rec.ATTRIBUTE6,
          p_ATTRIBUTE7  => l_Header_rec.ATTRIBUTE7,
          p_ATTRIBUTE8  => l_Header_rec.ATTRIBUTE8,
          p_ATTRIBUTE9  => l_Header_rec.ATTRIBUTE9,
          p_ATTRIBUTE10  => l_Header_rec.ATTRIBUTE10,
          p_ATTRIBUTE11  => l_Header_rec.ATTRIBUTE11,
          p_ATTRIBUTE12  => l_Header_rec.ATTRIBUTE12,
          p_ATTRIBUTE13  => l_Header_rec.ATTRIBUTE13,
          p_ATTRIBUTE14  => l_Header_rec.ATTRIBUTE14,
          p_ATTRIBUTE15  => l_Header_rec.ATTRIBUTE15,
          p_PARENT_PROJECT  => l_Header_rec.PARENT_PROJECT,
          p_LEAD_SOURCE_CODE  => l_Header_rec.LEAD_SOURCE_CODE,
          p_ORIG_SYSTEM_REFERENCE  => l_Header_rec.ORIG_SYSTEM_REFERENCE,
          p_CLOSE_COMPETITOR_ID  => l_Header_rec.CLOSE_COMPETITOR_ID,
          p_END_USER_CUSTOMER_NAME  => l_Header_rec.END_USER_CUSTOMER_NAME,
          p_PRICE_LIST_ID  => l_Header_rec.PRICE_LIST_ID,
          p_DELETED_FLAG  => l_Header_rec.DELETED_FLAG,
          p_AUTO_ASSIGNMENT_TYPE  => l_Header_rec.AUTO_ASSIGNMENT_TYPE,
          p_PRM_ASSIGNMENT_TYPE  => l_Header_rec.PRM_ASSIGNMENT_TYPE,
          p_CUSTOMER_BUDGET  => l_Header_rec.CUSTOMER_BUDGET,
          p_METHODOLOGY_CODE  => l_Header_rec.METHODOLOGY_CODE,
          p_SALES_METHODOLOGY_ID  => l_header_rec.SALES_METHODOLOGY_ID,
          p_ORIGINAL_LEAD_ID  => l_Header_rec.ORIGINAL_LEAD_ID,
          p_DECISION_TIMEFRAME_CODE  => l_Header_rec.DECISION_TIMEFRAME_CODE,
          p_INC_PARTNER_RESOURCE_ID=>l_Header_rec.INCUMBENT_PARTNER_RESOURCE_ID,
          p_INC_PARTNER_PARTY_ID  => l_Header_rec.INCUMBENT_PARTNER_PARTY_ID,
          p_OFFER_ID  => l_Header_rec.OFFER_ID,
          p_VEHICLE_RESPONSE_CODE  => l_Header_rec.VEHICLE_RESPONSE_CODE,
          p_BUDGET_STATUS_CODE  => l_Header_rec.BUDGET_STATUS_CODE,
          p_FOLLOWUP_DATE  => l_Header_rec.FOLLOWUP_DATE,
          p_PRM_EXEC_SPONSOR_FLAG  => l_Header_rec.PRM_EXEC_SPONSOR_FLAG,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG=>l_Header_rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
          p_PRM_IND_CLASSIFICATION_CODE  =>
                                      l_Header_rec.PRM_IND_CLASSIFICATION_CODE,
          p_PRM_LEAD_TYPE  => l_Header_rec.PRM_LEAD_TYPE,
          p_FREEZE_FLAG => l_Header_rec.FREEZE_FLAG,
          p_PRM_REFERRAL_CODE => l_Header_rec.PRM_REFERRAL_CODE);

      -- If decision_date changed Synchronize the forecast_date in purchase lines
      -- with decision_date in the header if the rolloing_forecast_flag = 'Y';

      IF l_Header_rec.DECISION_DATE <> FND_API.G_MISS_DATE AND
	  trunc(l_Header_rec.DECISION_DATE) <> trunc(l_decision_date)
      THEN
       	  UPDATE AS_LEAD_LINES_ALL
      	  SET object_version_number =  nvl(object_version_number,0) + 1, FORECAST_DATE = l_Header_rec.DECISION_DATE
	  --last_update_date = SYSDATE,
          --last_updated_by = FND_GLOBAL.USER_ID,
          --last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      	  WHERE lead_id = l_Header_rec.lead_id
      	  AND rolling_forecast_flag = 'Y';
      END IF;

      Select lead.win_probability, status.win_loss_indicator,
             status.forecast_rollup_flag
      Into   l_win_probability, l_win_loss_indicator,
             l_forecast_rollup_flag
      From as_leads_all lead, as_statuses_vl status
      Where lead_id = l_Header_rec.LEAD_ID
      And lead.status = status.status_code(+);

      IF AS_OPP_SALES_CREDIT_PVT.Apply_Forecast_Defaults(
          l_old_win_probability, l_old_win_loss_indicator,
          l_old_forecast_rollup_flag, 0, l_win_probability,
          l_win_loss_indicator, l_forecast_rollup_flag, 0, 'ON-UPDATE',
          l_opp_worst_forecast_amount, l_opp_forecast_amount,
          l_opp_best_forecast_amount)
      THEN
        l_tot_rev_opp_forecast_amt := 0;
        FOR curr_rec_sc_amt IN c_sales_credit_amount (l_Header_rec.LEAD_ID) LOOP
            l_temp_bool := AS_OPP_SALES_CREDIT_PVT.Apply_Forecast_Defaults(
                l_old_win_probability, l_old_win_loss_indicator,
                l_old_forecast_rollup_flag, curr_rec_sc_amt.credit_amount,
                l_win_probability, l_win_loss_indicator, l_forecast_rollup_flag,
                curr_rec_sc_amt.credit_amount, 'ON-UPDATE',
                l_opp_worst_forecast_amount, l_opp_forecast_amount,
                l_opp_best_forecast_amount);
            Update as_sales_credits
            Set object_version_number = nvl(object_version_number, 0) + 1,
                opp_worst_forecast_amount = l_opp_worst_forecast_amount,
                opp_forecast_amount = l_opp_forecast_amount,
                opp_best_forecast_amount = l_opp_best_forecast_amount
            Where sales_credit_id = curr_rec_sc_amt.sales_credit_id;
            -- The following condition added for ASNB
            IF curr_rec_sc_amt.credit_type_id= l_forecast_credit_type_id THEN
                l_tot_rev_opp_forecast_amt := nvl(l_tot_rev_opp_forecast_amt,0) + nvl(l_opp_forecast_amount,0);
            END IF;
        END LOOP;
        -- The following update added for ASNB
        UPDATE AS_LEADS_ALL
        SET TOTAL_REVENUE_OPP_FORECAST_AMT = nvl(l_tot_rev_opp_forecast_amt,0)
        WHERE lead_id = l_Header_rec.lead_id;
      ELSIF nvl(l_tot_rev_opp_forecast_amt, 0) <> FND_API.G_MISS_NUM THEN
        l_update_count := 0;
        -- Trickle down supplied TOTAL_REVENUE_OPP_FORECAST_AMT to
        -- sales credits/lines
        IF l_old_tot_rev_opp_forecast_amt = 0 THEN
            Select count(*) into l_count from as_sales_credits
            where lead_id = l_Header_rec.LEAD_ID and
                  credit_type_id = l_forecast_credit_type_id;
            IF l_count > 0 THEN -- Equally distribute
                l_opp_forecast_amount := nvl(l_tot_rev_opp_forecast_amt, 0)/l_count;
                Update as_sales_credits set opp_forecast_amount = l_opp_forecast_amount
                where lead_id = l_Header_rec.LEAD_ID AND
                      credit_type_id = l_forecast_credit_type_id;
                l_update_count := SQL%ROWCOUNT;
            END IF;
        ELSE
            Update as_sales_credits
            Set opp_forecast_amount =
                nvl(l_tot_rev_opp_forecast_amt, 0) * (nvl(opp_forecast_amount, 0)/l_old_tot_rev_opp_forecast_amt)
            where lead_id = l_Header_rec.LEAD_ID AND
                  credit_type_id = l_forecast_credit_type_id;
            l_update_count := SQL%ROWCOUNT;
        END IF;

        IF l_update_count = 0 THEN
            l_tot_rev_opp_forecast_amt := NULL;
        END IF;

        UPDATE AS_LEADS_ALL
      	SET TOTAL_REVENUE_OPP_FORECAST_AMT = l_tot_rev_opp_forecast_amt
      	WHERE lead_id = l_Header_rec.lead_id;
      END IF;

      -- Reset the owner in the sales team
      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'owner_sf_id: '||l_header_rec.owner_salesforce_id );
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'owner_sg_id: '||l_header_rec.owner_sales_group_id );

      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'l_owner_sf_id: '||l_owner_salesforce_id );
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'l_owner_sg_id: '||l_owner_sales_group_id );
      END IF;


      IF (l_header_rec.owner_salesforce_id IS NOT NULL) AND
	 (l_header_rec.owner_salesforce_id <> FND_API.G_MISS_NUM ) AND
	 (l_header_rec.owner_sales_group_id IS NOT NULL) AND
	 (l_header_rec.owner_sales_group_id <> FND_API.G_MISS_NUM )
      THEN
	  update as_accesses_all
	  set object_version_number =  nvl(object_version_number,0) + 1, owner_flag = null,
              last_update_date = SYSDATE,
              last_updated_by = FND_GLOBAL.USER_ID,
              last_update_login = FND_GLOBAL.CONC_LOGIN_ID
	  where lead_id = l_Header_rec.lead_id;

	  update as_accesses_all
	  set object_version_number =  nvl(object_version_number,0) + 1, owner_flag = 'Y',
	      freeze_flag = 'Y',
	      team_leader_flag = 'Y', -- Fix for bug# 4196657
              last_update_date = SYSDATE,
              last_updated_by = FND_GLOBAL.USER_ID,
              last_update_login = FND_GLOBAL.CONC_LOGIN_ID
	  where access_id in
		( select min(access_id)
		  from as_accesses_all
		  where lead_id = l_Header_rec.lead_id
		  and sales_group_id = l_header_rec.owner_sales_group_id
		  and salesforce_id = l_header_rec.owner_salesforce_id );

	  IF (SQL%NOTFOUND) THEN

	        -- create a salesteam for the new owner
      		l_Sales_Team_Rec.last_update_date      := SYSDATE;
      		l_Sales_Team_Rec.last_updated_by       := FND_GLOBAL.USER_ID;
      		l_Sales_Team_Rec.creation_date         := SYSDATE;
      		l_Sales_Team_Rec.created_by            := FND_GLOBAL.USER_ID;
      		l_Sales_Team_Rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;
      		l_Sales_Team_Rec.customer_id           := l_Customer_Id;
      		l_Sales_Team_Rec.address_id            := l_Address_Id;
     		l_Sales_Team_Rec.lead_id               := l_header_rec.lead_id;
      		l_Sales_Team_Rec.salesforce_id         := l_header_rec.owner_salesforce_id;
      		l_sales_team_rec.sales_group_id        := l_header_rec.owner_sales_group_id;
      		l_sales_team_rec.salesforce_role_code  := FND_PROFILE.Value('AS_DEF_OPP_ST_ROLE');
      		l_Sales_Team_Rec.team_leader_flag      := 'Y';
      		l_Sales_Team_Rec.reassign_flag         := 'N';
      		l_Sales_Team_Rec.freeze_flag           := 'Y';
		--l_Sales_Team_Rec.owner_flag            := 'Y';

	     	OPEN get_person_id_csr(l_header_rec.owner_salesforce_id);
      	  	FETCH get_person_id_csr into l_Sales_Team_Rec.person_id;
      	  	CLOSE get_person_id_csr;

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
                           'Create_owner_ST :l_access_id = ' || l_access_id);
		END IF;


      		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           		RAISE FND_API.G_EXC_ERROR;
      		END IF;

		UPDATE AS_ACCESSES_ALL
		SET object_version_number =  nvl(object_version_number,0) + 1, OWNER_FLAG = 'Y'
		WHERE access_id = l_access_id;

	  END IF; -- NOTFOUND

      ELSIF (l_header_rec.owner_salesforce_id IS NULL) AND
	    (l_header_rec.owner_sales_group_id IS NULL) THEN

	  update as_accesses_all
	  set object_version_number =  nvl(object_version_number,0) + 1, owner_flag = null,
              last_update_date = SYSDATE,
              last_updated_by = FND_GLOBAL.USER_ID,
              last_update_login = FND_GLOBAL.CONC_LOGIN_ID
	  where lead_id = l_Header_rec.lead_id;

      END IF;

      -- Assign/Reassign the territory resources for the opportunity

      -- Debug Message
      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Calling Opportunity Real Time API');
      END IF;

      AS_RTTAP_OPPTY.RTTAP_WRAPPER(
    	  P_Api_Version_Number         => 1.0,
    	  P_Init_Msg_List              => FND_API.G_FALSE,
    	  P_Commit                     => FND_API.G_FALSE,
    	  p_lead_id		       => l_header_rec.lead_id,
     	  X_Return_Status              => x_return_status,
    	  X_Msg_Count                  => x_msg_count,
    	  X_Msg_Data                   => x_msg_data
    	);

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Opportunity Real Time API fail');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
        END IF;


      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Calling Recreate_tasks');
      END IF;


      l_new_SALES_METHODOLOGY_ID := l_header_rec.SALES_METHODOLOGY_ID;
      l_new_SALES_STAGE_ID := l_header_rec.SALES_STAGE_ID;

      IF l_new_SALES_METHODOLOGY_ID = FND_API.G_MISS_NUM THEN
	 l_new_SALES_METHODOLOGY_ID := l_old_sales_methodology_id;
      END IF;
      IF l_new_SALES_STAGE_ID = FND_API.G_MISS_NUM THEN
	 l_new_SALES_STAGE_ID := l_old_sales_stage_id;
      END IF;

      IF l_old_sales_methodology_id IS NOT NULL AND
	 nvl(l_new_SALES_METHODOLOGY_ID, -99) <> l_old_sales_methodology_id THEN

	    IF l_debug THEN
	    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Should not change Sales methodology');
	    END IF;

            AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_NO_UPDATE_SALES_METHODOLOGY');


            RAISE FND_API.G_EXC_ERROR;
      END IF;

      Recreate_tasks(
    		p_LEAD_ID		 	=> l_header_rec.lead_id,
    		p_RESOURCE_ID			=> p_identity_salesforce_id,
    		p_OLD_SALES_METHODOLOGY_ID	=> l_old_sales_methodology_id,
    		p_OLD_SALES_STAGE_ID		=> l_old_sales_stage_id,
    		p_SALES_METHODOLOGY_ID		=> l_new_SALES_METHODOLOGY_ID,
    		p_SALES_STAGE_ID		=> l_new_SALES_STAGE_ID,
    		x_return_status 		=> x_return_status,
                X_Msg_Count                     => X_Msg_Count,
                X_Msg_Data                      => X_Msg_Data,
		X_Warning_Message		=> l_warning_msg );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            IF l_debug THEN
            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  'Recreate_tasks fail');
	    END IF;

            RAISE FND_API.G_EXC_ERROR;
      END IF;
/*
      -- Create lead competitor
      IF (l_header_rec.CLOSE_COMPETITOR_ID  IS NOT NULL) AND
	 (l_header_rec.CLOSE_COMPETITOR_ID  <> FND_API.G_MISS_NUM ) THEN

          Create_lead_competitor(
      		P_Api_Version_Number         => 2.0,
      		P_Init_Msg_List              => FND_API.G_FALSE,
      		P_Commit                     => p_commit,
      		P_Validation_Level           => P_Validation_Level,
      		P_Check_Access_Flag          => p_check_access_flag,
      		P_Admin_Flag                 => P_Admin_Flag,
      		P_Admin_Group_Id             => P_Admin_Group_Id,
      		P_Identity_Salesforce_Id     => P_Identity_Salesforce_Id,
      		P_Partner_Cont_Party_Id	     => p_partner_cont_party_id,
      		P_Profile_Tbl                => P_Profile_tbl,
    		p_LEAD_ID		     => l_header_rec.lead_id,
		p_COMPETITOR_ID		     => l_header_rec.CLOSE_COMPETITOR_ID,
      		X_Return_Status              => x_return_status,
      		X_Msg_Count                  => x_msg_count,
      		X_Msg_Data                   => x_msg_data);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Create lead competitor fail');
                END IF;

                RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;
*/

      -- Update competitor Products for the win/loss status
      IF (l_header_rec.lead_id IS NOT NULL)AND
         (l_header_rec.STATUS_CODE IS NOT NULL) AND
	 (l_header_rec.STATUS_CODE <> FND_API.G_MISS_CHAR ) THEN

	  Update_Competitor_Products(
    		p_LEAD_ID		=> l_header_rec.LEAD_ID,
    		p_STATUS_CODE		=> l_header_rec.STATUS_CODE,
    		x_return_status 	=> x_return_status);

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                IF l_debug THEN
                AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Update competitor Products  fail');
                END IF;
                RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;



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

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        x_msg_data := l_winprob_warning_msg || '#####'|| l_warning_msg;
	--x_msg_data := l_warning_msg;
      END IF;

-- Un-comment the following statements when AS_CALLOUT_PKG is ready.
/*
      -- if profile AS_POST_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_POST_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Update_opp_header_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Header_Rec      =>  l_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_opp_header;


PROCEDURE Delete_opp_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_lead_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
Cursor C_Get_opp_header(c_LEAD_ID Number) IS
    Select LAST_UPDATE_DATE, FREEZE_FLAG
    FROM AS_LEADS
    WHERE LEAD_ID = c_LEAD_ID
    For Update NOWAIT;

l_api_name                CONSTANT VARCHAR2(30) := 'Delete_opp_header';
l_api_version_number      CONSTANT NUMBER   := 2.0;
-- Local Variables
l_identity_sales_member_rec   AS_SALES_MEMBER_PUB.Sales_member_rec_Type;
l_last_update_date      DATE;
l_freeze_flag             VARCHAR2(1) := 'N'; -- solin, for bug 1554330
l_allow_flag              VARCHAR2(1);        -- solin, for bug 1554330
l_access_profile_rec      AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
l_access_flag             VARCHAR2(1);
l_val                     VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Delete_opp_header';

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_OPP_HEADER_PVT;

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
      -- if profile AS_PRE_CUSTOM_ENABLED is set to 'Y', callout procedure is
      -- invoked for customization purpose
      IF(FND_PROFILE.VALUE('AS_PRE_CUSTOM_ENABLED')='Y')
      THEN
          AS_CALLOUT_PKG.Delete_opp_header_BU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Header_Rec      =>  p_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          -- relationship.
                  x_return_status        =>  x_return_status,
                  x_msg_count            =>  x_msg_count,
                  x_msg_data             =>  x_msg_data);
      END IF;
*/

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

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Open Cursor to Select');
      END IF;

      Open C_Get_opp_header( p_LEAD_ID);
      Fetch C_Get_opp_header into l_last_update_date, l_freeze_flag;

      If ( C_Get_opp_header%NOTFOUND) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_MISSING_UPDATE_TARGET');
              -- FND_MESSAGE.Set_Token ('INFO', 'opp_header', FALSE);
              -- FND_MSG_PUB.Add;

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_OPP_HEADER_UPDATE');

          END IF;
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Debug Message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: - Close Cursor');
      END IF;
      close     C_Get_opp_header;

/*
      If (p_Header_rec.last_update_date is NULL or
          p_Header_rec.last_update_date = FND_API.G_MISS_Date ) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_MISSING_ID');
              -- FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
              -- FND_MSG_PUB.ADD;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LAST_UPDATE_DATE');

          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (p_Header_rec.last_update_date <> l_last_update_date) Then
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              -- FND_MESSAGE.Set_Name('AS', 'API_RECORD_CHANGED');
              -- FND_MESSAGE.Set_Token('INFO', 'opp_header', FALSE);
              -- FND_MSG_PUB.ADD;

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_OPP_HEADER_CHANGED');

          END IF;
          raise FND_API.G_EXC_ERROR;
      End if;
*/


/*
      -- Debug message
      IF l_debug THEN
      	AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Private API: Validate_opp_header');
      END IF;

      -- Invoke validation procedures
      Validate_opp_header(
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode  => AS_UTILITY_PVT.G_UPDATE,
          P_Header_Rec       => p_Header_Rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
*/


      -- Call Get_Access_Profiles to get access_profile_rec
      AS_OPPORTUNITY_PUB.Get_Access_Profiles(
          p_profile_tbl         => p_profile_tbl,
          x_access_profile_rec  => l_access_profile_rec);


      -- Access checking
      IF p_check_access_flag = 'Y'
      THEN
          -- Please un-comment here and complete it
          AS_ACCESS_PUB.Has_updateOpportunityAccess(
              p_api_version_number     => 2.0,
              p_init_msg_list          => p_init_msg_list,
              p_validation_level       => p_validation_level,
              p_access_profile_rec     => l_access_profile_rec,
              p_admin_flag             => p_admin_flag,
              p_admin_group_id         => p_admin_group_id,
              p_person_id              =>
                                l_identity_sales_member_rec.employee_person_id,
              p_opportunity_id         => P_lead_id,
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
              RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

      END IF;

      -- solin, for bug 1554330
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


      -- Hint: Add corresponding Master-Detail business logic here if necessary.

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: Calling update table handler');

      END IF;

      -- Invoke table handler(AS_LEADS_PKG.Update_Row)
      AS_LEADS_PKG.Update_Row(
          p_LEAD_ID  => p_LEAD_ID,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => FND_API.G_MISS_DATE,
          p_CREATED_BY  => FND_API.G_MISS_NUM,
          p_LAST_UPDATE_LOGIN  => FND_GLOBAL.CONC_LOGIN_ID,
          p_REQUEST_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_APPLICATION_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_ID  => FND_API.G_MISS_NUM,
          p_PROGRAM_UPDATE_DATE  => FND_API.G_MISS_DATE,
          p_LEAD_NUMBER  => FND_API.G_MISS_CHAR,
          p_STATUS  => FND_API.G_MISS_CHAR,
          p_CUSTOMER_ID  => FND_API.G_MISS_NUM,
          p_ADDRESS_ID  => FND_API.G_MISS_NUM,
          p_SALES_STAGE_ID  => FND_API.G_MISS_NUM,
          p_INITIATING_CONTACT_ID  => FND_API.G_MISS_NUM,
          p_CHANNEL_CODE  => FND_API.G_MISS_CHAR,
          p_TOTAL_AMOUNT  => FND_API.G_MISS_NUM,
          p_CURRENCY_CODE  => FND_API.G_MISS_CHAR,
          p_DECISION_DATE  => FND_API.G_MISS_DATE,
          p_WIN_PROBABILITY  => FND_API.G_MISS_NUM,
          p_CLOSE_REASON  => FND_API.G_MISS_CHAR,
          p_CLOSE_COMPETITOR_CODE  => FND_API.G_MISS_CHAR,
          p_CLOSE_COMPETITOR  => FND_API.G_MISS_CHAR,
          p_CLOSE_COMMENT  => FND_API.G_MISS_CHAR,
          p_DESCRIPTION  => FND_API.G_MISS_CHAR,
          p_RANK  => FND_API.G_MISS_CHAR,
          p_SOURCE_PROMOTION_ID  => FND_API.G_MISS_NUM,
          p_END_USER_CUSTOMER_ID  => FND_API.G_MISS_NUM,
          p_END_USER_ADDRESS_ID  => FND_API.G_MISS_NUM,
          p_OWNER_SALESFORCE_ID  => FND_API.G_MISS_NUM,
          p_OWNER_SALES_GROUP_ID => FND_API.G_MISS_NUM,
          --p_OWNER_ASSIGN_DATE  => FND_API.G_MISS_DATE,
          p_ORG_ID  => FND_API.G_MISS_NUM,
          p_NO_OPP_ALLOWED_FLAG  => FND_API.G_MISS_CHAR,
          p_DELETE_ALLOWED_FLAG  => FND_API.G_MISS_CHAR,
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
          p_PARENT_PROJECT  => FND_API.G_MISS_CHAR,
          p_LEAD_SOURCE_CODE  => FND_API.G_MISS_CHAR,
          p_ORIG_SYSTEM_REFERENCE  => FND_API.G_MISS_CHAR,
          p_CLOSE_COMPETITOR_ID  => FND_API.G_MISS_NUM,
          p_END_USER_CUSTOMER_NAME  => FND_API.G_MISS_CHAR,
          p_PRICE_LIST_ID  => FND_API.G_MISS_NUM,
          p_DELETED_FLAG  => 'Y',
          p_AUTO_ASSIGNMENT_TYPE  => FND_API.G_MISS_CHAR,
          p_PRM_ASSIGNMENT_TYPE  => FND_API.G_MISS_CHAR,
          p_CUSTOMER_BUDGET  => FND_API.G_MISS_NUM,
          p_METHODOLOGY_CODE  => FND_API.G_MISS_CHAR,
          p_SALES_METHODOLOGY_ID  => FND_API.G_MISS_NUM,
          p_ORIGINAL_LEAD_ID  => FND_API.G_MISS_NUM,
          p_DECISION_TIMEFRAME_CODE  => FND_API.G_MISS_CHAR,
          p_INC_PARTNER_RESOURCE_ID=>FND_API.G_MISS_NUM,
          p_INC_PARTNER_PARTY_ID  => FND_API.G_MISS_NUM,
          p_OFFER_ID  => FND_API.G_MISS_NUM,
          p_VEHICLE_RESPONSE_CODE  => FND_API.G_MISS_CHAR,
          p_BUDGET_STATUS_CODE  => FND_API.G_MISS_CHAR,
          p_FOLLOWUP_DATE  => FND_API.G_MISS_DATE,
          p_PRM_EXEC_SPONSOR_FLAG  => FND_API.G_MISS_CHAR,
          p_PRM_PRJ_LEAD_IN_PLACE_FLAG=>FND_API.G_MISS_CHAR,
          p_PRM_IND_CLASSIFICATION_CODE  =>
                                      FND_API.G_MISS_CHAR,
          p_PRM_LEAD_TYPE  => FND_API.G_MISS_CHAR,
          p_FREEZE_FLAG => FND_API.G_MISS_CHAR,
          p_PRM_REFERRAL_CODE => FND_API.G_MISS_CHAR);
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
          AS_CALLOUT_PKG.Delete_opp_header_AU(
                  p_api_version_number   =>  2.0,
                  p_init_msg_list        =>  FND_API.G_FALSE,
                  p_commit               =>  FND_API.G_FALSE,
                  p_validation_level     =>  p_validation_level,
                  p_identity_salesforce_id => p_identity_salesforce_id,
                  P_Header_Rec      =>  P_Header_Rec,
          -- Hint: Add detail tables as parameter lists if it's master-detail
          --       relationship.
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
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_opp_header;


--
-- Item-level validation procedures
--

PROCEDURE Validate_LEAD_ID (
    P_Init_Msg_List       IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode     IN   VARCHAR2,
    P_LEAD_ID             IN   NUMBER,
    X_Item_Property_Rec   OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status       OUT NOCOPY  VARCHAR2,
    X_Msg_Count           OUT NOCOPY  NUMBER,
    X_Msg_Data            OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Lead_Id_Exists (c_Lead_Id NUMBER) IS
      SELECT 'X'
      FROM  as_leads
      WHERE lead_id = c_Lead_Id;

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_LEAD_ID';

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
          IF (p_LEAD_ID is NOT NULL) and (p_LEAD_ID <> FND_API.G_MISS_NUM)
          THEN
              OPEN  C_Lead_Id_Exists (p_Lead_Id);
              FETCH C_Lead_Id_Exists into l_val;

              IF C_Lead_Id_Exists%FOUND THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                           'Private API: LEAD_ID exist');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_DUPLICATE_LEAD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_LEAD_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Lead_Id_Exists;
          END IF;

      -- Calling from Update API
      ELSIF(p_validation_mode = AS_UTILITY_PVT.G_UPDATE)
      THEN
          -- validate NOT NULL column
          IF (p_LEAD_ID is NULL) or (p_LEAD_ID = FND_API.G_MISS_NUM)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --          'Private API: Violate NOT NULL constraint(LEAD_ID)');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          ELSE
              OPEN  C_Lead_Id_Exists (p_Lead_Id);
              FETCH C_Lead_Id_Exists into l_val;

              IF C_Lead_Id_Exists%NOTFOUND
              THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                     'Private API: LEAD_ID is not valid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_LEAD_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_LEAD_ID );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_Lead_Id_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_ID;


/*
PROCEDURE Validate_LEAD_NUMBER (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_LEAD_NUMBER        IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_LEAD_NUMBER_Exists (c_LEAD_NUMBER CHAR) IS
      SELECT 'X'
      FROM  as_leads
      WHERE lead_number = c_lead_number;

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

      IF(p_LEAD_NUMBER is NULL)
      THEN
          -- validate NOT NULL column
          -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
          --          'Private API: Violate NOT NULL constraint(LEAD_NUMBER)');

          AS_UTILITY_PVT.Set_Message(
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_LEAD_NUMBER');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          -- Calling from Create API, LEAD_NUMBER can not be G_MISS_CHAR
          IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) and
             (p_LEAD_NUMBER = FND_API.G_MISS_CHAR)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                           'Private API: missing LEAD_NUMBER');

              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_LEAD_NUMBER');

          END IF;

          -- LEAD_NUMBER should be unique
          IF (p_LEAD_NUMBER <> FND_API.G_MISS_CHAR)
          THEN
              OPEN  C_LEAD_NUMBER_Exists (p_LEAD_NUMBER);
              FETCH C_LEAD_NUMBER_Exists into l_val;

              IF C_LEAD_NUMBER_Exists%FOUND THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                       'Private API: LEAD_NUMBER exist');

                  AS_UTILITY_PVT.Set_Message(
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_DUPLICATE_LEAD_NUMBER',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_LEAD_NUMBER );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_LEAD_NUMBER_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_NUMBER;
*/


PROCEDURE Validate_STATUS (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_STATUS             IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_STATUS_Exists (c_status CHAR) IS
      SELECT 'X'
      FROM  as_statuses_b
      WHERE status_code = c_status
            and enabled_flag = 'Y'
            and opp_flag = 'Y';

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_STATUS';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_STATUS is NULL)
      THEN
          -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
          --                'Private API: Violate NOT NULL constraint(STATUS)');

          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_STATUS');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
          -- Calling from Create API, STATUS can not be G_MISS_CHAR
          IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) and
             (p_STATUS = FND_API.G_MISS_CHAR)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --            'Private API: STATUS is missing');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_STATUS');

              x_return_status := FND_API.G_RET_STS_ERROR;

          -- STATUS should exist in as_statuses_b
          ELSIF(p_STATUS <> FND_API.G_MISS_CHAR)
          THEN
              OPEN  C_STATUS_Exists (p_STATUS);
              FETCH C_STATUS_Exists into l_val;

              IF C_STATUS_Exists%NOTFOUND THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                          'Private API: STATUS is invalid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_OPP_STATUS',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_STATUS );

                  x_return_status := FND_API.G_RET_STS_ERROR;
              END IF;

              CLOSE C_STATUS_Exists;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_STATUS;


-- Added for MOAC
PROCEDURE Validate_ORG_ID (
    P_Init_Msg_List      IN   VARCHAR2 := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_ORG_ID             IN   NUMBER,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_ORG_ID_Exists (c_ORG_ID NUMBER) IS
      SELECT 'X'
      FROM hr_operating_units hr
      WHERE hr.organization_id= P_ORG_ID
            and mo_global.check_access(hr.organization_id) = 'Y';

  l_val   VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_ORG_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_validation_mode = AS_UTILITY_PVT.G_CREATE THEN
          OPEN  C_ORG_ID_Exists (p_ORG_ID);
          FETCH C_ORG_ID_Exists into l_val;

          IF C_ORG_ID_Exists%NOTFOUND THEN

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'AS_ORG_NULL_OR_INVALID');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_ORG_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORG_ID;


PROCEDURE Validate_SALES_STAGE_ID (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_SALES_STAGE_ID     IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_SALES_STAGE_ID_Exists (c_SALES_STAGE_ID NUMBER) IS
      SELECT 'X'
      FROM  as_sales_stages_all_b
      WHERE sales_stage_id = c_sales_stage_id
            -- ffang 091200 for bug 1403865
            and nvl(start_date_active, sysdate) <= sysdate
            and nvl(end_date_active, sysdate) >= sysdate
            and enabled_flag = 'Y';
            -- end ffang 091200

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_SALES_STAGE_ID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_SALES_STAGE_ID is NOT NULL) and
         (p_SALES_STAGE_ID <> FND_API.G_MISS_NUM)
      THEN
          -- SALES_STAGE_ID should exist in as_sales_stages_all_b
          OPEN  C_SALES_STAGE_ID_Exists (p_SALES_STAGE_ID);
          FETCH C_SALES_STAGE_ID_Exists into l_val;

          IF C_SALES_STAGE_ID_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: SALES_STAGE_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_SALES_STAGE_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_SALES_STAGE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_SALES_STAGE_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SALES_STAGE_ID;


PROCEDURE Validate_CHANNEL_CODE (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_CHANNEL_CODE       IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_CHANNEL_CODE_Exists (c_CHANNEL_CODE CHAR) IS
	SELECT 'X'
	FROM OE_LOOKUPS
	WHERE lookup_code = c_channel_code
	AND   lookup_type = 'SALES_CHANNEL'
	AND   nvl(start_date_active, sysdate) <= sysdate
	AND   nvl(end_date_active, sysdate) >= sysdate
	AND   enabled_flag = 'Y';

  l_val   VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_CHANNEL_CODE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CHANNEL_CODE is NOT NULL) and
         (p_CHANNEL_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- CHANNEL_CODE should exist in OE_LOOKUPS
          OPEN  C_CHANNEL_CODE_Exists (p_CHANNEL_CODE);
          FETCH C_CHANNEL_CODE_Exists into l_val;

          IF C_CHANNEL_CODE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: CHANNEL_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_CHANNEL_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_CHANNEL_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_CHANNEL_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CHANNEL_CODE;


PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_CURRENCY_CODE      IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Currency_Exists (c_currency_code VARCHAR2) IS
    SELECT  'X'
    FROM  fnd_currencies
    WHERE currency_code = c_currency_code
          -- ffang 091200 for bug 1403865
          and nvl(start_date_active, sysdate) <= sysdate
          and nvl(end_date_active, sysdate) >= sysdate
          and enabled_flag = 'Y';
          -- end ffang 091200

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_CURRENCY_CODE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CURRENCY_CODE is NOT NULL) and
         (p_CURRENCY_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- CURRENCY_CODE should exist in fnd_currencies_vl
          OPEN  C_Currency_Exists (p_CURRENCY_CODE);
          FETCH C_Currency_Exists into l_val;

          IF C_Currency_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: CURRENCY_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_CURRENCY_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_CURRENCY_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_Currency_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CODE;


PROCEDURE Validate_WIN_PROBABILITY (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_WIN_PROBABILITY    IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Win_Prob_Exists (c_Win_Prob NUMBER) IS
     SELECT  'X'
     FROM  as_forecast_prob
     WHERE probability_value = c_Win_Prob
           -- ffang 091200 for bug 1403865
           and nvl(start_date_active, sysdate) <= sysdate
           and nvl(end_date_active, sysdate) >= sysdate
           and enabled_flag = 'Y';
           -- end ffang 091200

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_WIN_PROBABILITY';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_WIN_PROBABILITY is NOT NULL) and
         (p_WIN_PROBABILITY <> FND_API.G_MISS_NUM)
      THEN
          -- WIN_PROBABILITY should exist in as_forecast_prob
          OPEN  C_Win_Prob_Exists (p_WIN_PROBABILITY);
          FETCH C_Win_Prob_Exists into l_val;

          IF C_Win_Prob_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: WIN_PROBABILITY is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_WIN_PROB',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_WIN_PROBABILITY );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_Win_Prob_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_WIN_PROBABILITY;


PROCEDURE Validate_CLOSE_REASON (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_CLOSE_REASON       IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_CLOSE_REASON_Exists (c_lookup_type VARCHAR2,
                                c_CLOSE_REASON VARCHAR2) IS
     SELECT  'X'
     FROM  as_lookups
     WHERE lookup_type = c_lookup_type
           and lookup_code = c_CLOSE_REASON;
           -- and enabled_flag = 'Y';

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_CLOSE_REASON';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CLOSE_REASON is NOT NULL) and
         (p_CLOSE_REASON <> FND_API.G_MISS_CHAR)
      THEN
          -- CLOSE_REASON should exist in as_lookups
          OPEN  C_CLOSE_REASON_Exists ('CLOSE_REASON', p_CLOSE_REASON);
          FETCH C_CLOSE_REASON_Exists into l_val;

          IF C_CLOSE_REASON_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: CLOSE_REASON is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_CLOSE_REASON',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_CLOSE_REASON );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_CLOSE_REASON_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CLOSE_REASON;


PROCEDURE Validate_SOURCE_PROMOTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_SOURCE_PROMOTION_ID        IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_SOURCE_PROMOTION_ID_Exists (c_Source_Code_ID VARCHAR2) IS
     SELECT  'X'
     FROM  ams_source_codes
     WHERE source_code_id = c_Source_Code_ID
           -- and active_flag = 'Y'
	   and ARC_SOURCE_CODE_FOR <> 'OFFR';
	   -- nkamble commented below line and put OFFR condition for bug#3133993
	   --in ('CAMP', 'CSCH', 'EVEO', 'EVEH');

  l_source_code_required VARCHAR2(1) := FND_PROFILE.value('AS_OPP_SOURCE_CODE_REQUIRED');

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_SOURCE_PROMOTION_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( p_SOURCE_PROMOTION_ID is NULL OR
	   ( p_validation_mode = AS_UTILITY_PVT.G_CREATE AND
             p_SOURCE_PROMOTION_ID = FND_API.G_MISS_NUM     )  ) AND
         nvl(l_source_code_required, 'N') = 'Y' THEN
                  AS_UTILITY_PVT.Set_Message(
                     p_module        => l_module,
                     p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name      => 'API_MISSING_SOURCE_PROM_ID');

                  x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF (p_SOURCE_PROMOTION_ID is NOT NULL )AND
         (p_SOURCE_PROMOTION_ID <> FND_API.G_MISS_NUM)
      THEN
          -- SOURCE_PROMOTION_ID should exist in ams_source_codes
          OPEN  C_SOURCE_PROMOTION_ID_Exists (p_SOURCE_PROMOTION_ID);
          FETCH C_SOURCE_PROMOTION_ID_Exists into l_val;

          IF C_SOURCE_PROMOTION_ID_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: SOURCE_PROMOTION_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_SOURCE_PROM_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_SOURCE_PROMOTION_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_SOURCE_PROMOTION_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_SOURCE_PROMOTION_ID;


PROCEDURE Validate_NO_OPP_ALLOWED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_NO_OPP_ALLOWED_FLAG        IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_NO_OPP_ALLOWED_FLAG';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_NO_OPP_ALLOWED_FLAG is NOT NULL) and
         (p_NO_OPP_ALLOWED_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_NO_OPP_ALLOWED_FLAG) <> 'Y') and
             (UPPER(p_NO_OPP_ALLOWED_FLAG) <> 'N')
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: NO_OPP_ALLOWED_FLAG is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_NO_OPP_ALLOWED_FLG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_NO_OPP_ALLOWED_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_NO_OPP_ALLOWED_FLAG;


PROCEDURE Validate_DELETE_ALLOWED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DELETE_ALLOWED_FLAG        IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_DELETE_ALLOWED_FLAG';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_DELETE_ALLOWED_FLAG is NOT NULL) and
         (p_DELETE_ALLOWED_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_DELETE_ALLOWED_FLAG) <> 'Y') and
             (UPPER(p_DELETE_ALLOWED_FLAG) <> 'N')
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: DELETE_ALLOWED_FLAG is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_DEL_ALLOWED_FLAG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_DELETE_ALLOWED_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DELETE_ALLOWED_FLAG;


PROCEDURE Validate_LEAD_SOURCE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_LEAD_SOURCE_CODE           IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_LEAD_SOURCE_CODE_Exists (c_lookup_type VARCHAR2,
                                    c_LEAD_SOURCE_CODE VARCHAR2) IS
     SELECT  'X'
     FROM  as_lookups
     WHERE lookup_type = c_lookup_type
           and lookup_code = c_LEAD_SOURCE_CODE
           and enabled_flag = 'Y';

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_LEAD_SOURCE_CODE';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_LEAD_SOURCE_CODE is NOT NULL) and
         (p_LEAD_SOURCE_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- LEAD_SOURCE_CODE should exist in as_lookups
          OPEN  C_LEAD_SOURCE_CODE_Exists ('LEAD_SOURCE', p_LEAD_SOURCE_CODE);
          FETCH C_LEAD_SOURCE_CODE_Exists into l_val;

          IF C_LEAD_SOURCE_CODE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                  'Private API: LEAD_SOURCE_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_LEAD_SOURCE_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_LEAD_SOURCE_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_LEAD_SOURCE_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_LEAD_SOURCE_CODE;


PROCEDURE Validate_PRICE_LIST_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PRICE_LIST_ID              IN   NUMBER,
    P_CURRENCY_CODE              IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Price_List_Exists (c_Price_List_Id NUMBER,
                              c_Currency_Code VARCHAR2) IS
      SELECT  'X'
      FROM  qp_price_lists_v
      WHERE price_list_id = c_Price_List_Id
      and currency_code = c_Currency_Code
      and nvl(start_date_active, sysdate) <= sysdate
      and nvl(end_date_active, sysdate) >= sysdate;

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRICE_LIST_ID';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRICE_LIST_ID is NOT NULL) and
         (p_PRICE_LIST_ID <> FND_API.G_MISS_NUM)
      THEN
          -- PRICE_LIST_ID should exist in qp_price_lists_v
          OPEN  C_Price_List_Exists (p_PRICE_LIST_ID, p_CURRENCY_CODE);
          FETCH C_Price_List_Exists into l_val;

          IF C_Price_List_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                  'Private API: PRICE_LIST_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRICE_LIST_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRICE_LIST_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_Price_List_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRICE_LIST_ID;


PROCEDURE Validate_DELETED_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DELETED_FLAG               IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

	l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
    l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_DELETED_FLAG';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_DELETED_FLAG is NOT NULL) and
         (p_DELETED_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (p_DELETED_FLAG <> 'Y') and (p_DELETED_FLAG <> 'N')
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: DELETED_FLAG is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_DELETED_FLAG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_DELETED_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DELETED_FLAG;


PROCEDURE Validate_METHODOLOGY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_METHODOLOGY_CODE           IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_METHODOLOGY_CODE_Exists (c_lookup_type VARCHAR2,
                                    c_METHODOLOGY_CODE VARCHAR2) IS
     SELECT  'X'
     FROM  as_lookups
     WHERE lookup_type = c_lookup_type
           and lookup_code = c_METHODOLOGY_CODE
           and enabled_flag = 'Y';

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_METHODOLOGY_CODE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_METHODOLOGY_CODE is NOT NULL) and
         (p_METHODOLOGY_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- METHODOLOGY_CODE should exist in as_lookups
          OPEN  C_METHODOLOGY_CODE_Exists ('METHODOLOGY_TYPE',
                                           p_METHODOLOGY_CODE);
          FETCH C_METHODOLOGY_CODE_Exists into l_val;

          IF C_METHODOLOGY_CODE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                  'Private API: METHODOLOGY_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_METHODOLOGY_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_METHODOLOGY_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_METHODOLOGY_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_METHODOLOGY_CODE;


PROCEDURE Validate_ORIGINAL_LEAD_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_ORIGINAL_LEAD_ID           IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_ORIGINAL_LEAD_ID_Exists (c_ORIGINAL_LEAD_ID VARCHAR2) IS
     SELECT  'X'
     FROM  as_leads_all
     WHERE lead_id = c_original_lead_id;

  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_ORIGINAL_LEAD_ID';


BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_ORIGINAL_LEAD_ID is NOT NULL) and
         (p_ORIGINAL_LEAD_ID <> FND_API.G_MISS_NUM)
      THEN
          -- METHODOLOGY_CODE should exist in as_leads_all
          OPEN  C_ORIGINAL_LEAD_ID_Exists (p_ORIGINAL_LEAD_ID);
          FETCH C_ORIGINAL_LEAD_ID_Exists into l_val;

          IF C_ORIGINAL_LEAD_ID_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                  'Private API: ORIGINAL_LEAD_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_ORIG_LEAD_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_ORIGINAL_LEAD_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_ORIGINAL_LEAD_ID_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_ORIGINAL_LEAD_ID;


PROCEDURE Validate_DECN_TIMEFRAME_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DECISION_TIMEFRAME_CODE    IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_DECN_TIMEFRAME_Exists (c_lookup_type VARCHAR2,
                                  c_DECISION_TIMEFRAME_CODE VARCHAR2) IS
     SELECT  'X'
     FROM  as_lookups
     WHERE lookup_type = c_lookup_type
           and lookup_code = c_DECISION_TIMEFRAME_CODE
           and enabled_flag = 'Y';

  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_DECN_TIMEFRAME_CODE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_DECISION_TIMEFRAME_CODE is NOT NULL) and
         (p_DECISION_TIMEFRAME_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- DECISION_TIMEFRAME_CODE should exist in as_lookups
          OPEN  C_DECN_TIMEFRAME_Exists ('DECISION_TIMEFRAME',
                                         p_DECISION_TIMEFRAME_CODE);
          FETCH C_DECN_TIMEFRAME_Exists into l_val;

          IF C_DECN_TIMEFRAME_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --           'Private API: DECISION_TIMEFRAME_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_DCN_TIMEFRAME_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_DECISION_TIMEFRAME_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_DECN_TIMEFRAME_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DECN_TIMEFRAME_CODE;


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
     SELECT  'X'
     FROM  ams_source_codes
     WHERE source_code_id = c_offer_id
     and   ARC_SOURCE_CODE_FOR = 'OFFR';

--
--           and nvl(start_date, sysdate) <= sysdate
--           and nvl(end_date, sysdate) >= sysdate
           -- ffang 012501
--           and ARC_ACT_OFFER_USED_BY = 'CAMP'
--           and ACT_OFFER_USED_BY_ID =
--	                  (SELECT CAMPAIGN_ID
--	                   FROM AMS_CAMPAIGNS_VL c, AMS_SOURCE_CODES s
--	                   WHERE c.SOURCE_CODE = s.SOURCE_CODE
--                      AND s.SOURCE_CODE_ID = P_SOURCE_PROMOTION_ID);

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_OFFER_ID';
BEGIN

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   -- 'Validate offer id');

      IF (p_OFFER_ID is NOT NULL) and (p_OFFER_ID <> FND_API.G_MISS_NUM)
      THEN
          -- OFFER_ID should exist in ams_act_offers
          OPEN  C_OFFER_ID_Exists (p_OFFER_ID);
          FETCH C_OFFER_ID_Exists into l_val;

          IF C_OFFER_ID_Exists%NOTFOUND THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Private API: OFFER_ID is invalid');
              END IF;
              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
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


PROCEDURE Validate_VEHICLE_RESPONSE_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_VEHICLE_RESPONSE_CODE      IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_VEHICLE_RESPONSE_Exists (c_lookup_type VARCHAR2,
                                    c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  fnd_lookup_values
      WHERE lookup_type = c_lookup_type
        and lookup_code = c_Lookup_Code
	and enabled_flag = 'Y'
	and (end_date_active > SYSDATE OR end_date_active IS NULL);

  l_val VARCHAR2(1);
  l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_VEHICLE_RESPONSE_CODE';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_VEHICLE_RESPONSE_CODE is NOT NULL) and
         (p_VEHICLE_RESPONSE_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- VEHICLE_RESPONSE_CODE should exist in as_lookups
          OPEN  C_VEHICLE_RESPONSE_Exists ('VEHICLE_RESPONSE_CODE',
                                           p_VEHICLE_RESPONSE_CODE);
          FETCH C_VEHICLE_RESPONSE_Exists into l_val;

          IF C_VEHICLE_RESPONSE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --             'Private API: VEHICLE_RESPONSE_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_VEHICLE_RESP_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_VEHICLE_RESPONSE_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_VEHICLE_RESPONSE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_VEHICLE_RESPONSE_CODE;


PROCEDURE Validate_BUDGET_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_BUDGET_STATUS_CODE         IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_BUDGET_STATUS_Exists (c_lookup_type VARCHAR2,
                                 c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_BUDGET_STATUS_CODE';


BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_BUDGET_STATUS_CODE is NOT NULL) and
         (p_BUDGET_STATUS_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- BUDGET_STATUS_CODE should exist in as_lookups
          OPEN  C_BUDGET_STATUS_Exists ('BUDGET_STATUS', p_BUDGET_STATUS_CODE);
          FETCH C_BUDGET_STATUS_Exists into l_val;

          IF C_BUDGET_STATUS_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --             'Private API: BUDGET_STATUS_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_BUDGET_STATUS_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_BUDGET_STATUS_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_BUDGET_STATUS_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_BUDGET_STATUS_CODE;


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
  CURSOR C_PRM_LEAD_TYPE_Exists (c_lookup_type VARCHAR2,
                                 c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRM_LEAD_TYPE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRM_LEAD_TYPE is NOT NULL) and
         (p_PRM_LEAD_TYPE <> FND_API.G_MISS_CHAR)
      THEN
          -- PRM_LEAD_TYPE should exist in as_lookups
          OPEN  C_PRM_LEAD_TYPE_Exists ('PRM_LEAD_TYPE', p_PRM_LEAD_TYPE);
          FETCH C_PRM_LEAD_TYPE_Exists into l_val;

          IF C_PRM_LEAD_TYPE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                     'Private API: PRM_LEAD_TYPE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRM_LEAD_TYPE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRM_LEAD_TYPE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_PRM_LEAD_TYPE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_LEAD_TYPE;


PROCEDURE Validate_CUSTOMER_ID (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_CUSTOMER_ID        IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS

CURSOR c_customer_status(p_customer_id number) IS
	select STATUS
	from hz_parties
	where party_id = p_customer_id;
l_status 	VARCHAR2(1);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_CUSTOMER_ID';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_CUSTOMER_ID is NULL)
      THEN
          -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
          --          'Private API: Violate NOT NULL constraint(CUSTOMER_ID)');

          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_CUSTOMER_ID');

          x_return_status := FND_API.G_RET_STS_ERROR;
      ELSE
	  -- Check customer status in creation mode
          IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) and
             (p_CUSTOMER_ID <> FND_API.G_MISS_NUM)
          THEN
	      OPEN c_customer_status(P_CUSTOMER_ID);
	      FETCH c_customer_status into l_status;
	      CLOSE c_customer_status;
	      IF l_status = 'I' THEN
          	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          	  THEN
              	      AS_UTILITY_PVT.Set_Message(
                  	p_module        => l_module,
                  	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	p_msg_name      => 'WARN_INACTIVE_CUSTOMER');

          	  END IF;
		  x_return_status := FND_API.G_RET_STS_ERROR;
                  raise FND_API.G_EXC_ERROR;
	      END IF;
	  END IF;

          -- Calling from Create APIs, customer_id can not be G_MISS_NUM
          IF (p_validation_mode = AS_UTILITY_PVT.G_CREATE) and
             (p_CUSTOMER_ID = FND_API.G_MISS_NUM)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --                        'Private API: CUSTOMER_ID is missing');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_CUSTOMER_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;

          -- If customer_id <> G_MISS_NUM, use TCA validation procedure
          ELSIF (p_CUSTOMER_ID <> FND_API.G_MISS_NUM)
          THEN
              AS_TCA_PVT.validate_party_id(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_party_id               => P_CUSTOMER_ID,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --                 'Private API: CUSTOMER_ID is invalid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_CUSTOMER_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_CUSTOMER_ID );

              END IF;

          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_CUSTOMER_ID;



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
      -- FROM  pv_partners_v
      -- WHERE partner_id = c_inc_parn_party_id;
  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_INC_PARTNER_PARTY_ID';

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
          -- AS_TCA_PVT.validate_party_id(
          --     p_init_msg_list          => FND_API.G_FALSE,
          --     p_party_id               => P_INC_PARTNER_PARTY_ID,
          --     x_return_status          => x_return_status,
          --     x_msg_count              => x_msg_count,
          --     x_msg_data               => x_msg_data);

          -- IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --     -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
          --     --             'Private API: INC_PARTNER_PARTY_ID is invalid');


          OPEN  C_INC_PRTN_PARTY_ID_Exist (P_INC_PARTNER_PARTY_ID);
          FETCH C_INC_PRTN_PARTY_ID_Exist into l_val;

          IF C_INC_PRTN_PARTY_ID_Exist%NOTFOUND THEN

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_INC_PTNR_PARTY_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_INC_PARTNER_PARTY_ID );

          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_INC_PARTNER_PARTY_ID;


PROCEDURE Validate_CLOSE_COMPETITOR_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CLOSE_COMPETITOR_ID        IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_CLOSE_COMPETITOR_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_CLOSE_COMPETITOR_ID is NOT NULL) and
         (p_CLOSE_COMPETITOR_ID <> FND_API.G_MISS_NUM)
      THEN
          AS_TCA_PVT.validate_party_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_CLOSE_COMPETITOR_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: CLOSE_COMPETITOR_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_CLOSE_COMP_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_CLOSE_COMPETITOR_ID );

          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CLOSE_COMPETITOR_ID;


PROCEDURE Validate_END_USER_CUSTOMER_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_USER_CUSTOMER_ID       IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_END_USER_CUSTOMER_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_END_USER_CUSTOMER_ID is NOT NULL) and
         (p_END_USER_CUSTOMER_ID <> FND_API.G_MISS_NUM)
      THEN
          AS_TCA_PVT.validate_party_id(
              p_init_msg_list          => FND_API.G_FALSE,
              p_party_id               => p_END_USER_CUSTOMER_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --               'Private API: END_USER_CUSTOMER_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_END_USER_CUST_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_END_USER_CUSTOMER_ID );

          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_END_USER_CUSTOMER_ID;



PROCEDURE Validate_ADDRESS_ID (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_ADDRESS_ID         IN   NUMBER,
    P_CUSTOMER_ID        IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
l_check_address  VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_ADDRESS_ID';

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
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --      'Private API: need CUSTOMER_ID to validate ADDRESS_ID');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_CUSTOMER_ID');

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
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --               'Private API: ADDRESS_ID is invalid');
		  FND_MSG_PUB.initialize;
                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'AS_INVALID_ADDRESS_ID');

              END IF;
          END IF;

      ELSIF p_ADDRESS_ID = FND_API.G_MISS_NUM AND
            p_validation_mode = AS_UTILITY_PVT.G_UPDATE THEN
 	  NULL;

      ELSE  -- address_id is NULL or g_miss_num in creation mode
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'ADDRESS_ID is not entered');
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                  FND_PROFILE.Value('AS_OPP_ADDRESS_REQUIRED'));

          END IF;

          l_check_address :=
                    nvl(FND_PROFILE.Value('AS_OPP_ADDRESS_REQUIRED'),'Y');
          IF (l_check_address = 'Y')
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
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


PROCEDURE Validate_END_USER_ADDRESS_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_END_USER_ADDRESS_ID        IN   NUMBER,
    P_END_USER_CUSTOMER_ID       IN   NUMBER,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_END_USER_ADDRESS_ID';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_END_USER_ADDRESS_ID is not NULL) and
         (p_END_USER_ADDRESS_ID <> FND_API.G_MISS_NUM)
      THEN
          IF (p_END_USER_CUSTOMER_ID is NULL) or
             (p_END_USER_CUSTOMER_ID = FND_API.G_MISS_NUM)
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --       'Private API: need CUSTOMER_ID to validate ADDRESS_ID');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_MISSING_END_USER_CUST_ID');

              x_return_status := FND_API.G_RET_STS_ERROR;

          ELSE
              AS_TCA_PVT.validate_party_site_id(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_party_id               => P_END_USER_CUSTOMER_ID,
                  p_party_site_id          => P_END_USER_ADDRESS_ID,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --           'Private API: END_USER_ADDRESS_ID is invalid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_END_USER_ADDR_ID',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_END_USER_ADDRESS_ID );

              END IF;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_END_USER_ADDRESS_ID;

PROCEDURE Validate_OPP_OWNER (
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode        IN   VARCHAR2,
    P_OWNER_SALESFORCE_ID    IN   NUMBER,
    P_OWNER_SALES_GROUP_ID   IN   NUMBER,
    X_Item_Property_Rec      OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status          OUT NOCOPY  VARCHAR2,
    X_Msg_Count              OUT NOCOPY  NUMBER,
    X_Msg_Data               OUT NOCOPY  VARCHAR2
    )
IS

CURSOR VALIDATE_SALESGROUP (p_SALESGROUP_ID NUMBER)
IS
      SELECT 'X'
      FROM   jtf_rs_groups_b grp
      WHERE  NVL(GRP.end_date_active,SYSDATE) >= SYSDATE
      AND    grp.group_id = p_SALESGROUP_ID ;

CURSOR VALIDATE_COMBINATION (p_SALESREP_ID NUMBER, p_SALESGROUP_ID NUMBER)
IS
	SELECT 'X'
	  FROM jtf_rs_group_members GRPMEM
	 WHERE resource_id = p_SALESREP_ID
	   AND group_id = p_SALESGROUP_ID
	   AND delete_flag = 'N'
	   AND EXISTS
		(SELECT 'X'
		   FROM jtf_rs_role_relations REL
		  WHERE role_resource_type = 'RS_GROUP_MEMBER'
		    AND delete_flag = 'N'
		    AND sysdate between REL.start_date_active  and nvl(REL.end_date_active,sysdate)
		    AND REL.role_resource_id = GRPMEM.group_member_id
		    AND role_id IN (SELECT role_id FROM jtf_rs_roles_b WHERE role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM')));


CURSOR VALIDATE_SALESREP (P_SALESREP_ID NUMBER)
IS
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
      AND    res.resource_id = p_SALESREP_ID
      AND    res.category = 'EMPLOYEE';

l_val   VARCHAR2(1);
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_OPP_OWNER';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	  OPEN  VALIDATE_SALESREP (p_owner_salesforce_id);
	  FETCH VALIDATE_SALESREP into l_val;
	  IF VALIDATE_SALESREP%NOTFOUND THEN
	      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		    'Private API: OWNER_SALESFORCE_ID is not valid');
	      END IF;
		AS_UTILITY_PVT.Set_Message(
		  p_module        => l_module,
		  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  p_msg_name      => 'API_INVALID_ID',
		  p_token1        => 'COLUMN',
		  p_token1_value  => 'OWNER SALESFORCE_ID',
		  p_token2        => 'VALUE',
		  p_token2_value  => p_owner_salesforce_id );
	      x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
	  CLOSE VALIDATE_SALESREP;

	  OPEN  VALIDATE_SALESGROUP (p_owner_sales_group_id);
	  FETCH VALIDATE_SALESGROUP into l_val;
	  IF VALIDATE_SALESGROUP%NOTFOUND THEN
	      IF l_debug THEN
		      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
			    'Private API: OWNER_SALES_GROUP_ID is not valid');
	      END IF;
		AS_UTILITY_PVT.Set_Message(
		  p_module        => l_module,
		  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  p_msg_name      => 'API_INVALID_ID',
		  p_token1        => 'COLUMN',
		  p_token1_value  => 'OWNER SALESGROUP_ID',
		  p_token2        => 'VALUE',
		  p_token2_value  => p_owner_sales_group_id );
	      x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
	  CLOSE VALIDATE_SALESGROUP;

	  OPEN  VALIDATE_COMBINATION (p_owner_salesforce_id,p_owner_sales_group_id);
	  FETCH VALIDATE_COMBINATION into l_val;
	  IF VALIDATE_COMBINATION%NOTFOUND THEN
	      IF l_debug THEN
	      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_ERROR,
		    'Private API: OWNER_SALES_GROUP_ID is not valid');
	      END IF;
		AS_UTILITY_PVT.Set_Message(
		  p_module        => l_module,
		  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
		  p_msg_name      => 'API_INVALID_ID',
		  p_token1        => 'COLUMN',
		  p_token1_value  => 'OWNER SALESFORCE/SALESGROUP COMBINATION',
		  p_token2        => 'VALUE',
		  p_token2_value  => to_char(p_owner_salesforce_id) || '/' || to_char(p_owner_sales_group_id) );
	      x_return_status := FND_API.G_RET_STS_ERROR;
	  END IF;
	  CLOSE VALIDATE_COMBINATION;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OPP_OWNER;

PROCEDURE Validate_AUTO_ASGN_TYPE (
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
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_AUTO_ASGN_TYPE';

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
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --              'Private API: AUTO_ASSIGNMENT_TYPE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
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

END Validate_AUTO_ASGN_TYPE;


PROCEDURE Validate_PRM_ASGN_TYPE (
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
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRM_ASGN_TYPE';

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
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --              'Private API: PRM_ASSIGNMENT_TYPE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
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

END Validate_PRM_ASGN_TYPE;


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
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_INC_PRTNR_RESOURCE_ID';

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
          -- INCUMBENT_PARTNER_RESOURCE_ID should exist in jtf_rs_resource_extns
          OPEN  C_RESOURCE_ID_Exists (p_INC_PARTNER_RESOURCE_ID);
          FETCH C_RESOURCE_ID_Exists into l_val;

          IF C_RESOURCE_ID_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --          'Private API: INC_PARTNER_RESOURCE_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_INC_PRTN_RS_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_INC_PARTNER_RESOURCE_ID );

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
  CURSOR C_PRM_IND_CLS_CODE_Exists (c_lookup_type VARCHAR2,
                                    c_Lookup_Code VARCHAR2) IS
      SELECT  'X'
      FROM  as_lookups
      WHERE lookup_type = c_lookup_type
            and lookup_code = c_Lookup_Code;
  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRM_IND_CLS_CODE';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRM_IND_CLASSIFICATION_CODE is NOT NULL) and
         (p_PRM_IND_CLASSIFICATION_CODE <> FND_API.G_MISS_CHAR)
      THEN
          -- PRM_IND_CLASSIFICATION_CODE should exist in as_lookups
          OPEN  C_PRM_IND_CLS_CODE_Exists ('PRM_IND_CLASSIFICATION_TYPE',
                                           p_PRM_IND_CLASSIFICATION_CODE);
          FETCH C_PRM_IND_CLS_CODE_Exists into l_val;

          IF C_PRM_IND_CLS_CODE_Exists%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --       'Private API: PRM_IND_CLASSIFICATION_CODE is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRM_IND_CLS_CODE',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRM_IND_CLASSIFICATION_CODE );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          CLOSE C_PRM_IND_CLS_CODE_Exists;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_IND_CLS_CODE;


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
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRM_EXEC_SPONSOR_FLAG';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRM_EXEC_SPONSOR_FLAG is NOT NULL) and
         (p_PRM_EXEC_SPONSOR_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_PRM_EXEC_SPONSOR_FLAG) <> 'Y') and
             (UPPER(p_PRM_EXEC_SPONSOR_FLAG) <> 'N')
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --        'Private API: PRM_EXEC_SPONSOR_FLAG is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRM_EXEC_SPNR_FLAG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRM_EXEC_SPONSOR_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
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
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_PRM_PRJ_LDINPLE_FLAG';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_PRM_PRJ_LEAD_IN_PLACE_FLAG is NOT NULL) and
         (p_PRM_PRJ_LEAD_IN_PLACE_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_PRM_PRJ_LEAD_IN_PLACE_FLAG) <> 'Y') and
             (UPPER(p_PRM_PRJ_LEAD_IN_PLACE_FLAG) <> 'N')
          THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
              --        'Private API: PRM_PRJ_LEAD_IN_PLACE_FLAG is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_PRM_PRJ_LDINPL_FLG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_PRM_PRJ_LEAD_IN_PLACE_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PRM_PRJ_LDINPLE_FLAG;


-- 091200 ffang, for bug 1402449, description is a mandatory column
PROCEDURE Validate_Description (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_Description        IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_Description';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_Description is NULL)
      THEN
          AS_UTILITY_PVT.Set_Message(
              p_module        => l_module,
              p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              p_msg_name      => 'API_MISSING_DESCRIPTION');

          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
END Validate_Description;
-- end 091200 ffang


PROCEDURE Validate_FREEZE_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FREEZE_FLAG                IN   VARCHAR2,
    X_Item_Property_Rec          OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_FREEZE_FLAG';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_FREEZE_FLAG is NOT NULL) and
         (p_FREEZE_FLAG <> FND_API.G_MISS_CHAR)
      THEN
          IF (UPPER(p_FREEZE_FLAG) <> 'Y') and
             (UPPER(p_FREEZE_FLAG) <> 'N')
          THEN

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_FREEZE_FLAG',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_FREEZE_FLAG );

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FREEZE_FLAG;



--
-- Record-level validation procedures
--

PROCEDURE Validate_WinPorb_StageID (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_Sales_Methodology_ID IN NUMBER,
    P_SALES_STAGE_ID     IN   NUMBER,
    P_WIN_PROBABILITY    IN   NUMBER,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Get_Stage_Info (c_SALES_STAGE_ID NUMBER) IS
      SELECT  nvl(min_win_probability, 0), nvl(max_win_probability, 100)
      FROM  as_sales_stages_all_b
      WHERE sales_stage_id = c_Sales_Stage_Id;

  CURSOR c_Win_Prob_Limit(c_SALES_METHODOLOGY_ID NUMBER, c_SALES_STAGE_ID NUMBER) IS
      SELECT  nvl(min_win_probability, 0), nvl(max_win_probability, 100)
      FROM as_sales_meth_stage_map
      WHERE sales_methodology_id = c_SALES_METHODOLOGY_ID
      AND   sales_stage_id = c_SALES_STAGE_ID;


  l_min_winprob   NUMBER;
  l_max_winprob   NUMBER;
  l_warning_msg   VARCHAR2(2000) := '';

  l_prob_ss_link  VARCHAR2(10) :=
        NVL(FND_PROFILE.Value('AS_OPPTY_PROB_SS_LINK'), 'WARNING');

  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_WinPorb_StageID';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF(p_SALES_METHODOLOGY_ID is NOT NULL) and
     (p_SALES_METHODOLOGY_ID <> FND_API.G_MISS_NUM) THEN

      IF (p_SALES_STAGE_ID is NOT NULL) and
         (p_SALES_STAGE_ID <> FND_API.G_MISS_NUM) and
         (P_WIN_PROBABILITY is NOT NULL) and
         (P_WIN_PROBABILITY  <> FND_API.G_MISS_NUM)
      THEN
          -- get Sales Stage information
          OPEN  c_Win_Prob_Limit (p_SALES_METHODOLOGY_ID, p_SALES_STAGE_ID);
          FETCH c_Win_Prob_Limit into l_min_winprob, l_max_winprob;

          IF c_Win_Prob_Limit%NOTFOUND THEN
              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_SALES_STAGE_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_SALES_STAGE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;

          -- Validate the win probability/sales stage link
          ELSIF l_min_winprob > p_win_probability or
              l_max_winprob < p_win_probability
          THEN
              IF l_prob_ss_link = 'WARNING'
              THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                  THEN

			NULL; -- bug 2437635
			--FND_MESSAGE.Set_Name('AS', 'API_WARN_PROB_SS_LINK');
                        --FND_MSG_PUB.ADD;
                        --FND_MSG_PUB.G_MSG_LVL_ERROR

              		--AS_UTILITY_PVT.Set_Message(
                  	--p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	--p_msg_name      =>  'API_WARN_PROB_SS_LINK');

		  	 l_warning_msg := FND_MESSAGE.GET_STRING('AS','API_WARN_PROB_SS_LINK');
                  -- x_return_status := FND_API.G_RET_STS_ERROR;


                  END IF;

              ELSIF l_prob_ss_link = 'ERROR'
              THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      -- FND_MESSAGE.Set_Name('AS', 'API_ERROR_PROB_SS_LINK');
                      -- FND_MSG_PUB.ADD;

              		AS_UTILITY_PVT.Set_Message(
                  	p_module        => l_module,
                  	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	p_msg_name      =>  'API_ERROR_PROB_SS_LINK');

                  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;
          END IF;

          CLOSE c_Win_Prob_Limit;
      END IF;

   ELSE

      IF (p_SALES_STAGE_ID is NOT NULL) and
         (p_SALES_STAGE_ID <> FND_API.G_MISS_NUM) and
         (P_WIN_PROBABILITY is NOT NULL) and
         (P_WIN_PROBABILITY  <> FND_API.G_MISS_NUM)
      THEN
          -- get Sales Stage information
          OPEN  C_Get_Stage_Info (p_SALES_STAGE_ID);
          FETCH C_Get_Stage_Info into l_min_winprob, l_max_winprob;

          IF C_Get_Stage_Info%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              --                     'Private API: SALES_STAGE_ID is invalid');

              AS_UTILITY_PVT.Set_Message(
                  p_module        => l_module,
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'API_INVALID_SALES_STAGE_ID',
                  p_token1        => 'VALUE',
                  p_token1_value  => p_SALES_STAGE_ID );

              x_return_status := FND_API.G_RET_STS_ERROR;

          -- Validate the win probability/sales stage link
          ELSIF l_min_winprob > p_win_probability or
              l_max_winprob < p_win_probability
          THEN
              IF l_prob_ss_link = 'WARNING'
              THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
                  THEN
                       --FND_MESSAGE.Set_Name('AS', 'API_WARN_PROB_SS_LINK');
                       --FND_MSG_PUB.ADD;

              		--AS_UTILITY_PVT.Set_Message(
                  	--p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	--p_msg_name      =>  'API_WARN_PROB_SS_LINK');
		  l_warning_msg := FND_MESSAGE.GET_STRING('AS','API_WARN_PROB_SS_LINK');
                  -- x_return_status := FND_API.G_RET_STS_ERROR;


                  END IF;

              ELSIF l_prob_ss_link = 'ERROR'
              THEN
                  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
                  THEN
                      -- FND_MESSAGE.Set_Name('AS', 'API_ERROR_PROB_SS_LINK');
                      -- FND_MSG_PUB.ADD;

              		AS_UTILITY_PVT.Set_Message(
                  	p_module        => l_module,
                  	p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  	p_msg_name      =>  'API_ERROR_PROB_SS_LINK');

                  END IF;

                  x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;
          END IF;

          CLOSE C_Get_Stage_Info;
      END IF;

   END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       		x_msg_data := l_warning_msg;
       END IF;

END Validate_WinPorb_StageID;


PROCEDURE Validate_Status_CloseReason (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_STATUS             IN   VARCHAR2,
    P_CLOSE_REASON       IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
  CURSOR C_Get_OppOpenStatusFlag (c_STATUS_CODE VARCHAR2) IS
      SELECT  opp_open_status_flag
      FROM  as_statuses_b
      WHERE STATUS_CODE = c_STATUS_CODE
		  and opp_flag = 'Y'
            and ENABLED_FLAG = 'Y';
  l_val VARCHAR2(1);
  l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_Status_CloseReason';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF (p_STATUS is NOT NULL) and (p_STATUS <> FND_API.G_MISS_CHAR)
	 THEN
          IF (P_CLOSE_REASON is NULL) or (P_CLOSE_REASON = FND_API.G_MISS_CHAR)
          THEN
              -- get opp_open_status_flag
              OPEN  C_Get_OppOpenStatusFlag (p_STATUS);
              FETCH C_Get_OppOpenStatusFlag into l_val;

              IF C_Get_OppOpenStatusFlag%NOTFOUND THEN
              -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
              --                     'Private API: STATUS is invalid');

                  AS_UTILITY_PVT.Set_Message(
                      p_module        => l_module,
                      p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                      p_msg_name      => 'API_INVALID_OPP_STATUS',
                      p_token1        => 'VALUE',
                      p_token1_value  => p_STATUS );

                  x_return_status := FND_API.G_RET_STS_ERROR;

              -- If opp_open_status_flag = 'N' (closed status),
              -- then close_reason should exist
              ELSIF l_val = 'N'
              THEN
                  -- AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_ERROR,
                  --     'Private API: CLOSE_REASON is missing');

                  AS_UTILITY_PVT.Set_Message(
                     p_module        => l_module,
                     p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                     p_msg_name      => 'API_MISSING_CLOSE_REASON');

                  x_return_status := FND_API.G_RET_STS_ERROR;

              END IF;

              CLOSE C_Get_OppOpenStatusFlag;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Status_CloseReason;




PROCEDURE Validate_DecisionDate (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_DECISION_DATE      IN   DATE,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS

l_max_date DATE;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_DecisionDate';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF FND_PROFILE.value('AS_MAX_DAY_CLOSE_OPPORTUNITY') IS NOT NULL THEN
      l_max_date := TRUNC(SYSDATE)+ to_number(FND_PROFILE.value('AS_MAX_DAY_CLOSE_OPPORTUNITY'));
             IF TRUNC(P_DECISION_DATE) > l_max_date THEN
      		--DBMS_OUTPUT.PUT_LINE('rAISE ERROR');
      		x_return_status := FND_API.G_RET_STS_ERROR;
              	AS_UTILITY_PVT.Set_Message(
              	         p_module        => l_module,
              	         p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
              	         p_msg_name      => 'AS_CLOSE_DATE_VALIDATION',
              	         p_token1        => 'DATE',
                         p_token1_value  =>  TO_CHAR(l_max_date));
             END IF;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
      WHEN VALUE_ERROR THEN
      	--DBMS_OUTPUT.PUT_LINE('In VALUE_ERROR exception');
      	x_return_status := FND_API.G_RET_STS_ERROR;
      	AS_UTILITY_PVT.Set_Message(
                       p_module        => l_module,
                       p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                       p_msg_name      => 'AS_MAX_DAY_ERROR');

END Validate_DecisionDate;


PROCEDURE Validate_BudgetAmt_Currency (
    P_Init_Msg_List      IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode    IN   VARCHAR2,
    P_TOTAL_AMOUNT       IN   NUMBER,
    P_CURRENCY_CODE      IN   VARCHAR2,
    X_Item_Property_Rec  OUT NOCOPY  AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE,
    X_Return_Status      OUT NOCOPY  VARCHAR2,
    X_Msg_Count          OUT NOCOPY  NUMBER,
    X_Msg_Data           OUT NOCOPY  VARCHAR2
    )
IS
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_BudgetAmt_Currency';

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- If budget amount is entered
      -- then currency_code should exist
      IF (P_TOTAL_AMOUNT is NOT NULL) and
         (P_TOTAL_AMOUNT <> FND_API.G_MISS_NUM)
      THEN
          IF (p_CURRENCY_CODE is NULL) or
             (p_CURRENCY_CODE = FND_API.G_MISS_CHAR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                 p_module        => l_module,
                 p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                 p_msg_name      => 'API_MISSING_CURRENCY_CODE');

              x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


END Validate_BudgetAmt_Currency;



PROCEDURE Validate_opp_header(
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2

    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_opp_header';
l_Item_Property_Rec   AS_UTILITY_PUB.ITEM_PROPERTY_REC_TYPE;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_Win_prob_warning_msg VARCHAR2(2000) := '';
l_module CONSTANT VARCHAR2(255) := 'as.plsql.ldhpv.Validate_opp_header';
 BEGIN

      -- Debug Message
      IF l_debug THEN
      AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Added for MOAC
      Validate_ORG_ID(
          p_init_msg_list          => FND_API.G_FALSE,
          p_validation_mode        => p_validation_mode,
          p_ORG_ID                 => P_Header_Rec.ORG_ID,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

      -- Calling item level validation procedures
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_ITEM)
      THEN
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_LEAD_ID');
              END IF;

              Validate_LEAD_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_LEAD_ID                => P_Header_Rec.LEAD_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;



              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_STATUS');
	      END IF;

              Validate_STATUS(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_STATUS                 => P_HEADER_REC.STATUS_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_SALES_STAGE_ID');
	      END IF;

              Validate_SALES_STAGE_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_SALES_STAGE_ID         => P_Header_Rec.SALES_STAGE_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Validate_CHANNEL_CODE');
              END IF;

              Validate_CHANNEL_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CHANNEL_CODE           => P_Header_Rec.CHANNEL_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,'Validate_CURRENCY_CODE');
              END IF;

              Validate_CURRENCY_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CURRENCY_CODE          => P_Header_Rec.CURRENCY_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

	      IF l_debug THEN
	            AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
	                                         'Validate_DecisionDate');
	      END IF;
	  	Validate_DecisionDate(
	                p_init_msg_list          => FND_API.G_FALSE,
	                p_validation_mode        => p_validation_mode,
	                P_DECISION_DATE          => P_Header_Rec.DECISION_DATE,
	                x_item_property_rec      => l_item_property_rec,
	                x_return_status          => x_return_status,
	                x_msg_count              => x_msg_count,
	                x_msg_data               => x_msg_data);
	        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	                raise FND_API.G_EXC_ERROR;
	        END IF;

          	IF l_debug THEN
          	AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_BudgetAmt_Currency');

          	END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_WIN_PROBABILITY');

              END IF;

              Validate_WIN_PROBABILITY(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_WIN_PROBABILITY        => P_Header_Rec.WIN_PROBABILITY,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                      x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
                  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_CLOSE_REASON');
	      END IF;

              Validate_CLOSE_REASON(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CLOSE_REASON           => P_Header_Rec.CLOSE_REASON,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_SOURCE_PROMOTION_ID');
		END IF;

              Validate_SOURCE_PROMOTION_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_SOURCE_PROMOTION_ID    => P_Header_Rec.SOURCE_PROMOTION_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_NO_OPP_ALLOWED_FLAG');
              END IF;

              Validate_NO_OPP_ALLOWED_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_NO_OPP_ALLOWED_FLAG    => P_Header_Rec.NO_OPP_ALLOWED_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_DELETE_ALLOWED_FLAG');
              END IF;

              Validate_DELETE_ALLOWED_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_DELETE_ALLOWED_FLAG    => P_Header_Rec.DELETE_ALLOWED_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_LEAD_SOURCE_CODE');
              END IF;

              Validate_LEAD_SOURCE_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_LEAD_SOURCE_CODE       => P_Header_Rec.LEAD_SOURCE_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRICE_LIST_ID');
              END IF;

              Validate_PRICE_LIST_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_PRICE_LIST_ID          => P_Header_Rec.PRICE_LIST_ID,
                  p_CURRENCY_CODE          => P_Header_Rec.CURRENCY_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_DELETED_FLAG');
              END IF;

              Validate_DELETED_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_DELETED_FLAG           => P_Header_Rec.DELETED_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_METHODOLOGY_CODE');
              END IF;

              Validate_METHODOLOGY_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_METHODOLOGY_CODE       => P_Header_Rec.METHODOLOGY_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_ORIGINAL_LEAD_ID');
              END IF;

              Validate_ORIGINAL_LEAD_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_ORIGINAL_LEAD_ID       => P_Header_Rec.ORIGINAL_LEAD_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_DECN_TIMEFRAME_CODE');
              END IF;

              Validate_DECN_TIMEFRAME_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_DECISION_TIMEFRAME_CODE
                                       => P_Header_Rec.DECISION_TIMEFRAME_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_OFFER_ID');
              END IF;

              Validate_OFFER_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
		  p_SOURCE_PROMOTION_ID    => P_Header_Rec.SOURCE_PROMOTION_ID,
                  p_OFFER_ID               => P_Header_Rec.OFFER_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_VEHICLE_RESPONSE_CODE');
              END IF;

              Validate_VEHICLE_RESPONSE_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_VEHICLE_RESPONSE_CODE => P_Header_Rec.VEHICLE_RESPONSE_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_BUDGET_STATUS_CODE');
              END IF;

              Validate_BUDGET_STATUS_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_BUDGET_STATUS_CODE   => P_Header_Rec.BUDGET_STATUS_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRM_LEAD_TYPE');
              END IF;

              Validate_PRM_LEAD_TYPE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  P_PRM_LEAD_TYPE          => P_Header_Rec.PRM_LEAD_TYPE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_CUSTOMER_ID');
              END IF;

              Validate_CUSTOMER_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CUSTOMER_ID            => P_Header_Rec.CUSTOMER_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_INC_PARTNER_PARTY_ID');
              END IF;

              Validate_INC_PARTNER_PARTY_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  P_INC_PARTNER_PARTY_ID   =>
                                      P_Header_Rec.INCUMBENT_PARTNER_PARTY_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_CLOSE_COMPETITOR_ID');
              END IF;

              Validate_CLOSE_COMPETITOR_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_CLOSE_COMPETITOR_ID    => P_Header_Rec.CLOSE_COMPETITOR_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_END_USER_CUSTOMER_ID');
              END IF;

              Validate_END_USER_CUSTOMER_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_END_USER_CUSTOMER_ID   => P_Header_Rec.END_USER_CUSTOMER_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_ADDRESS_ID');
              END IF;

              Validate_ADDRESS_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_ADDRESS_ID             => P_Header_Rec.ADDRESS_ID,
                  p_CUSTOMER_ID            => P_Header_Rec.CUSTOMER_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_END_USER_ADDRESS_ID');
              END IF;

              Validate_END_USER_ADDRESS_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_END_USER_ADDRESS_ID    => P_Header_Rec.END_USER_ADDRESS_ID,
                  P_END_USER_CUSTOMER_ID   => P_Header_Rec.END_USER_CUSTOMER_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_AUTO_ASGN_TYPE');
              END IF;

              Validate_AUTO_ASGN_TYPE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_AUTO_ASSIGNMENT_TYPE   => P_Header_Rec.AUTO_ASSIGNMENT_TYPE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRM_ASGN_TYPE');
              END IF;

              Validate_PRM_ASGN_TYPE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_PRM_ASSIGNMENT_TYPE    => P_Header_Rec.PRM_ASSIGNMENT_TYPE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_INC_PRTNR_RESOURCE_ID');
              END IF;

              Validate_INC_PRTNR_RESOURCE_ID(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  P_INC_PARTNER_RESOURCE_ID   =>
                                    P_Header_Rec.INCUMBENT_PARTNER_RESOURCE_ID,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRM_IND_CLS_CODE');
              END IF;

              Validate_PRM_IND_CLS_CODE(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_PRM_IND_CLASSIFICATION_CODE   =>
                                      P_Header_Rec.PRM_IND_CLASSIFICATION_CODE,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRM_EXEC_SPONSOR_FLAG');
              END IF;

              Validate_PRM_EXEC_SPONSOR_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_PRM_EXEC_SPONSOR_FLAG => P_Header_Rec.PRM_EXEC_SPONSOR_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_PRM_PRJ_LDINPLE_FLAG');
              END IF;

              Validate_PRM_PRJ_LDINPLE_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_PRM_PRJ_LEAD_IN_PLACE_FLAG   =>
                                      P_Header_Rec.PRM_PRJ_LEAD_IN_PLACE_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;

              -- 091200 ffang, for bug 1402449
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_DESCRIPTION');
              END IF;

              Validate_DESCRIPTION(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_DESCRIPTION            => P_Header_Rec.DESCRIPTION,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;
              -- end 091200 ffang

              -- solin, for bug 1554330
              IF l_debug THEN
              AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                           'Validate_FREEZE_FLAG');
              END IF;

              Validate_FREEZE_FLAG(
                  p_init_msg_list          => FND_API.G_FALSE,
                  p_validation_mode        => p_validation_mode,
                  p_FREEZE_FLAG            =>
                                      P_Header_Rec.FREEZE_FLAG,
                  x_item_property_rec      => l_item_property_rec,
                  x_return_status          => x_return_status,
                  x_msg_count              => x_msg_count,
                  x_msg_data               => x_msg_data);
              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  raise FND_API.G_EXC_ERROR;
              END IF;
              IF (P_Header_Rec.OWNER_SALESFORCE_ID IS NOT NULL AND
	          P_Header_Rec.OWNER_SALESFORCE_ID <> FND_API.G_MISS_NUM)  AND
	          (P_Header_Rec.OWNER_SALES_GROUP_ID IS NOT NULL AND
		   P_Header_Rec.OWNER_SALES_GROUP_ID  <> FND_API.G_MISS_NUM) THEN
		      VALIDATE_OPP_OWNER(
			    P_Init_Msg_List          => FND_API.G_FALSE,
			    P_Validation_mode        => p_validation_mode,
			    P_OWNER_SALESFORCE_ID    => P_Header_Rec.OWNER_SALESFORCE_ID,
			    P_OWNER_SALES_GROUP_ID   => P_Header_Rec.OWNER_SALES_GROUP_ID,
			    x_item_property_rec      => l_item_property_rec,
			    x_return_status          => x_return_status,
			    x_msg_count              => x_msg_count,
			    x_msg_data               => x_msg_data);
		      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  raise FND_API.G_EXC_ERROR;
		      END IF;
	      END IF;

              -- end solin

      END IF;

      -- Calling record level validation procedures
      IF (p_validation_level >= AS_UTILITY_PUB.G_VALID_LEVEL_RECORD)
      THEN
          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_WinPorb_StageID');
          END IF;

          Validate_WinPorb_StageID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
	      p_SALES_METHODOLOGY_ID   => P_Header_Rec.SALES_METHODOLOGY_ID,
              P_SALES_STAGE_ID         => P_Header_Rec.SALES_STAGE_ID,
              P_WIN_PROBABILITY        => P_Header_Rec.WIN_PROBABILITY,
              x_item_property_rec      => l_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             l_Win_prob_warning_msg := x_msg_data;
          END IF;

          IF l_debug THEN
          AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                       'Validate_Status_CloseReason');
          END IF;

          Validate_Status_CloseReason(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              P_STATUS                 => P_Header_Rec.STATUS_CODE,
              P_CLOSE_REASON           => P_Header_Rec.CLOSE_REASON,
              x_item_property_rec      => l_item_property_rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;



          Validate_BudgetAmt_Currency (
              P_Init_Msg_List          => FND_API.G_FALSE,
              P_Validation_mode        => p_validation_mode,
              P_TOTAL_AMOUNT           => P_Header_Rec.TOTAL_AMOUNT,
              P_CURRENCY_CODE          => P_Header_Rec.CURRENCY_CODE,
              X_Item_Property_Rec      => l_item_property_rec,
              X_Return_Status          => x_return_status,
              X_Msg_Count              => x_msg_count,
              X_Msg_Data               => x_msg_data);
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
                                   'Private API: ' || l_api_name || ' end');

      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
            x_msg_data := l_Win_prob_warning_msg;
      END IF;

END Validate_opp_header;


End AS_OPP_HEADER_PVT;

/
