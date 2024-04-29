--------------------------------------------------------
--  DDL for Package Body AMS_DELIVERABLERULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DELIVERABLERULES_PVT" AS
/* $Header: amsvderb.pls 120.0 2005/05/31 16:40:45 appldev noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_DeliverableRules_PVT';




-------------------------------------------------------------------------
-- FUNCTION
--    is_content_item
--
-- PURPOSE
--    to findout whether the deliverable's custom setup has a
--     object_attribute "ECON" ( for future releases or "CPAGE"  )
--
-- HISTORY
--   18-JUL-02   MUSMAN     Created.
--   14-AUG-02   MUSMAN     Bug 2492857 fix. Changed the query to get the Content
--                          in Approve_content_item, since the terminlogy has changed.
--------------------------------------------------------------------------
FUNCTION is_content_item
( p_deliverable_id    IN   NUMBER
)
RETURN VARCHAR2 IS

   CURSOR c_custom_attr
      ( p_custom_setup_id IN NUMBER)
   IS
   SELECT 'Y'
   FROM   ams_custom_setup_attr
   WHERE  custom_setup_id = p_custom_setup_id
   AND    object_attribute IN ('ECON'); --,'CPAGE') ;

   CURSOR c_custom_setup
   IS
   SELECT custom_setup_id
   FROM ams_deliverables_all_b
   WHERE deliverable_id = p_deliverable_id;


   l_flag VARCHAR2(1) := 'N';
   l_custom_Setup_id NUMBER ;

BEGIN

   OPEN c_custom_setup;
   FETCH c_custom_setup INTO l_custom_Setup_id ;
   CLOSE c_custom_setup ;

   OPEN c_custom_attr(l_custom_setup_id);
   FETCH c_custom_attr INTO l_flag ;
   CLOSE c_custom_attr ;

   IF l_flag = 'Y' THEN
      l_flag := FND_API.g_true;
   ELSIF l_flag = 'N' THEN
      l_flag := FND_API.g_false;
   END IF;

   RETURN l_flag ;

END is_content_item;
-------------------------------------------------------------------------
-- FUNCTION
--    call_budget_request
--
-- PURPOSE
--    to calling the budget api to make the budget active if
--     the budget_approval is not reqd.
--
-- HISTORY
--   25-OCT-02   MUSMAN     Created.
--------------------------------------------------------------------------
PROCEDURE call_budget_request
( p_deliverable_id    IN   NUMBER
)
IS

l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_status_code VARCHAR2(30);

BEGIN

   l_return_status := FND_API.g_ret_sts_success;

   AMS_UTILITY_PVT.debug_message(' CALLING THE call_budget_request :'||p_deliverable_id);

   OZF_BUDGETAPPROVAL_PVT.budget_request_approval(
       p_init_msg_list    => FND_API.g_false
      ,p_api_version      => 1.0
      ,p_commit           => FND_API.g_false
      ,x_return_status    => l_return_status
      ,x_msg_count        => l_msg_count
      ,x_msg_data         => l_msg_data
      ,p_object_type      => 'DELV'
      ,p_object_id        => p_deliverable_id
      ,x_status_code      => l_status_code
     );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;

END call_budget_request;

------------------------------------------------------------------------
-- PROCEDURE
--    Update_Status
--
-- PURPOSE
--    This api is called in Update Delv api to call the approvals if necessary
--
-- HISTORY
--     01-JUL-2002   musman   created.
------------------------------------------------------------------------
PROCEDURE update_delv_status(
    p_deliverable_id   IN   NUMBER
   ,p_user_status_id   IN   NUMBER
)
IS

   l_budget_exist      NUMBER;
   l_old_status_id     NUMBER;
   l_new_status_id     NUMBER;
   l_deny_status_id    NUMBER;
   l_object_version    NUMBER;
   l_approval_type     VARCHAR2(30);
   l_return_status     VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);


   CURSOR c_old_status IS
   SELECT user_status_id, object_version_number,
          status_code,custom_setup_id
   FROM   ams_deliverables_all_b
   WHERE  deliverable_id = p_deliverable_id;

   CURSOR c_budget_exist IS
   SELECT 1
   FROM   DUAL
   WHERE  EXISTS(
          SELECT 1
          FROM   ams_act_budgets
          WHERE  arc_act_budget_used_by = 'DELV'
          AND    act_budget_used_by_id = p_deliverable_id);


   l_system_status_code VARCHAR2(30) := AMS_Utility_PVT.get_system_status_code(p_user_status_id) ;
   l_old_status_code    VARCHAR2(30) ;
   l_custom_setup_id    NUMBER ;
BEGIN

   l_return_status := FND_API.g_ret_sts_success;

   OPEN c_old_status;
   FETCH c_old_status INTO l_old_status_id, l_object_version, l_old_status_code,l_custom_setup_id ;
   CLOSE c_old_status;

   AMS_Utility_PVT.debug_message('new status code'||l_system_status_code);
   AMS_Utility_PVT.debug_message('old status code'||l_old_status_code);

   IF l_old_status_id = p_user_status_id THEN
      RETURN;
   END IF;

   AMS_Utility_PVT.check_new_status_change(
      p_object_type      => 'DELV',
      p_object_id        => p_deliverable_id,
      p_old_status_id    => l_old_status_id,
      p_new_status_id    => p_user_status_id,
      p_custom_setup_id  => l_custom_setup_id,
      x_approval_type    => l_approval_type,
      x_return_status    => l_return_status
   );

   IF l_return_status <> FND_API.g_ret_sts_success THEN
      RAISE FND_API.g_exc_error;
   END IF;


   IF AMS_UTILITY_PVT.get_system_status_code(p_user_status_id)= 'AVAILABLE'
   AND AMS_UTILITY_PVT.get_system_status_code(l_old_status_id)= 'NEW'
   --AND nvl(l_approval_type,'A') <> 'BUDGET'
   THEN
      call_budget_request(p_deliverable_id);
   END IF;


   IF l_approval_type = 'BUDGET' THEN
      -- start budget approval process
      l_new_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_DELIV_STATUS',
         'SUBMITTED_BA'
      );
      l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_DELIV_STATUS',
         'DENIED_BA'
      );


      AMS_Approval_PVT.StartProcess(
         p_activity_type => 'DELV',
         p_activity_id => p_deliverable_id,
         p_approval_type => l_approval_type,
         p_object_version_number => l_object_version,
         p_orig_stat_id => l_old_status_id,
         p_new_stat_id => p_user_status_id,
         p_reject_stat_id => l_deny_status_id,
         p_requester_userid => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         p_workflowprocess => 'AMS_APPROVAL',
         p_item_type => 'AMSAPRV'
      );
   ELSIF l_approval_type = 'THEME' THEN
      l_new_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_DELIV_STATUS',
         'SUBMITTED_TA'
      );
      l_deny_status_id := AMS_Utility_PVT.get_default_user_status(
         'AMS_DELIV_STATUS',
         'DENIED_TA'
      );

      AMS_Approval_PVT.StartProcess(
         p_activity_type => 'DELV',
         p_activity_id => p_deliverable_id,
         p_approval_type => 'CONCEPT',
         p_object_version_number => l_object_version,
         p_orig_stat_id => l_old_status_id,
         p_new_stat_id => p_user_status_id,
         p_reject_stat_id => l_deny_status_id,
         p_requester_userid => AMS_Utility_PVT.get_resource_id(FND_GLOBAL.user_id),
         p_workflowprocess => 'AMS_CONCEPT_APPROVAL',
         p_item_type => 'AMSAPRV'
      );
   ELSE
      l_new_status_id := p_user_status_id;
   END IF;
/*
   -- because if there is no BAPL the status get changed from NEW - Available
   AMS_UTILITY_PVT.debug_message(' l_approval_type :'||l_approval_type);
   AMS_UTILITY_PVT.debug_message(' THE NEW STATUS ID :'||l_new_status_id);

   IF AMS_UTILITY_PVT.get_system_status_code(l_new_status_id)= 'BUDGET_APPR'
   AND nvl(l_approval_type,'A') <> 'BUDGET'
   THEN
      call_budget_request(p_deliverable_id);
   END IF;
*/
   update_status(p_deliverable_id      =>   p_deliverable_id,
                 p_new_status_id    =>   l_new_status_id,
                 p_new_status_code  =>   AMS_Utility_PVT.get_system_status_code(l_new_status_id)
                                 ) ;

END update_delv_status;

------------------------------------------------------------------------
-- PROCEDURE
--    Update_Status
--
-- PURPOSE
--    This api is called in Update Delv api (and in approvals' api)
--
-- HISTORY
--     01-JUL-2002   musman   created.
------------------------------------------------------------------------
PROCEDURE update_status(
    p_deliverable_id          IN   NUMBER
   ,p_new_status_id           IN   NUMBER
   ,p_new_status_code         IN   VARCHAR2
   )
IS

--   CURSOR c_get_type IS
--   SELECT d.can_fulfill_electronic_flag
--   FROM ams_custom_Setup_attr a
--       ,ams_custom_setups_b b
--       ,ams_deliverables_vl d
--   WHERE a.object_attribute  = 'ECON'
--   AND a.custom_Setup_id = b.custom_setup_id
--   AND b.object_type ='DELV'
--   AND d.custom_setup_id = b.custom_setup_id
--   AND d.deliverable_id = p_deliverable_id;

   l_electronic_flag  VARCHAR2(1);
   l_category_type_id  NUMBER;
   l_return_status VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

BEGIN

   l_return_status := FND_API.g_ret_sts_success;

   IF (p_new_status_code = 'AVAILABLE')
   THEN
      IF is_content_item(p_deliverable_id) = FND_API.g_true
      THEN
         Approve_Content_Item(
            p_deliverable_id         => p_deliverable_id
           ,p_api_version_number     => 1.0
           ,x_return_status          => l_return_status
           ,x_msg_count              => l_msg_count
           ,x_msg_data               => l_msg_data
         );

         IF l_return_status <> FND_API.g_ret_sts_success
         THEN
            RAISE FND_API.g_exc_error;
         END IF;

      END IF; --if deliverable is a content item
   END IF;  -- if new status code is "AVAILABLE"

   UPDATE ams_deliverables_all_b
   SET    user_status_id = p_new_status_id,
          status_code = p_new_status_code,
          status_date = SYSDATE,
          private_flag = DECODE(p_new_status_code,'AVAILABLE','N',private_flag)
   WHERE  deliverable_id = p_deliverable_id;

END update_status;


------------------------------------------------------------------------
-- PROCEDURE
--    Approve_Content_Item
--
-- PURPOSE
--    This api is to approve the content associated.
--
-- HISTORY
--     01-JUL-2002   aranka   created.
--     14-AUG-2002   musman   Bug 2492857 fix.
--     06-NOV-2003   musman   Modified the CURSOR c_content_approve as requested by soagrawa
------------------------------------------------------------------------

  PROCEDURE Approve_Content_Item(
    p_deliverable_id             IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_api_version_number                IN  NUMBER,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
     )

  IS
      L_API_NAME                  CONSTANT VARCHAR2(30) := 'Approve_Content_Item';
      L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
      l_return_status  VARCHAR2(1);

      l_content_item_id                       NUMBER;
      l_citem_version_id                      NUMBER;
      l_object_version_number                 NUMBER;
      l_content_item_status                   VARCHAR2(30);

      CURSOR c_content_approve IS
     SELECT ci.content_item_id, ver.citem_version_id, ci.object_version_number, content_item_status
     FROM ibc_associations assoc,ibc_content_items ci , ibc_citem_versions_vl ver
      WHERE assoc.associated_object_val1 = to_char(p_deliverable_id)  ---musman: bug 4145845 Fix
      AND ci.content_type_code = 'IBC_CONTENT_BLOCK'     --anchaudh on 27 Oct '03: changed AMF_EMAIL_DELIVERABLE to IBC_CONTENT_BLOCK
      AND ci.content_item_id = ver.content_item_id
      --AND ci.content_type_code = assoc.association_type_code
      AND assoc.association_type_code = 'AMS_DELV'
      AND assoc.content_item_id = ci.content_item_id
      AND ver.citem_Version_id = (select max(citem_version_id) from ibc_citem_versions_b where content_item_id = ci.content_item_id);
      --anchaudh on 27 Oct '03: added the above extra clause.

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Approve_Content_Item;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'start');


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- call ibc approve content API
   OPEN c_content_approve;
   FETCH c_content_approve INTO l_content_item_id, l_citem_version_id, l_object_version_number, l_content_item_status;
   CLOSE c_content_approve;

   IF l_content_item_status IS NULL
   OR l_content_item_status <> 'PENDING'
   THEN
      AMS_UTILITY_PVT.debug_message('l_content_item_status is either null or not PENDING ' || l_content_item_status);
      RETURN;
   END IF;

   AMS_UTILITY_PVT.debug_message('Public API: ' || l_content_item_id || ':' || l_citem_version_id ||':' || l_object_version_number || ':' || l_content_item_status);

   IBC_CITEM_ADMIN_GRP.approve_item(
         p_citem_ver_id               => l_citem_version_id,
         p_commit                     => p_commit,
         p_api_version_number         => 1.0,
         p_init_msg_list              => p_init_msg_list,
         px_object_version_number     => l_object_version_number,
         x_return_status              => x_return_status,
         x_msg_count                  => x_msg_count,
         x_msg_data                   => x_msg_data);

   -- Check return status from the above procedure call
   IF x_return_status = FND_API.G_RET_STS_ERROR then
      RAISE FND_API.G_EXC_ERROR;
   elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
   AMS_UTILITY_PVT.debug_message('Public API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
    (p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
    );

EXCEPTION

WHEN AMS_Utility_PVT.resource_locked THEN
   x_return_status := FND_API.g_ret_sts_error;
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
      FND_MESSAGE.set_name('AMS', 'AMS_API_RESOURCE_LOCKED');
      FND_MSG_PUB.add;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Approve_Content_Item;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Approve_Content_Item;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
    );

WHEN OTHERS THEN
   ROLLBACK TO Approve_Content_Item;
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

END Approve_Content_Item;



END AMS_DeliverableRules_PVT;

/
