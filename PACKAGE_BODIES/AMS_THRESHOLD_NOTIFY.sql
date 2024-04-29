--------------------------------------------------------
--  DDL for Package Body AMS_THRESHOLD_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_THRESHOLD_NOTIFY" AS
   /* $Header: amsvtnob.pls 115.15 2001/12/18 10:33:22 pkm ship        $*/
   g_pkg_name    CONSTANT VARCHAR2(30) := 'ams_threshold_notify';

   --  Start of Comments
   --  API name    ams_acct_generator
   --  Type        Private
   --  Version     Current version = 1.0
   --              Initial version = 1.0
   --  Created    Feliu
   --  Updated    05/15/2001   mpande 1) Introduced generic workflow process
   --                          mpande 2) Commented the old code
   --  Updated    13/08/2001   fliu  added parent owner and subject message.
-------------------------------------------------------------------------------
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
PROCEDURE Get_User_Role
  ( p_user_id            IN     NUMBER,
    x_role_name          OUT    VARCHAR2,
    x_role_display_name  OUT    VARCHAR2 ,
    x_return_status      OUT    VARCHAR2)
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
   WF_DIRECTORY.getrolename(p_orig_system     => 'PER',
                            p_orig_system_id    => l_person_id ,
                            p_name => x_role_name,
                            p_display_name => x_role_display_name );

   IF x_role_name is NULL  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('AMS','AMS_APPR_INVALID_ROLE');
        FND_MSG_PUB.Add;
   END IF;
END Get_User_Role;


   /*===========================================================================+
    | Name: START_PROCESS                                                       |
    | Purpose: Runs the Workflow process to create the Threshold Notification   |
    +===========================================================================*/
   --  Start of Comments
   --  API name    ams_acct_generator
   --  Type        Private
   --  Version     Current version = 1.0
   --              Initial version = 1.0

   --  Created    Feliu
   --  Updated    05/15/2001          mpande 1) Introduced generic workflow process
   --                                 mpande 2) Commented the old code
-------------------------------------------------------------------------------

PROCEDURE start_process(
      p_api_version_number   IN       NUMBER
     ,x_msg_count            OUT      NUMBER
     ,x_msg_data             OUT      VARCHAR2
     ,x_return_status         OUT     VARCHAR2
     ,p_owner_id             IN       NUMBER
     ,p_parent_owner_id      IN       NUMBER
     ,p_message_text         IN       VARCHAR2
     ,p_activity_log_id      IN       NUMBER
)
   IS
      l_itemtype                       VARCHAR2(30)   := 'AMSGAPP';
      l_workflowprocess                VARCHAR2(30)   := 'AMS_GENERIC_NOTIFICATIONS';
      l_itemkey                        VARCHAR2(38);
      l_return_status                  VARCHAR2(1);
      l_api_version_number    CONSTANT NUMBER         := 1.0;
      l_api_name              CONSTANT VARCHAR2(30)   := 'Start_Process';
      l_owner_role                     VARCHAR2(30);
      l_parent_owner_role              VARCHAR2(30);
      l_owner_disp_name                VARCHAR2(30);
      l_parent_disp_name               VARCHAR2(30);
      l_strSubject                     VARCHAR2(30);
      l_strChildSubject                VARCHAR2(30);

   BEGIN
      AMS_UTILITY_PVT.debug_message('Entering ams_threshold_notify.Start_process : ');

      IF NOT fnd_api.compatible_api_call(
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      fnd_message.set_name('AMS', 'AMS_THRESHOLD_SUBJECT');
      l_strSubject := fnd_message.get;
      fnd_message.set_name('AMS', 'AMS_THRESHOLD_CHILDSUBJ');
      l_strChildSubject := fnd_message.get;


	-- Setting up the role
      Get_User_Role(p_user_id           => p_owner_id ,
                    x_role_name         => l_owner_role,
                    x_role_display_name => l_owner_disp_name,
                    x_return_status     => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
         RAISE FND_API.G_EXC_ERROR;
      END IF;


     -- we need to start 2 process here one for parent owner , other for budget owner
     ams_generic_ntfy_pvt.StartProcess(p_activity_type => 'FTHO',
                                       p_activity_id => p_activity_log_id,
                                       p_workflowprocess => l_workflowprocess,
                                       p_item_type  => l_itemtype,
    	                               p_send_by  => l_owner_role, -- role of the fund owner
    	                               p_sent_to  => l_owner_role,  -- role of the fund owner
	                               p_item_key_suffix => '1',
                                       p_subject      => l_strSubject
                                       );
      IF p_parent_owner_id <>0 THEN
         -- Setting up the parent role
         Get_User_Role(p_user_id              => p_owner_id ,
                       x_role_name            => l_parent_owner_role,
                       x_role_display_name    => l_parent_disp_name,
                       x_return_status        => l_return_status
		       );

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS  then
            RAISE FND_API.G_EXC_ERROR;
         END IF;

        -- Start process for parent owner.
         ams_generic_ntfy_pvt.StartProcess(p_activity_type => 'FTHO',
                                           p_activity_id => p_activity_log_id,
                                           p_workflowprocess => l_workflowprocess,
                                           p_item_type  => l_itemtype,
    	                                   p_send_by  => l_parent_owner_role, -- role of the fund parent owner
    	                                   p_sent_to  => l_parent_owner_role,  -- role of the fund parent owner
	                                   p_item_key_suffix => '2',
                                           p_subject      => l_strChildSubject
                                          );
      END IF;
 -- what about exception for above call?

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   END start_process; /*  START_PROCESS */

      --------------------------------------------------------------------------
   -- PROCEDURE
   --   notify_threshold_violate
   --
   -- PURPOSE
   --   Generate the Approval Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   05/15/2001        MUMU PANDE        CREATION
   ----------------------------------------------------------------------------
   PROCEDURE notify_threshold_violate(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT   VARCHAR2
     ,document_type   IN OUT   VARCHAR2)
   IS
      l_api_name            VARCHAR2(61)    := g_pkg_name || 'notify_threshold_violate';
      l_hyphen_pos1         NUMBER;
      l_fyi_notification    VARCHAR2(10000);
      l_activity_type       VARCHAR2(30);
      l_item_type           VARCHAR2(30);
      l_item_key            VARCHAR2(30);
      l_approval_type       VARCHAR2(30);
      l_approver            VARCHAR2(30);
      l_note                VARCHAR2(3000);
      l_string              VARCHAR2(1000);
      l_string1             VARCHAR2(1000);
      l_string2             VARCHAR2(2500);
      l_Activity_log_id     NUMBER;
      l_message             VARCHAR2(3000);

      CURSOR c_message_text(p_activity_log_id NUMBER) IS
      SELECT  log_message_text
      FROM ams_act_logs
      WHERE activity_log_id = p_activity_log_id;

   BEGIN
      ams_utility_pvt.debug_message(l_api_name || 'Entering' || 'document id ' || document_id);
      document_type := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1 := INSTR(document_id, ':');
      l_item_type := SUBSTR(document_id, 1, l_hyphen_pos1 - 1);
      l_item_key := SUBSTR(document_id, l_hyphen_pos1 + 1);

      l_activity_type := wf_engine.getitemattrtext(itemtype => l_item_type
                                                   ,itemkey => l_item_key
                                                   ,aname => 'AMS_ACTIVITY_TYPE');

      l_activity_log_id := wf_engine.getitemattrnumber(itemtype => l_item_type
                                                       ,itemkey => l_item_key
                                                       ,aname => 'AMS_ACTIVITY_ID');

      OPEN c_message_text(l_activity_log_id);
      FETCH c_message_text INTO l_message;
      CLOSE c_message_text;

      --fnd_message.set_name('AMS', 'AMS_WF_THREHOLD_NTF');
      --l_string := fnd_message.get;

      --  IF (display_type = 'text/plain') THEN
      l_fyi_notification := NVL(l_message,'Y')||'AMS_THRESHOLD_NOTIFY';
      document := document || l_fyi_notification;
      document_type := 'text/plain';

      RETURN;
   --      END IF;

   /*      IF (display_type = 'text/html') THEN
            l_fyi_notification :=
          l_string ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string1 ||
               FND_GLOBAL.LOCAL_CHR(10) ||
               l_string2;
            document := document||l_appreq_notification;
            document_type := 'text/html';
            RETURN;
         END IF;
         */
   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('AMSGAPP', 'Notify_requestor_FYI', l_item_type, l_item_key);
         RAISE;
   END notify_threshold_violate;

END ams_threshold_notify;

/
