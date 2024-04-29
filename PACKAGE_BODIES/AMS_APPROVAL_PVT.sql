--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_PVT" AS
/* $Header: amsvappb.pls 120.7 2007/08/09 10:24:50 rsatyava ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ams_approval_pvt';
G_ITEMTYPE     CONSTANT VARCHAR2(30) := 'AMSAPRV';

/***************************  PRIVATE ROUTINES  *******************************/
/*============================================================================*/
-- Start of Comments
--
-- NAME
--   HANDLE_ERR
--
-- PURPOSE
--   This Procedure will Get all the Errors from the Message stack and
--
-- NOTES
--
-- End of Comments
/*============================================================================*/

PROCEDURE Handle_Err
  (p_itemtype                IN VARCHAR2    ,
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

BEGIN
  -- Retriveing Error Message from FND_MSG_PUB
  -- Called by most of the procedures if it encounter error
  WHILE l_cnt < p_msg_count
  LOOP
    Fnd_Msg_Pub.Get
      (p_msg_index       => l_cnt + 1,
      p_encoded         => Fnd_Api.G_FALSE,
      p_data            => l_msg_data,
      p_msg_index_out   => l_msg_index );
    l_final_data := l_final_data ||l_msg_index||': '
      ||l_msg_data||Fnd_Global.local_chr(10) ;
    l_cnt := l_cnt + 1 ;
  END LOOP ;
  x_error_msg   := l_final_data;
  Wf_Engine.SetItemAttrText
    (itemtype  => p_itemtype,
    itemkey    => p_itemkey ,
    aname      => p_attr_name,
    avalue     => l_final_data   );
END Handle_Err;
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
/*============================================================================*/
-- Procedure to Update status of the activity
-- Called by different procedures such as CAMP, EVEH,EVEO
/*============================================================================*/
PROCEDURE Update_Status(p_activity_type          IN  VARCHAR2,
            p_activity_id            IN  NUMBER,
            p_next_stat_id           IN  NUMBER,
            x_return_status          OUT NOCOPY VARCHAR2)

IS
  l_msg_count  NUMBER;
  l_msg_data  VARCHAR2(4000);
  l_return_stat VARCHAR2(1);
  p_next_stat_code     VARCHAR2(240);

  CURSOR c_sys_stat(l_user_stat_id NUMBER) IS
  SELECT system_status_code
  FROM ams_user_statuses_vl
  WHERE user_status_id = l_user_stat_id ;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN c_sys_stat(p_next_stat_id) ;
  FETCH c_sys_stat INTO p_next_stat_code ;
  CLOSE c_sys_stat ;
  /*AMS_Utility_PVT.create_log(x_return_status => l_return_stat,
          p_arc_log_used_by  => 'AMS Markeing Approval',
          p_log_used_by_id  => 0,
          p_msg_data => 'Update_Status: p_activity_type' || p_activity_type ||
                        ' p_activity_id' || p_activity_id || 'p_next_stat_id' || p_next_stat_id);
  */
  IF p_activity_type = 'CAMP' THEN
  /* commented for 11.5.6 using API provided by sonali
    UPDATE AMS_CAMPAIGNS_ALL_B
    SET user_status_id = p_next_stat_id,
    status_code = p_next_stat_code,
    status_date = sysdate,
    object_version_number = object_version_number + 1
    WHERE campaign_id = p_activity_id  ;
    -- Following code is commented by ptendulk on 09-Oct-2001
    -- as the wrapper api will take care of it.
    -- DeActivate all other campaigns by same name if the campaign goes active
    IF p_next_stat_code = 'ACTIVE' THEN
      AMS_CampaignRules_PVT.activate_campaign(p_campaign_id  => p_activity_id);
    END IF ;
    */
    Ams_Campaignrules_Pvt.update_status(p_campaign_id => p_activity_id,
                      p_new_status_id => p_next_stat_id,
                      p_new_status_code => p_next_stat_code);
    /* added my murali code given by ravi start*/
  ELSIF p_activity_type='CSCH' THEN
    /* commented for 11.5.6 oct 08 using API provided by sonali
    UPDATE AMS_CAMPAIGN_SCHEDULES_B
    SET user_status_id = p_next_stat_id,
    status_code = p_next_stat_code,
    status_date = sysdate,
    object_version_number = object_version_number + 1
    WHERE campaign_id = p_activity_id  ;
    */
    Ams_Schedulerules_Pvt.update_status(p_schedule_id => p_activity_id,
                      p_new_status_id => p_next_stat_id,
                      p_new_status_code => p_next_stat_code);
  ELSIF p_activity_type='OFFR' THEN
  -- Migrate AMS to OZF for Offers
    Ozf_Offer_Pvt.activate_offer(
      x_return_status  => x_return_status,
      x_msg_count => l_msg_count,
      x_msg_data  => l_msg_data,
      p_qp_list_header_id  => p_activity_id,
      p_new_status_id   => p_next_stat_id
    );
    /*sathis api commented on aug16-2001 for HP recut 10a
     commented to call satish api aug07-2001 start */
    /*commented for 11.5.6 oct 08
    UPDATE AMS_OFFERS
    SET user_status_id = p_next_stat_id,
    status_code = p_next_stat_code,
    status_date = sysdate,
    object_version_number = object_version_number + 1
    WHERE qp_list_header_id = p_activity_id  ;
    */
    -- commented to call satish api aug07-2001 end
    /* added my murali code given by ravi end*/
  ELSIF p_activity_type = 'DELV' THEN
  -- commented direct status update call for deliverable
  -- in favor of an API call VMODUR Aug-01-2002
     AMS_DeliverableRules_PVT.update_status(
          p_deliverable_id     => p_activity_id
         ,p_new_status_id      => p_next_stat_id
         ,p_new_status_code    => p_next_stat_code
      );
  /*
    UPDATE AMS_DELIVERABLES_ALL_B
    SET user_status_id = p_next_stat_id,
    status_code = p_next_stat_code,
    status_date = SYSDATE,
    object_version_number = object_version_number + 1
    WHERE deliverable_id = p_activity_id ;
  */
  ELSIF p_activity_type  = 'EVEH' THEN
    /*UPDATE AMS_EVENT_HEADERS_ALL_B */
      Ams_Evhrules_Pvt.Update_Event_Header_Status(p_event_header_id => p_activity_id,
                      p_new_status_id => p_next_stat_id,
                      p_new_status_code => p_next_stat_code);

   ELSIF p_activity_type = 'EVEO' OR p_activity_type ='EONE' THEN
      /*UPDATE AMS_EVENT_OFFERS_ALL_B*/
     Ams_Evhrules_Pvt.Update_Event_Schedule_Status(p_event_offer_id => p_activity_id,
                      p_new_status_id => p_next_stat_id,
                      p_new_status_code => p_next_stat_code);
  END IF;
  /*AMS_Utility_PVT.create_log(x_return_status => l_return_stat,
    p_arc_log_used_by  => 'AMS Markeing Approval',
    p_log_used_by_id  => 0,
    p_msg_data => 'Update_Status: Exiting sucessfully'); */


EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.context ('ams_approval_pvt', 'Update_Status',p_activity_type
                       ,p_activity_id ,'Unexpected error in Update_Status');
        RAISE;

END Update_Status;

/*============================================================================*/
-- Attach Notes to Activity
-- Update Object Attributes table  if notes are added
-- Note Added will be of Type Approval
/*============================================================================*/
PROCEDURE Update_Note(p_activity_type IN   VARCHAR2,
          p_activity_id   IN   NUMBER,
          p_note          IN   VARCHAR2,
          p_user          IN   NUMBER,
          x_msg_count     OUT NOCOPY  NUMBER,
          x_msg_data      OUT NOCOPY  VARCHAR2,
          x_return_status OUT NOCOPY  VARCHAR2)
IS
  l_id  NUMBER ;
  l_user  NUMBER;
  l_resource_name          VARCHAR2(360);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

  CURSOR c_resource IS
  SELECT user_id user_id, resource_name
  FROM ams_jtf_rs_emp_v
  WHERE resource_id = p_user ;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN c_resource ;
  FETCH c_resource INTO l_user, l_resource_name ;
  IF c_resource%NOTFOUND THEN
    CLOSE c_resource ;
    Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
    Fnd_Message.Set_Token('ROW', SQLERRM );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE c_resource ;

 -- Handle error when no user is associated with the approver's resource id.
  IF l_user IS NULL THEN
    Fnd_Message.Set_Name('AMS','AMS_RESOURCE_HAS_NO_USER');
    Fnd_Message.Set_Token('RESOURCE', l_resource_name );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  -- Note API to Update Approval Notes
  /*AMS_ObjectAttribute_PVT.modify_object_attribute(
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
    FND_MESSAGE.Set_Token('ROW', SQLERRM );
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
  END IF;
  */

  Jtf_Notes_Pub.Create_note
  ( p_api_version      =>  1.0 ,
  x_return_status      =>  x_return_status,
  x_msg_count          =>  x_msg_count,
  x_msg_data           =>  x_msg_data,
  p_source_object_id   =>  p_activity_id,
  p_source_object_code =>  'AMS_'||p_activity_type,
  p_notes              =>  p_note,
  p_note_status        =>  NULL ,
  p_entered_by         =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
  p_entered_date       =>  SYSDATE,
  p_last_updated_by    =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
  x_jtf_note_id        =>  l_id ,
  p_note_type          =>  'AMS_APPROVAL'    ,
  p_last_update_date   =>  SYSDATE  ,
  p_creation_date      =>  SYSDATE  ) ;
  IF x_return_status  <> Fnd_Api.G_RET_STS_SUCCESS THEN
    Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
    Fnd_Message.Set_Token('ROW', SQLERRM );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  /*AMS_Utility_PVT.create_log(x_return_status => l_return_stat,
    p_arc_log_used_by  => 'AMS Markeing Approval',
    p_log_used_by_id  => 0,
    p_msg_data => 'Update_Note: Exiting sucessfully'); */

EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;
    Wf_Core.context ('ams_approval_pvt', 'Update_Note',p_activity_type
            ,p_activity_id , 'Unexpected Error in Update_Note' );
    RAISE;

END Update_Note;

/*============================================================================*/
-- Attach Notes to Activity
-- Update Object Attributes table  if notes are added
-- Note Added will be of Type Approval
/*============================================================================*/
PROCEDURE Update_Justification_Note(p_activity_type IN   VARCHAR2,
          p_activity_id   IN   NUMBER,
          p_note          IN   VARCHAR2,
          p_user          IN   NUMBER,
          x_msg_count     OUT NOCOPY  NUMBER,
          x_msg_data      OUT NOCOPY  VARCHAR2,
          x_return_status OUT NOCOPY  VARCHAR2)
IS
  l_id  NUMBER ;
  l_user  NUMBER;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

  CURSOR c_resource IS
  SELECT user_id user_id
  FROM ams_jtf_rs_emp_v
  WHERE resource_id = p_user ;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN c_resource ;
  FETCH c_resource INTO l_user ;
  IF c_resource%NOTFOUND THEN
    CLOSE c_resource ;
    Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
    Fnd_Message.Set_Token('ROW', SQLERRM );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE c_resource ;
  -- Note API to Update Approval Notes
  Ams_Objectattribute_Pvt.modify_object_attribute(
    p_api_version        => 1.0,
    p_init_msg_list      => Fnd_Api.g_false,
    p_commit             => Fnd_Api.g_false,
    p_validation_level   => Fnd_Api.g_valid_level_full,
    x_return_status      => x_return_status,
    x_msg_count          => x_msg_count,
    x_msg_data           => x_msg_data,
    p_object_type        => p_activity_type,
    p_object_id          => p_activity_id ,
    p_attr               => 'NOTE',
    p_attr_defined_flag  => 'Y'
    );
  IF x_return_status  <> Fnd_Api.G_RET_STS_SUCCESS THEN
    Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
    Fnd_Message.Set_Token('ROW', SQLERRM );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  Jtf_Notes_Pub.Create_note
  ( p_api_version      =>  1.0 ,
  x_return_status      =>  x_return_status,
  x_msg_count          =>  x_msg_count,
  x_msg_data           =>  x_msg_data,
  p_source_object_id   =>  p_activity_id,
  p_source_object_code =>  'AMS_'||p_activity_type,
  p_notes              =>  p_note,
  p_note_status        =>  NULL ,
  p_entered_by         =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
  p_entered_date       =>  SYSDATE,
  p_last_updated_by    =>   l_user , -- 1000050 ,  -- FND_GLOBAL.USER_ID,
  x_jtf_note_id        =>  l_id ,
  p_note_type          =>  'AMS_FREQ'    ,
  p_last_update_date   =>  SYSDATE  ,
  p_creation_date      =>  SYSDATE  ) ;
  IF x_return_status  <> Fnd_Api.G_RET_STS_SUCCESS THEN
    Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
    Fnd_Message.Set_Token('ROW', SQLERRM );
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  /*AMS_Utility_PVT.create_log(x_return_status => l_return_stat,
    p_arc_log_used_by  => 'AMS Markeing Approval',
    p_log_used_by_id  => 0,
    p_msg_data => 'Update_Note: Exiting sucessfully'); */

EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;
    Wf_Core.context ('ams_approval_pvt', 'Update_Note',p_activity_type
            ,p_activity_id , 'Unexpected Error in Update_Note' );
    RAISE;

END Update_Justification_Note;


/*============================================================================*/
-- Given the resource Name it returns the full name of the user
-- Ams_jtf_rs_emp_v is a view created for AMS based on
--     fnd_user and jtf_resource_extns
/*============================================================================*/
PROCEDURE Get_User_Name
  ( p_user_id            IN     NUMBER,
  x_full_name          OUT NOCOPY    VARCHAR2,
  x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

  CURSOR c_resource IS
  SELECT  full_name
  FROM ams_jtf_rs_emp_v
  WHERE resource_id = p_user_id ;
BEGIN
  /*AMS_Utility_PVT.create_log(x_return_status => l_return_stat,
    p_arc_log_used_by  => 'AMS Markeing Approval',
    p_log_used_by_id  => 0,
    p_msg_data => 'Get_User_Name: p_user_id' || p_user_id); */

  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN c_resource ;
  FETCH c_resource INTO x_full_name ;
  IF c_resource%NOTFOUND THEN
    CLOSE c_resource ;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_RESOURCE_ID');
    Fnd_Msg_Pub.ADD;
    RETURN;
  END IF;
  CLOSE c_resource ;
EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;
    Wf_Core.context ('Ams_Approval_Pvt', 'Get_User_Name',p_user_id,
            'Unexpected Error IN Get_User_Name');
    RAISE;

END Get_User_Name;
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
------------------------------------------------------------------------------
PROCEDURE Check_Reassigned (itemtype IN VARCHAR2,
                            itemkey  IN VARCHAR2,
                            x_approver_id OUT NOCOPY NUMBER,
                            x_return_status OUT NOCOPY VARCHAR2)
IS
l_forward_nid NUMBER;
l_responder   VARCHAR2(320);
l_approver_id NUMBER;
l_appr_display_name VARCHAR2(360);
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

     l_forward_nid        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_FORWARD_NID');

     IF l_forward_nid IS NOT NULL THEN

       l_responder := wf_notification.responder(l_forward_nid);

       Get_New_Res_Details(p_responder => l_responder,
                           x_resource_id => l_approver_id,
                           x_resource_disp_name => l_appr_display_name,
                           x_return_status => l_return_status);

       IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN

         -- Set the WF Attributes
         wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPR_USERNAME',
                              avalue   => l_responder);


        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_ID',
                              avalue   => l_approver_id);


        wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPR_DISPLAY_NAME',
                              avalue   => l_appr_display_name);


      END IF;
        -- Reset the forward_nid wf attribute to null
        -- This is a must

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_FORWARD_NID',
                              avalue   => null);

     x_approver_id   := l_approver_id;
     x_return_status := l_return_status;
     END IF;
END Check_Reassigned;
/*============================================================================*/
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

/*============================================================================*/

PROCEDURE Get_User_Role
  ( p_user_id            IN     NUMBER,
  x_role_name          OUT NOCOPY    VARCHAR2,
  x_role_display_name  OUT NOCOPY    VARCHAR2 ,
  x_return_status      OUT NOCOPY    VARCHAR2)
IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);


  CURSOR c_resource IS
  SELECT employee_id , user_id, category
  FROM ams_jtf_rs_emp_v
  WHERE resource_id = p_user_id ;

  l_person_id NUMBER;
  l_user_id NUMBER;
  l_category  VARCHAR2(30);
BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN c_resource ;
  FETCH c_resource INTO l_person_id , l_user_id, l_category;
  IF c_resource%NOTFOUND THEN
    CLOSE c_resource ;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_RESOURCE_ID');
    Fnd_Msg_Pub.ADD;
    RETURN;
  END IF;
  CLOSE c_resource ;
      -- Pass the Employee ID to get the Role
  IF l_category = 'PARTY' THEN
    Wf_Directory.getrolename
    ( p_orig_system     => 'FND_USR',
    p_orig_system_id    => l_user_id ,
    p_name              => x_role_name,
    p_display_name      => x_role_display_name );
    IF x_role_name IS NULL  THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
      Fnd_Msg_Pub.ADD;
      RETURN;
    END IF;
  ELSE
    Wf_Directory.getrolename
    ( p_orig_system     => 'PER',
    p_orig_system_id    => l_person_id ,
    p_name              => x_role_name,
    p_display_name      => x_role_display_name );
    IF x_role_name IS NULL  THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
      Fnd_Msg_Pub.ADD;
      RETURN;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;
    Wf_Core.context ('Ams_Approval_Pvt', 'Get_User_Role',p_user_id
            ,'Unexpected Error IN Get_User_Role' );
    RAISE;
END Get_User_Role;

/*============================================================================*/
-- Gets Activity details
-- If the Activity type is Fund then the priority is taken from the parent
/*============================================================================*/
PROCEDURE Get_Activity_Details
  ( p_activity_type       IN     VARCHAR2,
  p_activity_id           IN   NUMBER,
  x_object_details     OUT NOCOPY  ObjRecTyp,
  x_return_status      OUT NOCOPY     VARCHAR2 )
IS

  TYPE obj_csr_type IS REF CURSOR ;
  l_obj_details obj_csr_type;
  l_meaning VARCHAR2(80);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  IF p_activity_type = 'CAMP' THEN

    OPEN l_obj_details  FOR
    SELECT A.campaign_name,
    A.business_unit_id,
    A.city_id,
    A.custom_setup_id,
    A.budget_amount_tc,
    A.org_id,
    --media_type_code,
    A.ROLLUP_TYPE,
    A.priority,
    A.actual_exec_start_date ,
    A.actual_exec_end_date ,
    A.campaign_type ,
    A.description ,
    A.owner_user_id ,
    A.transaction_currency_code ,
    ''priority_desc,
    A.source_code,
    b.source_code,
    b.campaign_name
    FROM ams_campaigns_vl A, ams_campaigns_vl b
    WHERE A.campaign_id = p_activity_id
    AND NVL(A.parent_campaign_id, 0) = b.campaign_id(+);
    /* code added by murali and the code from ravi start*/
  ELSIF p_activity_type = 'CSCH' THEN
        --insert into ams.test_murali (text) values ('IN CSCH');
    OPEN l_obj_details  FOR
    SELECT A.schedule_name,
    b.business_unit_id,
    b.city_id, -- changed Bug 2529071 b.country_code
    A.custom_setup_id,
    A.budget_amount_tc,
    A.org_id,
    A.activity_type_code,
    A.priority,
    A.start_date_time,
    A.end_date_time ,
    A.objective_code ,
    A.description ,
    A.owner_user_id ,
    A.transaction_currency_code ,
    ''priority_desc,
    A.source_code,
    b.source_code ,
    b.campaign_name
    FROM ams_campaign_schedules_vl A, ams_campaigns_vl b
    WHERE A.schedule_id=p_activity_id
    AND b.campaign_id=A.campaign_id
    AND NVL(A.campaign_id, 0) = b.campaign_id;
  ELSIF p_activity_type = 'OFFR' THEN
    OPEN l_obj_details  FOR
    SELECT  SUBSTR(qlh.description,1,240), -- Bug 2986290
    '' business_unit_id,
    '' country_code,
    OFF.custom_setup_id,
    OFF.budget_amount_tc,
    qlh.orig_org_id, -- org_id Bug 3894489
    OFF.offer_type,--'' activity_type_code, -- Changed to fix bug#2288550
    '' priority,
    qlh.start_date_active,
    qlh.end_date_active ,
    OFF.offer_type ,
    qlh.comments ,
    OFF.owner_id ,
    OFF.transaction_currency_code ,
    ''priority_desc,
    OFF.offer_code source_code, -- Bug 2873713
    ''parent_source_code,
    ''parent_name
    FROM ozf_offers OFF, qp_list_headers_vl qlh
    WHERE OFF.qp_list_header_id=qlh.list_header_id
    AND qlh.list_header_id=p_activity_id;
      /* code added by murali and the code from ravi end*/
  ELSIF p_activity_type =  'EVEH' THEN
    OPEN l_obj_details FOR
    SELECT A.event_header_name,
    A.business_unit_id,
    A.country_code,
    A.setup_type_id,
    A.fund_amount_tc,
    A.org_id,
    A.event_type_code,
    A.priority_type_code,
    A.active_from_date,
    A.active_to_date,
    '' ,
    A.description ,
    A.owner_user_id ,
    A.currency_code_tc  ,
    ''priority_desc,
    A.source_code,
    b.source_code ,
    b.campaign_name
    FROM ams_event_headers_vl A, ams_campaigns_vl b
    WHERE A.event_header_id = p_activity_id
    AND NVL(A.program_id, 0) = b.campaign_id(+);
  ELSIF p_activity_type = 'EVEO' THEN
    OPEN l_obj_details FOR
    SELECT A.event_offer_name,
    A.business_unit_id,
    A.country_code,
    A.setup_type_id,
    A.fund_amount_tc,
    A.org_id,
    A.event_type_code,
    A.priority_type_code,
    A.event_start_date ,
    A.event_end_date ,
    '' ,
    A.description ,
    A.owner_user_id ,
    A.currency_code_tc  ,
    ''priority_desc,
    A.source_code,
    b.source_code,
    b.event_header_name
    FROM ams_event_offers_vl A, ams_event_headers_vl b
    WHERE A.event_offer_id = p_activity_id
        AND A.event_object_type = 'EVEO'
        AND A.event_header_id = b.event_header_id;
    /* code added by murali start */
  ELSIF p_activity_type = 'EONE' THEN
    OPEN l_obj_details FOR
    SELECT A.event_offer_name,
    A.business_unit_id,
    A.country_code,
    A.setup_type_id,
    A.fund_amount_tc,
    A.org_id,
    A.event_type_code,
    A.priority_type_code,
    A.event_start_date ,
    A.event_end_date ,
    '' ,
    A.description ,
    A.owner_user_id ,
    A.currency_code_tc  ,
    '' priority_desc,
    A.source_code,
    b.source_code,
    b.campaign_name
    FROM ams_event_offers_vl A, ams_campaigns_vl b
    WHERE A.event_offer_id = p_activity_id
        AND A.event_object_type = 'EONE'
        AND NVL(A.parent_id, 0) = b.campaign_id(+);
    /* code added by murali start */
  ELSIF p_activity_type = 'FUND' THEN
    OPEN l_obj_details FOR
    SELECT short_name,
    '' business_unit_id,
    '' country_code,
    custom_setup_id setup_type_id,
    NVL(original_budget,0)    +
    NVL(transfered_in_amt,0)  -
    NVL(transfered_out_amt,0)
    total_budget,
    org_id,
    TO_CHAR(category_id),
    '' priority_type_code,
    start_date_active ,
    end_date_active ,
    '' ,
    description ,
    owner,
    currency_code_tc  ,
    '' priority_desc,
    '' source_code,
    '' parent_source_code,
    '' parent_name
    FROM ozf_funds_all_vl
    WHERE fund_id = p_activity_id;
  ELSIF p_activity_type = 'DELV' THEN
    OPEN l_obj_details FOR
    SELECT deliverable_name,
    '',
    TO_CHAR(country_id) country_code,
    custom_setup_id setup_type_id, -- was null vmodur
    budget_amount_tc,
    org_id,
    TO_CHAR(category_type_id),--' setup_type_id, -- Changed to fix bug#2288550
    '' priority_type_code,
    actual_avail_from_date ,
    actual_avail_to_date ,
    '' ,
    description ,
    owner_user_id,
    transaction_currency_code  ,
    '' priority_desc,
    '' source_code,
    '' parent_source_code,
    '' parent_name
    FROM ams_deliverables_vl
    WHERE deliverable_id = p_activity_id;
  ELSE
    Fnd_Message.Set_Name('AMS','AMS_BAD_APPROVAL_OBJECT_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF ;

  FETCH l_obj_details INTO x_object_details;
  IF l_obj_details%NOTFOUND THEN
    CLOSE l_obj_details;
    Fnd_Message.Set_Name('AMS','AMS_APPR_BAD_DETAILS');
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;
  CLOSE l_obj_details;

  -- Bug 2789111 Priority for CSCH and EONE too
  IF x_object_details.priority IS NOT NULL THEN
    IF p_activity_type IN ('CAMP','EVEH','EVEO','CSCH','EONE') THEN

      Ams_Utility_Pvt.get_lookup_meaning( 'AMS_PRIORITY',
                    x_object_details.priority,
                    x_return_status,
                    l_meaning
                    );

      IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
          Fnd_Message.set_name('AMS', 'AMS_BAD_PRIORITY');
          Fnd_Msg_Pub.ADD;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          RETURN;
        END IF;
      END IF;
      x_object_details.priority_desc := l_meaning;
    END IF;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;
    Wf_Core.context ('ams_approval_pvt', 'Get_Activity_Details',p_activity_type
            ,p_activity_id ,'Unexpected Error In Get_Activity_Details');
    RAISE;

END Get_Activity_Details;
------------------------------------------------------------------------------
PROCEDURE Get_Ntf_Rule_Values
 (p_approver_name IN VARCHAR2,
  p_result IN VARCHAR2,
  x_text_value OUT NOCOPY VARCHAR2,
  x_number_value OUT NOCOPY NUMBER)
IS

  CURSOR c_get_rule IS
  SELECT b.text_value, b.number_value
  FROM wf_routing_rules a, wf_routing_rule_attributes b, wf_routing_rule_attributes c
  WHERE a.rule_id = b.rule_id
  AND a.role = p_approver_name
  AND TRUNC(sysdate) BETWEEN TRUNC(NVL(begin_date, sysdate -1)) AND
      TRUNC(NVL(end_date,sysdate+1))
  AND a.message_name = 'AMS_LINE_APPROVE'
  AND b.name = 'AMS_APPROVED_LINE_AMOUNT'
  AND b.rule_id = c.rule_id
  AND c.name = 'RESULT'
  AND c.text_value = p_result;

BEGIN
  OPEN c_get_rule;
  FETCH c_get_rule INTO x_text_value, x_number_value;
  IF c_get_rule%NOTFOUND THEN
    x_text_value := NULL;
    x_number_value := 0;
  END IF;
  CLOSE c_get_rule;
EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('ams_approval_pvt','get_ntf_rule_values','p_approver_name',
                     'Unexpected Error in Get_Ntf_Rule_Values');
  RAISE;
END Get_Ntf_Rule_Values;

/*============================================================================*/
-- Gets the amount
-- Gets the total amount which is approved for activities other than
-- Budget
-- For Budget it gets the request amount
/*============================================================================*/
PROCEDURE Get_line_amounts
         ( p_activity_id         IN  NUMBER,
           p_activity_type       IN  VARCHAR2,
           p_act_budget_id       IN  NUMBER, -- was default g_miss_num
           x_amount              OUT NOCOPY NUMBER)
IS

  CURSOR c_line_amount IS
  SELECT request_amount
  FROM ozf_act_budgets
  WHERE activity_budget_id = p_act_budget_id ;


  /* New Cursor Definition */
  CURSOR c_total_amount IS
  SELECT SUM(NVL(DECODE(a1.transfer_type ,
          'REQUEST',
             DECODE(a1.status_code ,'NEW',a1.request_amount,'APPROVED', a1.approved_amount,0),
          'TRANSFER' ,
             DECODE(a1.status_code ,'NEW',a1.src_curr_request_amt,'APPROVED', -a1.approved_original_amount))
          ,0)) approved_amount
  FROM ozf_act_budgets a1
  WHERE DECODE(a1.transfer_type , 'REQUEST', a1.act_budget_used_by_id, 'TRANSFER' , a1.budget_source_id ) = p_activity_id
  AND DECODE(a1.transfer_type , 'REQUEST', a1.arc_act_budget_used_by, 'TRANSFER' , a1.budget_source_type) = p_activity_type
  AND a1.transfer_type <> 'UTILIZED'
  AND status_code = 'APPROVED';

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

BEGIN
  IF p_act_budget_id IS NOT NULL THEN
    OPEN  c_line_amount;
    FETCH c_line_amount INTO x_amount;
    CLOSE c_line_amount;
  ELSE
    OPEN  c_total_amount;
    FETCH c_total_amount INTO x_amount;
    CLOSE c_total_amount;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.context ('Ams_Approval_Pvt', 'Get_line_amounts',p_activity_type
            ,p_activity_id ,'Unexpected Error IN Get_line_amounts');
    RAISE;

END Get_line_amounts;

/*============================================================================*/
-- Checks if there are more approvers
/*============================================================================*/
PROCEDURE Check_Approval_Required
  ( p_approval_detail_id    IN  NUMBER,
  p_current_seq             IN   NUMBER,
  x_next_seq                OUT NOCOPY  NUMBER,
  x_required_flag           OUT NOCOPY  VARCHAR2)
IS

  CURSOR c_check_app IS
  SELECT approver_seq
  FROM ams_approvers
  WHERE ams_approval_detail_id = p_approval_detail_id
  AND approver_seq > p_current_seq
  AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
  AND TRUNC(NVL(end_date_active,SYSDATE + 1))
  AND active_flag = 'Y'
  ORDER BY approver_seq  ;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);
BEGIN
  OPEN  c_check_app;
  FETCH c_check_app INTO x_next_seq;
  IF c_check_app%NOTFOUND THEN
    x_required_flag    :=  Fnd_Api.G_FALSE;
  ELSE
    x_required_flag    :=  Fnd_Api.G_TRUE;
  END IF;
  CLOSE c_check_app;
EXCEPTION
  WHEN OTHERS THEN

    Wf_Core.context ('Ams_Approval_Pvt', 'Check_Approval_Required',p_approval_detail_id
            ,p_current_seq ,'Unexpected Error IN Check_Approval_Required');
    RAISE;

END  Check_Approval_Required;

/*============================================================================*/
-- Gets approver info
-- Approvers Can be user or Role
-- If it is role it should of role_type MKTAPPR AMSAPPR
-- The Seeded role is AMS_DEFAULT_APPROVER
-- SVEERAVE - 10-MAR-2002    Changed x_approver_id, x_object_approver_id to NUMBER from VARCHAR2
/*============================================================================*/
PROCEDURE Get_Approver_Info
  ( p_approval_detail_id       IN  NUMBER,
  p_current_seq                IN   NUMBER,
  x_approver_id                OUT NOCOPY  NUMBER, --  x_approver_id          OUT  VARCHAR2,
  x_approver_type              OUT NOCOPY  VARCHAR2,
  x_role_name                  OUT NOCOPY  VARCHAR2,
  x_object_approver_id         OUT NOCOPY  NUMBER, --  x_object_approver_id   OUT  VARCHAR2,
  x_notification_type          OUT NOCOPY  VARCHAR2,
  x_notification_timeout       OUT NOCOPY  VARCHAR2,
  x_return_status              OUT NOCOPY  VARCHAR2
  )
IS
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);

  l_approver_id            NUMBER;
  l_rule_name              VARCHAR2(240);

  CURSOR c_approver_info IS
    SELECT approver_id
      , approver_type
      , object_approver_id
      , notification_type
      , notification_timeout
    FROM ams_approvers
    WHERE ams_approval_detail_id = p_approval_detail_id
      AND approver_seq = p_current_seq
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE-1 ))
      AND TRUNC(NVL(end_date_active,SYSDATE + 1))
      AND active_flag = 'Y';

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
    SELECT role_resource_id
      , role_name
    FROM jtf_rs_defresroles_vl
    WHERE role_type_code IN ('MKTGAPPR','AMSAPPR')
      AND role_id   = l_approver_id
      AND role_resource_type = 'RS_INDIVIDUAL'
      AND delete_flag = 'N'
      AND TRUNC(SYSDATE) BETWEEN TRUNC(res_rl_start_date)
      AND TRUNC(NVL(res_rl_end_date,SYSDATE));
*/
  CURSOR c_role_info_count IS
  SELECT COUNT(1)
    FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
    WHERE rr.role_id = rl.role_id
    AND rr.role_resource_type = 'RS_INDIVIDUAL'
    AND rr.delete_flag = 'N'
    AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
    AND rl.role_type_code in ( 'MKTGAPPR', 'AMSAPPR')
    AND rl.role_id = l_approver_id;
-- SQL Repository Fix
  /*
    SELECT COUNT(1)
    FROM jtf_rs_defresroles_vl
    WHERE role_type_code IN ('MKTGAPPR','AMSAPPR')
      AND role_id   = l_approver_id
      AND role_resource_type = 'RS_INDIVIDUAL'
      AND delete_flag = 'N'
      AND TRUNC(SYSDATE) BETWEEN TRUNC(res_rl_start_date)
      AND TRUNC(NVL(res_rl_end_date,SYSDATE));
  */
  CURSOR c_default_role_info IS
    SELECT rr.role_id
    FROM jtf_rs_role_relations rr,
      jtf_rs_roles_b rl
    WHERE rr.role_id = rl.role_id
      AND  rl.role_type_code IN( 'MKTGAPPR','AMSAPPR')
      AND rl.role_code   = 'AMS_DEFAULT_APPROVER'
      AND rr.role_resource_type = 'RS_INDIVIDUAL'
      AND delete_flag = 'N'
      AND TRUNC(SYSDATE) BETWEEN TRUNC(rr.start_date_active)
      AND TRUNC(NVL(rr.end_date_active,SYSDATE));

  CURSOR c_rule_name IS
    SELECT name
      FROM ams_approval_details_vl
     WHERE approval_detail_id = p_approval_detail_id;

  l_count NUMBER;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  OPEN  c_approver_info;
  FETCH c_approver_info INTO x_approver_id,
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
    Fnd_Msg_Pub.ADD;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF x_approver_type = 'ROLE' THEN
    IF x_object_approver_id IS NULL THEN
      OPEN  c_default_role_info ;
      FETCH c_default_role_info INTO x_object_approver_id;
      IF c_default_role_info%NOTFOUND THEN
        CLOSE c_default_role_info ;
        Fnd_Message.Set_Name('AMS','AMS_NO_DEFAULT_ROLE'); -- VMODUR added
        --Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
        Fnd_Msg_Pub.ADD;
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        RETURN;
      END IF;
      CLOSE c_default_role_info ;
    END IF;
    l_approver_id := x_object_approver_id;
    OPEN  c_role_info_count;
    FETCH c_role_info_count INTO l_count;
    IF l_count > 1 THEN
      CLOSE c_role_info_count;
      Fnd_Message.Set_Name('AMS','AMS_MANY_DEFAULT_ROLE'); -- VMODUR added
      --Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CLOSE c_role_info_count;
    OPEN  c_role_info;
    FETCH c_role_info INTO x_object_approver_id, x_role_name;
    IF c_role_info%NOTFOUND THEN
      CLOSE c_role_info;
      Fnd_Message.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
      Fnd_Msg_Pub.ADD;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      RETURN;
    END IF;
    CLOSE c_role_info;
  END IF;
  CLOSE c_approver_info;
EXCEPTION
  WHEN OTHERS THEN
    -- wf_engine.threshold := l_save_threshold ;

    Wf_Core.context ('Ams_Approval_Pvt', 'Get_Approver_Info',p_approval_detail_id
            ,p_current_seq ,'Unexpected Error IN Get_Approver_Info');
    RAISE;
END Get_Approver_Info;

/*****************************************************************
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
-- p_act_budget_id           If called from header record this field is null
-- x_object_details          Object details contains the detail of objects
-- x_approval_detail_id      Approval detail Id macthing the criteria
-- x_approver_seq            Approval Sequence
-- x_return_status           Return Status
-- NOTES
-- HISTORY
--  15-SEP-2000          GJOBY       CREATED
-- End of Comments
*****************************************************************/


PROCEDURE Get_Approval_Details
  ( p_activity_id        IN  NUMBER,
  p_activity_type        IN   VARCHAR2,
  p_approval_type        IN   VARCHAR2 DEFAULT  'BUDGET',
  p_act_budget_id        IN   NUMBER , -- was default g_mss_num
  x_object_details       OUT NOCOPY  ObjRecTyp,
  x_approval_detail_id   OUT NOCOPY  NUMBER,
  x_approver_seq         OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2)
IS
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_error_msg           VARCHAR2(4000);

  l_amount              NUMBER;
  l_business_unit_id    NUMBER           := Fnd_Api.G_MISS_NUM;
  l_org_id              NUMBER           := Fnd_Api.G_MISS_NUM;
  l_setup_type_id       NUMBER           := Fnd_Api.G_MISS_NUM;
  l_object_type         VARCHAR2(30)     := Fnd_Api.G_MISS_CHAR;
  l_priority            VARCHAR2(30)     := Fnd_Api.G_MISS_CHAR;
  l_country_code        VARCHAR2(30)     := Fnd_Api.G_MISS_CHAR;
  l_approver_id         NUMBER;
  l_object_details      ObjRecTyp;
  l_activity_type       VARCHAR2(30);
  l_activity_id         NUMBER;
  l_curr_match          VARCHAR2(1) := 'N';
  l_appr_amount         NUMBER;
  l_rule_curr_code      VARCHAR2(15);
  l_curr_code           VARCHAR2(15);
  l_obj_curr_code       VARCHAR2(15);
  l_lower_limit         NUMBER;
  l_upper_limit         NUMBER;
  l_budget_amount       NUMBER;
  l_return_status       VARCHAR2(1);
  d_msg                 VARCHAR2(4000);

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

-- Start: Added for fixing the bug 6310662 by rsatyava on 2007/08/09

  l_org_cnd_stmt       VARCHAR2(2000):=' AND NVL(organization_id,:orgid) =:orgid ' ;

  l_appr_detl_stmt1 VARCHAR2(4000):=' SELECT approval_detail_id,
					 currency_code,
					 nvl(approval_limit_from,0),
					 nvl(approval_limit_to, :amount)
				    FROM ams_approval_details
				    WHERE NVL(business_unit_id,:businessunit) =:businessunit ' ;

l_appr_detl_stmt2 VARCHAR2(4000):='  AND NVL(custom_setup_id,:customsetupid) =:customsetupid
				     AND approval_object  =:appobject AND approval_type  =:apptype
				     AND NVL(approval_object_type,:appobjecttype) =:appobjecttype
                                     AND NVL(user_country_code,:usercountrycode) =:usercountrycode
                                     AND NVL(approval_priority,:apppriority) =:apppriority
                                     AND seeded_flag  =''N''
                                     AND :amount between DECODE(:amount, 0, 0, nvl(approval_limit_from,0)) and
                                     NVL(approval_limit_to,:amount)
                                     AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
                                     AND TRUNC(NVL(end_date_active,SYSDATE + 1))
				  ORDER BY (POWER(2,DECODE(business_unit_id,'''',0,6)) +
					       POWER(2,DECODE(organization_id,'''',0,5)) +
					       POWER(2,DECODE(custom_setup_id,'''',0,1)) +
					       POWER(2,DECODE(user_country_code,'''',0,2)) +
					       POWER(2,DECODE(approval_object_type,'''',0,4)) +
					       POWER(2,DECODE(approval_priority,'''',0,3)  )) DESC ';

 l_appr_csr appr_cursor;

-- End: Added for fixing the bug 6310662 by rsatyava on 2007/08/09


  CURSOR c_approver_detail_id (amount IN NUMBER) IS
  SELECT approval_detail_id,
         currency_code,
	 nvl(approval_limit_from,0),
	 nvl(approval_limit_to, amount)
  FROM ams_approval_details
  WHERE NVL(business_unit_id,l_business_unit_id) = l_business_unit_id
  AND NVL(organization_id,l_org_id)              = l_org_id
  AND NVL(custom_setup_id,l_setup_type_id)       = l_setup_type_id
  AND approval_object                            = p_activity_type
  AND approval_type                              = p_approval_type
  AND NVL(approval_object_type,l_object_type)    = l_object_type
  AND NVL(user_country_code,l_country_code)      = l_country_code
  AND NVL(approval_priority,l_priority)          = l_priority
  AND seeded_flag                                = 'N'
  AND amount between DECODE(amount, 0, 0, nvl(approval_limit_from,0)) and
                    nvl(approval_limit_to,amount)
  AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
  AND TRUNC(NVL(end_date_active,SYSDATE + 1))
  ORDER BY (POWER(2,DECODE(business_unit_id,'',0,6)) +
               POWER(2,DECODE(organization_id,'',0,5)) +
               POWER(2,DECODE(custom_setup_id,'',0,1)) +
	       POWER(2,DECODE(user_country_code,'',0,2)) +
               POWER(2,DECODE(approval_object_type,'',0,4)) +
               POWER(2,DECODE(approval_priority,'',0,3)  )) DESC ;

  -- If the there are no matching records it takes the default Rule
  CURSOR c_approver_def IS
  SELECT approval_detail_id
  FROM ams_approval_details
  WHERE approval_detail_id = 150;
 -- WHERE seeded_flag = 'Y'; -- to avoid FTS

  -- Takes Min Approver Sequence From Ams_approvers Once matching records are
  -- Found form ams_approval_deatils
  CURSOR c_approver_seq IS
  SELECT MIN(approver_seq)
  FROM ams_approvers
  WHERE ams_approval_detail_id  = x_approval_detail_id
  AND TRUNC(SYSDATE) BETWEEN
  TRUNC(NVL(start_date_active,SYSDATE -1 )) AND TRUNC(NVL(end_date_active,SYSDATE + 1))
  AND active_flag = 'Y';

  -- For Budgets the priority has to to be taken from the Object priority
  -- The Following cursor returns the Approval object and Approval Object Id
  -- for the parent

  CURSOR c_fund_priority IS
  SELECT ARC_ACT_BUDGET_USED_BY,
         ACT_BUDGET_USED_BY_ID
  FROM ozf_act_budgets
  WHERE ACTIVITY_BUDGET_ID =  p_act_budget_id;
BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


  Get_Activity_Details
  ( p_activity_type    => p_activity_type,
  p_activity_id        => p_activity_id,
  x_object_details     => x_object_details,
  x_return_status      => x_return_status);

  IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    RETURN;
  END IF;

  l_business_unit_id    := NVL(x_object_details.business_unit_id,l_business_unit_id);
  l_org_id              := NVL(x_object_details.org_id,l_org_id);
  l_setup_type_id       := NVL(x_object_details.setup_type_id,l_setup_type_id);
  l_object_type         := NVL(x_object_details.object_type,l_object_type);
  l_priority            := NVL(x_object_details.priority,l_priority);
  l_country_code        := NVL(x_object_details.country_code,l_country_code);
  l_curr_code           := nvl(x_object_details.currency, 'USD');


  IF p_act_budget_id = Fnd_Api.G_MISS_NUM OR
     p_act_budget_id IS NULL THEN -- Important for JAVA call
    -- This amount is in the objects currency
    l_amount := NVL(x_object_details.total_header_amount, 0);
  ELSE

    Get_line_amounts
      ( p_activity_id       => p_activity_id,
      p_activity_type       => p_activity_type,
      p_act_budget_id       => p_act_budget_id,
      x_amount              => l_amount);

    x_object_details.total_header_amount  :=  NVL(l_amount, 0) ;

    OPEN c_fund_priority ;
    FETCH c_fund_priority INTO l_activity_type , l_activity_id ;
    CLOSE c_fund_priority ;

    Get_Activity_Details
      ( p_activity_type      => l_activity_type,
        p_activity_id        => l_activity_id,
        x_object_details     => l_object_details,
        x_return_status      => x_return_status);

    l_priority            := NVL(l_object_details.priority,l_priority);
    l_obj_curr_code       := nvl(l_object_details.currency,'USD');

    IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
  END IF;

    IF (p_approval_type = 'BUDGET' AND p_activity_type = 'FUND') THEN

     -- For Budget Line, if a rule with same currency exists
     -- then that rule would be the first choice
     -- Convert l_amount from the Object Currency to the currency of the
     -- Budget

     AMS_Utility_Pvt.Convert_Currency (
          p_from_currency      => l_obj_curr_code,
          p_to_currency        => l_curr_code,
          p_from_amount        => l_amount,
          x_to_amount          => l_budget_amount,
          x_return_status      => x_return_status );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      return;
     END IF;

     OPEN c_approver_detail_id(l_budget_amount);
     LOOP
     FETCH c_approver_detail_id INTO x_approval_detail_id,
           l_rule_curr_code, l_lower_limit, l_upper_limit;
     EXIT WHEN c_approver_detail_id%NOTFOUND;

       IF l_rule_curr_code = l_curr_code THEN
         l_curr_match := 'Y';
         EXIT;
       END  IF;
     END LOOP;
     CLOSE c_approver_detail_id;

     -- If no approval rule has been defined with the same currency as the
     -- budget, then convert the amount from the budget currency
     -- to the approval rule currency and then compare

     IF l_curr_match <> 'Y' THEN
       -- Get all rules regardless of amount
       OPEN c_approver_detail_id(0);
       LOOP
       FETCH c_approver_detail_id INTO x_approval_detail_id, l_rule_curr_code,
                                       l_lower_limit, l_upper_limit;
       EXIT WHEN c_approver_detail_id%NOTFOUND;

          AMS_Utility_Pvt.Convert_Currency (
          p_from_currency      => l_curr_code,
          p_to_currency        => l_rule_curr_code,
          p_from_amount        => l_budget_amount,
          x_to_amount          => l_appr_amount,
          x_return_status      => l_return_status );

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- Added following condition to account for upper limit
        -- being null in which case it will be initialized as
        -- zero. reopned 3655122 fix

        IF l_upper_limit = 0 THEN
           l_upper_limit := l_appr_amount;
        END IF;

        --
        -- Check whether the amount in converted currency is between
        -- the approval rules' lower and upper amounts
        IF l_appr_amount BETWEEN l_lower_limit and l_upper_limit THEN
           EXIT;
        END IF;

      END IF;
          x_approval_detail_id := NULL;
      END LOOP;
      CLOSE c_approver_detail_id;

    END IF;

       -- No approval rule in any currency matched the budget line
       -- Get the default approval rule
       IF x_approval_detail_id IS NULL THEN
         OPEN c_approver_def ;
         FETCH c_approver_def INTO x_approval_detail_id;
         IF c_approver_def%NOTFOUND THEN
           CLOSE c_approver_def ;
           FND_MESSAGE.Set_Name('AMS','AMS_NO_DEFAULT_ROLE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           return;
         END IF;
        CLOSE c_approver_def ;
      END IF;

  -- All other object and approval type combinations don't really
  -- need currency code for determining an approval rule
  ELSE -- Not a Budget Line

  -- Start:Added by rsatyava for fixing the bug#6310662 on 2007/08/09
  IF(p_activity_type = 'FUND' OR p_activity_type = 'OFFR') THEN
     OPEN l_appr_csr for l_appr_detl_stmt1 ||
			 l_org_cnd_stmt ||
			 l_appr_detl_stmt2
     using l_amount,
	   l_business_unit_id,l_business_unit_id,
	   l_org_id,l_org_id,
	   l_setup_type_id,l_setup_type_id,
	   p_activity_type,p_approval_type,
	   l_object_type, l_object_type,
	   l_country_code, l_country_code,
	   l_priority, l_priority,
	   l_amount, l_amount,l_amount;
  ELSE
    -- If the activity type is CAMP,CSCH,DELV,EVEO,EVEH,EONE then the conditional clause for oragnization id is not appended.
    OPEN l_appr_csr for l_appr_detl_stmt1 ||
			l_appr_detl_stmt2
	  using l_amount,
		l_business_unit_id,l_business_unit_id,
		l_setup_type_id,l_setup_type_id,
		p_activity_type,p_approval_type,
		l_object_type, l_object_type,
		l_country_code, l_country_code,
		l_priority, l_priority,
		l_amount, l_amount,l_amount;
     END IF;
  -- End:Added for fixing the bug 6310662 by rsatyava on 2007/08/09

    -- Start:Modified by rsatyava for fixing the bug#6310662 on 2007/08/09

    LOOP
    FETCH l_appr_csr  INTO x_approval_detail_id, l_rule_curr_code,
        l_lower_limit, l_upper_limit;
    EXIT WHEN l_appr_csr%NOTFOUND;

    -- End:Modified by rsatyava for fixing the bug#6210036 on 2007/08/01

    -- Fix for Bug when zero budget approvals pick up rules starting
    -- at more than zero. get all rules and pick up one which the
    -- amount is between low and high. if none found use the default

      IF l_amount BETWEEN l_lower_limit and l_upper_limit THEN
        EXIT;
      END IF;
        x_approval_detail_id := null;
    END LOOP;
   CLOSE l_appr_csr;

   -- End:Modified by rsatyava for fixing the bug#6310662 on 2007/08/09



  IF x_approval_detail_id IS NULL THEN
      OPEN c_approver_def ;
      FETCH c_approver_def INTO x_approval_detail_id;
      IF c_approver_def%NOTFOUND THEN
        CLOSE c_approver_def ;
        FND_MESSAGE.Set_Name('AMS','AMS_NO_DEFAULT_ROLE');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
      END IF;
      CLOSE c_approver_def ;
  END IF;

END IF; -- not a budget line

  OPEN  c_approver_seq  ;
  FETCH c_approver_seq INTO x_approver_seq ;
   IF c_approver_seq%NOTFOUND THEN
    CLOSE c_approver_seq;
    FND_MESSAGE.Set_Name('AMS','AMS_NO_APPROVER_SEQUENCE');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
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
-- p_item_type                         AMSAPRV
-- NOTES
-- Item key generated as combination of Activity Type, Activity Id, and Object
-- Version Number.
-- For ex. CAMP100007 where 7 is object version number and 10000 Activity id
-- HISTORY
--  15-SEP-2000          GJOBY       CREATED
-- End of Comments
*****************************************************************/

PROCEDURE StartProcess
      (p_activity_type         IN   VARCHAR2,
      p_activity_id            IN   NUMBER,
      p_approval_type          IN   VARCHAR2,
      p_object_version_number  IN   NUMBER,
      p_orig_stat_id           IN   NUMBER,
      p_new_stat_id            IN   NUMBER,
      p_reject_stat_id         IN   NUMBER,
      p_requester_userid       IN   NUMBER,
      p_notes_from_requester   IN   VARCHAR2   DEFAULT NULL,
      p_workflowprocess        IN   VARCHAR2   ,
      p_item_type              IN   VARCHAR2
      )
IS
  itemtype                 VARCHAR2(30) := NVL(p_item_type,'AMSAPRV');
  itemkey                  VARCHAR2(30) := p_activity_type||p_activity_id||
                                                p_object_version_number;
  itemuserkey              VARCHAR2(80) := p_activity_type||p_activity_id||
                                                p_object_version_number;

  l_requester_role         VARCHAR2(320) ; -- was 100
  l_manager_role           VARCHAR2(100) ;
  l_display_name           VARCHAR2(360) ; -- was 240
  l_requester_id           NUMBER ;
  l_person_id              NUMBER ;
  l_appr_for               VARCHAR2(240) ;
  l_appr_meaning           VARCHAR2(240);
  l_return_status          VARCHAR2(1);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);
  x_resource_id            NUMBER;

  l_save_threshold         NUMBER := Wf_Engine.threshold;

  l_appr_hist_rec          AMS_Appr_Hist_PVT.appr_hist_rec_type;

  -- [BEGIN OF BUG2741039 FIXING by vmodur 09-Jan-2003]
    l_user_id                NUMBER;
    l_resp_id                NUMBER;
    l_appl_id                NUMBER;
    l_security_group_id      NUMBER;
  -- [END OF BUG2741039 FIXING]

  CURSOR c_resource IS
  SELECT resource_id ,employee_id source_id,full_name resource_name
  FROM ams_jtf_rs_emp_v
  WHERE user_id = x_resource_id ;
BEGIN
  Fnd_Msg_Pub.initialize();

  /* Delete any previous history rows for this object and approval type Bug 2761026*/

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

  Ams_Utility_Pvt.debug_message('START :Item TYPE : '||itemtype
                         ||' Item KEY : '||itemkey);

    -- wf_engine.threshold := -1;
  Wf_Engine.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

   Wf_Engine.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);

  -- 09-Jan-2003  VMODUR  Fix for BUG 2741039 - add pl/sql global context into
  --                      workflow item attribute.It could be used later on for
  --                      PL/SQL function to initialize the global context when the
  --                      session is established by workflow mailer.

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
                               avalue     =>  l_security_group_id
                              );
  -- [END OF BUG2741039 FIXING]

   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/

   -- Activity Type  (Some of valid values are 'CAMP','DELV','EVEH','EVEO'..);
   Wf_Engine.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_ACTIVITY_TYPE',
                             avalue     =>   p_activity_type  );

   -- Activity ID  (primary Id of Activity Object)
   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_ACTIVITY_ID',
                               avalue    =>  p_activity_id  );


   -- Original Status Id (If error occurs we have to revert back to this
   --                     status )
   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_ORIG_STAT_ID',
                               avalue    =>  p_orig_stat_id  );

   -- New Status Id (If activity is approved status of activity is updated
   --                by this status )
   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_NEW_STAT_ID',
                               avalue    =>  p_new_stat_id  );

   -- Reject Status Id (If activity is approved status of activity is rejected
   --                by this status )
   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_REJECT_STAT_ID',
                               avalue    =>  p_reject_stat_id  );


   -- Object Version Number
   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_OBJECT_VERSION_NUMBER',
                               avalue    =>  p_object_version_number  );

   -- Notes from the requester
   Wf_Engine.SetItemAttrText(itemtype   =>  itemtype,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_NOTES_FROM_REQUESTER',
                             avalue     =>  NVL(p_notes_from_requester,'') );

   /*-- Fetch resource Id for the requestor
   OPEN c_resource ;
   FETCH c_resource INTO l_requester_id ,l_person_id ;
   CLOSE c_resource ; */

   Wf_Engine.SetItemAttrNumber(itemtype  =>  itemtype,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_REQUESTER_ID',
                               avalue    =>  p_requester_userid       );

  l_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  --  check for description of activity For ex. CAMP Campaign
  Ams_Utility_Pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                      p_activity_type,
                                      l_return_status,
                                      l_appr_meaning
                                     );
  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
     Fnd_Message.Set_Name('AMS','AMS_BAD_APPROVAL_OBJECT_TYPE');
     Fnd_Msg_Pub.ADD;
     RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  --  set description of activity
  Wf_Engine.SetItemAttrText(itemtype =>  itemtype ,
                            itemkey  =>  itemkey,
                            aname    =>  'AMS_APPROVAL_OBJECT_MEANING',
                            avalue   =>  l_appr_meaning  );

  Wf_Engine.SetItemAttrText(itemtype =>  itemtype ,
                            itemkey  =>  itemkey,
                            aname    =>  'AMS_APPROVAL_TYPE',
                            avalue   =>  p_approval_type  );

  -- Setting up the role
  Get_User_Role(p_user_id              => p_requester_userid ,
                x_role_name            => l_requester_role,
                x_role_display_name    => l_display_name,
                x_return_status        => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
     RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  Wf_Engine.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'AMS_REQUESTER',
                            avalue      =>  l_requester_role  );



   Wf_Engine.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requester_role);


   -- Start the Process
   Wf_Engine.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);


   /* 11.5.9 Approval Details Enhancement */

   /* Create the Submitted row in ams_approval_history */

   l_appr_hist_rec.object_id := p_activity_id;
   l_appr_hist_rec.object_type_code := p_activity_type;
   l_appr_hist_rec.sequence_num := 0;
   l_appr_hist_rec.object_version_num := p_object_version_number;
   l_appr_hist_rec.action_code := 'SUBMITTED';
   l_appr_hist_rec.action_date := sysdate;
   l_appr_hist_rec.approver_id := p_requester_userid;
   l_appr_hist_rec.note := p_notes_from_requester;
   l_appr_hist_rec.approval_type := p_approval_type;
   l_appr_hist_rec.approver_type := 'USER'; -- User always submits
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
     WHEN Fnd_Api.G_EXC_ERROR THEN
        -- wf_engine.threshold := l_save_threshold ;
        Fnd_Msg_Pub.Count_And_Get (
          p_encoded => Fnd_Api.G_FALSE,
          p_count   => l_msg_count,
          p_data    => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg       );
        Wf_Core.context ('Ams_Approval_Pvt', 'StartProcess',p_activity_type
                       ,p_activity_id ,l_error_msg);
        RAISE;
     WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
        Wf_Core.context ('Ams_Approval_Pvt', 'StartProcess',p_activity_type
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
l_object_details        ObjRecTyp;
l_approval_detail_id    NUMBER;
l_approver_seq          NUMBER;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_orig_stat_id          NUMBER;
x_resource_id           NUMBER;
l_full_name             VARCHAR2(360); --l_full_name             VARCHAR2(60); --SVEERAVE,04/10/02
l_func_name             VARCHAR2(100);
l_dtail_url             VARCHAR2(200);-- how much

cursor c_get_function_id (c_func_name varchar2) is
 select function_id from fnd_form_functions where function_name = c_func_name ;

BEGIN
  Fnd_Msg_Pub.initialize();
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_approval_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );


     Get_Approval_Details
        ( p_activity_id          =>  l_activity_id,
          p_activity_type        =>  l_activity_type,
          p_approval_type        =>  l_approval_type,
          p_act_budget_id        =>  null,
          x_object_details       =>  l_object_details,
          x_approval_detail_id   =>  l_approval_detail_id,
          x_approver_seq         =>  l_approver_seq,
          x_return_status        =>  l_return_status
        );

     IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN

      IF l_activity_type IN ('CAMP','CSCH') THEN
        IF l_activity_type = 'CAMP' THEN
          l_func_name := 'AMS_WB_CAMP_DETL';
        ELSE
          l_func_name := 'AMS_WB_CSCH_UPDATE';
        END IF;
/*
        open c_get_function_id(l_func_name);
        fetch c_get_function_id into l_function_id;
        close c_get_function_id;

        l_dtail_url := fnd_run_function.get_run_function_url
                   (l_function_id,
                        530,
                        -1,
                         0,
                        'objId=' || l_activity_id );
*/
        l_dtail_url := 'JSP:/OA_HTML/OA.jsp?OAFunc='||l_func_name||'&'||'objId='||l_activity_id;
        l_dtail_url := l_dtail_url||'&'||'addBreadCrumb=Y';

        wf_engine.SetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_URL',
                                   avalue   => l_dtail_url );

      END IF;

        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACT_NAME',
                                    avalue    => l_dtail_url);

        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACT_NAME',
                                    avalue    => l_object_details.name);

        Wf_Engine.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACTIVITY_DETAIL_ID',
                                    avalue    => l_approval_detail_id);
        Wf_Engine.SetItemAttrDate(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_START_DATE',
                                    avalue    => l_object_details.start_date);
        Wf_Engine.SetItemAttrDate(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_END_DATE',
                                    avalue    => l_object_details.end_date);
        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACTIVITY_DESCRIPTION',
                                    avalue    => l_object_details.description);
       -- Changed Priority code to meaning
        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_PRIORITY',
                                    avalue    => l_object_details.priority_desc);
        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACTIVITY_CURRENCY',
                                    avalue    => l_object_details.currency);
        --
        Wf_Engine.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_APPROVER_SEQ',
                                    avalue    => l_approver_seq);
        Wf_Engine.SetItemAttrNumber(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACTIVITY_AMOUNT',
                                    avalue    =>
                                         l_object_details.total_header_amount);
            --insert into ams.test_murali (text) values ('source_code ' || l_object_details.source_code);
            -- Fix for Bug 2031309. AMS_CURRENCY was being set to source_code
          Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_CURRENCY',
                                    avalue    => l_object_details.currency);

          Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_SOURCE_CODE',
                                    avalue    => l_object_details.source_code);

         Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_PARENT_SOURCE_CODE',
                                    avalue    => l_object_details.parent_source_code);

         Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_PARENT_OBJECT',
                                    avalue    => l_object_details.parent_name);


        Get_User_Name
          ( p_user_id            => l_object_details.owner_id,
            x_full_name          => l_full_name,
            x_return_status      => l_return_status );

        IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN

           Fnd_Msg_Pub.Count_And_Get (
           p_encoded => Fnd_Api.G_FALSE,
           p_count   => l_msg_count,
           p_data    => l_msg_data);

           Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);

           resultout := 'COMPLETE:ERROR';
           RETURN;
        END IF;

        Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                    itemkey   => itemkey,
                                    aname     => 'AMS_ACTIVITY_OWNER',
                                    avalue    => l_full_name );

        resultout := 'COMPLETE:SUCCESS';
        RETURN;

     ELSE
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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

   /*
        wf_core.context('Ams_Approval_Pvt','Set_Activity_Details',
                        itemtype,itemkey,actid,l_error_msg);  */
        -- RAISE FND_API.G_EXC_ERROR;
        resultout := 'COMPLETE:ERROR';
        RETURN;
     END IF;
  END IF;

  --
  -- CANCEL mode
  --
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
  --

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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
       resultout := 'COMPLETE:ERROR';
      /*wf_core.context('Ams_Approval_Pvt','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      raise; */
   WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
      Wf_Core.context('Ams_Approval_Pvt','Set_Activity_Details',
                      itemtype,itemkey,actid,funcmode,l_error_msg);
      RAISE;
END Set_Activity_Details ;

/*============================================================================*/
-- Check_Budget_Lines
/*============================================================================*/
PROCEDURE Check_Budget_Lines( itemtype        IN  VARCHAR2,
                              itemkey         IN  VARCHAR2,
                              actid           IN  NUMBER,
                              funcmode        IN  VARCHAR2,
                              resultout       OUT NOCOPY VARCHAR2    )
IS
l_activity_id           NUMBER;
l_activity_type         VARCHAR2(30);
l_dummy_char            VARCHAR2(30);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg                VARCHAR2(4000);

  CURSOR c_check_lines IS
  SELECT status_code
    FROM ozf_act_budgets
   WHERE arc_act_budget_used_by = l_activity_type
     AND act_budget_used_by_id = l_activity_id
     AND status_code NOT IN ('APPROVED','REJECTED','CANCELLED','PENDING')
     AND ROWNUM < 2;
BEGIN
  Fnd_Msg_Pub.initialize();

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

      OPEN  c_check_lines;
      FETCH c_check_lines INTO l_dummy_char ;
      IF l_dummy_char IS NULL  THEN
         resultout := 'COMPLETE:LINES_APPROVED' ;
      ELSE
         resultout := 'COMPLETE:LINES_NOT_APPROVED' ;
      END IF;
      CLOSE c_check_lines;
  END IF;

  --
  -- CANCEL mode
  --
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
  --


EXCEPTION
  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'Check_Budget_Lines',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Check_Budget_Lines;

/*============================================================================*/
-- Get_Approval_Rules
/*============================================================================*/
PROCEDURE Get_Approval_Rules( p_activity_type   IN  VARCHAR2,
                              p_activity_id     IN  NUMBER,
                              p_activity_amount IN  NUMBER,
                              x_approved_flag   OUT NOCOPY VARCHAR2)
IS
l_amount         NUMBER;
l_percent        NUMBER;
l_offer_type     VARCHAR2(30);
CURSOR c_offer_type IS
  SELECT offer_type
    FROM ozf_offers
   WHERE qp_list_header_id = p_activity_id;
BEGIN
  Fnd_Msg_Pub.initialize();
  -- Change for Offers Team for Bug 2861942

  IF p_activity_type = 'OFFR' THEN
     OPEN c_offer_type;
     FETCH c_offer_type INTO l_offer_type;
     IF c_offer_type%NOTFOUND THEN
       CLOSE c_offer_type;
     END IF;
     CLOSE c_offer_type;
  END IF;

  IF l_offer_type IN ('SCAN_DATA','LUMPSUM') THEN
     l_percent := 1;
  ELSE
  -- Why is it NVL(profile,0)/100 should it not be NVL(profile,100)/100
  l_percent := NVL(Fnd_Profile.Value('AMS_APPROVAL_CUTOFF_PERCENT'),0)/100 ;
  END IF;

  Get_line_amounts
         ( p_activity_id         => p_activity_id,
           p_activity_type       => p_activity_type,
           p_act_budget_id       => null,
           x_amount              => l_amount);
  IF ( NVL(l_amount,0)   >=  NVL(p_activity_amount,0) * l_percent ) THEN
       x_approved_flag  := Fnd_Api.G_TRUE;
  ELSE
     x_approved_flag  := Fnd_Api.G_FALSE ;
  END IF;
END Get_Approval_Rules ;
/*============================================================================*/
PROCEDURE local_dummy IS
l_dummy              DATE ;
l_dummy1             CHAR  := 'y';
BEGIN
l_dummy := SYSDATE;
LOOP
     SELECT 'x'
     INTO l_dummy1
     FROM dual
     WHERE (( SYSDATE  - l_dummy )*(24*60))  < .01 ;
END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      NULL;
END local_dummy;
/*============================================================================*/
--Check_Approval_rules
/*============================================================================*/
PROCEDURE Check_Approval_rules( itemtype        IN  VARCHAR2,
                                itemkey         IN  VARCHAR2,
                                actid           IN  NUMBER,
                                funcmode        IN  VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2    )

IS
l_activity_id           NUMBER;
l_activity_amount       NUMBER;
l_activity_type         VARCHAR2(30);
l_approved_flag         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
l_error_msg             VARCHAR2(4000);
l_save_threshold        NUMBER := Wf_Engine.threshold;
BEGIN
  Fnd_Msg_Pub.initialize();
  IF (funcmode = 'RUN') THEN
    Wf_Engine.threshold := -1;
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_activity_amount    := Wf_Engine.GetItemAttrNumber(
                               itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'AMS_ACTIVITY_AMOUNT' );

     Get_Approval_Rules( p_activity_type      => l_activity_type ,
                         p_activity_id        => l_activity_id,
                         p_activity_amount    => l_activity_amount,
                         x_approved_flag      => l_approved_flag );

     IF l_approved_flag = Fnd_Api.G_TRUE THEN
        resultout := 'COMPLETE:SUCCESS';
     ELSE
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count => l_msg_count,
               p_data  => l_msg_data
          );
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data , -- Number of error Messages
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
        resultout := 'COMPLETE:FAILURE';
     END IF;
    Wf_Engine.threshold := l_save_threshold ;

  END IF;

  --
  -- CANCEL mode
  --
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
EXCEPTION
WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'check_approval_rules',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
  --

END Check_Approval_Rules ;

/*============================================================================*/
-- Prepare Doc
/*============================================================================*/

PROCEDURE Prepare_Doc( itemtype        IN  VARCHAR2,
                       itemkey         IN  VARCHAR2,
                       actid           IN  NUMBER,
                       funcmode        IN  VARCHAR2,
                       resultout       OUT NOCOPY VARCHAR2 )
IS
BEGIN
  Fnd_Msg_Pub.initialize();
  IF (funcmode = 'RUN') THEN
     resultout := 'COMPLETE:SUCCESS';
  END IF;

  --
  -- CANCEL mode
  --
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
  --

END;

/*============================================================================*/
-- Set_Approver_details
/*============================================================================*/

PROCEDURE Set_Approver_Details( itemtype        IN  VARCHAR2,
                                itemkey         IN  VARCHAR2,
                                actid           IN  NUMBER,
                                funcmode        IN  VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2 )
IS
l_current_seq             NUMBER;
l_approval_detail_id      NUMBER;
l_approver_id             NUMBER;
l_approver                VARCHAR2(320);--l_approver   VARCHAR2(30); --SVEERAVE,04/10/02
l_prev_approver           VARCHAR2(320);--l_prev_approver  VARCHAR2(30); --SVEERAVE,04/10/02
l_approver_display_name   VARCHAR2(360);
l_notification_type       VARCHAR2(30);
l_notification_timeout    NUMBER;
l_approver_type           VARCHAR2(30);
l_role_name               VARCHAR2(100); --l_role_name  VARCHAR2(30);--SVEERAVE,04/10/02
l_prev_role_name          VARCHAR2(100); --l_prev_role_name  VARCHAR2(30);--SVEERAVE,04/10/02
l_object_approver_id      NUMBER;
l_return_status           VARCHAR2(1);
l_msg_count               NUMBER;
l_msg_data                VARCHAR2(4000);
l_error_msg               VARCHAR2(4000);
l_pkg_name                VARCHAR2(80);
l_proc_name               VARCHAR2(80);
l_appr_id                 NUMBER;
dml_str                   VARCHAR2(2000);
--11.5.9
l_approval_type           VARCHAR2(30);
l_activity_type           VARCHAR2(30);
l_activity_id             NUMBER;
l_object_details          ObjRecTyp;
l_version                 NUMBER;
l_appr_seq                NUMBER;
l_appr_type               VARCHAR2(30);
l_obj_appr_id             NUMBER;
l_appr_hist_rec           AMS_Appr_Hist_PVT.appr_hist_rec_type;

CURSOR c_API_Name(rule_id_in IN NUMBER) IS
     SELECT package_name, procedure_name
       FROM ams_object_rules_b
      WHERE OBJECT_RULE_ID = rule_id_in;

CURSOR c_approver(rule_id IN NUMBER) IS
     SELECT approver_seq, approver_type, object_approver_id
       FROM ams_approvers
      WHERE ams_approval_detail_id = rule_id
       AND  active_flag = 'Y'
       AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
       AND TRUNC(NVL(end_date_active,SYSDATE + 1));
BEGIN
  Fnd_Msg_Pub.initialize();
  IF (funcmode = 'RUN') THEN
     l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_DETAIL_ID' );

     l_current_seq        := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_SEQ' );
     -- 11.5.9

     l_activity_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_version            := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_OBJECT_VERSION_NUMBER' );

     l_approval_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey => itemkey,
                                 aname   => 'AMS_APPROVAL_TYPE' );

     -- 11.5.9
      Get_Approver_Info
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
        -- Bug 2745031
        RAISE Fnd_Api.G_EXC_ERROR;
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
           Fnd_Msg_Pub.Count_And_Get (
              p_encoded => Fnd_Api.G_FALSE,
              p_count => l_msg_count,
              p_data  => l_msg_data
             );
            Handle_Err
             (p_itemtype         => itemtype   ,
              p_itemkey          => itemkey    ,
              p_msg_count        => l_msg_count,
              p_msg_data         => l_msg_data ,
              p_attr_name        => 'AMS_ERROR_MSG',
              x_error_msg         => l_error_msg);

              resultout := 'COMPLETE:ERROR';
        END IF;

         END LOOP;
         CLOSE c_approver;
      END IF;

  IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS THEN
    IF (l_approver_type = 'FUNCTION') THEN -- was l_role_name Bug 2346128
      OPEN c_API_Name(l_object_approver_id);
      FETCH c_API_Name INTO l_pkg_name, l_proc_name;
      IF (c_Api_Name%FOUND) THEN
        dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:appr_id, :l_return_stat); END;';
        EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey, OUT l_appr_id, OUT l_return_status;

        IF(l_return_status = 'S') THEN
          l_object_approver_id := l_appr_id;
        ELSE
          Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
          );
          Handle_Err
          (p_itemtype         => itemtype   ,
          p_itemkey           => itemkey    ,
          p_msg_count         => l_msg_count, -- Number of error Messages
          p_msg_data          => l_msg_data , -- Number of error Messages
          p_attr_name         => 'AMS_ERROR_MSG',
          x_error_msg         => l_error_msg
          )               ;
          resultout := 'COMPLETE:ERROR';
        END IF;
      END IF;
      CLOSE c_API_Name;
    END IF;

    Get_User_Role(p_user_id      => l_object_approver_id ,
          x_role_name            => l_approver,
          x_role_display_name    => l_approver_display_name,
          x_return_status        => l_return_status);

    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

    l_prev_approver  := Wf_Engine.GetItemAttrText(
                itemtype => itemtype,
                itemkey  => itemkey,
                aname    => 'AMS_APPR_USERNAME' );

        /*
          wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_PREV_APPR_USERNAME',
                                    avalue   => l_prev_approver);  */

          Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPR_USERNAME',
                                    avalue   => l_approver);

          Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPR_DISPLAY_NAME',
                                    avalue   => l_approver_display_name);

          l_prev_role_name  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_ROLE' );

          Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVAL_ROLE',
                                    avalue   => l_role_name);

        /*
          wf_engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_PREV_APPROVER_ROLE',
                                    avalue   => l_prev_role_name);
         */

          Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER_ID',
                                    avalue   => l_object_approver_id);


        Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_NOTIFICATION_TYPE',
                                    avalue   => l_notification_type);

          Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_NOTIFICATION_TIMEOUT',
                                    avalue   => l_notification_timeout);

          -- 11.5.9 Update the 'Open' row to 'Pending'


          l_appr_hist_rec.object_id          := l_activity_id;
          l_appr_hist_rec.object_type_code   := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code        := 'PENDING';
          l_appr_hist_rec.approval_type      := l_approval_type;
          l_appr_hist_rec.approver_type      := l_approver_type;
          l_appr_hist_rec.sequence_num       := l_current_seq;
          l_appr_hist_rec.approver_id        := l_object_approver_id;

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
     ELSE
        RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
  END IF;

  --
  -- CANCEL mode
  --
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
           )               ;
       resultout := 'COMPLETE:ERROR';
    /*wf_core.context('Ams_Approval_Pvt',
                    'set_approval_rules',
                    itemtype, itemkey,to_char(actid),l_error_msg);
         RAISE; */
 WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'set_approval_rules',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
  --

END;

/*============================================================================*/
--Set_Further_Approvals
/*============================================================================*/
PROCEDURE Set_Further_Approvals( itemtype        IN  VARCHAR2,
                                 itemkey         IN  VARCHAR2,
                                 actid           IN  NUMBER,
                                 funcmode        IN  VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2 )
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
l_new_approver_id         NUMBER;
BEGIN
  Fnd_Msg_Pub.initialize();
  IF (funcmode = 'RUN') THEN
     l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_DETAIL_ID' );

     l_current_seq        := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_SEQ' );
     -- get the activity note
     l_note            := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NOTE' );

     l_approver_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVER_ID' );

     l_activity_id := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     -- put this later
     IF l_note IS NOT NULL THEN
       Update_Note(p_activity_type => l_activity_type,
                   p_activity_id   => l_activity_id,
                   p_note          => l_note,
                   p_user          => l_approver_id,
                   x_msg_count     => l_msg_count,
                   x_msg_data     =>  l_msg_data,
                   x_return_status => l_return_status);
     END IF;

     IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
             RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
      -- Added for 11.5.9
      l_version := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_OBJECT_VERSION_NUMBER' );

      l_approval_type := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_APPROVAL_TYPE' );
   -- Commented for Bug 3150550
     -- Start of addition for forward/reassign notification
/*
     Check_Reassigned (itemtype => itemtype,
                       itemkey  => itemkey,
                       x_approver_id => l_new_approver_id,
                       x_return_status => l_return_status);


     IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
       RAISE Fnd_Api.G_EXC_ERROR;
     END IF;


     IF l_new_approver_id IS NOT NULL THEN
       l_approver_id := l_new_approver_id;
     END IF;

    -- End of addition for forward/re-assign notification
    --End of Comment
*/
     -- Added in case of failure of get_Approval_details
     -- in case of Budget Approval. Will cause missing
     -- update target
     IF l_approver_id IS NOT NULL THEN


         -- update the record from 'PENDING' to 'APPROVED'
          l_appr_hist_rec.object_id          := l_activity_id;
          l_appr_hist_rec.object_type_code   := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code        := 'APPROVED';
          l_appr_hist_rec.approval_type      := l_approval_type;
          l_appr_hist_rec.sequence_num       := l_current_seq;
          l_appr_hist_rec.approver_id        := l_approver_id;
          l_appr_hist_rec.note               := l_note;
          l_appr_hist_rec.action_date        := sysdate;

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

      END IF;

     -- get all the activity notes
           l_all_note    := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ALL_NOTE' );

     -- NOTE another option is to get them from database and display
     -- issue : cannot distinguish from notes created by activities or budget lines
     -- option : can insert a carriage return when concatenating notes
     l_all_note := l_all_note ||l_note;

     Wf_Engine.SetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ALL_NOTE' ,
                                 avalue   => l_all_note ) ;

     -- set the note to null
     l_note := NULL;
     Wf_Engine.SetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NOTE' ,
                                 avalue   => l_note ) ;

     Check_Approval_Required
             ( p_approval_detail_id       => l_approval_detail_id,
               p_current_seq              => l_current_seq,
               x_next_seq                 => l_next_seq,
               x_required_flag            => l_required_flag);

     IF l_next_seq IS NOT NULL THEN
          Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
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
        RETURN;
  END IF;

  --
  -- TIMEOUT mode
  --
  IF (funcmode = 'TIMEOUT') THEN
        resultout := 'COMPLETE:';
        RETURN;
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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
    Wf_Core.context('Ams_Approval_Pvt',
                    'set_further_approvals',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
         RAISE;
WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'set_further_approvals',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
  --

END;

/*============================================================================*/
--Revert_Status
/*============================================================================*/

PROCEDURE Revert_Status( itemtype        IN  VARCHAR2,
                         itemkey         IN  VARCHAR2,
                         actid           IN  NUMBER,
                         funcmode        IN  VARCHAR2,
                         resultout       OUT NOCOPY VARCHAR2    )
IS
l_activity_id            NUMBER;
l_activity_type          VARCHAR2(30);
l_orig_status_id         NUMBER;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_error_msg              VARCHAR2(4000);
-- 11.5.9
l_version                NUMBER;
l_approval_type          VARCHAR2(30);

BEGIN
  Fnd_Msg_Pub.initialize();
  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_orig_status_id     := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ORIG_STAT_ID' );


     -- 11.5.9 addition
     l_version     := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_OBJECT_VERSION_NUMBER' );

     l_approval_type := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );


     -- end 11.5.9 addition

     Update_Status(p_activity_type        => l_activity_type,
                   p_activity_id          => l_activity_id,
                   p_next_stat_id         => l_orig_status_id,
                   x_return_status        => l_return_status);


    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
      RAISE Fnd_Api.G_EXC_ERROR;
      -- Delete all history rows
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

      resultout := 'COMPLETE:SUCCESS';
    END IF;
  END IF;

  --
  -- CANCEL mode
  --
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
  --

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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
       resultout := 'COMPLETE:FAILURE';

  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'Revert_status',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Revert_Status;

/*============================================================================*/
-- Approve_Activity_status
/*============================================================================*/

PROCEDURE Approve_Activity_status( itemtype        IN  VARCHAR2,
                         itemkey         IN  VARCHAR2,
                         actid           IN  NUMBER,
                         funcmode        IN  VARCHAR2,
                         resultout       OUT NOCOPY VARCHAR2    )
IS
l_activity_id            NUMBER;
l_activity_type          VARCHAR2(30);
l_orig_status_id         NUMBER;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_error_msg              VARCHAR2(4000);
BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_orig_status_id     := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NEW_STAT_ID' );


     Update_Status(p_activity_type        => l_activity_type,
                   p_activity_id          => l_activity_id,
                   p_next_stat_id         => l_orig_status_id,
                   x_return_status           => l_return_status);
    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
      resultout := 'COMPLETE:SUCCESS';
    END IF;


  END IF;

  --
  -- CANCEL mode
  --
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
  --


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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
       resultout := 'COMPLETE:ERROR';

  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'Approve_activity_status',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Approve_Activity_status;

/*============================================================================*/
-- Reject_Activity_Status
/*============================================================================*/

PROCEDURE Reject_Activity_status( itemtype        IN  VARCHAR2,
                         itemkey         IN  VARCHAR2,
                         actid           IN  NUMBER,
                         funcmode        IN  VARCHAR2,
                         resultout       OUT NOCOPY VARCHAR2    )
IS
l_activity_id            NUMBER;
l_activity_type          VARCHAR2(30);
l_orig_status_id         NUMBER;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_error_msg              VARCHAR2(4000);
-- added for 11.5.9
l_approver_seq           NUMBER;
l_version                NUMBER;
l_approver_id            NUMBER;
l_approval_detail_id     NUMBER;
l_approval_type          VARCHAR2(30);
l_note                   VARCHAR2(4000);
l_appr_hist_rec          AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
l_new_approver_id        NUMBER;
--
BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the acitvity id
     l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

     l_orig_status_id     := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_REJECT_STAT_ID' );

     -- Added by VM for 11.5.9
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
                                 aname    => 'AMS_ACTIVITY_DETAIL_ID' );

     l_approval_type := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_TYPE' );
     -- End 11.5.9


     Update_Status(p_activity_type        => l_activity_type,
                   p_activity_id          => l_activity_id,
                   p_next_stat_id         => l_orig_status_id,
                   x_return_status        => l_return_status);

    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
      RAISE Fnd_Api.G_EXC_ERROR;
    ELSE
    -- Commented for bug 3150550
      -- Start of addition for forward/reassign notification
/*
          Check_Reassigned (itemtype => itemtype,
                       itemkey  => itemkey,
                       x_approver_id   => l_new_approver_id,
                       x_return_status => l_return_status);

     IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
       RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF l_new_approver_id IS NOT NULL THEN
        l_approver_id := l_new_approver_id;
     END IF;

     -- End of addition for forward/re-assign notification
     -- End of Comment
*/
         -- update the record from 'PENDING' to 'REJECTED'
          l_appr_hist_rec.object_id          := l_activity_id;
          l_appr_hist_rec.object_type_code   := l_activity_type;
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code        := 'REJECTED';
          l_appr_hist_rec.approval_type      := l_approval_type;
          l_appr_hist_rec.sequence_num       := l_approver_seq;
          l_appr_hist_rec.note               := l_note;
          l_appr_hist_rec.action_date        := SYSDATE;

          -- should i reset approver_id-- yes
          l_appr_hist_rec.approver_id       := l_approver_id;

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

      resultout := 'COMPLETE:SUCCESS';
    END IF;
  END IF;

  --
  -- CANCEL mode
  --
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
  --


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
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg
           )               ;
       resultout := 'COMPLETE:ERROR';
     WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
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
    Wf_Core.context('Ams_Approval_Pvt',
                    'Reject_activity_status',
                    itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Reject_Activity_status;


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
             (p_itemkey          IN   VARCHAR2
             ,p_workflowprocess  IN   VARCHAR2      DEFAULT NULL
             ,p_itemtype         IN   VARCHAR2      DEFAULT NULL
             )
IS
    itemkey   VARCHAR2(30) := p_itemkey ;
    itemtype  VARCHAR2(30) := NVL(p_itemtype,'AMS_APPROVAL') ;
BEGIN
   Ams_Utility_Pvt.debug_message('Process ABORT Process');
   Wf_Engine.AbortProcess (itemtype   =>   itemtype,
                           itemkey       =>  itemkey ,
                           process       =>  p_workflowprocess);
EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.context('Ams_Approval_Pvt',
                      'AbortProcess',
                      itemtype,
                      itemkey
                      ,p_workflowprocess);
         RAISE;
END AbortProcess;
/*============================================================================*/
-- NAME
--    get_object_currency
-- PURPOSE
--    Return the currency code of the object trying to
--    associate a budget.
-- NOTE
--    To support other objects, the function will need
--    to be modified.
-- HISTORY
-- 15-Aug-2000  choang     Created.
-- 01-Sep-2000  choang     ARC qualifier for deliverables should be DELV
/*============================================================================*/

FUNCTION get_object_currency (
   p_object IN VARCHAR2,
   p_object_id IN NUMBER
)
RETURN VARCHAR2
IS
   l_currency_code      VARCHAR2(15);

   CURSOR c_campaign IS
      SELECT transaction_currency_code
      FROM   ams_campaigns_vl
      WHERE  campaign_id = p_object_id;
      /* code added by murali code done by ravi start*/
      CURSOR c_schedule IS
      SELECT transaction_currency_code
      FROM   ams_campaign_schedules_vl
      WHERE  schedule_id = p_object_id;
   CURSOR c_offer IS
      SELECT transaction_currency_code
      FROM   ozf_offers OFF
      WHERE  OFF.qp_list_header_id = p_object_id;
        /* code added by murali code done by ravi end*/
   CURSOR c_eheader IS
      SELECT currency_code_tc
      FROM   ams_event_headers_vl
      WHERE  event_header_id = p_object_id;
   CURSOR c_eoffer IS
      SELECT currency_code_tc
      FROM   ams_event_offers_vl
      WHERE  event_offer_id = p_object_id;
   CURSOR c_deliverable IS
      SELECT transaction_currency_code
      FROM   ams_deliverables_vl
      WHERE  deliverable_id = p_object_id;
   CURSOR c_fund IS
      SELECT currency_code_tc
      FROM   ozf_funds_all_vl
      WHERE  fund_id = p_object_id;
BEGIN
   -- Campaign
   IF p_object = 'CAMP' THEN
      OPEN c_campaign;
      FETCH c_campaign INTO l_currency_code;
      IF c_campaign%NOTFOUND THEN
         CLOSE c_campaign;
         Ams_Utility_Pvt.error_message ('AMS_BUDGET_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_campaign;
      /* code added by murali code done by ravi start*/
    -- Campaign Schedule
 ELSIF p_object = 'CSCH' THEN
      OPEN c_schedule;
      FETCH c_schedule INTO l_currency_code;
      IF c_schedule%NOTFOUND THEN
         CLOSE c_schedule;
         Ams_Utility_Pvt.error_message ('AMS_BUDGET_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_schedule;
   -- Offer
 ELSIF p_object = 'OFFR' THEN
      OPEN c_offer;
      FETCH c_offer INTO l_currency_code;
      IF c_offer%NOTFOUND THEN
         CLOSE c_offer;
         Ams_Utility_Pvt.error_message ('AMS_BUDGET_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_offer;
      /* code added by murali code done by ravi end*/
   -- Event Header/Rollup Event
   ELSIF p_object = 'EVEH' THEN
      OPEN c_eheader;
      FETCH c_eheader INTO l_currency_code;
      IF c_eheader%NOTFOUND THEN
         CLOSE c_eheader;
         Ams_Utility_Pvt.error_message ('AMS_BUDGET_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_eheader;
   -- Event Offer/Execution Event
   ELSIF (p_object = 'EVEO' OR p_object = 'EONE')THEN
      OPEN c_eoffer;
      FETCH c_eoffer INTO l_currency_code;
      IF c_eoffer%NOTFOUND THEN
         CLOSE c_eoffer;
         Ams_Utility_Pvt.error_message ('AMS_BUDGET_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_eoffer;
   -- Deliverable
   ELSIF p_object = 'DELV' THEN
      OPEN c_deliverable;
      FETCH c_deliverable INTO l_currency_code;
      IF c_deliverable%NOTFOUND THEN
         CLOSE c_deliverable;
         Ams_Utility_Pvt.error_message ('AMS_ACT_BUDG_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_deliverable;
   ELSIF p_object = 'FUND' THEN
      OPEN c_fund;
      FETCH c_fund INTO l_currency_code;
      IF c_fund%NOTFOUND THEN
         CLOSE c_fund;
         Ams_Utility_Pvt.error_message ('AMS_ACT_BUDG_NO_OWNER');
         RAISE Fnd_Api.g_exc_error;
      END IF;
      CLOSE c_fund;
   ELSE
      RAISE Fnd_Api.g_exc_unexpected_error;
   END IF;

   RETURN l_currency_code;
EXCEPTION
   WHEN OTHERS THEN
      IF c_campaign%ISOPEN THEN
         CLOSE c_campaign;
      END IF;
      IF c_eheader%ISOPEN THEN
         CLOSE c_eheader;
      END IF;
      IF c_eoffer%ISOPEN THEN
         CLOSE c_eoffer;
      END IF;
      IF c_deliverable%ISOPEN THEN
         CLOSE c_deliverable;
      END IF;
      IF c_fund%ISOPEN THEN
         CLOSE c_fund;
      END IF;
      RAISE;
END get_object_currency;

/*============================================================================*/
-- Start_Process
/*============================================================================*/

PROCEDURE Start_Process(
     p_requestor_id               IN  NUMBER,
     p_act_budget_id              IN  NUMBER,
     p_orig_stat_id               IN  NUMBER,
     p_new_stat_id                IN  NUMBER,
     p_rejected_stat_id           IN  NUMBER,
     p_parent_process_flag        IN  VARCHAR2,
     p_parent_process_key         IN  VARCHAR2,
     p_parent_context             IN  VARCHAR2,
     p_parent_approval_flag       IN  VARCHAR2,
     p_continue_flow              IN  VARCHAR2
)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Start_Process';
  l_itemtype            VARCHAR2(30) := G_ITEMTYPE;
  l_itemkey             VARCHAR2(80);
  l_itemuserkey         VARCHAR2(80);
  l_process             VARCHAR2(80) := 'AMS_LINE_APPROVAL';
  l_owner               VARCHAR2(100); --l_owner          VARCHAR2(80);--SVEERAVE,04/10/02
  l_requestor_name      VARCHAR2(320);-- was 100  VARCHAR2(30);--SVEERAVE,04/10/02
  l_version             NUMBER;
  l_activity_detail_id  NUMBER;
  l_approver_seq        NUMBER;
  l_approver_obj ObjRecTyp;
  l_parent_object_details       ObjRecTyp;
  l_object_details       ObjRecTyp;

  l_parent_amount       NUMBER;
  l_budget_id           NUMBER;
  l_budget_type         VARCHAR2(30);
  l_activity_id         NUMBER;
  l_activity_type       VARCHAR2(30);
  l_request_amount      NUMBER;
  l_request_currency    VARCHAR2(30);
  l_budget_amount       NUMBER;
  l_budget_currency     VARCHAR2(30);
  l_appr_meaning        VARCHAR2(240);
  l_return_status       VARCHAR2(30);
  l_requestor_display_name VARCHAR2(360); -- was 80

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(4000);
  l_error_msg           VARCHAR2(4000);
  l_full_name           VARCHAR2(360); --l_full_name   VARCHAR2(60); -- SVEERAVE, 04/10/02
  l_justification_text  VARCHAR2(2000);

  -- 11.5.9
  l_appr_hist_rec       AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;

  -- [BEGIN OF BUG2741039 FIXING by vmodur 09-Jan-2003]
    l_user_id                NUMBER;
    l_resp_id                NUMBER;
    l_appl_id                NUMBER;
    l_security_group_id      NUMBER;
  -- [END OF BUG2741039 FIXING]

  CURSOR      budget_lines_csr IS
    SELECT      budget_source_id
      , budget_source_type
      , act_budget_used_by_id
      , arc_act_budget_used_by
      , request_amount
      , request_currency
      , object_version_number
      , src_curr_request_amt -- Added Bug 3729490
    FROM    ozf_act_budgets
    WHERE   activity_budget_id = p_act_budget_id;

  CURSOR justification_text_csr(id_in IN NUMBER) IS
    SELECT notes
    FROM jtf_notes_vl
    WHERE source_object_code = 'AMS_FREQ'
    AND note_type = 'AMS_JUSTIFICATION'
    AND source_object_id = id_in;

BEGIN

  Fnd_Msg_Pub.initialize();

     -- Delete any previous approval history rows Bug 2761026

   AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
	     p_object_id          => p_act_budget_id,
             p_object_type_code   => 'FUND',
             p_sequence_num       => null,
	     p_action_code        => null,
             p_object_version_num => null,
             p_approval_type      => 'BUDGET');

	   IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
	     RAISE Fnd_Api.G_EXC_ERROR;
	   END IF;

  -- get the budget line ids
  OPEN budget_lines_csr;
  FETCH budget_lines_csr INTO l_budget_id, l_budget_type,
                          l_activity_id, l_activity_type,
                          l_request_amount, l_request_currency,
                          l_version, l_budget_amount;
  IF budget_lines_csr%NOTFOUND THEN
    CLOSE budget_lines_csr;
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
  CLOSE budget_lines_csr;

     -- set the itemkey and itemuserkey
  IF p_parent_process_flag = Fnd_Api.G_TRUE THEN
       -- for process started from a parent process
    l_itemkey := p_act_budget_id||'_'||p_parent_process_key;
    l_itemuserkey := l_activity_id||'_'||l_budget_id||'_'||p_parent_process_key;
  ELSE
      -- for a standalone process
    l_itemkey := p_act_budget_id||'_'||l_version;
    l_itemuserkey := l_activity_id||'_'||l_budget_id||'_'||l_version;
  END IF;

       -- create a new process
       --
  Wf_Engine.CreateProcess(ItemType => l_itemtype,
                          ItemKey  => l_itemkey,
                          process  => l_process );

     -- set the user key for process
     --
  Wf_Engine.SetItemUserKey(ItemType => l_itemtype,
                           ItemKey => l_itemkey,
                           UserKey => l_itemuserkey);

  -- 09-Jan-2003  VMODUR  Fix for BUG 2741039 - add pl/sql global context into
  --                      workflow item attribute.It could be used later on for
  --                      PL/SQL function to initialize the global context when the
  --                      session is established by workflow mailer.

   l_user_id := FND_GLOBAL.user_id;
   l_resp_id := FND_GLOBAL.resp_id;
   l_appl_id := FND_GLOBAL.resp_appl_id;
   l_security_group_id := FND_GLOBAL.security_group_id;

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  l_itemtype ,
                               itemkey    =>  l_itemkey,
                               aname      =>  'USER_ID',
                               avalue     =>  l_user_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  l_itemtype ,
                               itemkey    =>  l_itemkey,
                               aname      =>  'RESPONSIBILITY_ID',
                               avalue     =>  l_resp_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  l_itemtype ,
                               itemkey    =>  l_itemkey,
                               aname      =>  'APPLICATION_ID',
                               avalue     =>  l_appl_id
                              );

   WF_ENGINE.SetItemAttrNumber(itemtype   =>  l_itemtype ,
                               itemkey    =>  l_itemkey,
                               aname      =>  'SECURITY_GROUP_ID',
                               avalue     =>  l_security_group_id
                              );
  -- [END OF BUG2741039 FIXING]

     -- set the parent  item
     --
  IF p_parent_process_flag = Fnd_Api.G_TRUE THEN
        -- set parent
    Wf_Engine.SetItemParent(itemtype      =>l_itemtype,
                            itemkey      => l_itemkey,
                            parent_itemtype  => l_itemtype,
                            parent_itemkey   => p_parent_process_key,
                            parent_context   => p_parent_context );

          -- get parent amount
    l_parent_amount := Wf_Engine.GetItemAttrNumber(
                                           itemtype => l_itemtype,
                                           itemkey  => p_parent_process_key,
                                           aname    => 'AMS_ACTIVITY_AMOUNT' );

       --
    Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                                itemkey   => l_itemkey,
                                aname     => 'AMS_ACTIVITY_AMOUNT',
                                avalue    => l_parent_amount);

  END IF;

  OPEN justification_text_csr(p_act_budget_id);
  FETCH justification_text_csr INTO l_justification_text;
  CLOSE justification_text_csr;

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                                    itemkey   => l_itemkey,
                                    aname     => 'AMS_JUSTIFICATION',
                                    avalue    => l_justification_text);

  Get_Activity_Details
        ( p_activity_type      => l_activity_type,
          p_activity_id        => l_activity_id,
          x_object_details     => l_parent_object_details,
          x_return_status      => l_return_status);
  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_ACT_NAME',
                            avalue    => l_parent_object_details.name);

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_START_DATE',
                            avalue    => l_parent_object_details.start_date);


  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_END_DATE',
                            avalue    => l_parent_object_details.end_date);
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_ACTIVITY_DESCRIPTION',
                            avalue    => l_parent_object_details.description);
     -- Changed Priority code to meaning
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   =>l_itemkey,
                            aname     => 'AMS_PRIORITY',
                            avalue    => l_parent_object_details.priority_desc);
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_ACTIVITY_CURRENCY',
                            avalue    => l_parent_object_details.currency);
        --
        --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_ACTIVITY_AMOUNT',
                              avalue    =>
                              l_parent_object_details.total_header_amount);
			      --Version Number Added for 11.5.9
Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_OBJECT_VERSION_NUMBER',
                              avalue    =>  l_version);
			      -- End add of addition
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_SOURCE_CODE',
                            avalue    => l_parent_object_details.source_code);

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_PARENT_SOURCE_CODE',
                            avalue    => l_parent_object_details.parent_source_code);

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_PARENT_OBJECT',
                            avalue    => l_parent_object_details.parent_name);

  Ams_Utility_Pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                      l_activity_type,
                                      l_return_status,
                                      l_appr_meaning);

  --  check for description of activity
  Wf_Engine.SetItemAttrText(itemtype =>  l_itemtype ,
                            itemkey    =>  l_itemkey,
                            aname      =>  'AMS_APPROVAL_OBJECT_MEANING',
                            avalue     =>  l_appr_meaning  );
  Get_User_Name
          ( p_user_id            => l_parent_object_details.owner_id,
            x_full_name          => l_full_name,
            x_return_status      => l_return_status );

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                                    itemkey   => l_itemkey,
                                    aname     => 'AMS_ACTIVITY_OWNER',
                                    avalue    => l_full_name );

  IF p_parent_approval_flag = Fnd_Api.G_TRUE THEN
         --
    Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_CONTINUEFLOW',
                              avalue    => 'CONTINUEFLOW-1');
  END IF;

  -- set othet attributes required for lines approval
  --
  Wf_Engine.SetItemAttrNumber(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AMS_ACT_BUDGET_ID',
                              avalue   => p_act_budget_id);
      --
  Wf_Engine.SetItemAttrNumber(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AMS_LINE_ORIG_STAT_ID',
                              avalue   => p_orig_stat_id);
      --
  Wf_Engine.SetItemAttrNumber(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AMS_LINE_NEW_STAT_ID',
                              avalue   => p_new_stat_id);
      --
  Wf_Engine.SetItemAttrNumber(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => 'AMS_LINE_REJECT_STAT_ID',
                              avalue   => p_rejected_stat_id);
       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_ACTIVITY_ID',
                              avalue    => l_activity_id);
       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_ACTIVITY_TYPE',
                            avalue    => l_activity_type);
       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_BUDGET_ID',
                              avalue    => l_budget_id);
       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_BUDGET_TYPE',
                            avalue    => l_budget_type);
       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_PARENT_WAITING',
                            avalue    => p_parent_process_flag);
       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_PARENT_ITEMKEY',
                            avalue    => p_parent_process_key);
       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_PARENT_APPROVED',
                            avalue    => p_parent_approval_flag);

       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_CONTINUE_FLOW',
                            avalue    => p_continue_flow);

  Get_User_Role(p_user_id      => p_requestor_id,
                x_role_name         => l_requestor_name,
                x_role_display_name => l_requestor_display_name ,
                x_return_status        => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

       --
  Wf_Engine.SetItemAttrNumber(  itemtype  => l_itemtype,
                                    itemkey   => l_itemkey,
                                    aname     => 'AMS_REQUESTER_ID',
                                    avalue    => p_requestor_id);

       --
  Wf_Engine.SetItemAttrText(  itemtype  => l_itemtype,
                                    itemkey   => l_itemkey,
                                    aname     => 'AMS_REQUESTER',
                                    avalue    => l_requestor_name);

     -- Get more details for the current activity
  BEGIN
    Get_Approval_Details (
          p_activity_id          => l_budget_id,
          p_activity_type        => l_budget_type,
          p_act_budget_id        => p_act_budget_id,
          x_object_details       => l_object_details,
          x_approval_detail_id   => l_activity_detail_id,
          x_approver_seq         => l_approver_seq,
          x_return_status        => l_return_status );
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
      Fnd_Message.Set_Token('ROW', SQLERRM );
      Fnd_Msg_Pub.ADD;
      RAISE Fnd_Api.G_EXC_ERROR;
  END;

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

  l_budget_currency := get_object_currency(l_budget_type, l_budget_id);

 /*  Bug 3729490 Fix -- Don't recompute always. Get from ozf_act_budgets
                         SRC_CURR_REQUEST_AMT. If that is null for some
                         reason then convert
   */

    IF l_budget_amount IS NULL THEN
     -- convert budget line amount to transaction currency of the source
    Ams_Utility_Pvt.Convert_Currency (
          p_from_currency      => l_request_currency,
          p_to_currency        => l_budget_currency,
          p_from_amount        => l_request_amount,
          x_to_amount          => l_budget_amount,
          x_return_status      => l_return_status );

    END IF;

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  END IF;

       --
     /*
       wf_engine.SetItemAttrText(itemtype  => l_itemtype,
                                    itemkey   => l_itemkey,
                                    aname     => 'AMS_ACT_NAME',
                                    avalue    => l_approver_obj.name);
       */

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_BUDGET_NAME',
                            avalue    => l_object_details.name);

  Get_User_Name
          ( p_user_id            => l_object_details.owner_id,
            x_full_name          => l_full_name,
            x_return_status      => l_return_status );

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_BUDGET_OWNER',
                            avalue    => l_full_name );

  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_BUDGET_CURRENCY',
                            avalue    => l_budget_currency);

  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_BUDGET_AMOUNT',
                              avalue    => l_request_amount);
       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_BUDGET_AMOUNT_CONV',
                              avalue    => l_budget_amount);

       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_APPROVED_LINE_AMOUNT',
                              avalue    => l_budget_amount);

       --
  Wf_Engine.SetItemAttrText(itemtype  => l_itemtype,
                            itemkey   => l_itemkey,
                            aname     => 'AMS_CURRENCY',
                            avalue    => l_budget_currency);

       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_APPROVER_SEQ',
                              avalue    => l_approver_seq);

       --
  Wf_Engine.SetItemAttrNumber(itemtype  => l_itemtype,
                              itemkey   => l_itemkey,
                              aname     => 'AMS_ACTIVITY_DETAIL_ID',
                              avalue    => l_activity_detail_id);

/*
        ams_utility_pvt.get_lookup_meaning( 'AMS_SYS_ARC_QUALIFIER',
                                      l_budget_type,
                                      l_return_status,
                                      l_appr_meaning);

         --  check for description of activity
         wf_engine.SetItemAttrText(itemtype =>  l_itemtype ,
                            itemkey    =>  l_itemkey,
                            aname      =>  'AMS_APPROVAL_OBJECT_MEANING',
                            avalue     =>  l_appr_meaning  );
*/

  Wf_Engine.SetItemAttrText(itemtype =>  l_itemtype ,
                            itemkey    =>  l_itemkey,
                            aname      =>  'AMS_APPROVAL_TYPE',
                            avalue     =>  'BUDGET'  );

     -- set the process owner
       --
     -- owner of the process
  l_owner := l_requestor_name;

  Wf_Engine.SetItemOwner(itemtype =>l_itemtype,
                         itemkey => l_itemkey,
                         owner   => l_owner );

     -- start the process
       --
  Wf_Engine.StartProcess(itemtype => l_itemtype,
                         itemkey  => l_itemkey );


   l_appr_hist_rec.object_id          := p_act_budget_id;
   l_appr_hist_rec.object_type_code   := 'FUND';
   l_appr_hist_rec.sequence_num       := 0;
   l_appr_hist_rec.object_version_num := l_version;
   l_appr_hist_rec.action_code        := 'SUBMITTED';
   l_appr_hist_rec.action_date        := sysdate;
   l_appr_hist_rec.approver_id        := p_requestor_id;
   l_appr_hist_rec.note               := l_justification_text;
   l_appr_hist_rec.approval_detail_id := l_activity_detail_id;
   l_appr_hist_rec.approval_type      := 'BUDGET';
   l_appr_hist_rec.approver_type      := 'USER';
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

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
     -- raise error if not able to get the budget line
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
      Fnd_Message.set_name('AMS', 'AMS_BUDGET_LINE_START_ERROR');
      Fnd_Msg_Pub.ADD;
    END IF;

    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context ('Ams_Approval_Pvt', 'Start_Process',
                 l_budget_type ,l_budget_id ,l_error_msg);
    RAISE;
  WHEN OTHERS THEN
    IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
    THEN
      Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
          (p_itemtype          => l_itemtype   ,
           p_itemkey           => l_itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
    Wf_Core.context ('Ams_Approval_Pvt', 'Start_Process',
                 l_budget_type ,l_budget_id ,l_error_msg);
    RAISE;
--
END Start_Process;

/*============================================================================*/
--
-- Procedure
--      Start_LineApproval
--
-- Description
--      get details of budget line(s)
-- IN
--   p_act_budget_id          - act budget line identifier
--   p_parent_process_flag       - parent process exists flag
--   p_parent_process_key        - parent process itemkey
--   p_parent_context           - parent context
--   p_parent_approval_flag      - parent process approved flag
--
/*============================================================================*/

PROCEDURE Start_LineApproval(
    p_api_version                 IN  NUMBER
   ,p_init_msg_list               IN  VARCHAR2 := Fnd_Api.G_FALSE
   ,p_commit                      IN  VARCHAR2 := Fnd_Api.G_FALSE
   ,p_validation_level            IN  NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL

   ,x_return_status               OUT NOCOPY VARCHAR2
   ,x_msg_data                    OUT NOCOPY VARCHAR2
   ,x_msg_count                   OUT NOCOPY NUMBER

   ,p_user_id                      IN  NUMBER
   ,p_act_budget_id                IN  NUMBER
   ,p_orig_status_id               IN  NUMBER
   ,p_new_status_id                IN  NUMBER
   ,p_rejected_status_id           IN  NUMBER
   ,p_parent_process_flag          IN  VARCHAR2 := Fnd_Api.G_FALSE
   ,p_parent_process_key           IN  VARCHAR2  -- was g_miss_char
   ,p_parent_context               IN  VARCHAR2  -- was g_miss_char
   ,p_parent_approval_flag         IN  VARCHAR2 := Fnd_Api.G_FALSE
   ,p_continue_flow                IN  VARCHAR2 := Fnd_Api.G_FALSE
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_LineApproval';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_resource_id       NUMBER;
l_user_id           NUMBER;
l_login_user_id     NUMBER;
l_login_user_status      VARCHAR2(30);
l_Error_Msg              VARCHAR2(2000);
l_Error_Token            VARCHAR2(80);
l_object_version_number  NUMBER := 1;
--
BEGIN
     -- Standard begin of API savepoint
     SAVEPOINT  Start_LineApproval_PVT;
     -- Standard call to check for call compatibility.
     IF NOT Fnd_Api.Compatible_API_Call (
          l_api_version,
          p_api_version,
          l_api_name,
          G_PKG_NAME)
     THEN
          RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END IF;
     -- Debug Message
     IF Fnd_Msg_Pub.Check_Msg_level (Fnd_Msg_Pub.G_MSG_LVL_DEBUG_LOW) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',l_full_name||': START');
          Fnd_Msg_Pub.ADD;
     END IF;
     --Initialize message list if p_init_msg_list is TRUE.
     IF Fnd_Api.To_Boolean (p_init_msg_list) THEN
          Fnd_Msg_Pub.initialize;
     END IF;
     -- Initialize API return status to sucess
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      BEGIN
          -- kickoff workflow processes for a line
          Start_Process (
               p_requestor_id            => p_user_id,
               p_act_budget_id           => p_act_budget_id,
               p_orig_stat_id            => p_orig_status_id,
               p_new_stat_id             => p_new_status_id,
               p_rejected_stat_id        => p_rejected_status_id,
               p_parent_process_flag     => p_parent_process_flag,
               p_parent_process_key      => p_parent_process_key,
               p_parent_context          => p_parent_context,
               p_parent_approval_flag    => p_parent_approval_flag,
               p_continue_flow           => p_continue_flow );
     EXCEPTION
          WHEN OTHERS THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
     END;

     --Standard check of commit
     IF Fnd_Api.To_Boolean ( p_commit ) THEN
          COMMIT WORK;
     END IF;
     -- Debug Message
     IF Fnd_Msg_Pub.Check_Msg_level (Fnd_Msg_Pub.G_MSG_LVL_DEBUG_LOW) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',l_full_name||': END');
          Fnd_Msg_Pub.ADD;
     END IF;
     --Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
          p_encoded => Fnd_Api.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
     );
EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
          ROLLBACK TO  Start_LineApproval_PVT;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          -- Standard call to get message count and if count=1, get the message
          Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
          );
     WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO  Start_LineApproval_PVT;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          -- Standard call to get message count and if count=1, get the message
          Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
          );
     WHEN OTHERS THEN
          ROLLBACK TO  Start_LineApproval_PVT;
          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
          THEN
               Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          Fnd_Msg_Pub.Count_And_Get (
               p_encoded => Fnd_Api.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
          );
--
END Start_LineApproval;

/*============================================================================*/
--
-- Procedure
--   Start_Line_Approval
--
--   Workflow cover: Get line details for an activity and start process for lines not acted on
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's PRIMARY KEY.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_START_LINE_APPROVAL
--
/*============================================================================*/

PROCEDURE Start_Line_Approval( itemtype  IN  VARCHAR2,
                              itemkey    IN  VARCHAR2,
                              actid      IN  NUMBER,
                              funcmode   IN  VARCHAR2,
                              resultout  OUT NOCOPY VARCHAR2    )
IS
--
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(4000);
l_msg_count         NUMBER;
l_error_msg         VARCHAR2(4000);
--
l_approval_amount   NUMBER;
l_activity_type     VARCHAR2(30);
l_activity_id       NUMBER;
l_act_budget_id     NUMBER;

l_requestor_id      NUMBER;
l_context           VARCHAR2(240);
l_approval_flag     VARCHAR2(30);
l_continue_flow     VARCHAR2(30);
l_object_version_number  NUMBER;

l_budget_rec          Ozf_Actbudgets_Pvt.Act_Budgets_Rec_Type;
/* New cursor Definition */
CURSOR planned_lines_csr(p_id in NUMBER, p_type in VARCHAR2) IS
  select activity_budget_id, object_version_number
  from   ozf_act_budgets
  where  act_budget_used_by_id = p_id
  and    arc_act_budget_used_by = p_type
  and    status_code = 'NEW'
  AND    transfer_type = 'REQUEST' ;

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     --resultout := 'COMPLETE:ERROR';

     -- get the activity id
       l_approval_amount := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_ACTIVITY_AMOUNT' );

     -- get the activity id
       l_activity_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_ID' );

     -- get the activity type
       l_activity_type := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_TYPE' );

     -- get the requestor id
       l_requestor_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_REQUESTER_ID' );

         -- check if activity meets the approval condition
       Get_Approval_Rules( p_activity_type  => l_activity_type ,
                          p_activity_id        => l_activity_id,
                          p_activity_amount    => l_approval_amount,
                          x_approved_flag      => l_approval_flag );

     -- set the parent context
     l_context := itemtype||':'||itemkey||':'||actid;

     -- set continue to true for first line if approval rule already met
     IF l_approval_flag = Fnd_Api.G_TRUE THEN
          l_continue_flow := Fnd_Api.G_TRUE;
     ELSE
          l_continue_flow := Fnd_Api.G_FALSE;
     END IF;

     -- get all planned budget lines
     OPEN planned_lines_csr(l_activity_id, l_activity_type);
      LOOP
        FETCH planned_lines_csr INTO  l_act_budget_id,l_object_version_number ;
        IF planned_lines_csr%NOTFOUND THEN
	   EXIT;
	END IF;
          -- process each line
          BEGIN
                  Ozf_Actbudgets_Pvt.Init_Act_Budgets_Rec(l_budget_rec);

               l_budget_rec.activity_budget_id := l_act_budget_id;
               l_budget_rec.status_code := 'APPROVED';
--following block of code added for mumu  start
             l_budget_rec.user_status_id := Ams_Utility_Pvt.get_default_user_status (
                                                             'OZF_BUDGETSOURCE_STATUS',
                                                             l_budget_rec.status_code
                                                              );
  l_budget_rec.object_version_number := l_object_version_number;
--following block of code added for mumu  END
/* following code commented by mumu
                  AMS_ActBudgets_PVT.Complete_Act_Budgets_Rec(l_budget_rec,
                                            l_budget_rec );
*/
               -- start process for each lines activity lines for approval
                  Ozf_Actbudgets_Pvt.Update_Act_Budgets (
                     p_api_version             => 1.0,
                     p_init_msg_list           => Fnd_Api.G_FALSE,
                     p_commit                  => Fnd_Api.G_FALSE,
                     p_validation_level        => Fnd_Api.G_VALID_LEVEL_FULL,
                     x_return_status           => l_return_status,
                     x_msg_count               => l_msg_count,
                     x_msg_data                => l_msg_data,
                     p_act_Budgets_rec         => l_budget_rec,
                     p_parent_process_flag     => Fnd_Api.G_TRUE,
                     p_parent_process_key      => itemkey,
                     p_parent_context          => l_context,
                     p_parent_approval_flag    => l_approval_flag,
                     p_continue_flow           => l_continue_flow );

               IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
           --resultout := 'COMPLETE:ERROR';
                    -- raise exception
                   RAISE Fnd_Api.G_EXC_ERROR;
               END IF;

          EXCEPTION
             WHEN OTHERS THEN
	       -- Commented for Bug 2485371
               --Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
               --Fnd_Message.Set_Token('ROW', SQLERRM );
               --Fnd_Msg_Pub.ADD;
               RAISE Fnd_Api.G_EXC_ERROR;
               Fnd_Msg_Pub.Count_And_Get (
                             p_encoded => Fnd_Api.G_FALSE,
                             p_count => l_msg_count,
                             p_data  => l_msg_data);
               Handle_Err
                    (p_itemtype          => itemtype   ,
                     p_itemkey           => itemkey    ,
                     p_msg_count         => l_msg_count,
                     p_msg_data          => l_msg_data ,
                     p_attr_name         => 'AMS_ERROR_MSG',
                     x_error_msg         => l_error_msg);
          END;

          -- set continue flow for consequtive lines to false
          l_continue_flow := Fnd_Api.G_FALSE;
       END LOOP;
     CLOSE planned_lines_csr;

     resultout := 'COMPLETE:SUCCESS';
     RETURN;
  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
     -- raise error if not able to get the budget line
        -- Commented for Bug 2485371
        --IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
        --  Fnd_Message.set_name('AMS', 'AMS_BUDGET_LINE_UPDATE_ERROR');
        --  Fnd_Msg_Pub.ADD;
        --END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
    resultout := 'COMPLETE:ERROR';
/*        wf_core.context('AMS_APPROVAL_PVT',
                        'Start_Line_Approval',
                        itemtype, itemkey,to_char(actid),l_error_msg);
        RAISE;
    */
  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Start_Line_Approval',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  --
END Start_Line_Approval;

/*============================================================================*/
--
-- Procedure
--   Get_Line_Approver_Details
--
--   Workflow cover: Get and set the details for a budget line to start approval process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' After getting line approver details
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_GET_LINE_DETAILS
--
/*============================================================================*/

PROCEDURE Get_Line_Approver_Details( itemtype        IN  VARCHAR2,
                           itemkey         IN  VARCHAR2,
                           actid           IN  NUMBER,
                           funcmode        IN  VARCHAR2,
                           resultout       OUT NOCOPY VARCHAR2    )
IS
  l_approval_detail_id    NUMBER;
  l_budget_type           VARCHAR2(30);
  l_budget_id             NUMBER;
  l_current_seq           NUMBER;
  l_approver_id           NUMBER; --l_approver_id          VARCHAR2(30);--SVEERAVE,04/10/02
  l_approver              VARCHAR2(320); -- Was 100  VARCHAR2(30);--SVEERAVE,04/10/02
  l_approver_display_name VARCHAR2(360); -- Was 240
  l_notification_type     VARCHAR2(30);
  l_notification_timeout  NUMBER;
  l_approver_type         VARCHAR2(30);
  l_object_approver_id    NUMBER; --l_object_approver     VARCHAR2(30); --SVEERAVE,04/10/02
  l_role_name             VARCHAR2(100); --l_role_name           VARCHAR2(30);--SVEERAVE,04/10/02
  l_prev_role_name        VARCHAR2(100);--l_prev_role_name        VARCHAR2(30); --SVEERAVE,04/10/02
  l_return_status         VARCHAR2(1);
  l_msg_data              VARCHAR2(4000);
  l_msg_count             NUMBER;
  l_error_msg             VARCHAR2(4000);
  l_note                  VARCHAR2(4000);
  l_all_note              VARCHAR2(4000);
  l_activity_type         VARCHAR2(30);
  l_activity_id           NUMBER;
  dml_str                 VARCHAR2(2000);
  l_pkg_name              varchar2(80);
  l_proc_name             varchar2(80);
  l_appr_id               NUMBER;
  -- 11.5.9
  l_appr_seq              NUMBER;
  l_appr_type             VARCHAR2(30);
  l_obj_appr_id           NUMBER;
  l_act_budget_id         NUMBER;
  l_version               NUMBER;
  l_appr_hist_rec         AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;

CURSOR c_API_Name (rule_id_in IN NUMBER) is
SELECT package_name, procedure_name
FROM ams_object_rules_b
WHERE OBJECT_RULE_ID = rule_id_in;

-- 11.5.9
CURSOR c_approver(rule_id IN NUMBER) IS
SELECT approver_seq, approver_type, object_approver_id
FROM ams_approvers
WHERE ams_approval_detail_id = rule_id
AND  active_flag = 'Y'
AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active,SYSDATE -1 ))
AND TRUNC(NVL(end_date_active,SYSDATE + 1));

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the approval detail id
    l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_ACTIVITY_DETAIL_ID'
                                  );
     -- get the budget type
    l_current_seq := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_APPROVER_SEQ'
                                  );

      -- get the details for current approver
      Get_Approver_Info(p_approval_detail_id      => l_approval_detail_id,
                 p_current_seq           => l_current_seq,
                 x_approver_id           => l_approver_id,
                 x_approver_type         => l_approver_type,
                 x_role_name             => l_role_name,
                 x_object_approver_id    => l_object_approver_id, --l_object_approver,
                 x_notification_type     => l_notification_type,
                 x_notification_timeout  => l_notification_timeout,
                 x_return_status         => l_return_status
                 );

      IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          -- raise error
        Fnd_Msg_Pub.Count_And_Get(p_encoded => Fnd_Api.G_FALSE,
                                  p_count => l_msg_count,
                                  p_data  => l_msg_data);

        Handle_Err (p_itemtype => itemtype   ,
          p_itemkey           => itemkey    ,
          p_msg_count         => l_msg_count, -- Number of error Messages
          p_msg_data          => l_msg_data ,
          p_attr_name         => 'AMS_ERROR_MSG',
          x_error_msg         => l_error_msg
        );
        resultout := 'COMPLETE:ERROR';
        RETURN;
      END IF;

       	-- 11.5.9
         -- Get the Activity Budget Id
	 l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_ACT_BUDGET_ID'
                                  );

	 l_version := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_OBJECT_VERSION_NUMBER'
                                  );

       -- Bug 2835488 Fix similar to 2729108
       IF l_current_seq = 1 OR
        Is_Min_Sequence(l_approval_detail_id, l_current_seq) THEN

	 -- Set Record Attributes that won't change for each approver
         l_appr_hist_rec.object_id          := l_act_budget_id;
	 l_appr_hist_rec.object_type_code   := 'FUND';
         l_appr_hist_rec.object_version_num := l_version;
         l_appr_hist_rec.action_code        := 'OPEN';
         l_appr_hist_rec.approval_type      := 'BUDGET';
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

         IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
	   CLOSE c_approver;
           RAISE Fnd_Api.G_EXC_ERROR;
         END IF;

	 END LOOP;
         CLOSE c_approver;
       END IF;

   -- in case of functions, object_approver_id is the object_rule_id, and not resource/role id.
   -- and hence function needs to be executed, which should return resource_id
   -- and this is populated back into object_approver_id
   -- This block of code was added by VMODUR for Bug 2390070

         IF (l_approver_type = 'FUNCTION') then
                   OPEN c_API_Name(l_object_approver_id);
                   FETCH c_API_Name INTO l_pkg_name, l_proc_name;
                   IF (c_Api_Name%FOUND) THEN
                        dml_str := 'BEGIN ' || l_pkg_name||'.'||l_proc_name||'(:itemtype,:itemkey,:appr_id, :l_return_stat); END;';
                        EXECUTE IMMEDIATE dml_str USING IN itemtype,IN itemkey, OUT l_appr_id, OUT l_return_status;

                        IF (l_return_status = 'S') THEN
                          l_object_approver_id := l_appr_id;
                        ELSE
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
                          x_error_msg         => l_error_msg);

                          resultout := 'COMPLETE:ERROR';
                          return;
                        END IF;
                   END IF;
                   CLOSE c_API_Name;
         END IF;
  -- End of Addition

      -- Setting up the role
      Get_User_Role
          (p_user_id             => l_object_approver_id,-- l_object_approver,
          x_role_name            => l_approver,
          x_role_display_name    => l_approver_display_name,
          x_return_status        => l_return_status
          );

      IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      l_prev_role_name  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_APPROVAL_ROLE' );

      Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVAL_ROLE',
                                    avalue   => l_role_name);

     -- get the activity id
    l_activity_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'AMS_ACTIVITY_ID' );

     -- get the activity type
    l_activity_type := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_ACTIVITY_TYPE' );

          -- get the activity note
    l_note  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NOTE' );

    IF l_note IS NOT NULL THEN
      Update_Note(
             p_activity_type => l_activity_type,
             p_activity_id   => l_activity_id,
             p_note          => l_note,
             p_user          => l_object_approver_id ,--l_object_approver,
             x_msg_count     => l_msg_count,
             x_msg_data     =>  l_msg_data,
             x_return_status => l_return_status);
    END IF;

    IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
             RAISE Fnd_Api.G_EXC_ERROR;
    END IF;

          -- get all the budget line notes
    l_all_note    := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ALL_NOTE' );

          -- NOTE another option is to get them from database and display
          -- issue : cannot distinguish from notes created by activities or budget lines
     -- option : can insert a carriage return when concaniting notes
    l_all_note := l_all_note || l_note;

    Wf_Engine.SetItemAttrText( itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'AMS_ALL_NOTE' ,
                     avalue   => l_all_note ) ;

    -- set the note to null
    l_note := NULL;
    Wf_Engine.SetItemAttrText( itemtype => itemtype,
                     itemkey  => itemkey,
                     aname    => 'AMS_NOTE' ,
                     avalue   => l_note ) ;

    Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPROVER_ID',
                                    avalue   => l_object_approver_id);
                                    --avalue   => l_object_approver);

    -- Changed by VMODUR from l_approver to l_approver_display_name
    -- Unchanged
    Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPR_USERNAME',
                                    avalue   => l_approver);

    Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_APPR_DISPLAY_NAME',
                                    avalue   => l_approver_display_name);

    Wf_Engine.SetItemAttrText(  itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_NOTIFICATION_TYPE',
                                    avalue   => l_notification_type);

    Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'AMS_NOTIFICATION_TIMEOUT',
                                    avalue   => l_notification_timeout);

          -- 11.5.9 Update the 'Open' row to 'Pending'

          l_appr_hist_rec.object_id := l_act_budget_id;
	  l_appr_hist_rec.object_type_code := 'FUND';
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code := 'PENDING';
          l_appr_hist_rec.approval_type := 'BUDGET';
	  l_appr_hist_rec.approver_type := l_approver_type;
	  l_appr_hist_rec.sequence_num  := l_current_seq;
          l_appr_hist_rec.approver_id   := l_object_approver_id;


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
    RETURN;
  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
        (p_itemtype          => itemtype   ,
        p_itemkey           => itemkey    ,
        p_msg_count         => l_msg_count, -- Number of error Messages
        p_msg_data          => l_msg_data ,
        p_attr_name         => 'AMS_ERROR_MSG',
        x_error_msg         => l_error_msg);
    resultout := 'COMPLETE:ERROR';

  WHEN OTHERS THEN
    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
    Wf_Core.context('AMS_APPROVAL_PVT',
                        'Get_Line_Approver_Details ' || l_approver || ' : ',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
  --
END Get_Line_Approver_Details;

/*============================================================================*/
--
-- Procedure
--   Check_Line_Further_Approval
--
--   Workflow cover: Check if line needs further approvals
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If line needs further approvals
--             - 'COMPLETE:N' If line does not need further approvals
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_GET_APPROVER_DETAILS
--
/*============================================================================*/

PROCEDURE Check_Line_Further_Approval( itemtype      IN  VARCHAR2,
                                     itemkey         IN  VARCHAR2,
                                     actid           IN  NUMBER,
                                     funcmode        IN  VARCHAR2,
                                     resultout       OUT NOCOPY VARCHAR2    )
IS
l_act_budget_id          NUMBER;
l_approval_detail_id     NUMBER;
l_budget_type            VARCHAR2(30);
l_budget_id              NUMBER;
l_current_seq            NUMBER;
l_next_seq               NUMBER;
l_required_flag          VARCHAR2(30);
l_msg_data               VARCHAR2(4000);
l_msg_count              NUMBER;
l_error_msg              VARCHAR2(4000);
l_note                   VARCHAR2(4000);
-- Added for 11.5.9
l_approver_id            NUMBER;
l_version                NUMBER;
l_return_status          VARCHAR2(1);
l_appr_hist_rec          AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
l_new_approver_id        NUMBER;

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN

     -- get the approval detail id
       l_approval_detail_id := Wf_Engine.GetItemAttrNumber(
                              itemtype  => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_DETAIL_ID' );

     -- get the budget type
       l_current_seq := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_SEQ' );

     -- check if further approval is required
     Check_Approval_Required(p_approval_detail_id => l_approval_detail_id,
                    p_current_seq       => l_current_seq,
                    x_next_seq          => l_next_seq,
                    x_required_flag     => l_required_flag);

      -- Added for 11.5.9
      l_version := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_OBJECT_VERSION_NUMBER' );

      l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_ACT_BUDGET_ID' );

      l_approver_id   := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_APPROVER_ID');

      l_note            := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NOTE' );

      -- Bug Fix 2677401 Nov-14-2003
      -- Stuck at Check Line Further Approval if first/last approver has a problem

      IF l_next_seq IS NULL AND l_approver_id IS NULL THEN
         resultout := 'COMPLETE:N';
         RETURN;

      -- Higher up approvers can still approve for Budget Lines
      -- If we don't return, the pending to approved update will fail
      -- due to lack of target as the current approver_id is null

      ELSIF l_next_seq IS NOT NULL and l_approver_id IS NULL THEN
         resultout := 'COMPLETE:Y';
         RETURN;
      END IF;
   -- Commented for bug 3150550
     -- Start of addition for forward/reassign notification
/*
          Check_Reassigned (itemtype => itemtype,
                            itemkey  => itemkey,
                            x_approver_id   => l_new_approver_id,
                            x_return_status => l_return_status);

     IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
        RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF l_new_approver_id IS NOT NULL THEN
        l_approver_id := l_new_approver_id;
     END IF;

     -- End of addition for forward/re-assign notification
 -- End of Comment
 */

         -- update the record from 'PENDING' to 'APPROVED'
          l_appr_hist_rec.object_id := l_act_budget_id;
          l_appr_hist_rec.object_type_code := 'FUND';
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code := 'APPROVED';
          l_appr_hist_rec.approval_type := 'BUDGET';
          l_appr_hist_rec.sequence_num  := l_current_seq;
          l_appr_hist_rec.approver_id  := l_approver_id;
          l_appr_hist_rec.note := l_note;
          l_appr_hist_rec.action_date := SYSDATE;


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

     --IF l_required_flag = FND_API.G_TRUE THEN
     IF l_next_seq IS NOT NULL THEN
           --
            Wf_Engine.SetItemAttrNumber(itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'AMS_APPROVER_SEQ',
                                             avalue   => l_next_seq);

             resultout := 'COMPLETE:Y';
             RETURN;
     ELSE
             resultout := 'COMPLETE:N';
             RETURN;
     END IF;
  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Check_Line_Further_Approval',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Check_Line_Further_Approval',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  --
END Check_Line_Further_Approval;

/*============================================================================*/
--
-- Procedure
--   Approve_Budget_Line
--
--   Workflow cover: Approve a budget line
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' After approval
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_APPROVE_BUDGET_LINE
--
/*============================================================================*/

PROCEDURE Approve_Budget_Line(itemtype  IN  VARCHAR2,
                             itemkey    IN  VARCHAR2,
                             actid      IN  NUMBER,
                             funcmode   IN  VARCHAR2,
                             resultout  OUT NOCOPY VARCHAR2    )
IS
--
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(4000);
l_msg_count         NUMBER;
l_error_msg         VARCHAR2(4000);
--
l_act_budget_id     NUMBER;
l_approver_id       NUMBER;
l_approved_amount   NUMBER;
l_budget_amount     NUMBER;
l_approver          VARCHAR2(100);
l_text_value        VARCHAR2(2000);
l_number_value      NUMBER;
l_approved_currency VARCHAR2(30);
l_approved_status_id    NUMBER;
l_comment               VARCHAR2(4000); -- Was 2000 Bug 2991398

l_approver_seq      NUMBER;
l_version           NUMBER;
--
BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the budget id
       l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACT_BUDGET_ID' );

     -- get the approved id
       l_approver_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_APPROVER_ID' );

     -- get the approved amount
       l_approved_amount := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_APPROVED_LINE_AMOUNT' );

     -- get the approved currency
       l_approved_currency := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_CURRENCY' );

     -- get the approved status id
       l_approved_status_id := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_LINE_NEW_STAT_ID' );

       l_comment := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_NOTE' );

       l_approver := wf_engine.GetItemAttrText(
                               itemtype => itemtype,
                               itemkey => itemkey,
                               aname => 'AMS_APPR_USERNAME');

       l_budget_amount := wf_engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'AMS_BUDGET_AMOUNT_CONV');

       Get_Ntf_Rule_Values(l_approver,
                              'APPROVE',
                              l_text_value,
                              l_number_value);

       IF l_number_value > 0 THEN
         IF l_number_value > l_budget_amount THEN
           l_approved_amount := l_budget_amount;
         END IF;
       END IF;

     BEGIN
          -- update to approved
-- Changed Hard code form USD l_approved_currency
          Ozf_Budgetapproval_Pvt.WF_Respond (
               p_api_version        => 1.0,
               p_init_msg_list      => Fnd_Api.G_FALSE,
               p_commit             => Fnd_Api.G_TRUE,
               p_validation_level   => Fnd_Api.G_VALID_LEVEL_FULL,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_respond_status_id  => l_approved_status_id,
               p_activity_budget_id => l_act_budget_id,
               p_approver_id        => l_approver_id,
               p_approved_amount    => l_approved_amount,
               p_approved_currency  => l_approved_currency,
               p_comment            => l_comment);

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
    (p_itemtype         => itemtype   ,
    p_itemkey           => itemkey    ,
    p_msg_count         => l_msg_count, -- Number of error Messages
    p_msg_data          => l_msg_data ,
    p_attr_name         => 'AMS_ERROR_MSG',
    x_error_msg         => l_error_msg);
         resultout := 'COMPLETE:ERROR';
               RETURN;

          END IF;
     EXCEPTION
        WHEN OTHERS THEN
               Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW', SQLERRM );
          Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
     END;

     resultout := 'COMPLETE:SUCCESS';
     RETURN;

  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Approve_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Approve_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Approve_Budget_Line;

/*============================================================================*/
--
-- Procedure
--   Reject_Budget_Line
--
--   Workflow cover: Reject a budget line
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' After Rejection
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_REJECT_BUDGET_LINE
--
/*============================================================================*/

PROCEDURE Reject_Budget_Line(itemtype  IN  VARCHAR2,
                            itemkey    IN  VARCHAR2,
                            actid      IN  NUMBER,
                            funcmode   IN  VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2    )
IS
--
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(4000);
l_msg_count         NUMBER;
l_error_msg         VARCHAR2(4000);
--
l_act_budget_id     NUMBER;
l_approver_id       NUMBER;
l_approved_amount   NUMBER;
l_budget_amount     NUMBER;
l_approver          VARCHAR2(100);
l_text_value        VARCHAR2(2000);
l_number_value      NUMBER;
l_approved_currency       VARCHAR2(30);
l_rejected_status_id      NUMBER;
l_comment               VARCHAR2(4000); -- was 2000
-- 11.5.9
l_appr_hist_rec     AMS_Appr_Hist_Pvt.Appr_Hist_Rec_Type;
l_version           NUMBER;
l_approver_seq      NUMBER;
l_note              VARCHAR2(4000);
l_new_approver_id   NUMBER;

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the budget id
       l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACT_BUDGET_ID' );

     -- get the approved id
       l_approver_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'AMS_APPROVER_ID' );

     -- get the approved amount
       l_approved_amount := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'AMS_APPROVED_LINE_AMOUNT' );

     -- get the approved currency
       l_approved_currency := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'AMS_CURRENCY' );

     -- get the rejected status id
       l_rejected_status_id := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_LINE_REJECT_STAT_ID' );

       l_comment := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_NOTE' );

       l_approver := wf_engine.GetItemAttrText(
                               itemtype => itemtype,
                               itemkey => itemkey,
                               aname => 'AMS_APPR_USERNAME');

       l_budget_amount := wf_engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'AMS_BUDGET_AMOUNT_CONV');

       -- 11.5.9 version  sequence and note
       l_version := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_OBJECT_VERSION_NUMBER' );

       l_approver_seq := Wf_Engine.GetItemAttrNumber(
                                itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_APPROVER_SEQ' );

       -- get the note
       l_note  := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_NOTE' );

       Get_Ntf_Rule_Values(l_approver,
                              'REJECT',
                              l_text_value,
                              l_number_value);

       IF l_number_value > 0 THEN
         IF l_number_value > l_budget_amount THEN
           l_approved_amount := l_budget_amount;
         END IF;
       END IF;

     BEGIN
          -- update to rejected
          Ozf_Budgetapproval_Pvt.WF_Respond (
               p_api_version        => 1.0,
               p_init_msg_list      => Fnd_Api.G_FALSE,
               p_commit             => Fnd_Api.G_TRUE,
               p_validation_level   => Fnd_Api.G_VALID_LEVEL_FULL,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_respond_status_id  => l_rejected_status_id,
               p_activity_budget_id => l_act_budget_id,
               p_approver_id        => l_approver_id,
               p_approved_amount    => l_approved_amount,
               p_approved_currency  => l_approved_currency,
               p_comment => l_comment);

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
               Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
               Handle_Err
                   (p_itemtype          => itemtype   ,
                    p_itemkey           => itemkey    ,
                    p_msg_count         => l_msg_count,
                    p_msg_data          => l_msg_data ,
                    p_attr_name         => 'AMS_ERROR_MSG',
                    x_error_msg         => l_error_msg);
               resultout := 'COMPLETE:ERROR';
               RETURN;
          END IF;

     EXCEPTION
        WHEN OTHERS THEN
               Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW', SQLERRM );
          Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
     END;
   -- Commented for bug 3150550
     -- Start of addition for forward/reassign notification
/*
          Check_Reassigned (itemtype => itemtype,
                            itemkey  => itemkey,
                            x_approver_id => l_new_approver_id,
                            x_return_status => l_return_status);

     IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
      RAISE Fnd_Api.G_EXC_ERROR;
     END IF;

     IF l_new_approver_id IS NOT NULL THEN
        l_approver_id := l_new_approver_id;
     END IF;
     -- End of addition for forward/re-assign notification
*/
         -- update the record from 'PENDING' to 'REJECTED'
          l_appr_hist_rec.object_id := l_act_budget_id;
          l_appr_hist_rec.object_type_code := 'FUND';
          l_appr_hist_rec.object_version_num := l_version;
          l_appr_hist_rec.action_code := 'REJECTED';
          l_appr_hist_rec.approval_type := 'BUDGET';
          l_appr_hist_rec.sequence_num  := l_approver_seq;
          l_appr_hist_rec.note := l_note;
          -- bug 3161431
          l_appr_hist_rec.action_date := SYSDATE;

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
             p_object_id          => l_act_budget_id,
             p_object_type_code   => 'FUND',
             p_sequence_num       => null, -- all open rows
             p_action_code        => 'OPEN',
             p_object_version_num => l_version,
             p_approval_type      => 'BUDGET');

           IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.G_EXC_ERROR;
           END IF;

     resultout := 'COMPLETE:SUCCESS';
     RETURN;

  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Reject_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Reject_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Reject_Budget_Line;

/*============================================================================*/
--
-- Procedure
--   Revert_Budget_Line
--
--   Workflow cover: Reject a budget line
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' After Rejection
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_REJECT_BUDGET_LINE
--
/*============================================================================*/

PROCEDURE Revert_Budget_Line(itemtype   IN  VARCHAR2,
                            itemkey    IN  VARCHAR2,
                            actid      IN  NUMBER,
                            funcmode   IN  VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2    )
IS
--
l_return_status     VARCHAR2(1);
l_msg_data          VARCHAR2(4000);
l_msg_count         NUMBER;
l_error_msg         VARCHAR2(4000);
--
l_act_budget_id        NUMBER;
l_approver_id          NUMBER;
l_approved_amount      NUMBER;
l_approved_currency    VARCHAR2(30);
l_rejected_status_id   NUMBER;
l_comment              VARCHAR2(4000); -- Was 2000
l_version              NUMBER;

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the budget id
       l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACT_BUDGET_ID' );

     -- get the approved id
       l_approver_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'AMS_APPROVER_ID' );

     -- get the approved amount
       l_approved_amount := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'AMS_APPROVED_LINE_AMOUNT' );

     -- get the approved currency
       l_approved_currency := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'AMS_CURRENCY' );

     -- get the rejected status id
       l_rejected_status_id := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_LINE_REJECT_STAT_ID' );

       l_comment := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_NOTE' );
     BEGIN
          -- update to rejected
          -- This API is being called with validation_level NONE
          -- to prevent errors from being thrown by ams_fund_pvt
          -- which compares object_amount and sum of the requested_amounts
          -- even during revert

          Ozf_Budgetapproval_Pvt.WF_Respond (
               p_api_version        => 1.0,
               p_init_msg_list      => Fnd_Api.G_FALSE,
               p_commit             => Fnd_Api.G_TRUE,
               p_validation_level   => Fnd_Api.G_VALID_LEVEL_NONE,
               x_return_status      => l_return_status,
               x_msg_count          => l_msg_count,
               x_msg_data           => l_msg_data,
               p_respond_status_id  => NULL,
               p_activity_budget_id => l_act_budget_id,
               p_approver_id        => l_approver_id,
               p_approved_amount    => l_approved_amount,
               p_approved_currency  => l_approved_currency,
               p_comment => l_comment);

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
            --Fnd_Message.Set_Token('ROW', SQLERRM );
            Fnd_Msg_Pub.ADD;

          Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
            Handle_Err
            (p_itemtype          => itemtype   ,
             p_itemkey           => itemkey    ,
             p_msg_count         => l_msg_count, -- Number of error Messages
             p_msg_data          => l_msg_data ,
             p_attr_name         => 'AMS_ERROR_MSG',
             x_error_msg         => l_error_msg);
          resultout := 'COMPLETE:ERROR';
          RETURN;

          END IF;

     EXCEPTION
        WHEN OTHERS THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW', SQLERRM );
          Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
     END;

          -- 11.5.9 addition
          l_version     := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_OBJECT_VERSION_NUMBER' );

          -- Delete all rows
           AMS_Appr_Hist_PVT.Delete_Appr_Hist(
             p_api_version_number => 1.0,
             p_init_msg_list      => FND_API.G_FALSE,
             p_commit             => FND_API.G_FALSE,
             p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
             x_return_status      => l_return_status,
             x_msg_count          => l_msg_count,
             x_msg_data           => l_msg_data,
             p_object_id          => l_act_budget_id,
             p_object_type_code   => 'FUND',
             p_sequence_num       => null,
             p_action_code        => null,
             p_object_version_num => l_version,
             p_approval_type      => 'BUDGET');

          IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
             RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

     -- end 11.5.9 addition
     resultout := 'COMPLETE:SUCCESS';
     RETURN;

  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Revert_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
  WHEN OTHERS THEN
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Reject_Budget_Line',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Revert_Budget_Line;


--------------------------------------------------------------------------------
--
-- Procedure
--   Is_Parent_Waiting
--
--   Workflow cover: Check if there is a parent procoess waiting for further process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_PARENT_EXISTS
--
--------------------------------------------------------------------------------
PROCEDURE Is_Parent_Waiting (itemtype       IN  VARCHAR2,
                            itemkey         IN  VARCHAR2,
                            actid           IN  NUMBER,
                            funcmode        IN  VARCHAR2,
                            resultout       OUT NOCOPY VARCHAR2)
IS
l_msg_data           VARCHAR2(4000);
l_msg_count          NUMBER;
l_error_msg          VARCHAR2(4000);
l_parent_waiting_flag VARCHAR2(30);
BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN

       l_parent_waiting_flag := Wf_Engine.GetItemAttrText(
                               itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_PARENT_WAITING' );

     IF l_parent_waiting_flag = Fnd_Api.G_TRUE THEN
             resultout := 'COMPLETE:Y';
             RETURN;
     ELSE
             resultout := 'COMPLETE:N';
             RETURN;
     END IF;

  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Is_Parent_Waiting',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Is_Parent_Waiting;
--------------------------------------------------------------------------------
--
-- Procedure
--   Check_Line_Approval_Rule
--
--   Workflow cover: Check if approval rule is met after action on a particular line
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_CHECK_LINE_APPROVAL_RULE
--
--------------------------------------------------------------------------------
PROCEDURE Check_Line_Approval_Rule(itemtype      IN  VARCHAR2,
                                 itemkey         IN  VARCHAR2,
                                 actid           IN  NUMBER,
                                 funcmode        IN  VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2    )
IS
l_msg_data           VARCHAR2(4000);
l_msg_count          NUMBER;
l_error_msg          VARCHAR2(4000);
l_approval_amount    NUMBER;
l_activity_type      VARCHAR2(30);
l_activity_id        NUMBER;

l_approval_flag          VARCHAR2(30);
l_continue_flag          VARCHAR2(30);
l_parent_approval_flag   VARCHAR2(30);

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the approval amount
       l_approval_amount := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_AMOUNT' );

     -- get the activity id
       l_activity_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_ID' );

     -- get the activity type
       l_activity_type := Wf_Engine.GetItemAttrText(
                                itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'AMS_ACTIVITY_TYPE' );

     -- get parent process approved flag
       l_parent_approval_flag := Wf_Engine.GetItemAttrText(
                               itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_PARENT_APPROVED' );

     -- set the continue flow (if continues) to second continue flow
       --
       Wf_Engine.SetItemAttrText(itemtype  => itemtype,
                                 itemkey   => itemkey,
                                 aname     => 'AMS_CONTINUEFLOW',
                                 avalue    => 'CONTINUEFLOW');

     -- check condition for approval flag coming from parent
     IF l_parent_approval_flag = Fnd_Api.G_FALSE THEN
            -- check if activity meets the approval condition
           Get_Approval_Rules(p_activity_type  => l_activity_type ,
                              p_activity_id        => l_activity_id,
                              p_activity_amount    => l_approval_amount,
                              x_approved_flag      => l_approval_flag );

         IF l_approval_flag = Fnd_Api.G_TRUE THEN
          -- set continue to true
          l_continue_flag := Fnd_Api.G_TRUE;

            Wf_Engine.SetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'AMS_CONTINUE_FLOW',
                                              avalue   => l_continue_flag);

             resultout := 'COMPLETE:Y';
             RETURN;
         ELSE

          --
             resultout := 'COMPLETE:N';
             RETURN;
         END IF;

     ELSE
          --
             resultout := 'COMPLETE:Y';
             RETURN;
     END IF;

  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Check_Line_Approval_Rule',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Check_Line_Approval_Rule;
--------------------------------------------------------------------------------
--
-- Procedure
--   Check_More_Lines_Remaining
--
--   Workflow cover: Check if more lines are remaining for approval
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_CHECK_MORE_LINES_REMAINING
--
--------------------------------------------------------------------------------
PROCEDURE Check_More_Lines_Remaining(itemtype        IN  VARCHAR2,
                                 itemkey         IN  VARCHAR2,
                                 actid        IN  NUMBER,
                                 funcmode        IN  VARCHAR2,
                                 resultout       OUT NOCOPY VARCHAR2    )
IS
l_msg_data           VARCHAR2(4000);
l_msg_count          NUMBER;
l_error_msg          VARCHAR2(4000);
l_activity_type      VARCHAR2(30);
l_activity_id        NUMBER;
l_line_id            NUMBER;
l_remaining_flag     VARCHAR2(30);
l_continue_flag      VARCHAR2(30);

CURSOR lines_due_csr(p_id IN NUMBER, p_type IN VARCHAR2) IS
SELECT activity_budget_id
FROM   ozf_act_budgets
WHERE  act_budget_used_by_id = p_id
AND    arc_act_budget_used_by = p_type
AND    status_code = 'PENDING';

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN

     -- get the activity id
       l_activity_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_ID' );

     -- get the activity type
       l_activity_type := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_ACTIVITY_TYPE' );

     -- check if more lines exist for approval
     OPEN lines_due_csr(l_activity_id, l_activity_type);
             FETCH lines_due_csr INTO l_line_id;
     CLOSE lines_due_csr;

     IF l_line_id IS NOT NULL THEN
          l_remaining_flag := Fnd_Api.G_TRUE;
     ELSE
          l_remaining_flag := Fnd_Api.G_FALSE;
     END IF;

     -- continue to parent if no more lines remain
     IF l_remaining_flag = Fnd_Api.G_FALSE THEN
            -- set continue to true
          l_continue_flag := Fnd_Api.G_TRUE;

            Wf_Engine.SetItemAttrText(itemtype => itemtype,
                                        itemkey  => itemkey,
                                    aname    => 'AMS_CONTINUE_FLOW',
                                    avalue   => l_continue_flag);
             resultout := 'COMPLETE:N';
             RETURN;
     ELSE
             resultout := 'COMPLETE:Y';
             RETURN;
     END IF;
     --
  END IF;

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Check_More_Lines_Remaining',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Check_More_Lines_Remaining;
--------------------------------------------------------------------------------
--
-- Procedure
--   Can_Continue_Flow
--
--   Workflow cover: Check if this process can continue the flow of the main process
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:Y' If there is a parent process that started this process
--             - 'COMPLETE:N' If there is no parent process and this process can end
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_PARENT_EXISTS
--
--------------------------------------------------------------------------------
PROCEDURE Can_Continue_Flow (itemtype       IN  VARCHAR2,
                            itemkey         IN  VARCHAR2,
                            actid           IN  NUMBER,
                            funcmode        IN  VARCHAR2,
                            resultout       OUT NOCOPY VARCHAR2    )
IS
l_msg_data         VARCHAR2(4000);
l_msg_count        NUMBER;
l_error_msg        VARCHAR2(4000);
l_continue_flag    VARCHAR2(30);
l_parent_approved  VARCHAR2(30);
l_itemkey          VARCHAR2(80);
l_parent_itemkey   VARCHAR2(80);
l_activity_id      NUMBER;
l_activity_type    VARCHAR2(30);
l_line_id          NUMBER;
l_version          NUMBER;

CURSOR pending_lines_csr(p_id IN NUMBER, p_type IN VARCHAR2) IS
SELECT activity_budget_id
,      object_version_NUMBER
FROM   ozf_act_budgets
WHERE  act_budget_used_by_id = p_id
AND    arc_act_budget_used_by = p_type
AND    status_code = 'PENDING';

BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN

       l_continue_flag := Wf_Engine.GetItemAttrText(
                               itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_CONTINUE_FLOW' );

     IF l_continue_flag = Fnd_Api.G_TRUE THEN
          -- get the activity id
            l_activity_id := Wf_Engine.GetItemAttrNumber(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_ACTIVITY_ID' );

          -- get the activity id
            l_activity_type := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey => itemkey,
                              aname   => 'AMS_ACTIVITY_TYPE' );

          -- get the activity type
            l_parent_itemkey := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_PARENT_ITEMKEY' );

          -- set continue flow to FALSE for other lines in the same activity
          --
          l_continue_flag := Fnd_Api.G_FALSE;
          l_parent_approved := Fnd_Api.G_TRUE;

          OPEN pending_lines_csr(l_activity_id, l_activity_type);
             LOOP
               FETCH pending_lines_csr INTO l_line_id, l_version;
               EXIT WHEN pending_lines_csr%NOTFOUND;

               -- derive the itemkeys that were set while creating them
               l_itemkey     := l_line_id||'_'||l_parent_itemkey;

                 Wf_Engine.SetItemAttrText ( itemtype => itemtype,
                                                 itemkey  => l_itemkey,
                                                 aname    => 'AMS_CONTINUE_FLOW',
                                                 avalue   => l_continue_flag);

                 Wf_Engine.SetItemAttrText ( itemtype => itemtype,
                                                 itemkey  => l_itemkey,
                                                 aname    => 'AMS_PARENT_APPROVED',
                                                 avalue   => l_parent_approved);
             END LOOP;
          CLOSE pending_lines_csr;

             resultout := 'COMPLETE:Y';
             RETURN;
     ELSE
             resultout := 'COMPLETE:N';
             RETURN;
     END IF;

  END IF;  -- end RUN mode

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Can_Continue_Flow',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Can_Continue_Flow;

------------------------------------------------------------------------------
--
-- Procedure
--   Continue_Parent_Process
--
--   Workflow cover: continues the parent process from the block state
-- IN
--   itemtype  - A valid item type from (WF_ITEM_TYPES table).
--   itemkey   - A string generated from the application object's primary key.
--   actid     - The function activity(instance id).
--   funcmode  - Run/Cancel/Timeout
-- OUT
--   Resultout - 'COMPLETE:' none
--
-- USED BY ACTIVITIES
--  <ITEM_TYPE>         <ACTIVITY>
--  AMS_APPROVAL_PVT    AMS_CONTINUE_PARENT
--
--------------------------------------------------------------------------------
PROCEDURE Continue_Parent_Process (itemtype    IN  VARCHAR2,
                                   itemkey     IN  VARCHAR2,
                                   actid       IN  NUMBER,
                                   funcmode    IN  VARCHAR2,
                                   resultout   OUT NOCOPY VARCHAR2    )
IS
l_msg_data           VARCHAR2(4000);
l_msg_count          NUMBER;
l_error_msg          VARCHAR2(4000);
l_parent_itemkey     VARCHAR2(80);
l_parent_process     VARCHAR2(80) := 'AMS_APPROVAL';
l_activity_label     VARCHAR2(30) := 'BLOCK';
BEGIN

  --
  -- RUN mode
  --
  IF (funcmode = 'RUN') THEN
     -- get the activity type
       l_parent_itemkey := Wf_Engine.GetItemAttrText(
                             itemtype => itemtype,
                             itemkey =>  itemkey,
                             aname   =>  'AMS_PARENT_ITEMKEY' );

     BEGIN
         /* Added for zero budget Approval */
          Wf_Engine.BeginActivity(itemtype => g_itemtype,
                    itemkey  => l_parent_itemkey,
                    activity => l_parent_process||':'||l_activity_label
                    );
          Wf_Engine.CompleteActivity(itemtype => g_itemtype,
                    itemkey  => l_parent_itemkey,
                    activity => l_parent_process||':'||l_activity_label,
                    result   => 'COMPLETE:');
     EXCEPTION
          WHEN OTHERS THEN
             Wf_Core.clear;
     END;

         resultout := 'COMPLETE:';
     RETURN;
  END IF;  -- end RUN mode

  --
  -- CANCEL mode
  --
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
  --

EXCEPTION
  WHEN OTHERS THEN
        IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_error) THEN
          Fnd_Message.Set_Name('AMS','AMS_API_DEBUG_MESSAGE');
          Fnd_Message.Set_Token('ROW',SQLERRM);
          Fnd_Msg_Pub.ADD;
        END IF;
        Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
        Wf_Core.context('AMS_APPROVAL_PVT',
                        'Continue_Parent_Process',
                        itemtype, itemkey,TO_CHAR(actid),l_error_msg);
        RAISE;
END Continue_Parent_Process;
--------------------------------------------------------------------------------
/*****************************************************************
-- Start of Comments
-- NAME
--   DelvStartProcess
-- PURPOSE
--   This Procedure will Start the Deliverable Cancellation Process
--
-- Used By Activities
-- NOTES
-- HISTORY
-- End of Comments
*****************************************************************/
PROCEDURE DelvStartProcess
           (p_deliverable_id         IN   NUMBER,
            p_deliverable_name       IN   VARCHAR2,
            p_object_version_number  IN   NUMBER,
            p_usedby_object_id       IN   NUMBER,
            p_usedby_object_name     IN   VARCHAR2,
            p_usedby_object_type_name IN   VARCHAR2,
            p_requester_userid       IN   NUMBER,
            p_deliverable_userid     IN   NUMBER,
            p_workflowprocess        IN   VARCHAR2,
            p_item_type              IN   VARCHAR2
             )
IS
itemtype   VARCHAR2(30) := NVL(p_item_type,'AMSAPRV');
itemkey    VARCHAR2(30) := 'CHI'||p_deliverable_id||p_object_version_number||p_usedby_object_id;
itemuserkey VARCHAR2(80) :='CHI'||p_deliverable_id||p_object_version_number||p_usedby_object_id;

l_requester_role         VARCHAR2(320) ;  -- was 100
l_delv_user_role         VARCHAR2(320) ;  -- was 100
l_deliverable_userid     NUMBER ;
l_delv_requester_name    VARCHAR2(360);  -- was 100
l_delv_user_name         VARCHAR2(360);  -- was 100

l_return_status          VARCHAR2(1);
l_msg_data               VARCHAR2(4000);
l_msg_count              NUMBER;
l_error_msg              VARCHAR2(4000);

BEGIN
   /*****************************************************************
     Start Process :
      If workflowprocess is passed, it will be run.
      If workflowprocess is NOT passed, the selector function
      defined in the item type will determine which process to run.
   *****************************************************************/

   Ams_Utility_Pvt.debug_message('Start :Item Type : '||itemtype
                         ||' Item key : '||itemkey);

   Wf_Engine.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

   Wf_Engine.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);


   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/


   Wf_Engine.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_DELV_NAME',
                             avalue     =>   p_deliverable_name  );

   Wf_Engine.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_DELV_USEDBY_NAME',
                             avalue     =>   p_usedby_object_name  );

   Wf_Engine.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_DELV_USEDBY_TYPE',
                             avalue     =>   p_usedby_object_type_name  );



 -- l_return_status := FND_API.G_RET_STS_SUCCESS;

  --  check for description of activity

  -- Setting up the role
  Get_User_Role(p_user_id              => p_deliverable_userid ,
                x_role_name            => l_delv_user_role,
                x_role_display_name    => l_delv_user_name,
                x_return_status        => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
             RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  Wf_Engine.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'AMS_DELV_USER',
                            avalue      =>  l_delv_user_role  );

  Get_User_Role(p_user_id              => p_requester_userid ,
                x_role_name            => l_requester_role,
                x_role_display_name    => l_delv_requester_name,
                x_return_status        => l_return_status);

  IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN
             RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


  Wf_Engine.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => l_requester_role);


   -- Start the Process
   Wf_Engine.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);


EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
        Wf_Core.context ('ams_approval_pvt', 'DelvStartProcess'
                       ,p_deliverable_id ,p_workflowprocess);
        RAISE;
  WHEN OTHERS THEN
        Wf_Core.context ('ams_approval_pvt', 'DelvStartProcess'
                       ,p_deliverable_id ,p_workflowprocess);
        Ams_Utility_Pvt.debug_message('Inside Exception');
        RAISE;
END DelvStartProcess;
--------------------------------------------------------------------------------

PROCEDURE RECONCILE_BUDGET_LINE( itemtype        IN  VARCHAR2,
                                itemkey         IN  VARCHAR2,
                                actid           IN  NUMBER,
                                funcmode        IN  VARCHAR2,
                                resultout       OUT NOCOPY VARCHAR2    )
IS
l_activity_id           NUMBER;
l_activity_type         VARCHAR2(30);
l_approved_currency     VARCHAR2(30);
l_return_status         VARCHAR2(1);
l_msg_data              VARCHAR2(4000);
l_msg_count             NUMBER;
l_error_msg             VARCHAR2(4000);
l_child_item_key        VARCHAR2(240);
l_child_item_type       VARCHAR2(30);

CURSOR c_find_child (item_key_in IN VARCHAR2, item_type_in IN VARCHAR2) IS
SELECT item_type, item_key FROM wf_items_v
WHERE PARENT_ITEM_TYPE = item_type_in
AND parent_item_key = item_key_in
AND END_DATE IS NULL;

BEGIN
      l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_ID' );

     -- get the activity type
     l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

       l_approved_currency := Wf_Engine.GetItemAttrText(
                              itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'AMS_CURRENCY' );


  Ozf_Fund_Reconcile_Pvt.reconcile_budget_line (
    p_budget_used_by_id => l_activity_id
    ,p_budget_used_by_type => l_activity_type
    ,p_object_currency => l_approved_currency
    ,p_api_version  => 1.0
    ,p_init_msg_list   => Fnd_Api.g_false
    ,p_commit   => Fnd_Api.g_false
    ,p_validation_level => Fnd_Api.g_valid_level_full
    ,x_return_status => l_return_status
    ,x_msg_count => l_msg_count
    ,x_msg_data => l_msg_data
  );
        IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
    RAISE Fnd_Api.G_EXC_ERROR;
  ELSE
    OPEN c_find_child(itemkey, itemtype);
    FETCH c_find_child INTO l_child_item_type, l_child_item_key;
    IF c_find_child%FOUND THEN
      LOOP
        EXIT WHEN c_find_child%NOTFOUND;
        AbortProcess(p_itemkey  => l_child_item_key
             ,p_workflowprocess  => NULL
             ,p_itemtype  => l_child_item_type
        );
        FETCH c_find_child INTO l_child_item_type, l_child_item_key;
      END LOOP;
    END IF;
    CLOSE c_find_child;
  END IF;
 EXCEPTION
     WHEN Fnd_Api.G_EXC_ERROR THEN
        -- wf_engine.threshold := l_save_threshold ;
        Fnd_Msg_Pub.Count_And_Get (
          p_encoded => Fnd_Api.G_FALSE,
          p_count   => l_msg_count,
          p_data    => l_msg_data);
        Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg       );
        Wf_Core.context ('ams_approval_pvt', 'StartProcess',l_activity_type
                       ,l_activity_id ,l_error_msg);
        RAISE;
END;
---------------------------------------------------------------------------
PROCEDURE Validate_Object_Budget_WF(itemtype  IN  VARCHAR2,
                                 itemkey   IN  VARCHAR2,
                                 actid     IN  NUMBER,
                                 funcmode  IN  VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2)

IS
--
l_return_status   VARCHAR2(1);
l_msg_data        VARCHAR2(4000);
l_msg_count       NUMBER;
l_error_msg       VARCHAR2(4000);
l_activity_id     NUMBER;
l_activity_type   VARCHAR2(30);
l_act_budget_id   NUMBER;


BEGIN
  Fnd_Msg_Pub.initialize();

  --
  -- RUN mode
  --
    IF (funcmode = 'RUN') THEN
       -- get the acitvity id
       l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_ID' );

       -- get the activity type
       l_activity_type      := Wf_Engine.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_TYPE' );

      IF l_activity_type = 'OFFR' THEN

        l_act_budget_id     := Wf_Engine.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACT_BUDGET_ID' );

      -- Call API Validate_Object_Budget
      -- with required parameters

      Ozf_Budgetapproval_Pvt.validate_object_budget(
          p_object_id     => l_activity_id,
          p_object_type   => l_activity_type,
          p_actbudget_id  => l_act_budget_id,
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data);

        -- After Call to API

        IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN

    Handle_Err
        (p_itemtype  => itemtype,
         p_itemkey   => itemkey,
         p_msg_count => l_msg_count,
         p_msg_data  => l_msg_data,
         p_attr_name => 'AMS_ERROR_MSG',
         x_error_msg => l_error_msg
      );
         resultout := 'COMPLETE:FAILURE';
  ELSE
         resultout := 'COMPLETE:SUCCESS';
  END IF;

      -- For all other activity types return complete
      --
      ELSE

        resultout := 'COMPLETE:SUCCESS';
        RETURN;

      END IF;
    END IF; --  Run Mode
    --
    -- CANCEL mode
    --


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
  --
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
  Wf_Core.context('AMS_APPROVAL_PVT',
                    'Validate_Object_Budget_WF',
                     itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
          --resultout := 'COMPLETE:ERROR';
  WHEN OTHERS THEN
    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
    Wf_Core.context('AMS_APPROVAL_PVT',
                    'Validate_Object_Budget_WF',
                     itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Validate_Object_Budget_WF;
----------------------------------------------------------------------------
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
----------------------------------------------------------------------------
/*****************************************************************
-- Start of Comments
-- NAME
--   Auto_Approve
-- PURPOSE
--   This Procedure will determine if the approver of an activity
--   has a profile amount defined that can be used to automatically
--   approve budget lines or budgets(objects). If the profile amount
--   is greater than the line amount or activity amount, the approval
--   is automatic
-- Used By Activities
-- NOTES
-- HISTORY
-- End of Comments
******************************************************************/
PROCEDURE Auto_Approve (itemtype    IN  VARCHAR2,
                        itemkey     IN  VARCHAR2,
                        actid       IN  NUMBER,
                        funcmode    IN  VARCHAR2,
                        resultout   OUT NOCOPY VARCHAR2)
IS
CURSOR res_user_csr (p_resource_id IN NUMBER) IS
SELECT user_id
FROM ams_jtf_rs_emp_v
WHERE resource_id = p_resource_id ;

l_auto_amount      NUMBER;
l_approver_id      NUMBER;
l_user_id          NUMBER;
l_act_budget_id    NUMBER;
l_appr_line_amount NUMBER;
l_activity_amount  NUMBER;

BEGIN

  --
  -- RUN mode
  --
IF (funcmode = 'RUN') THEN
Fnd_Msg_Pub.initialize();

-- Get the Approver Id
l_approver_id := Wf_Engine.GetItemAttrNumber( itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_APPROVER_ID' );
-- Get the user id
OPEN res_user_csr (l_approver_id);
FETCH res_user_csr INTO l_user_id;
CLOSE res_user_csr;

-- Get the auto approval amount of the approver
l_auto_amount := NVL(Fnd_Profile.Value_Specific(name => 'AMS_AUTO_APPROVAL_AMOUNT',
                                                user_id => l_user_id),0);

IF l_auto_amount > 0 THEN

  -- Get the Budget ID

  l_act_budget_id := Wf_Engine.GetItemAttrNumber( itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_ACT_BUDGET_ID' );

  IF l_act_budget_id IS NOT NULL THEN
  -- It is a budget line

    -- get the approved line amount that is seen by approver
    l_appr_line_amount := Wf_Engine.GetItemAttrNumber( itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_APPROVED_LINE_AMOUNT');

    IF l_appr_line_amount <= l_auto_amount THEN
      -- Automatic Approval
      resultout := 'COMPLETE:Y';
    ELSE
      -- No Automatic Approval
      resultout := 'COMPLETE:N';
    END IF;

    RETURN;

  ELSE
  -- It is not a budget line

    -- Get the Activity Amount
    l_activity_amount := Wf_Engine.GetItemAttrNumber( itemtype => itemtype,
                                        itemkey => itemkey,
                                        aname   => 'AMS_ACTIVITY_AMOUNT');
    IF l_activity_amount > 0 THEN
      IF l_activity_amount <= l_auto_amount THEN
        -- Automatic Approval
        resultout := 'COMPLETE:Y';
      ELSE
        -- No Automatic Approval
        resultout := 'COMPLETE:N';
      END IF;

      RETURN;
    END IF;
  -- No auto approval for zero budget objects
  resultout := 'COMPLETE:N';
  return;
  END IF; --3

ELSE -- if l_auto_amount <=0

  resultout := 'COMPLETE:N';
  return;
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
--
END Auto_Approve;

--------------------------------------------------------------------------
-- Wrapper for Get_Approval_Details
-- Called by ApproverListVO.java
PROCEDURE Get_Approval_Rule ( p_activity_id        IN  NUMBER,
                              p_activity_type      IN  VARCHAR2,
                              p_approval_type      IN  VARCHAR2,
                              p_act_budget_id      IN  NUMBER,
                              x_approval_detail_Id OUT NOCOPY NUMBER,
                              x_return_status      OUT NOCOPY  VARCHAR2)
IS
l_obj_details       ObjRecTyp;
l_approver_seq      NUMBER;
BEGIN
  -- Get the approval rule
  -- Declare Get_Approval_Details as a public procedure


  IF p_activity_type IN ('PRIC', 'CLAM', 'RFRQ', 'FREQ') THEN -- add others like OFFRADJ

     AMS_Gen_Approval_Pvt.Get_Approval_Rule(p_activity_id   => p_activity_id,
                                            p_activity_type => p_activity_type,
                                            p_approval_type => p_approval_type,
                                            p_act_budget_id => p_act_budget_id,
                                            x_approval_detail_id  => x_approval_detail_id,
                                            x_return_status       => x_return_status);
  ELSE

  AMS_Approval_Pvt.Get_Approval_Details(p_activity_id => p_activity_id,
                              p_activity_type       => p_activity_type,
                              p_approval_type       => p_approval_type,
                              p_act_budget_id       => p_act_budget_id,
                              x_object_details      => l_obj_details,
                              x_approval_detail_id  => x_approval_detail_id,
                              x_approver_seq        => l_approver_seq,
                              x_return_status       => x_return_status);

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
                              aname    => 'AMS_APPR_USERNAME',
                              avalue   => l_assignee);

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPROVER_ID',
                              avalue   => l_new_approver_id);

        wf_engine.SetItemAttrText(  itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'AMS_APPR_DISPLAY_NAME',
                              avalue   => l_appr_display_name);

  -- Update the approver details here

        l_activity_type      := Wf_Engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

        l_act_budget_id := Wf_Engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey => itemkey,
                                  aname   => 'AMS_ACT_BUDGET_ID'
                                  );

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

       IF l_act_budget_id IS NOT NULL THEN
          l_activity_type := 'FUND';
          l_activity_id   := l_act_budget_id;
       END IF;

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
      wf_core.context('ams_approval_pvt','PostNotif_Update',
                      itemtype,itemkey,actid,funcmode,'Error in PNF');
      raise;
END PostNotif_Update;
---------------------------------------------------------------
PROCEDURE Validate_Object_Budget_All_WF(itemtype  IN  VARCHAR2,
                                 itemkey   IN  VARCHAR2,
                                 actid     IN  NUMBER,
                                 funcmode  IN  VARCHAR2,
                                 resultout OUT NOCOPY VARCHAR2)

IS
--
l_return_status   VARCHAR2(1);
l_msg_data        VARCHAR2(4000);
l_msg_count       NUMBER;
l_error_msg       VARCHAR2(4000);
l_activity_id     NUMBER;
l_activity_type   VARCHAR2(30);
--l_act_budget_id   NUMBER;


BEGIN
  Fnd_Msg_Pub.initialize();

  --
  -- RUN mode
  --
    IF (funcmode = 'RUN') THEN
       -- get the acitvity id
       l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_ID' );

       -- get the activity type
       l_activity_type      := Wf_Engine.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_TYPE' );

      IF l_activity_type = 'OFFR' THEN

  --      l_act_budget_id     := Wf_Engine.GetItemAttrText(
  --                                itemtype => itemtype,
  --                                 itemkey  => itemkey,
  --                                aname    => 'AMS_ACT_BUDGET_ID' );

      -- Call API Validate_Object_Budget
      -- with required parameters

      Ozf_Budgetapproval_Pvt.validate_object_budget_all(
          p_object_id     => l_activity_id,
          p_object_type   => l_activity_type,
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data);

        -- After Call to API

        IF l_return_status <> Fnd_Api.G_RET_STS_SUCCESS  THEN

    Handle_Err
        (p_itemtype  => itemtype,
         p_itemkey   => itemkey,
         p_msg_count => l_msg_count,
         p_msg_data  => l_msg_data,
         p_attr_name => 'AMS_ERROR_MSG',
         x_error_msg => l_error_msg
      );
         resultout := 'COMPLETE:FAILURE';
  ELSE
         resultout := 'COMPLETE:SUCCESS';
  END IF;

      -- For all other activity types return complete
      --
      ELSE

        resultout := 'COMPLETE:SUCCESS';
        RETURN;

      END IF;
    END IF; --  Run Mode
    --
    -- CANCEL mode
    --


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
  --
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
  Wf_Core.context('AMS_APPROVAL_PVT',
                    'Validate_Object_Budget_All_WF',
                     itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
          --resultout := 'COMPLETE:ERROR';
  WHEN OTHERS THEN
    Fnd_Msg_Pub.Count_And_Get (
                   p_encoded => Fnd_Api.G_FALSE,
                   p_count => l_msg_count,
                   p_data  => l_msg_data);
    Handle_Err
          (p_itemtype          => itemtype   ,
           p_itemkey           => itemkey    ,
           p_msg_count         => l_msg_count, -- Number of error Messages
           p_msg_data          => l_msg_data ,
           p_attr_name         => 'AMS_ERROR_MSG',
           x_error_msg         => l_error_msg);
    Wf_Core.context('AMS_APPROVAL_PVT',
                    'Validate_Object_Budget_All_WF',
                     itemtype, itemkey,TO_CHAR(actid),l_error_msg);
    RAISE;
END Validate_Object_Budget_All_WF;
--------------------------------------------------------------------------
PROCEDURE Bypass_Approval (itemtype    IN  VARCHAR2,
                        itemkey     IN  VARCHAR2,
                        actid       IN  NUMBER,
                        funcmode    IN  VARCHAR2,
                        resultout   OUT NOCOPY VARCHAR2)
IS
l_activity_id NUMBER;
l_activity_type VARCHAR2(30);
l_custom_setup_id NUMBER;

CURSOR c_offr(id IN NUMBER) IS
SELECT custom_setup_id
FROM ozf_offers
WHERE qp_list_header_id = id;
BEGIN
  Fnd_Msg_Pub.initialize();
  --
  -- RUN mode
  --
    IF (funcmode = 'RUN') THEN

       resultout := 'COMPLETE:N';
       -- get the activity type
       l_activity_type      := Wf_Engine.GetItemAttrText(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_TYPE' );
    IF l_activity_type = 'OFFR' THEN

      -- Get the Activity Id
       l_activity_id        := Wf_Engine.GetItemAttrNumber(
                                   itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'AMS_ACTIVITY_ID' );

      -- Get the Custom Setup Id
      OPEN c_offr(l_activity_id);
      FETCH c_offr INTO l_custom_setup_id;
      CLOSE c_offr;

      IF l_custom_setup_id = 110 THEN -- Softfund Lumpsum
         resultout := 'COMPLETE:Y';
      END IF;

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

END Bypass_Approval;

PROCEDURE must_preview (p_activity_id        IN  NUMBER,
                        p_activity_type      IN  VARCHAR2,
                        p_approval_type      IN  VARCHAR2,
                        p_act_budget_id      IN  NUMBER,
                        p_requestor_id       IN  NUMBER,
                        x_must_preview       OUT NOCOPY VARCHAR2,
                        x_return_status      OUT NOCOPY VARCHAR2)
IS
l_approval_detail_id NUMBER;
l_approver_type VARCHAR2(30);
l_obj_approver_id NUMBER;
l_pkg_name VARCHAR2(80);
l_proc_name VARCHAR2(80);
l_appr_id NUMBER;
l_return_status VARCHAR2(1);

CURSOR c_is_only_approver(id IN NUMBER) IS
SELECT approver_type, object_approver_id
from ams_approvers
where ams_approval_detail_id = id
and sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
and active_flag = 'Y'
and not exists (select count(approver_id) from ams_approvers
where ams_approval_detail_id = id
and sysdate between nvl(start_date_active, sysdate) and nvl(end_date_active, sysdate)
and active_flag = 'Y'
having count(approver_id) > 1);

CURSOR c_is_requestor_def_appr IS
SELECT rr.role_resource_id
FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
WHERE rr.role_id = rl.role_id
AND rr.role_resource_type = 'RS_INDIVIDUAL'
AND rl.role_code = 'AMS_DEFAULT_APPROVER'
AND rr.delete_flag = 'N'
AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
AND rl.role_type_code IN ('AMSAPPR','MKTGAPPR')
AND rr.role_resource_id = p_requestor_id;

CURSOR c_is_requestor_appr_role IS
SELECT rr.role_resource_id
FROM jtf_rs_role_relations rr, jtf_rs_roles_b rl
WHERE rr.role_id = rl.role_id
AND rr.role_resource_type = 'RS_INDIVIDUAL'
AND rr.delete_flag = 'N'
AND SYSDATE BETWEEN rr.start_date_active and nvl(rr.end_date_active, SYSDATE)
AND rl.role_type_code IN ('MKTGAPPR', 'AMSAPPR')
AND rr.role_id = l_obj_approver_id
AND rr.role_resource_id = p_requestor_id;

BEGIN
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  x_must_preview := 'Y'; -- Default is must preview
  Get_Approval_Rule ( p_activity_id => p_activity_id,
                      p_activity_type => p_activity_type,
                      p_approval_type => p_approval_type,
                      p_act_budget_id => p_act_budget_id,
                      x_approval_detail_Id => l_approval_detail_id,
                      x_return_status => l_return_status);

  IF l_return_status = Fnd_Api.G_RET_STS_SUCCESS
  AND l_approval_detail_id IS NOT NULL THEN

    OPEN c_is_only_approver(l_approval_detail_id);
    FETCH c_is_only_approver INTO l_approver_type, l_obj_approver_id;
    CLOSE c_is_only_approver;

    IF l_approver_type = 'USER' AND l_obj_approver_id = p_requestor_id THEN
      x_must_preview := 'N';
    END IF; --'USER'

    IF l_approver_type = 'ROLE' THEN

      IF l_obj_approver_id IS NULL THEN-- Default Approver
      -- Check if Default Approver is Requestor
        OPEN c_is_requestor_def_appr;
        FETCH c_is_requestor_def_appr INTO l_appr_id;
        IF c_is_requestor_def_appr%NOTFOUND THEN
           CLOSE c_is_requestor_def_appr;
           RETURN;
        END IF;
        x_must_preview := 'N';
        CLOSE c_is_requestor_def_appr;
        RETURN;
      END IF;

      IF l_obj_approver_id IS NOT NULL THEN -- Not Def Approver
        OPEN c_is_requestor_appr_role;
        FETCH c_is_requestor_appr_role INTO l_appr_id;
        IF c_is_requestor_appr_role%NOTFOUND THEN
           CLOSE c_is_requestor_appr_role;
           RETURN;
        END IF;
        x_must_preview := 'N';
        CLOSE c_is_requestor_appr_role;
        RETURN;
      END IF;

    END IF; -- 'ROLE'

  END IF;
END must_preview;
------------------------------------------------------------------------
PROCEDURE Check_Object_Type( itemtype        in  varchar2,
                             itemkey         in  varchar2,
                             actid           in  number,
                             funcmode        in  varchar2,
                             resultout   OUT NOCOPY varchar2)
IS
l_process_type varchar2(80);
l_activity_type varchar2(80);
BEGIN

     l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );

    If (l_activity_type = 'CAMP'
            OR l_activity_type = 'CSCH') THEN
              resultout := 'CAMP';
    else
              resultout := 'OTHER';
    end if;

END Check_Object_Type;
--------------------------------------------------------------------------
END Ams_Approval_Pvt;

/
