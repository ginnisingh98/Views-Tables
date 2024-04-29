--------------------------------------------------------
--  DDL for Package Body AMS_GEN_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_GEN_APPROVAL_PVT" as
/* $Header: amsvgapb.pls 120.2.12010000.3 2009/12/28 06:07:47 rsatyava ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ams_gen_approval_pvt';
G_ITEMTYPE     CONSTANT varchar2(30) := 'AMSGAPP';

/***************************  PRIVATE ROUTINES  *******************************/
-------------------------------------------------------------------------------
--
-- Attach Notes to Activity
-- Update Object Attributes table  if notes are added
-- Note Added will be of Type Approval
--
-------------------------------------------------------------------------------
PROCEDURE Update_Note(p_activity_type IN   VARCHAR2,
                      p_activity_id   IN   NUMBER,
                      p_note          IN   VARCHAR2,
                      p_user          IN   number,
                      x_msg_count     OUT NOCOPY  NUMBER,
                      x_msg_data      OUT NOCOPY  VARCHAR2,
                      x_return_status OUT NOCOPY  VARCHAR2)
IS
	l_id  NUMBER ;
	l_user  NUMBER;
	CURSOR c_resource IS
	SELECT user_id user_id
	FROM ams_jtf_rs_emp_v
	WHERE resource_id = p_user ;

BEGIN
	OPEN c_resource ;
	FETCH c_resource INTO l_user ;
	IF c_resource%NOTFOUND THEN
		FND_MESSAGE.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('ROW', sqlerrm );
		FND_MSG_PUB.Add;
	END IF;
	CLOSE c_resource ;
	-- Note API to Update Approval Notes
	AMS_ObjectAttribute_PVT.modify_object_attribute(
		p_api_version        => 1.0,
		p_init_msg_list      => FND_API.g_false,
		p_commit             => FND_API.g_false,
		p_validation_level   => FND_API.g_valid_level_full,
		x_return_status      => x_return_status,
		x_msg_count          => x_msg_count,
		x_msg_data           => x_msg_data,
		p_object_type        => p_activity_type,
		p_object_id          => p_activity_id ,
		p_attr               => 'NOTE',
		p_attr_defined_flag  => 'Y'
	);
	IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('ROW', sqlerrm );
		FND_MSG_PUB.Add;
	END IF;

	JTF_NOTES_PUB.Create_note(
		p_api_version      =>  1.0 ,
		x_return_status      =>  x_return_status,
		x_msg_count          =>  x_msg_count,
		x_msg_data           =>  x_msg_data,
		p_source_object_id   =>  p_activity_id,
		p_source_object_code =>  'AMS_'||p_activity_type,
		p_notes              =>  p_note,
		p_note_status        =>  NULL ,
		p_entered_by         =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
		p_entered_date       =>  sysdate,
		p_last_updated_by    =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
		x_jtf_note_id        =>  l_id ,
		p_note_type          =>  'AMS_APPROVAL'    ,
		p_last_update_date   =>  SYSDATE  ,
		p_creation_date      =>  SYSDATE  ) ;
	IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
		FND_MESSAGE.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
		FND_MESSAGE.Set_Token('ROW', sqlerrm );
		FND_MSG_PUB.Add;
	END IF;
END Update_Note;

-------------------------------------------------------------------------------
-- Start of Comments
-- NAME
--   Get_User_Role
--
-- PURPOSE
--   This Procedure will be return the User role for
--   the userid sent
-- Called By
-- NOTES
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE Get_User_Role(
	p_user_id            IN     NUMBER,
	x_role_name          OUT NOCOPY    VARCHAR2,
	x_role_display_name  OUT NOCOPY    VARCHAR2 ,
	x_return_status      OUT NOCOPY    VARCHAR2)
IS
	CURSOR c_resource IS
	SELECT employee_id source_id
	FROM ams_jtf_rs_emp_v
	WHERE resource_id = p_user_id ;
	l_person_id number;
BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	OPEN c_resource ;
	FETCH c_resource INTO l_person_id ;
	IF c_resource%NOTFOUND THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_RESOURCE_ID');
		FND_MSG_PUB.Add;
	END IF;
	CLOSE c_resource ;
    -- Pass the Employee ID to get the Role
	WF_DIRECTORY.getrolename(
		p_orig_system     => 'PER',
		p_orig_system_id    => l_person_id ,
		p_name              => x_role_name,
		p_display_name      => x_role_display_name );
	IF x_role_name is null  then
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
		FND_MSG_PUB.Add;
	END IF;
END Get_User_Role;
-------------------------------------------------------------------
-- Get the forward/reassigned resource details
-------------------------------------------------------------------
PROCEDURE Get_New_Res_Details(p_responder IN VARCHAR2,
                              x_resource_id OUT NOCOPY NUMBER,
			      x_resource_disp_name OUT NOCOPY VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
l_email VARCHAR2(360);
l_notif_pref VARCHAR2(30);
l_language VARCHAR2(30);
l_territory VARCHAR2(30);

CURSOR c_res_details(p_user_name IN VARCHAR2) IS
SELECT r.resource_id
FROM fnd_user f, ams_jtf_rs_emp_v r
WHERE r.user_id = f.user_id
AND f.user_name = p_user_name;

BEGIN

  wf_directory.getroleinfo(role                    => p_responder,
                           display_name            => x_resource_disp_name,
			   email_address           => l_email,
			   notification_preference => l_notif_pref,
			   language                => l_language,
			   territory               => l_territory);


  OPEN c_res_details(p_responder);
  FETCH c_res_details INTO x_resource_id;
  IF c_res_details%NOTFOUND THEN
     l_return_status := Fnd_Api.G_RET_STS_ERROR;
  END IF;
  CLOSE c_res_details;

x_return_status := l_return_status;
END Get_New_Res_Details;
-------------------------------------------------------------------------------
--
-- Checks if there are more approvers
--
-------------------------------------------------------------------------------
PROCEDURE Check_Approval_Required(
	p_approval_detail_id    IN  NUMBER,
	p_current_seq           IN   NUMBER,
	x_next_seq              OUT NOCOPY  NUMBER,
	x_required_flag         OUT NOCOPY  VARCHAR2)
IS

	CURSOR c_check_app IS
	SELECT approver_seq
	FROM ams_approvers
	WHERE ams_approval_detail_id = p_approval_detail_id
	AND approver_seq > p_current_seq
	and TRUNC(sysdate) between TRUNC(nvl(start_date_active,sysdate -1 ))
	and TRUNC(nvl(end_date_active,sysdate + 1))
	and active_flag = 'Y'
	order by approver_seq  ;

BEGIN
	OPEN  c_check_app;
	FETCH c_check_app
	INTO x_next_seq;
	IF c_check_app%NOTFOUND THEN
		x_required_flag    :=  FND_API.G_FALSE;
	ELSE
		x_required_flag    :=  FND_API.G_TRUE;
	END IF;
	CLOSE c_check_app;
END  Check_Approval_Required;


-------------------------------------------------------------------------------
--
-- Gets approver info
-- Approvers Can be user or Role
-- If it is role it should of role_type MKTAPPR AMSAPPR
-- The Seeded role is AMS_DEFAULT_APPROVER
--
-------------------------------------------------------------------------------
PROCEDURE Get_approver_Info(
	p_approval_detail_id   IN  NUMBER,
	p_current_seq          IN   NUMBER,
        x_approver_id          OUT NOCOPY  VARCHAR2,
        x_approver_type        OUT NOCOPY  VARCHAR2,
        x_role_name            OUT NOCOPY  VARCHAR2,
        x_object_approver_id   OUT NOCOPY  VARCHAR2,
        x_notification_type    OUT NOCOPY  VARCHAR2,
        x_notification_timeout OUT NOCOPY  VARCHAR2,
        x_return_status        OUT NOCOPY  VARCHAR2)
IS
	l_approver_id  number;
	CURSOR c_approver_info IS
	SELECT approver_id,
	       approver_type,
	       object_approver_id,
	       notification_type,
	       notification_timeout
	FROM ams_approvers
	WHERE ams_approval_detail_id = p_approval_detail_id
	AND approver_seq = p_current_seq
	and TRUNC(sysdate) between TRUNC(nvl(start_date_active,sysdate -1 ))
	and TRUNC(nvl(end_date_active,sysdate + 1))
	and active_flag ='Y';

        CURSOR c_role_info IS
        SELECT rr.role_resource_id, rl.role_name
        FROM jtf_rs_role_relations rr, jtf_rs_roles_vl rl
        WHERE rr.role_id = rl.role_id
        AND rr.role_resource_type = 'RS_INDIVIDUAL'
        AND rr.delete_flag = 'N'
        AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
        AND rl.role_type_code in ( 'MKTGAPPR', 'AMSAPPR')
        AND rl.role_id = l_approver_id;
-- SQL Repository Fix
/*
	SELECT ROLE_RESOURCE_ID,ROLE_NAME
	FROM JTF_RS_DEFRESROLES_VL
	WHERE role_type_code in( 'MKTGAPPR','AMSAPPR')
	AND ROLE_ID   = l_approver_id
	AND ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND delete_flag = 'N'
	AND TRUNC(sysdate) between TRUNC(RES_RL_start_DATE)
	and TRUNC(nvl(RES_RL_END_DATE,sysdate));
*/
        CURSOR c_role_info_count IS
        SELECT count(1)
        FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
        WHERE rr.role_id = rl.role_id
        AND rr.role_resource_type = 'RS_INDIVIDUAL'
        AND rr.delete_flag = 'N'
        AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
        AND rl.role_type_code in ( 'MKTGAPPR', 'AMSAPPR')
        AND rl.role_id = l_approver_id;
-- SQL Repository Fix
  /*
	FROM JTF_RS_DEFRESROLES_VL
	WHERE role_type_code in ('MKTGAPPR','AMSAPPR')
	AND ROLE_ID   = l_approver_id
	AND ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND delete_flag = 'N'
	AND TRUNC(sysdate) between TRUNC(RES_RL_start_DATE) and TRUNC(nvl(RES_RL_END_DATE,sysdate));
*/
	CURSOR c_default_role_info IS
	SELECT rr.role_id
	FROM jtf_rs_role_relations rr,
	     jtf_rs_roles_b rl
	WHERE rr.role_id = rl.role_id
	and  rl.role_type_code in( 'MKTGAPPR','AMSAPPR')
	AND rl.role_code   = 'AMS_DEFAULT_APPROVER'
	AND rr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
	AND delete_flag = 'N'
	AND TRUNC(sysdate) between TRUNC(rr.start_date_active)
	and TRUNC(nvl(rr.end_date_active,sysdate));

        CURSOR c_rule_name IS
        SELECT name
        FROM ams_approval_details_vl
        WHERE approval_detail_id = p_approval_detail_id;

	l_count number;
	l_pkg_name  VARCHAR2(80);
	l_proc_name VARCHAR2(80);
	dml_str     VARCHAR2(2000);
	--resultout   VARCHAR2(2000);
	x_msg_count   NUMBER;
	x_msg_data    VARCHAR2(2000);
	l_rule_name   VARCHAR2(240);

	CURSOR c_API_Name(id_in IN VARCHAR2) is
	SELECT package_name, procedure_name
	FROM ams_object_rules_b
	WHERE OBJECT_RULE_ID = id_in;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	OPEN  c_approver_info;
	FETCH c_approver_info
	INTO x_approver_id,
		x_approver_type,
		x_object_approver_id,
		x_notification_type,
		x_notification_timeout;
	IF c_approver_info%NOTFOUND THEN
		CLOSE c_approver_info;

		OPEN c_rule_name;
                FETCH c_rule_name INTO l_rule_name;
                CLOSE c_rule_name;
                Fnd_Message.Set_Name('AMS','AMS_NO_APPR_FOR_RULE');
                Fnd_Message.Set_Token('RULE_NAME',l_rule_name);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
	END IF;

/*
	IF x_approver_type = 'FUNCTION' THEN
		OPEN  c_API_Name(x_approver_id);
		FETCH c_API_Name INTO l_pkg_name, l_proc_name;
		IF c_API_Name%NOTFOUND THEN
			CLOSE c_API_Name;
			--dbms_output.put_line('In Role Check 2');
			FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_API_NAME');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_API_Name;
			dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:x_approver_id,:x_approver_type,:x_msg_count, x_msg_data,:x_return_status); END;';
			EXECUTE IMMEDIATE dml_str USING OUT x_approver_id,OUT x_approver_type, OUT x_msg_count, OUT x_msg_data,OUT x_return_status;
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				FND_MESSAGE.Set_Name('AMS','AMS_APPR_FUNCTION_API_FAIL');
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			END IF;
	END IF;
*/
	IF x_approver_type = 'ROLE' THEN
		if x_object_approver_id is null then
			OPEN  c_default_role_info ;
			FETCH c_default_role_info
			INTO x_object_approver_id;
			--dbms_output.put_line('In Role Check 1');
			IF c_default_role_info%NOTFOUND THEN
				CLOSE c_default_role_info ;
				Fnd_Message.Set_Name('AMS','AMS_NO_DEFAULT_ROLE'); -- VMODUR added
				--FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			END IF;
			CLOSE c_default_role_info ;
		end if;
		l_approver_id := x_object_approver_id;
		OPEN  c_role_info_count;
		FETCH c_role_info_count
		INTO l_count;
		IF l_count > 1 THEN
			CLOSE c_role_info_count;
			--dbms_output.put_line('In Role Check 2');
			Fnd_Message.Set_Name('AMS','AMS_MANY_DEFAULT_ROLE'); -- VMODUR added
			--FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_role_info_count;
		OPEN  c_role_info;
		FETCH c_role_info
		INTO x_object_approver_id,x_role_name;
		IF c_role_info%NOTFOUND THEN
			CLOSE c_role_info;
			--dbms_output.put_line('In Role Check 3');
			FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_role_info;
	END IF; --x_approval_type = ROLE;
	CLOSE c_approver_info;
END Get_approver_Info;
-------------------------------------------------------------------------------------
FUNCTION Is_Min_Sequence
   (p_approval_detail_id    IN NUMBER,
    p_sequence              IN NUMBER)
 RETURN BOOLEAN IS
    CURSOR c_min_seq IS
    SELECT min(approver_seq)
    FROM ams_approvers
    WHERE ams_approval_detail_id  = p_approval_detail_id
    AND active_flag = 'Y'
    AND TRUNC(sysdate) between TRUNC(nvl(start_date_active,sysdate -1 ))
    AND TRUNC(nvl(end_date_active,sysdate + 1));

    l_min_seq NUMBER;
BEGIN
    OPEN c_min_seq;
    FETCH c_min_seq INTO l_min_seq;
    IF c_min_seq%NOTFOUND THEN
       CLOSE c_min_seq;
       return false;
    END IF;
    CLOSE c_min_seq;
    IF l_min_seq = p_sequence THEN
       RETURN true;
    ELSE
       RETURN false;
    END IF;
END Is_Min_Sequence;


/************************END of Private Procedures************************************/

-- Start of Comments
--
-- NAME
--   HANDLE_ERR
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--   set it to the workflow error message attribute
--   It also sets the subject for the generic error message wf attribute
--   The generic error message body wf attribute is set in the
--   ntf_requestor_of_error procedure
--
-- NOTES
--
-- End of Comments


PROCEDURE Handle_Err
   (p_itemtype                 IN VARCHAR2    ,
    p_itemkey                  IN VARCHAR2    ,
    p_msg_count                IN NUMBER      , -- Number of error Messages
    p_msg_data                 IN VARCHAR2    ,
    p_attr_name                IN VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
   )
IS
   l_msg_count            NUMBER ;
   l_msg_data             VARCHAR2(2000);
   l_final_data           VARCHAR2(4000);
   l_msg_index            NUMBER ;
   l_cnt                  NUMBER := 0 ;
   l_appr_meaning         VARCHAR2(240);
   l_appr_obj_name        VARCHAR2(240);
   l_gen_err_sub          VARCHAR2(240);
BEGIN
   -- Retriveing Error Message from FND_MSG_PUB
   -- Called by most of the procedures if it encounter error
   WHILE l_cnt < p_msg_count
   LOOP
      FND_MSG_PUB.Get
        (p_msg_index       => l_cnt + 1,
         p_encoded         => FND_API.G_FALSE,
         p_data            => l_msg_data,
         p_msg_index_out   => l_msg_index )       ;
      l_final_data := l_final_data ||l_msg_index||': '
          ||l_msg_data||fnd_global.local_chr(10) ;
      l_cnt := l_cnt + 1 ;
   END LOOP ;
   x_error_msg   := l_final_data;
   WF_ENGINE.SetItemAttrText
      (itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => p_attr_name,
       avalue     => l_final_data   );
   --
   l_appr_meaning       := wf_engine.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AMS_APPROVAL_OBJECT_MEANING');

   l_appr_obj_name      := wf_engine.GetItemAttrText(
                                 itemtype => p_itemtype,
                                 itemkey  => p_itemkey,
                                 aname    => 'AMS_APPROVAL_OBJECT_NAME');
   --
   fnd_message.set_name ('AMS', 'AMS_GEN_NTF_ERROR_SUB');
   fnd_message.set_token ('OBJ_MEANING', l_appr_meaning, FALSE);
   fnd_message.set_token ('OBJ_NAME', l_appr_obj_name, FALSE);

   l_gen_err_sub  := SUBSTR(fnd_message.get,1,240);

   Wf_Engine.SetItemAttrText
      (itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => 'ERR_SUBJECT',
       avalue     => l_gen_err_sub );
END Handle_Err;
/*==============================================================================================*/

-- Start of Comments
-- NAME
--  Get_Approval_Details
-- PURPOSE
--   This Procedure get all the approval details
--
-- Used By Objects
-- p_activity_type           Activity Type or Objects
--                           (CAMP,DELV,EVEO,EVEH .. )
-- p_activity_id             Primary key of the Object
-- p_approval_type           BUDGET,CONCEPT
-- p_act_budget_id           If called from header record this field is null not used
-- p_object_details          Object details contains the detail of objects
-- x_approval_detail_id      Approval detail Id macthing the criteria
-- x_approver_seq            Approval Sequence
-- x_return_status           Return Status
-- NOTES
-- HISTORY
--  15-SEP-2000          GJOBY       CREATED
-- End of Comments
/*****************************************************************/


PROCEDURE Get_Approval_Details
( p_activity_id          IN   NUMBER,
  p_activity_type        IN   VARCHAR2,
  p_approval_type        IN   VARCHAR2 DEFAULT  'BUDGET',
 -- p_act_budget_id        IN   NUMBER, -- was default g_miss_num
  p_object_details       IN   ObjRecTyp,
  x_approval_detail_id   OUT NOCOPY  NUMBER,
  x_approver_seq         OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2)
IS

	l_amount              NUMBER           := 0; -- FND_API.G_MISS_NUM
	l_business_unit_id    NUMBER           := -9999; -- FND_API.G_MISS_NUM
	l_country_code        VARCHAR2(30)     := '-9999'; -- FND_API.G_MISS_CHAR
	l_org_id              NUMBER           := -9999; -- FND_API.G_MISS_NUM
	l_setup_type_id       NUMBER           := -9999; -- FND_API.G_MISS_NUM
	l_object_type         VARCHAR2(30)     := '-9999'; -- FND_API.G_MISS_CHAR
	l_priority            VARCHAR2(30)     := '-9999'; -- FND_API.G_MISS_CHAR
	l_approver_id         NUMBER;
	l_object_details      ObjRecTyp;
	l_activity_type       VARCHAR2(30);
	l_activity_id         NUMBER;
	l_freq_org_id         NUMBER; -- Added for fixing the Bug#6627988

  --l_approver_seq        NUMBER;
  --l_approval_detail_id  NUMBER;

 -- Get Approval Detail Id matching the Criteria
 -- Approval Object (CAMP, DELV.. ) is mandatory
 -- Approval type   (BUDGET    .. ) is mandatory
 -- APPROVAL_LIMIT_FROM  is mandatory
 -- Using Weightage Percentage
 -- business_unit_id            6
 -- organization_id             5
 -- approval_object_type        4
 -- approval_priority           3
 -- country_code                2
 -- custom_setup_id             1

	CURSOR c_approver_detail_id IS
	SELECT approval_detail_id, seeded_flag
		FROM ams_approval_details
	WHERE nvl(business_unit_id,l_business_unit_id)  = l_business_unit_id
	AND nvl(organization_id,l_org_id)             = l_org_id
	AND nvl(custom_setup_id,l_setup_type_id)      = l_setup_type_id
	AND approval_object                           = p_activity_type
	AND approval_type                             = p_approval_type
	AND nvl(approval_object_type,l_object_type)   = l_object_type
	AND NVL(user_country_code,l_country_code)     = l_country_code
	AND nvl(approval_priority,l_priority)         = l_priority
	AND seeded_flag                               = 'N'
	AND active_flag = 'Y'
	AND l_amount between nvl(approval_limit_from,0) and
                    nvl(approval_limit_to,l_amount)
	and TRUNC(sysdate) between TRUNC(nvl(start_date_active,sysdate -1 ))
	and TRUNC(nvl(end_date_active,sysdate + 1))
  ORDER BY (POWER(2,DECODE(business_unit_id,'',0,6)) +
               POWER(2,DECODE(organization_id,'',0,5)) +
               POWER(2,DECODE(custom_setup_id,'',0,1)) +
	       POWER(2,DECODE(user_country_code,'',0,2)) +
               POWER(2,DECODE(approval_object_type,'',0,3)) +
               POWER(2,DECODE(approval_priority,'',0,4)  )) DESC ;
/*
	order by (power(2,decode(business_unit_id,'',0,5)) +
               power(2,decode(organization_id,'',0,4)) +
               power(2,decode(custom_setup_id,'',0,1)) +
               power(2,decode(approval_object_type,'',0,2)) +
               power(2,decode(approval_priority,'',0,3)  )) desc ;
*/
  -- If the there are no matching records it takes the default Rule
  CURSOR c_approver_def IS
  SELECT approval_detail_id, seeded_flag
    FROM ams_approval_details
   WHERE approval_detail_id = 150;
  -- WHERE seeded_flag = 'Y'; -- to avoid FTS

  -- Takes Min Approver Sequence From Ams_approvers Once matching records are
  -- Found from ams_approval_deatils
  CURSOR c_approver_seq IS
  SELECT min(approver_seq)
    FROM ams_approvers
   WHERE ams_approval_detail_id  = x_approval_detail_id
   AND active_flag = 'Y'
   AND TRUNC(sysdate) between TRUNC(nvl(start_date_active,sysdate -1 ))
   AND TRUNC(nvl(end_date_active,sysdate + 1));
/*
  -- For Budgets the priority has to to be taken from the Object priority
  -- The Following cursor returns the Approval object and Approval Object Id
  -- for the parent

  CURSOR c_fund_priority IS
  SELECT ARC_ACT_BUDGET_USED_BY,
         ACT_BUDGET_USED_BY_ID
    FROM ams_act_budgets
   WHERE ACTIVITY_BUDGET_ID =  p_act_budget_id;
*/
   l_seeded_flag   varchar2(1);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start: Added for fixing the bug#6340621
  IF (p_activity_type='FREQ') THEN

   BEGIN

   SELECT distinct organization_id into l_freq_org_id
   FROM   ams_approval_details
   WHERE  approval_object                           = p_activity_type
   AND    approval_type                             = p_approval_type
   AND    approval_object_type                      = p_object_details.object_type;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN

   l_freq_org_id :=-9999;

   WHEN TOO_MANY_ROWS THEN

   l_freq_org_id :=-9999;

   END;
     ELSE
      l_org_id              := nvl(p_object_details.org_id,l_org_id);

  END IF;
  -- End: Added for fixing the bug#6627988


  l_business_unit_id    :=
          nvl(p_object_details.business_unit_id,l_business_unit_id)     ;

    -- Start: Added for fixing the bug#6627988
  IF (l_freq_org_id IS NOT NULL) THEN
	  l_org_id              := nvl(p_object_details.org_id,l_org_id);
  END IF;
   -- End: Added for fixing the bug#6627988

  l_setup_type_id       := nvl(p_object_details.setup_type_id,l_setup_type_id);
  l_object_type         := nvl(p_object_details.object_type,l_object_type);
  l_priority            := nvl(p_object_details.priority,l_priority);
  l_country_code        := nvl(p_object_details.country_code,l_country_code);
  l_amount              := nvl(p_object_details.total_header_amount,l_amount);


	OPEN  c_approver_detail_id ;
	FETCH c_approver_detail_id INTO x_approval_detail_id, l_seeded_flag;
	IF c_approver_detail_id%NOTFOUND THEN
		CLOSE c_approver_detail_id;
		OPEN c_approver_def ;
		FETCH c_approver_def INTO x_approval_detail_id, l_seeded_flag;
		IF c_approver_def%NOTFOUND THEN
			CLOSE c_approver_def ;
			FND_MESSAGE.Set_Name('AMS','AMS_NO_APPROVAL_DETAIL_ID');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		END IF;
		CLOSE c_approver_def ;
	ELSE
		CLOSE c_approver_detail_id;
	END IF;

	OPEN  c_approver_seq  ;
	FETCH c_approver_seq INTO x_approver_seq ;
	IF c_approver_seq%NOTFOUND THEN
		CLOSE c_approver_seq;
		IF l_seeded_flag = 'Y' THEN
			FND_MESSAGE.Set_Name('AMS','AMS_NO_APPROVER_SEQUENCE');
			FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_ERROR;
			return;
		else
			OPEN c_approver_def ;
			FETCH c_approver_def INTO x_approval_detail_id, l_seeded_flag;
			IF c_approver_def%NOTFOUND THEN
				CLOSE c_approver_def ;
				FND_MESSAGE.Set_Name('AMS','AMS_NO_APPROVAL_DETAIL_ID');
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			END IF;
			CLOSE c_approver_def ;
			OPEN  c_approver_seq  ;
			FETCH c_approver_seq INTO x_approver_seq ;
			IF c_approver_seq%NOTFOUND THEN
				CLOSE c_approver_seq;
				FND_MESSAGE.Set_Name('AMS','AMS_NO_APPROVER_SEQUENCE');
				FND_MSG_PUB.Add;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			END IF;
		END IF;
	END IF;
	CLOSE c_approver_seq;

END Get_Approval_Details;

/*****************************************************************
-- Start of Comments
-- NAME
--   StartProcess
-- PURPOSE
--   This Procedure will Start the flow
--
-- Used By Objects
-- p_activity_type                     Activity Type or Objects
--                                     (CAMP,DELV,EVEO,EVEH .. )
-- p_activity_id                       Primary key of the Object
-- p_approval_type                     BUDGET,CONCEPT
-- p_object_version_number             Object Version Number
-- p_orig_stat_id                      The status to which is
--                                     to be reverted if process fails
-- p_new_stat_id                       The status to which it is
--                                     to be updated if the process succeeds
-- p_reject_stat_id                    The status to which is
--                                     to be updated if the process fails
-- p_requester_userid                  The requester who has submitted the
--                                     process
-- p_notes_from_requester              Notes from the requestor
-- p_workflowprocess                   Name of the workflow process
--                                     AMS_CONCEPT_APPROVAL -- For Concept
--                                     AMS_APPROVAL -- For Budget Approvals
-- p_item_type                         AMSGAPP
-- NOTES
-- Item key generated as combination of Activity Type, Activity Id, and Object
-- Version Number.
-- For ex. CAMP100007 where 7 is object version number and 10000 Activity id
-- HISTORY
--  15-SEP-2000          GJOBY       CREATED
-- End of Comments
*****************************************************************/

PROCEDURE StartProcess
           (p_activity_type          IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
            p_approval_type          IN   VARCHAR2, -- DEFAULT NULL -- pass null
            p_object_version_number  IN   NUMBER,
            p_orig_stat_id           IN   NUMBER,
            p_new_stat_id            IN   NUMBER,
            p_reject_stat_id         IN   NUMBER,
            p_requester_userid       IN   NUMBER,
            p_notes_from_requester   IN   VARCHAR2   DEFAULT NULL,
            p_workflowprocess        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
	    p_gen_process_flag       IN   VARCHAR2   DEFAULT NULL
             )
IS
    itemtype                 VARCHAR2(30) := nvl(p_item_type,'AMSGAPP');
    itemkey                  VARCHAR2(30) := p_approval_type||p_activity_type||p_activity_id||
                                                p_object_version_number;
    itemuserkey              VARCHAR2(80) := p_activity_type||p_activity_id||
                                                p_object_version_number;

    l_requester_role         VARCHAR2(320) ;  -- Changed from VARCHAR2(100)
    l_display_name           VARCHAR2(360) ;  -- Changed from VARCHAR2(240);
    l_requester_id           NUMBER ;
    l_person_id              NUMBER ;
    l_appr_for               VARCHAR2(240) ;
    l_appr_meaning           VARCHAR2(240);
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(4000);
    l_error_msg              VARCHAR2(4000);
    x_resource_id            NUMBER;
    l_index                  NUMBER;
    l_save_threshold         NUMBER := wf_engine.threshold;
    -- [BEGIN OF BUG2631497 FIXING by mchang 23-OCT-2002]
    l_user_id                NUMBER;
    l_resp_id                NUMBER;
    l_appl_id                NUMBER;
    l_security_group_id      NUMBER;
    -- [END OF BUG2631497 FIXING]

    l_appr_hist_rec          AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;

    CURSOR c_resource IS
    SELECT resource_id ,employee_id source_id,full_name resource_name
      FROM ams_jtf_rs_emp_v
     WHERE user_id = x_resource_id ;
BEGIN
  FND_MSG_PUB.initialize();

    -- 11.5.9
    -- Delete any previous approval history

    AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
	     p_object_id          => p_activity_id,
             p_object_type_code   => p_activity_type,
             p_sequence_num       => null,
	     p_action_code        => null,
             p_object_version_num => null,
             p_approval_type      => p_approval_type);

	   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	     RAISE Fnd_Api.G_EXC_ERROR;
	   END IF;


   AMS_Utility_PVT.debug_message('Start :Item Type : '||itemtype
                         ||' Item key : '||itemkey);

    -- wf_engine.threshold := -1;
   WF_ENGINE.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

   WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);


   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/
   -- [BEGIN OF BUG2631497 FIXING by mchang 23-OCT-2002]
   -- mchang: add PL/SQL security context into workfow item attributes. It could be used
   --         later on for PL/SQL function to initialize the global context when the session
   --         is established by workflow mailer.

   l_user_id := FND_GLOBAL.user_id;
   l_resp_id := FND_GLOBAL.resp_id;
   l_appl_id := FND_GLOBAL.resp_appl_id;
   l_security_group_id := FND_GLOBAL.security_group_id;

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  itemtype ,
                               itemkey    =>  itemkey,
                               aname      =>  'USER_ID',
                               avalue     =>  l_user_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  itemtype ,
                               itemkey    =>  itemkey,
                               aname      =>  'RESPONSIBILITY_ID',
                               avalue     =>  l_resp_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  itemtype ,
                               itemkey    =>  itemkey,
                               aname      =>  'APPLICATION_ID',
                               avalue     =>  l_appl_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  itemtype ,
                               itemkey    =>  itemkey,
                               aname      =>  'SECURITY_GROUP_ID',
                               avalue     =>  l_security_group_id -- was l_appl_id
                              );
   -- [END OF BUG2631497 FIXING]


   -- Activity Type  (Some of valid values are 'CAMP','DELV','EVEH','EVEO'..);
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_ACTIVITY_TYPE',
                             avalue     =>   p_activity_type  );

   -- Activity ID  (primary Id of Activity Object)
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_ACTIVITY_ID',
                               avalue    =>  p_activity_id  );


   -- Original Status Id (If error occurs we have to revert back to this
   --                     status )
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_ORIG_STAT_ID',
                               avalue    =>  p_orig_stat_id  );

   -- New Status Id (If activity is approved status of activity is updated
   --                by this status )
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_NEW_STAT_ID',
                               avalue    =>  p_new_stat_id  );

   -- Reject Status Id (If activity is approved status of activity is rejected
   --                by this status )
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_REJECT_STAT_ID',
                               avalue    =>  p_reject_stat_id  );


   -- Object Version Number
   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_OBJECT_VERSION_NUMBER',
                               avalue    =>  p_object_version_number  );

   -- Notes from the requester
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_NOTES_FROM_REQUESTOR',
                             avalue     =>  nvl(p_notes_from_requester,'') );

   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'DOCUMENT_ID',
                             avalue     =>  itemtype || ':' ||itemkey);

   WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_REQUESTER_ID',
                               avalue    =>  p_requester_userid       );

  l_return_status := FND_API.G_RET_STS_SUCCESS;


  WF_ENGINE.SetItemAttrText(itemtype =>  itemtype ,
                            itemkey  =>  itemkey,
                            aname    =>  'AMS_APPROVAL_TYPE',
                            avalue   =>  p_approval_type  );

  -- Setting up the role
  Get_User_Role(p_user_id              => p_requester_userid ,
                x_role_name            => l_requester_role,
                x_role_display_name    => l_display_name,
                x_return_status        => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
     RAISE FND_API.G_EXC_ERROR;
  END IF;


  WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'AMS_REQUESTER',
                            avalue      =>  l_requester_role  );

/* genric flag requested by mumu.*/
   WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_GENERIC_FLAG',
                             avalue     =>   p_gen_process_flag  );

   WF_ENGINE.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requester_role);


   -- Start the Process
   WF_ENGINE.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);


   -- Create the Submitted history record

   l_appr_hist_rec.object_id        := p_activity_id;
   l_appr_hist_rec.object_type_code := p_activity_type;
   l_appr_hist_rec.sequence_num     := 0;
   l_appr_hist_rec.object_version_num := p_object_version_number;
   l_appr_hist_rec.action_code      := 'SUBMITTED';
   l_appr_hist_rec.action_date      := sysdate;
   l_appr_hist_rec.approver_id      := p_requester_userid;
   l_appr_hist_rec.note             := p_notes_from_requester;
   l_appr_hist_rec.approval_type    := p_approval_type;
   l_appr_hist_rec.approver_type    := 'USER'; -- User always submits
   --
   AMS_Appr_Hist_PVT.Create_Appr_Hist(
       p_api_version_number => 1.0,
       p_init_msg_list      => FND_API.G_FALSE,
       p_commit             => FND_API.G_FALSE,
       p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
       x_return_status      => l_return_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_appr_hist_rec      => l_appr_hist_rec
        );

   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
    -- wf_engine.threshold := l_save_threshold ;
 EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
        -- wf_engine.threshold := l_save_threshold ;
        FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => l_msg_count,
          p_data    => l_msg_data);

        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg );

        RAISE;
/*
if(l_msg_count > 0)then
  for I in 1 .. l_msg_count LOOP
      fnd_msg_pub.Get
      (p_msg_index      => FND_MSG_PUB.G_NEXT,
       p_encoded        => FND_API.G_FALSE,
       p_data           => l_msg_data,
       p_msg_index_out  =>       l_index);
       dbms_output.put_line('message :'||l_msg_data);
  end loop;
end if;

        wf_core.context ('ams_gen_approval_pvt', 'StartProcess',p_activity_type
                       ,p_activity_id ,l_error_msg);
        RAISE;
     WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);


if(l_msg_count > 0)then
  for I in 1 .. l_msg_count LOOP
      fnd_msg_pub.Get
      (p_msg_index      => FND_MSG_PUB.G_NEXT,
       p_encoded        => FND_API.G_FALSE,
       p_data           => l_msg_data,
       p_msg_index_out  =>       l_index);
       dbms_output.put_line('message :'||l_msg_data);
  end loop;
end if;
*/
/*
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
*/
     WHEN OTHERS THEN
        wf_core.context ('ams_gen_approval_pvt', 'StartProcess',p_activity_type
                       ,p_activity_id ,l_error_msg);
        RAISE;

END StartProcess;

/*****************************************************************
-- Start of Comments
--
-- NAME
--   set_activity_details
--
-- PURPOSE
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE Set_Activity_Details(itemtype     IN  VARCHAR2,
                               itemkey      IN  VARCHAR2,
                               actid        IN  NUMBER,
                               funcmode     IN  VARCHAR2,
			       resultout    OUT NOCOPY VARCHAR2) IS


l_activity_id           NUMBER;
l_activity_type         VARCHAR2(30);
l_approval_type         VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_pkg_name              varchar2(80);
l_proc_name             varchar2(80);
l_return_stat		varchar2(1);
dml_str                 VARCHAR2(2000);

BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

     Get_Api_Name('WORKFLOW', l_activity_type, 'SET_ACTIVITY_DETAILS', l_approval_type, l_pkg_name, l_proc_name, l_return_stat);

     IF (l_return_stat = 'S') THEN
       dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
       EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey,IN actid,IN funcmode, OUT resultout;

    -- [BEGIN OF BUG2540804 FIXING 08/29/2002 - mchnag]
    ELSE
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    --resultout := 'COMPLETE:SUCCESS';
    -- [END OF BUG2540804 FIXING]


  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      wf_core.context('ams_gen_approval_pvt','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      raise;
   WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
      wf_core.context('ams_approval_pvt','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      raise;
END Set_Activity_Details ;


-------------------------------------------------------------------------------
--
-- Prepare_Doc
--
-------------------------------------------------------------------------------

PROCEDURE Prepare_Doc( itemtype        in  varchar2,
                       itemkey         in  varchar2,
                       actid           in  number,
                       funcmode        in  varchar2,
                       resultout       OUT NOCOPY varchar2 )
IS
BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     resultout := 'COMPLETE:SUCCESS';
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --

END;

-------------------------------------------------------------------------------
--
-- Set_Approver_Details
--
-------------------------------------------------------------------------------
PROCEDURE Set_Approver_Details( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in  number,
                                funcmode        in  varchar2,
                                resultout       OUT NOCOPY varchar2 )
IS
l_activity_type           VARCHAR2(80);
l_current_seq             NUMBER;
l_approval_detail_id      NUMBER;
l_approver_id             NUMBER;
l_approver                VARCHAR2(320); -- Was VARCHAR2(100);
l_prev_approver           VARCHAR2(320); -- Was VARCHAR2(100);
l_approver_display_name   VARCHAR2(360); -- Was VARCHAR2(80)
l_notification_type       VARCHAR2(30);
l_notification_timeout    NUMBER;
l_approver_type           VARCHAR2(30);
l_role_name               VARCHAR2(100); --l_role_name  VARCHAR2(30);
l_prev_role_name          VARCHAR2(100); --l_prev_role_name VARCHAR2(30);
l_object_approver_id      NUMBER;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_error_msg               VARCHAR2(4000);
l_pkg_name                varchar2(80);
l_proc_name               varchar2(80);
l_appr_id                 NUMBER;
dml_str                   VARCHAR2(2000);
-- 11.5.9
l_appr_hist_rec           AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
l_version                 NUMBER;
l_approval_type           VARCHAR2(30);
l_activity_id             NUMBER;
l_appr_seq                NUMBER;
l_appr_type               VARCHAR2(30);
l_obj_appr_id             NUMBER;
l_prev_approver_disp_name VARCHAR2(360);
l_note                    VARCHAR2(4000);

CURSOR c_approver(rule_id IN NUMBER) IS
     SELECT approver_seq, approver_type, object_approver_id
       FROM ams_approvers
      WHERE ams_approval_detail_id = rule_id
       AND  active_flag = 'Y'
       -- Bug 3558516 No trunc for start_date_active
       AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
       AND TRUNC(NVL(end_date_active,SYSDATE + 1));

CURSOR c_API_Name(rule_id_in IN NUMBER) is
     SELECT package_name, procedure_name
       FROM ams_object_rules_b
      WHERE OBJECT_RULE_ID = rule_id_in;

BEGIN
	FND_MSG_PUB.initialize();
	IF (funcmode = 'RUN') THEN
		l_approval_detail_id := wf_engine.GetItemAttrNumber(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'AMS_APPROVAL_DETAIL_ID' );

		l_current_seq  := wf_engine.GetItemAttrText(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'AMS_APPROVER_SEQ' );

                     -- 11.5.9

                l_activity_id := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_ID' );

                l_activity_type := Wf_Engine.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_ACTIVITY_TYPE' );

                l_version  := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_OBJECT_VERSION_NUMBER' );

                l_approval_type := Wf_Engine.GetItemAttrText(
                                    itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname   => 'AMS_APPROVAL_TYPE' );

	Get_approver_Info
          ( p_approval_detail_id   =>  l_approval_detail_id,
            p_current_seq          =>  l_current_seq ,
            x_approver_id          =>  l_approver_id,
            x_approver_type        =>  l_approver_type,
            x_role_name            =>  l_role_name ,
            x_object_approver_id   =>  l_object_approver_id,
            x_notification_type    =>  l_notification_type,
            x_notification_timeout =>  l_notification_type,
            x_return_status        =>  l_return_status);

         IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
            --RETURN;
         END IF;

        -- Bug 2729108 Fix
        IF l_current_seq = 1 OR
           Is_Min_Sequence(l_approval_detail_id, l_current_seq) THEN

         -- Get all the obj attributes once for inserts

	 -- Set Record Attributes that won't change for each approver
         l_appr_hist_rec.object_id          := l_activity_id;
	 l_appr_hist_rec.object_type_code   := l_activity_type;
         l_appr_hist_rec.object_version_num := l_version;
         l_appr_hist_rec.action_code        := 'OPEN';
         l_appr_hist_rec.approval_type      := l_approval_type;
	 l_appr_hist_rec.approval_detail_id := l_approval_detail_id;

         OPEN c_approver(l_approval_detail_id);
         LOOP
         FETCH c_approver INTO l_appr_seq, l_appr_type, l_obj_appr_id;
         EXIT WHEN c_approver%NOTFOUND;

	 -- Set Record Attributes that will change for each approver
         l_appr_hist_rec.sequence_num  := l_appr_seq;
         l_appr_hist_rec.approver_type := l_appr_type;
	 l_appr_hist_rec.approver_id   := l_obj_appr_id;

         AMS_Appr_Hist_PVT.Create_Appr_Hist(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data,
            p_appr_hist_rec      => l_appr_hist_rec
            );

	 IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;

         END LOOP;
         CLOSE c_approver;
      END IF;

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF (l_approver_type = 'FUNCTION') THEN
	  open c_API_Name(l_object_approver_id);
	  fetch c_API_Name into l_pkg_name, l_proc_name;
            IF (c_Api_Name%FOUND) THEN
              dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:appr_id, :l_return_stat); END;';
              EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey, OUT l_appr_id, OUT l_return_status;

	        IF (l_return_status = 'S') THEN
		  l_object_approver_id := l_appr_id;
                END IF;

            END IF;
          close c_API_Name;
	END IF;
      ELSE
        RAISE FND_API.G_EXC_ERROR;
      END IF;


                Get_User_Role(p_user_id         => l_object_approver_id ,
                         x_role_name            => l_approver,
                         x_role_display_name    => l_approver_display_name,
                         x_return_status        => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_ERROR;
      END IF;
                -- Change for Bug 2535600
		l_prev_approver_disp_name  := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_DISPLAY_NAME' );

		-- Added for Bug 2535600
                wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_PREV_APPROVER_DISP_NAME',
                                    avalue   => l_prev_approver_disp_name);

                l_note := wf_engine.GetItemAttrText(itemtype => itemtype,
		                                    itemkey  => itemkey,
						    aname    => 'APPROVAL_NOTE');

                wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_PREV_APPROVER_NOTE',
                                    avalue   => l_note);

                -- Need to be set to null or else it consolidates notes
		wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'APPROVAL_NOTE',
                                    avalue   => null);

		wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER_DISPLAY_NAME',
                                    avalue   => l_approver_display_name);
		-- End of 2535600


		wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER',
                                    avalue   => l_approver);

		wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER_ID',
                                    avalue   => l_object_approver_id);

                -- 11.5.9 Update the 'Open' row to 'Pending'

               l_appr_hist_rec.object_id        := l_activity_id;
	       l_appr_hist_rec.object_type_code := l_activity_type;
               l_appr_hist_rec.object_version_num := l_version;
               l_appr_hist_rec.action_code      := 'PENDING';
	       l_appr_hist_rec.action_date      := sysdate;
               l_appr_hist_rec.approval_type    := l_approval_type;
	       l_appr_hist_rec.approver_type    := l_approver_type;
	       l_appr_hist_rec.sequence_num     := l_current_seq;
               l_appr_hist_rec.approver_id      := l_object_approver_id;

               AMS_Appr_Hist_PVT.Update_Appr_Hist(
                   p_api_version_number => 1.0,
                   p_init_msg_list      => FND_API.G_FALSE,
                   p_commit             => FND_API.G_FALSE,
                   p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                   x_return_status      => l_return_status,
                   x_msg_count          => l_msg_count,
                   x_msg_data           => l_msg_data,
                   p_appr_hist_rec      => l_appr_hist_rec
                   );

	      IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	         RAISE Fnd_Api.G_EXC_ERROR;
	      END IF;

	      resultout := 'COMPLETE:SUCCESS';
	END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

 EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data
      );
    Handle_Err
      (p_itemtype          => itemtype   ,
       p_itemkey           => itemkey    ,
       p_msg_count         => l_msg_count, -- Number of error Messages
       p_msg_data          => l_msg_data ,
       p_attr_name         => 'AMS_ERROR_MSG',
       x_error_msg         => l_error_msg
      );
 wf_core.context('ams_gen_approval_pvt',
                 'set_approval_rules',
                 itemtype, itemkey,to_char(actid),l_error_msg);
       resultout := 'COMPLETE:ERROR';
     --RAISE;
 WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'set_approver_details',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
  --

END;

-------------------------------------------------------------------------------
--
-- Set_Further_Approvals
--
-------------------------------------------------------------------------------
PROCEDURE Set_Further_Approvals( itemtype        in  varchar2,
                                 itemkey         in  varchar2,
                                 actid           in  number,
                                 funcmode        in  varchar2,
                                 resultout       OUT NOCOPY varchar2 )
IS
l_current_seq             NUMBER;
l_next_seq                NUMBER;
l_approval_detail_id      NUMBER;
l_required_flag           VARCHAR2(1);
l_approver_id             NUMBER;
l_note                    VARCHAR2(4000);
l_all_note                VARCHAR2(4000);
l_activity_type           VARCHAR2(30);
l_activity_id             NUMBER;
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_return_status           VARCHAR2(1);
l_error_msg               VARCHAR2(4000);
-- 11.5.9
l_version                 NUMBER;
l_approval_type           VARCHAR2(30);
l_appr_hist_rec           AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
--
l_forward_nid             NUMBER;
l_responder               VARCHAR2(320);
l_appr_display_name       VARCHAR2(360);
BEGIN
  FND_MSG_PUB.initialize();
  IF (funcmode = 'RUN') THEN
     l_approval_detail_id := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_DETAIL_ID' );

     l_current_seq        := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_SEQ' );

     l_approver_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_ID' );

     l_activity_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

      -- Added for 11.5.9
      -- Bug 2535600
     wf_engine.SetItemAttrText(  itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_DATE',
                                 avalue   => trunc(sysdate));

     l_version            := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_OBJECT_VERSION_NUMBER' );

     l_approval_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_APPROVAL_TYPE' );

     l_note               := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'APPROVAL_NOTE' );

     -- Start of addition for forward/reassign notification

     l_forward_nid        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_FORWARD_NID' );
-- Commented for 3150550
/*
     IF l_forward_nid IS NOT NULL THEN

       l_responder := wf_notification.responder(l_forward_nid);

       Get_New_Res_Details(p_responder => l_responder,
                                  x_resource_id => l_approver_id,
                                  x_resource_disp_name => l_appr_display_name,
                                  x_return_status => l_return_status);

       IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	     RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

         -- Set the WF Attributes
         wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER',
                              avalue   => l_responder);


        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_ID',
                              avalue   => l_approver_id);


        wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_DISPLAY_NAME',
                              avalue   => l_appr_display_name);

        -- Reset the forward_nid wf attribute to null
	-- This is a must

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_FORWARD_NID',
                              avalue   => null);
     END IF;
     -- End of addition for forward/re-assign notification
*/
         -- update the record from 'PENDING' to 'APPROVED'
          l_appr_hist_rec.object_id        := l_activity_id;
          l_appr_hist_rec.object_type_code := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code      := 'APPROVED';
          l_appr_hist_rec.approval_type    := l_approval_type;
          l_appr_hist_rec.sequence_num     := l_current_seq;
          l_appr_hist_rec.approver_id      := l_approver_id;
          l_appr_hist_rec.note             := l_note;
          l_appr_hist_rec.action_date      := sysdate;

          AMS_Appr_Hist_PVT.Update_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
             p_appr_hist_rec      => l_appr_hist_rec
             );

   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

     Check_Approval_Required
             ( p_approval_detail_id       => l_approval_detail_id,
               p_current_seq              => l_current_seq,
               x_next_seq                 => l_next_seq,
               x_required_flag            => l_required_flag);
     IF l_next_seq is not null THEN
          wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER_SEQ',
                                    avalue   => l_next_seq);
        resultout := 'COMPLETE:Y';
     ELSE
        resultout := 'COMPLETE:N';
     END IF;
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'set_further_approvals',
                    itemtype, itemkey,to_char(actid),l_error_msg);
         RAISE;
WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'set_further_approvals',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
  --

END;

-------------------------------------------------------------------------------
--
-- Revert_Status
--
-------------------------------------------------------------------------------
PROCEDURE Revert_Status( itemtype        in  varchar2,
                         itemkey         in  varchar2,
                         actid           in  number,
                         funcmode        in  varchar2,
                         resultout       OUT NOCOPY varchar2    )
IS
l_activity_id            NUMBER;
l_activity_type          VARCHAR2(30);
l_orig_status_id         NUMBER;
l_return_status          varchar2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_error_msg              VARCHAR2(4000);
-- 11.5.9
l_version                NUMBER;
l_approval_type          VARCHAR2(30);
l_appr_hist_rec          AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
BEGIN
  FND_MSG_PUB.initialize();
	/*
      UPDATE AMS_CAMPAIGNS_ALL_B
         SET user_status_id = 100,
                status_code = 'New',
                status_date = sysdate,
             object_version_number = object_version_number + 1
       WHERE campaign_id = 10112;
*/
  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_version            := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_OBJECT_VERSION_NUMBER' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

     l_orig_status_id     := wf_engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ORIG_STAT_ID' );

     -- Added by VMODUR on July-02-2002
     Wf_Engine.SetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'UPDATE_GEN_STATUS',
                               avalue   => 'ERROR');

     Update_Status(itemtype      => itemtype,
                   itemkey       => itemkey,
                   actid         => actid,
		   funcmode      => funcmode,
                   resultout     => resultout);

     IF resultout = 'COMPLETE:ERROR' then -- added VMODUR 10-Jun-2002

        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           );
     ELSE
   	     -- Delete all rows
	   AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
	     p_object_id          => l_activity_id,
             p_object_type_code   => l_activity_type,
             p_sequence_num       => null,
	     p_action_code        => null,
             p_object_version_num => l_version,
             p_approval_type      => l_approval_type);

	   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	     RAISE Fnd_Api.G_EXC_ERROR;
	   END IF;

     END IF; -- VM

     resultout := 'COMPLETE:';
  END IF;

  --
  -- CANCEL mode
  --
  IF (funcmode = 'CANCEL') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        return;
  END IF;
  --

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data
      );
    Handle_Err
      (p_itemtype          => itemtype   ,
       p_itemkey           => itemkey    ,
       p_msg_count         => l_msg_count, -- Number of error Messages
       p_msg_data          => l_msg_data ,
       p_attr_name         => 'AMS_ERROR_MSG',
       x_error_msg         => l_error_msg
      );
 wf_core.context('ams_gen_approval_pvt',
                 'Revert_Status',
                 itemtype, itemkey,to_char(actid),l_error_msg);
       resultout := 'COMPLETE:ERROR';
     --RAISE;
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Revert_status',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
END Revert_Status;

/*****************************************************************
-- Start of Comments
--
-- NAME
--   AbortProcess
-- PURPOSE
--   This Procedure will abort the process of Approvals
-- Used By Activities
--
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/

PROCEDURE AbortProcess
             (p_itemkey                       IN   VARCHAR2
             ,p_workflowprocess               IN   VARCHAR2      DEFAULT NULL
             ,p_itemtype                      IN   VARCHAR2      DEFAULT NULL
             )
IS
    itemkey   VARCHAR2(30) := p_itemkey ;
    itemtype  VARCHAR2(30) := nvl(p_itemtype,'AMS_APPROVAL') ;
BEGIN
   AMS_Utility_PVT.debug_message('Process Abort Process');
   WF_ENGINE.AbortProcess (itemtype   =>   itemtype,
                           itemkey    =>  itemkey ,
                           process    =>  p_workflowprocess);
EXCEPTION
   WHEN OTHERS THEN
      wf_core.context('ams_gen_approval_pvt',
                      'AbortProcess',
                      itemtype,
                      itemkey
                      ,p_workflowprocess);
         RAISE;
END AbortProcess;


--------------------------------------------------------------------------------
--
-- Procedure
--    Get_Api_Name
--
---------------------------------------------------------------------------------
PROCEDURE Get_Api_Name( p_rule_used_by        in  varchar2,
                        p_rule_used_by_type   in  varchar2,
                        p_rule_type           in  VARCHAR2,
                        p_appr_type           in  VARCHAR2,
                        x_pkg_name            OUT NOCOPY varchar2,
                        x_proc_name           OUT NOCOPY varchar2,
		        x_return_stat         OUT NOCOPY varchar2)
IS
	CURSOR c_API_Name(rule_used_by_in      IN VARCHAR2,
                          rule_used_by_type_in IN VARCHAR2,
                          rule_type_in         IN VARCHAR2,
                          appr_type_in         IN VARCHAR2) is
     SELECT package_name, procedure_name
       FROM ams_object_rules_b
      WHERE rule_used_by = rule_used_by_in
        AND rule_used_by_type = rule_used_by_type_in
        AND rule_type = rule_type_in
	AND nvl(APPROVAL_TYPE, 'NIL') = nvl(appr_type_in, 'NIL');

BEGIN
   x_return_stat := 'S';
	open c_API_Name(p_rule_used_by, p_rule_used_by_type,p_rule_type,p_appr_type);
	fetch c_API_Name into x_pkg_name, x_proc_name;
	IF c_API_Name%NOTFOUND THEN
	   x_return_stat := 'E';
	END IF;
	close c_API_Name;
EXCEPTION
        -- This exception will never be raised  VMODUR 10-Jun-2002
	--WHEN NO_DATA_FOUND THEN
	--  x_return_stat := 'E';
	 WHEN OTHERS THEN
	  x_return_stat := 'U';
	RAISE;
END Get_Api_Name;


--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type	    in OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat				varchar2(1);
l_activity_type    varchar2(80);
l_approval_type	varchar2(80);
l_msg_data              VARCHAR2(4000);
l_msg_count          number;
l_error_msg             VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_APPROVAL',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);
	if (l_return_stat = 'S') then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;
	end if;
	/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Reject_activity_status',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
 */
END Ntf_Approval;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval_reminder(itemtype     in  varchar2,
--                itemkey         in  varchar2,
--                p_object_type   in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approval_reminder(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type	    in OUT NOCOPY varchar2    )
IS
l_pkg_name      varchar2(80);
l_proc_name     varchar2(80);
l_return_stat   varchar2(1);
l_activity_type varchar2(80);
l_approval_type	varchar2(80);
l_msg_data      VARCHAR2(4000);
l_msg_count     number;
l_error_msg     VARCHAR2(4000);
dml_str         varchar2(2000);
l_itemType      varchar2(80);
l_itemKey       varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_APPROVAL_REMINDER',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
	if (l_return_stat = 'S') then
		dml_str := 'BEGIN ' ||  l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
	end if;
	/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Ntf_Approval_reminder',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Approval_reminder;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Forward_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                p_object_type   in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Forward_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type       in OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat				varchar2(1);
l_activity_type    varchar2(80);
l_approval_type	varchar2(80);
l_msg_data              VARCHAR2(4000);
l_msg_count          number;
l_error_msg             VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_FORWARD_FYI',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
	if (l_return_stat = 'S') then
		dml_str := 'BEGIN '|| l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
	end if;

	/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Ntf_Forward_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Forward_FYI;

--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approved_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Approved_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type			in OUT NOCOPY varchar2    )
IS
l_pkg_name    varchar2(80);
l_proc_name   varchar2(80);
l_return_stat varchar2(1);
l_activity_type    varchar2(80);
l_approval_type	   varchar2(80);
l_msg_data         VARCHAR2(4000);
l_msg_count        number;
l_error_msg        VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_APPROVED_FYI',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
	if (l_return_stat = 'S') then
		dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
	end if;

	/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Ntf_Approved_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
	*/
END Ntf_Approved_FYI;

-------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Rejected_FYI(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ntf_Rejected_FYI(document_id  in  varchar2,
                display_type        in  varchar2,
                document            in OUT NOCOPY  varchar2,
                document_type	    in OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat varchar2(1);
l_activity_type    varchar2(80);
l_approval_type	varchar2(80);
l_msg_data VARCHAR2(4000);
l_msg_count number;
l_error_msg VARCHAR2(4000);
dml_str  varchar2(2000);
l_itemType varchar2(80);
l_itemKey varchar2(80);
BEGIN
   l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_REJECTED_FYI',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
	if (l_return_stat = 'S') then
		dml_str := 'BEGIN '|| l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
		EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
	end if;

/*
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'Ntf_Rejected_FYI',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
*/

END Ntf_Rejected_FYI;
-------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Requestor_Of_Error (itemtype    in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
--  If uptaking functionality has an API registered for handling error, that API is
--  used to generate the error message content. If not, this API generates a less
--  meaningful message which will notify the requestor of an error
---------------------------------------------------------------------------------
PROCEDURE Ntf_Requestor_Of_Error(document_id   in     varchar2,
                                 display_type  in     varchar2,
                                 document      in OUT NOCOPY varchar2,
                                 document_type in OUT NOCOPY varchar2 )
IS
l_pkg_name         varchar2(80);
l_proc_name        varchar2(80);
l_return_stat      varchar2(1);
l_activity_type    varchar2(80);
l_approval_type	   varchar2(80);
l_msg_data         VARCHAR2(10000);
l_msg_count        number;
l_error_msg        VARCHAR2(4000);
dml_str            varchar2(2000);
l_appr_meaning     varchar2(240);
l_appr_obj_name    varchar2(240);
l_itemType         varchar2(80);
l_itemKey          varchar2(80);
l_body_string      varchar2(2500);
l_errmsg           varchar2(4000);
BEGIN
        l_itemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
	l_itemKey  := substr(document_id, instr(document_id,':')+1);

	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

        l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

        l_appr_meaning       := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_OBJECT_MEANING');

        l_appr_obj_name      := wf_engine.GetItemAttrText(
                                 itemtype => l_itemtype,
                                 itemkey  => l_itemkey,
                                 aname    => 'AMS_APPROVAL_OBJECT_NAME');


	Get_Api_Name('WORKFLOW', l_activity_type, 'NTF_ERROR',l_approval_type, l_pkg_name, l_proc_name, l_return_stat);
	if (l_return_stat = 'S') then

	    dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
	    EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document, IN OUT document_type;

        elsif (l_return_stat = 'E') THEN -- no data found, generate a generic message

            l_errmsg := wf_engine.GetItemAttrText(
                         itemtype => l_itemtype,
                         itemkey  => l_itemkey,
                         aname    => 'AMS_ERROR_MSG');

            fnd_message.set_name ('AMS', 'AMS_GEN_NTF_ERROR_BODY');
            fnd_message.set_token ('OBJ_MEANING', l_appr_meaning, FALSE);
            fnd_message.set_token ('OBJ_NAME', l_appr_obj_name, FALSE);
	    fnd_message.set_token ('ERR_MSG', l_errmsg, FALSE);
	    l_body_string  := SUBSTR(fnd_message.get,1,10000);

	    document_type := 'text/plain';
	    document := l_body_string;
	end if;

END Ntf_Requestor_Of_Error;
-------------------------------------------------------------------------------
--
-- Procedure
--   Appr_Update(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat				varchar2(1);
l_msg_data              VARCHAR2(4000);
l_msg_count          number;
l_error_msg             VARCHAR2(4000);
dml_str  varchar2(2000);
l_activity_type      varchar2(80);
l_approval_type	varchar2(80);


BEGIN
	l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

	Get_Api_Name('WORKFLOW', l_activity_type, 'UPDATE',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
	if (l_return_stat = 'S') then
			dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:actid,:funcmode,:resultout); END;';
			EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey, IN actid,IN funcmode,OUT resultout;
	end if;
END Update_Status;

-------------------------------------------------------------------------------
--
-- Procedure
--   Approved_Update_Status(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Approved_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
BEGIN
	WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>   'APPROVED'  );
	Update_Status(itemtype => itemtype,
                        itemkey => itemkey,
                        actid => actid,
                        funcmode => funcmode,
                        resultout => resultout);

END Approved_Update_Status;

-------------------------------------------------------------------------------
--
-- Procedure
--   Reject_Update(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Reject_Update_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
l_appr_hist_rec         AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
l_activity_id           NUMBER;
l_activity_type         VARCHAR2(30);
l_approver_seq          NUMBER;
l_version               NUMBER;
l_approver_id           NUMBER;
l_approval_detail_id    NUMBER;
l_approval_type         VARCHAR2(30);
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_note                  VARCHAR2(4000);
--
l_responder               VARCHAR2(100);
l_appr_display_name       VARCHAR2(360);
l_forward_nid             NUMBER;
BEGIN
        WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>  'REJECTED');


        -- Added by VM for 11.5.9
        l_activity_id  := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

        -- get the activity type
        l_activity_type := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

        l_approver_seq := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_APPROVER_SEQ' );

        l_version := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_OBJECT_VERSION_NUMBER' );

        l_approver_id := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_APPROVER_ID' );

        l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_DETAIL_ID' );

        l_approval_type := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );

        l_note          := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'APPROVAL_NOTE' );
     -- End 11.5.9
     -- Start of addition for forward/reassign notification

     l_forward_nid        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_FORWARD_NID' );
-- Commented for 3150550
/*
     IF l_forward_nid IS NOT NULL THEN

       l_responder := wf_notification.responder(l_forward_nid);

       Get_New_Res_Details(p_responder => l_responder,
                                  x_resource_id => l_approver_id,
                                  x_resource_disp_name => l_appr_display_name,
                                  x_return_status => l_return_status);

       IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
         RAISE Fnd_Api.G_EXC_ERROR;
       END IF;

         -- Set the WF Attributes
         wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER',
                              avalue   => l_responder);


        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_ID',
                              avalue   => l_approver_id);


        wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_DISPLAY_NAME',
                              avalue   => l_appr_display_name);

        -- Reset the forward_nid wf attribute to null
        -- This is a must

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_FORWARD_NID',
                              avalue   => null);

     END IF;
     -- End of addition for forward/re-assign notification
*/
         -- update the record from 'PENDING' to 'REJECTED'
          l_appr_hist_rec.object_id := l_activity_id;
          l_appr_hist_rec.object_type_code := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code := 'REJECTED';
          l_appr_hist_rec.approval_type := l_approval_type;
          l_appr_hist_rec.sequence_num  := l_approver_seq;
          l_appr_hist_rec.note := l_note;
          l_appr_hist_rec.action_date   := sysdate;

            -- should i reset approver_id? yes
          l_appr_hist_rec.approver_id  := l_approver_id;

          AMS_Appr_Hist_PVT.Update_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
             p_appr_hist_rec      => l_appr_hist_rec
             );

   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

        -- Delete any 'OPEN' rows
          AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
             p_object_id          => l_activity_id,
             p_object_type_code   => l_activity_type,
             p_sequence_num       => null, -- all open rows
             p_action_code        => 'OPEN',
             p_object_version_num => l_version,
             p_approval_type      => l_approval_type);

   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

           -- This needs to be last as it would change version number
          Update_Status(itemtype => itemtype,
                        itemkey => itemkey,
                        actid => actid,
                        funcmode => funcmode,
                        resultout => resultout);

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   FND_MSG_PUB.Count_And_Get (
           p_encoded => FND_API.G_FALSE,
           p_count => l_msg_count,
           p_data  => l_msg_data
      );
    Handle_Err
      (p_itemtype          => itemtype   ,
       p_itemkey           => itemkey    ,
       p_msg_count         => l_msg_count, -- Number of error Messages
       p_msg_data          => l_msg_data ,
       p_attr_name         => 'AMS_ERROR_MSG',
       x_error_msg         => l_error_msg
      );
 wf_core.context('ams_gen_approval_pvt',
                 'set_approval_rules',
                 itemtype, itemkey,to_char(actid),l_error_msg);
       resultout := 'COMPLETE:ERROR';
     --RAISE;
 WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    wf_core.context('ams_gen_approval_pvt',
                    'set_approver_details',
                    itemtype, itemkey,to_char(actid),l_error_msg);
    RAISE;
  --
END Reject_Update_Status;

-----------------------------------------------------------------------------
--
--PROCEDURE Check_Process_Type
--
-------------------------------------------------------------------------------
PROCEDURE Check_Process_Type( itemtype   	in  varchar2,
                           	itemkey    	in  varchar2,
                           	actid   	in  number,
                           	funcmode   	in  varchar2,
                           	resultout   OUT NOCOPY varchar2    )
IS
l_process_type varchar2(80);
l_activity_type varchar2(80);
BEGIN

     l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

    If (l_activity_type = 'RFRQ'
          --OR l_activity_type = 'ROOT_BUDGET'
            OR l_activity_type = 'FREQ') THEN
              resultout := 'BUDGET';
    else
              resultout := 'OTHER';
    end if;

      /* commented because of seed data change aug 17 2001
      l_process_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );
      if (l_process_type = 'BUDGET_REQUEST'
          OR l_process_type = 'ROOT_BUDGET'
          OR l_process_type = 'CHILD_BUDGET') THEN
            resultout := 'BUDGET';
      else
            resultout := 'OTHER';
      end if;
      */
END Check_Process_Type;
PROCEDURE DynTst(itemtype IN varchar2
                 ,itemkey  IN varchar2
                 ,resultout       OUT NOCOPY varchar2
   )
  IS
  x_result  VARCHAR2(80) := 'OK';
 BEGIN
     --dbms_output.put_line( 'Inside test loop' || itemtype || itemkey);
     null;
 END;

 PROCEDURE DynTst1(itemtype IN varchar2
                 ,itemkey  IN varchar2
     --            ,resultout       out varchar2
   )
  IS
  x_result  VARCHAR2(80) := 'OK';
 BEGIN
     --dbms_output.put_line( 'Inside test loop' || itemtype || itemkey);
     null;
 END;
/*****************************************************************
-- Start of Comments
-- NAME
--   Approval_Required
-- PURPOSE
--   This Procedure will determine if the requestor of an activity
--   is the same as the approver for that activity. This is used to
--   bypass approvals if requestor is the same as the approver.
-- Used By Activities
-- NOTES
-- HISTORY
-- End of Comments
****************************************************************/
PROCEDURE Approval_Required(itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2)
IS
--
l_requestor NUMBER;
l_approver  NUMBER;
l_note      VARCHAR2(3000);


BEGIN
  Fnd_Msg_Pub.initialize();
  --
  -- RUN mode
  --
    IF (funcmode = 'RUN') THEN

      -- Get the Requestor
      l_requestor := Wf_Engine.GetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_REQUESTER_ID');

      -- Get the Approver
      l_approver := Wf_Engine.GetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_APPROVER_ID');

      IF l_requestor = l_approver THEN

       l_note := wf_engine.getitemattrtext(
               itemtype => itemtype
              ,itemkey  => itemkey
              ,aname    => 'AMS_PREV_APPROVER_NOTE'
            );
      wf_engine.SetItemAttrText(  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVAL_NOTE',
                                  avalue   => l_note);
         resultout := 'COMPLETE:N';
      ELSE
         resultout := 'COMPLETE:Y';
      END IF;

      RETURN;

    END IF;

    IF (funcmode = 'CANCEL') THEN
            resultout := 'COMPLETE:';
            RETURN;
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
          resultout := 'COMPLETE:';
          RETURN;
    END IF;
END Approval_Required;
-----------------------------------------------------------------------
-- Used to Determine if a Fund is a Child Budget.
-----------------------------------------------------------------------
FUNCTION Is_Child_Budget
   (p_fund_id    IN NUMBER)
 RETURN VARCHAR2 IS
    CURSOR c_fund IS
    SELECT parent_fund_id
    FROM ozf_funds_all_b
    WHERE fund_id = p_fund_id;

    l_parent_fund_id NUMBER;
BEGIN
    OPEN c_fund;
    FETCH c_fund INTO l_parent_fund_id;
    IF c_fund%NOTFOUND THEN
       CLOSE c_fund;
       return 'N';
    END IF;
    CLOSE c_fund;
    IF l_parent_fund_id IS NOT NULL THEN
       RETURN 'Y';
    ELSE
       RETURN 'N';
    END IF;
END Is_Child_Budget;

----------------------------------------------------------------------
-- for 11.5.9
-- This is called by the Get_Approval_Rule procedure
----------------------------------------------------------------------
PROCEDURE Get_Generic_Activity_Details(p_activity_id        IN  NUMBER,
                                       p_activity_type      IN  VARCHAR2,
                                       x_object_details     OUT NOCOPY ObjRecTyp,
                                       x_return_status      OUT NOCOPY VARCHAR2 )
IS
  TYPE obj_csr_type IS REF CURSOR ;
  l_obj_details obj_csr_type;
  l_meaning VARCHAR2(80);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  IF p_activity_type = 'PRIC' THEN

    OPEN l_obj_details  FOR
     SELECT  name -- name
    ,        null -- business unit id
    ,        null -- country code
    ,        custom_setup_id -- set
    ,        null -- amount
    ,        null -- org id
    ,        'PRIC' -- object_type
    ,        null -- priority
    ,        start_date_active --  start date
    ,        end_date_active  -- end date
    ,        null -- purpose
    ,        description -- description
    ,        owner_id -- owner
    ,        currency_code -- currency
    ,        null -- priority desc
    FROM ams_price_lists_v
    WHERE list_header_id = p_activity_id;

  ELSIF p_activity_type = 'CLAM' THEN
    OPEN l_obj_details  FOR
    SELECT   c.claim_number -- name
    ,        null -- bus unit id
    ,        null -- country code
    ,        c.custom_setup_id -- set
--    ,        amount_settled -- tha
    ,        nvl(sum(l.claim_currency_amount),0)
    ,        c.org_id -- org id
    ,        to_char(c.claim_type_id) --obj type
    ,        to_char(c.reason_code_id) -- priority
    ,        c.claim_date -- start date
    ,        c.due_date -- end date
    ,        '' -- purpose
    ,        '' -- desc
    ,        c.owner_id -- owner
    ,        c.currency_code -- currency
    ,        '' -- priority desc
    FROM ozf_claims_all c, ozf_claim_lines_all l
    WHERE c.claim_id  = l.claim_id(+) -- Bug 2848568
    AND c.claim_id = p_activity_id
    GROUP BY c.claim_number, c.custom_setup_id, c.org_id, c.claim_type_id,
             c.reason_code_id, c.claim_date, c.due_date, c.owner_id, c.currency_code;

  ELSIF p_activity_type = 'RFRQ' THEN --or FUND
  -- Also used for Child Budgets
    OPEN l_obj_details  FOR
    SELECT   short_name -- name
    ,        business_unit_id --bus unit id Bug 3368022
    ,        null -- country code
    ,        custom_setup_id -- setup
    ,        original_budget -- amount settled
    ,        org_id -- org id
    ,        to_char(category_id) -- object type
    ,        null -- priority
    ,        start_date_active -- start date
    ,        end_date_active -- end date
    ,        '' -- purpose
    ,        '' -- desc
    ,        owner -- owner
    ,        currency_code_tc --curr code
    ,        '' --prioriy desc
           FROM ozf_funds_all_vl
          WHERE fund_id = p_activity_id;
  ELSIF p_activity_type = 'FREQ' THEN
    OPEN l_obj_details FOR
    SELECT   fund.short_name -- name
    ,        null --bud unit id
    ,        null --country code
    ,        null --fund.custom_setup_id
    ,        act1.request_amount
    ,        fund.org_id
    ,        to_char(fund.category_id) -- object type
    ,        null -- priority
    ,        fund.start_date_active
    ,        fund.end_date_active
    ,        '' -- purpose
    ,        '' -- desc
    ,        act1.requester_id -- owner
    ,        act1.request_currency -- curr code
    ,        '' --priority desc
         FROM     ams_act_budgets act1
                 ,ozf_funds_all_vl fund
         WHERE  activity_budget_id = p_activity_id
         AND act1.act_budget_used_by_id = fund.fund_id;
   -- Add Offer Adjustments
  ELSE
  -- add exception
    Fnd_Message.Set_Name('AMS','AMS_BAD_APPROVAL_OBJECT_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
  END IF ;

-- check here
  FETCH l_obj_details INTO x_object_details;
  IF l_obj_details%NOTFOUND THEN
    CLOSE l_obj_details;
    Fnd_Message.Set_Name('AMS','AMS_APPR_BAD_DETAILS');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE l_obj_details;
EXCEPTION
  WHEN OTHERS THEN
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );

END Get_Generic_Activity_Details;
--------------------------------------------------------------
-- 11.5.9
-- Called from ams_approval_pvt for determining approval rule
-- Added to display approval rule name in ApprovalDtailMain.jsp
--------------------------------------------------------------
PROCEDURE Get_Approval_Rule ( p_activity_id        IN  NUMBER,
                              p_activity_type      IN  VARCHAR2,
                              p_approval_type      IN  VARCHAR2,
                              p_act_budget_id      IN  NUMBER,
                              x_approval_detail_id OUT NOCOPY NUMBER,
                              x_return_status      OUT NOCOPY  VARCHAR2)
IS
l_obj_details       ObjRecTyp;
l_approver_seq      NUMBER;

BEGIN
IF p_activity_type = 'FREQ' THEN
-- pass activity_budget_id
Get_Generic_Activity_Details(p_activity_id =>  p_act_budget_id ,
                             p_activity_type => p_activity_type,
                             x_object_details => l_obj_details,
                             x_return_status => x_return_status);
ELSE

Get_Generic_Activity_Details(p_activity_id =>  p_activity_id ,
                             p_activity_type => p_activity_type,
                             x_object_details => l_obj_details,
                             x_return_status => x_return_status);

END IF;


IF p_activity_type = 'RFRQ'
AND Is_Child_Budget(p_activity_id) = 'Y' THEN

Get_Approval_Details ( p_activity_id =>  p_activity_id,
                       p_activity_type => 'FREQ',
                       p_approval_type => p_approval_type,
          --             p_act_budget_id  => p_act_budget_id,
                       p_object_details  => l_obj_details,
                       x_approval_detail_id  => x_approval_detail_id,
                       x_approver_seq     => l_approver_seq,
                       x_return_status    => x_return_status);

ELSIF p_activity_type = 'FREQ' THEN
Get_Approval_Details ( p_activity_id =>  p_act_budget_id,
                       p_activity_type => 'FREQ',
                       p_approval_type => p_approval_type,
          --             p_act_budget_id  => p_act_budget_id,
                       p_object_details  => l_obj_details,
                       x_approval_detail_id  => x_approval_detail_id,
                       x_approver_seq     => l_approver_seq,
                       x_return_status    => x_return_status);
ELSE
Get_Approval_Details ( p_activity_id =>  p_activity_id,
                       p_activity_type => p_activity_type,
                       p_approval_type => p_approval_type,
          --             p_act_budget_id  => p_act_budget_id,
                       p_object_details  => l_obj_details,
                       x_approval_detail_id  => x_approval_detail_id,
                       x_approver_seq     => l_approver_seq,
                       x_return_status    => x_return_status);
END IF;
END Get_Approval_Rule;
---------------------------------------------------------------------
-- Called in Approval Notifications
-- Used primarily to capture the new Approver in case of Forward/Re-assign
---------------------------------------------------------------------

PROCEDURE PostNotif_Update (itemtype  IN  VARCHAR2,
                            itemkey   IN  VARCHAR2,
                            actid     IN  NUMBER,
                            funcmode  IN  VARCHAR2,
                            resultout OUT NOCOPY VARCHAR2)
IS
l_nid NUMBER;
l_result VARCHAR2(30);
l_assignee VARCHAR2(320);
l_new_approver_id NUMBER;
l_appr_display_name VARCHAR2(360);
l_activity_type VARCHAR2(30);
l_version NUMBER;
l_activity_id NUMBER;
l_act_budget_id NUMBER;
l_approval_type VARCHAR2(30);
l_current_seq NUMBER;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_error_msg       VARCHAR2(4000);

l_appr_hist_rec AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;

BEGIN
l_nid := wf_engine.context_nid;

IF (funcmode = 'RESPOND') THEN

  l_result := upper(wf_notification.GETATTRTEXT(l_nid, 'RESULT'));

  IF l_result = 'APPROVE' then
     resultout := 'COMPLETE:APPROVE';
  ELSE
     resultout := 'COMPLETE:REJECT';
  END IF;

ELSIF (funcmode = 'TRANSFER' OR funcmode = 'FORWARD') THEN

  -- Set the forwarded/transferred notification id so that
  -- we can use it later to see actual approver

   l_assignee := WF_ENGINE.context_text;

-- ams_forward_nid is not really needed.
  wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_FORWARD_NID',
                              avalue   => l_nid);

  Get_New_Res_Details(p_responder => l_assignee,
                      x_resource_id => l_new_approver_id,
                      x_resource_disp_name => l_appr_display_name,
                      x_return_status => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
   RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

         -- Set the WF Attributes
         wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER',
                              avalue   => l_assignee);

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_ID',
                              avalue   => l_new_approver_id);

        wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_DISPLAY_NAME',
                              avalue   => l_appr_display_name);

  -- Update the approver details here

        l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

        l_version := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_OBJECT_VERSION_NUMBER'
                                  );

        l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

        l_current_seq        := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_SEQ' );

        l_approval_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_APPROVAL_TYPE' );

          l_appr_hist_rec.object_id          := l_activity_id;
          l_appr_hist_rec.object_type_code   := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.approval_type      := l_approval_type;
          l_appr_hist_rec.approver_type      := 'USER'; -- Always
          l_appr_hist_rec.sequence_num       := l_current_seq;
          l_appr_hist_rec.approver_id        := l_new_approver_id;

          AMS_Appr_Hist_PVT.Update_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
             p_appr_hist_rec      => l_appr_hist_rec
             );

           IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;

  resultout := 'COMPLETE';

END IF;
EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
          Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count,
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           );
      wf_core.token('MESSAGE', l_error_msg);
      wf_core.raise('WF_PLSQL_ERROR');
 WHEN OTHERS THEN
      wf_core.context('ams_gen_approval_pvt','PostNotif_Update',
                      itemtype,itemkey,actid,funcmode,'Error in Post Notif Function');
      raise;
END PostNotif_Update;

END ams_gen_approval_pvt;

/
