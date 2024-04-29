--------------------------------------------------------
--  DDL for Package Body DPP_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_APPROVAL_PVT" AS
/* $Header: dppvappb.pls 120.14.12010000.16 2010/04/21 13:33:19 kansari ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_APPROVAL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'dppvappb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

DPP_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
DPP_UNEXP_ERROR_ON BOOLEAN :=FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error);
DPP_ERROR_ON BOOLEAN := FND_MSG_PUB.check_msg_level(fnd_msg_pub.g_msg_lvl_error);
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

--Defining Global Value as Update_user_status, parametes are already defined
G_FORWARD_USER NUMBER;

---------------------------------------------------------------------
FUNCTION resource_valid (p_resource_id IN NUMBER )
RETURN BOOLEAN
IS

l_resource_id NUMBER;
l_return_status BOOLEAN := FALSE;

CURSOR csr_resource (p_resource_id IN NUMBER) IS
SELECT jre.resource_id
FROM   jtf_rs_resource_extns jre
WHERE  jre.resource_id = p_resource_id;

BEGIN
   OPEN csr_resource(p_resource_id);
      FETCH csr_resource INTO l_resource_id;
   CLOSE csr_resource;

   IF l_resource_id IS NOT NULL THEN
      l_return_status := TRUE;
   END IF;

   RETURN l_return_status;

EXCEPTION
   WHEN OTHERS THEN
      RETURN l_return_status;
END resource_valid;
---------------------------------------------------------------------
-- PROCEDURE
--    Update_User_Action
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Update_User_Action(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec      IN  approval_rec_type
)
IS
l_api_name CONSTANT varchar2(80) := 'Update_User_Action';
l_api_version CONSTANT number := 1.0;
l_approver_id number;
l_approval_access_id number;
l_approver_found varchar2(1) := 'N';
l_approver_level number;
l_approvers_tbl approvers_tbl_type;
l_ame_approver_rec ame_util.approverRecord2;
l_ame_forward_rec ame_util.approverRecord2 default ame_util.emptyApproverRecord2;
l_approval_status varchar2(30);
l_application_id number := 9000;
l_approver_type varchar2(30);
l_act_approver_id number;
l_permission varchar2(40);
l_min_reassign_level  number;
l_action_code varchar2(30);
l_updateItemIn boolean := false;
l_user_name varchar2(200);
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.UPDATE_USER_ACTION';

CURSOR csr_person_user (p_source_id IN NUMBER )IS
select fu.user_id, fu.user_name
from  fnd_user fu
where fu.employee_id = p_source_id;


CURSOR csr_curr_approver (p_object_type IN VARCHAR2, p_object_id IN NUMBER,
                          p_action_performed IN VARCHAR2 )IS

SELECT daa.approval_access_id, fu.user_id, fu.user_name
FROM   DPP_APPROVAL_ACCESS daa, FND_USER fu
WHERE  daa.approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id
AND    daa.approver_id = DECODE(daa.approver_type, 'PERSON', fu.employee_id, fu.user_id)
AND    fu.user_id = p_action_performed
AND    rownum < 2;

CURSOR csr_count_approvers (p_object_type IN VARCHAR2, p_object_id IN NUMBER )IS
SELECT count(1)
FROM   DPP_APPROVAL_ACCESS
WHERE  approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id;

CURSOR csr_check_reassign_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(min(approval_level),0)
FROM   DPP_APPROVAL_ACCESS
WHERE  object_type = p_object_type
AND    approval_access_flag = 'Y'
AND    object_id   = p_object_id;

CURSOR csr_approver_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(max(approval_level),0)
FROM   DPP_APPROVAL_ACCESS
WHERE  object_type = p_object_type
AND    object_id   = p_object_id;


BEGIN

    -- Standard begin of API savepoint Update_User_Action_PVT
    SAVEPOINT  Update_User_Action_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get Current Approver and update their access
    OPEN csr_curr_approver(p_approval_rec.object_type, p_approval_rec.object_id,
                            p_approval_rec.action_performed_by);

        FETCH csr_curr_approver INTO l_approval_access_id, l_approver_id, l_user_name;

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_approval_access_id :  ' || l_approval_access_id);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_approver_id :  ' || l_approver_id);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_user_name :  ' || l_user_name);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.action_performed_by : ' || p_approval_rec.action_performed_by);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_type : ' || p_approval_rec.object_type);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_id : ' || p_approval_rec.object_id);

        UPDATE DPP_APPROVAL_ACCESS
        SET    action_code = p_approval_rec.action_code
        ,      action_date = SYSDATE
        ,      action_performed_by = p_approval_rec.action_performed_by
        WHERE  approval_access_id = l_approval_access_id;

        l_approver_found := 'Y';

    CLOSE csr_curr_approver;
    IF l_approver_found = 'N' THEN

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'it comes here l_approver_found :  '||l_approver_found);

       -- get current approval level
       OPEN csr_approver_level (p_approval_rec.object_type, p_approval_rec.object_id);
          FETCH csr_approver_level INTO l_approver_level;
       CLOSE csr_approver_level;

--       -- construct approvers table
       l_approvers_tbl := approvers_tbl_type();
       l_approvers_tbl.extend;
       l_approvers_tbl(1).approver_type := 'USER';
       l_approvers_tbl(1).approver_id := p_approval_rec.action_performed_by;
       l_approvers_tbl(1).approver_level := l_approver_level;
       -- Add_Access  - List Approvers sent from Get_Approvers api
       Add_Access(
           p_api_version       => p_api_version
          ,p_init_msg_list     => FND_API.G_FALSE
          ,p_commit            => FND_API.G_FALSE
          ,p_validation_level  => p_validation_level
          ,x_return_status     => x_return_status
          ,x_msg_data          => x_msg_data
          ,x_msg_count         => x_msg_count
          ,p_approval_rec      => p_approval_rec
          ,p_approvers         => l_approvers_tbl );

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       -- Update approval access table to revoke access
       UPDATE DPP_APPROVAL_ACCESS
       SET    action_code = p_approval_rec.action_code
       ,      action_date = SYSDATE
       ,      action_performed_by = p_approval_rec.action_performed_by
       WHERE  object_type = p_approval_rec.object_type
       AND    object_id = p_approval_rec.object_id
       AND    approver_id = p_approval_rec.action_performed_by
       AND    approval_level = l_approver_level;

    END IF;

     OPEN csr_check_reassign_level (p_approval_rec.object_type, p_approval_rec.object_id);
        FETCH csr_check_reassign_level INTO l_min_reassign_level;
     CLOSE csr_check_reassign_level;

    -- Debug Message

     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Approval done by user in approval list? ' || l_approver_found );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Approver User Id ' || p_approval_rec.action_performed_by );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Approver Action ' || p_approval_rec.action_code );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Approver Type ' || l_approver_type );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Act Approver User Id ' || l_act_approver_id );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Act Approver Person/User Id ' || l_approver_id );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Minimum Reassign Level ' || l_min_reassign_level );
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_action_code ' || l_action_code );

    /*
    Check for minimum Reassign Level is added because , if it is 0 then the case is No AME Rule was
    found for Transaction and Default approver was found from profile
    */
    if l_min_reassign_level <> 0  AND l_action_code is NULL then
    -- Update AME with approvers action

         dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Inside if l_min_reassign_level <> 0  AND l_action_code is NULL then' );

         l_ame_approver_rec.orig_system_id := l_approver_id;

         IF p_approval_rec.action_code = 'REJECT' THEN

            dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'IF p_approval_rec.action_code = REJECT THEN' );

		-- Rejection of Request
		l_ame_approver_rec.approval_status := AME_UTIL.rejectStatus;

	    ELSIF p_approval_rec.action_code = 'APPROVE' THEN

              dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'ELSIF p_approval_rec.action_code = APPROVE THEN' );

		-- Approval of Request
		l_ame_approver_rec.approval_status := AME_UTIL.approvedStatus;
          END IF;


      l_ame_approver_rec.name := l_user_name;

      IF l_approver_found = 'N' THEN
         l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;
      ELSE
         l_ame_approver_rec.api_insertion  := ame_util.oamGenerated;
      END IF;


      AME_API2.updateApprovalStatus(applicationIdIn   => l_application_id
                           ,transactionIdIn   => p_approval_rec.object_id
                           ,approverIn        => l_ame_approver_rec
                           ,transactionTypeIn => p_approval_rec.object_type
                           );
	end if; -- End if minimum reassign Level not 0

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Revoke Access ' || p_approval_rec.action_code  );

       -- Revoke_Access  - Revoke acces to previous appprovers in the chain
       Revoke_Access(
           p_api_version       => p_api_version
          ,p_init_msg_list     => FND_API.G_FALSE
          ,p_validation_level  => p_validation_level
          ,x_return_status     => x_return_status
          ,x_msg_data          => x_msg_data
          ,x_msg_count         => x_msg_count
          ,p_object_type       => p_approval_rec.object_type
          ,p_object_id         => p_approval_rec.object_id);

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Update_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Update_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Update_User_Action;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_Approvers
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Approvers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,x_approvers           OUT NOCOPY approvers_tbl_type
   ,x_final_approval_flag OUT NOCOPY VARCHAR2
)
IS


l_api_name CONSTANT varchar2(80) := 'Get_Approvers';
l_api_version CONSTANT number := 1.0;
l_application_id number := 9000;
l_object_type    varchar2(30) := p_approval_rec.object_type;
l_object_id      varchar2(30) := p_approval_rec.object_id;
l_next_approver  ame_util.approversTable2;
l_approver_level number;
l_resource_id number;
l_approvalProcessCompleteYNOut VARCHAR2(100);
l_currApprRec ame_util.approverRecord2;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.GET_APPROVERS';

CURSOR csr_approver_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(max(approval_level),0)
FROM   DPP_APPROVAL_ACCESS
WHERE  object_type = p_object_type
AND    object_id   = p_object_id;

BEGIN

    -- Standard begin of API savepoint
    SAVEPOINT  Get_Approvers_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN csr_approver_level (l_object_type, l_object_id);
       FETCH csr_approver_level INTO l_approver_level;
    CLOSE csr_approver_level;

    -- increment approval level by 1 for next approval;
    l_approver_level := l_approver_level + 1;

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_application_id:'|| l_application_id);
    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_id:'|| p_approval_rec.object_id);
    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_type:'|| p_approval_rec.object_type);

    -- Get Approver list from Approvals Manager
      AME_API2.getNextApprovers4(applicationIdIn   => l_application_id,
                              transactionTypeIn => p_approval_rec.object_type,
                              transactionIdIn   => p_approval_rec.object_id,
                              approvalProcessCompleteYNOut => l_approvalProcessCompleteYNOut,
                              nextApproversOut   => l_next_approver);

        FOR i IN 1..l_next_approver.COUNT LOOP

dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.name : ' || l_next_approver(i).name);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.orig_system : ' || l_next_approver(i).orig_system);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.orig_system_id : ' || l_next_approver(i).orig_system_id);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.display_name : ' || l_next_approver(i).display_name);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.approver_category : ' || l_next_approver(i).approver_category);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.api_insertion : ' || l_next_approver(i).api_insertion);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.authority : ' || l_next_approver(i).authority);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.approval_status : ' || l_next_approver(i).approval_status);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.action_type_id : ' || l_next_approver(i).action_type_id);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.group_or_chain_id : ' || l_next_approver(i).group_or_chain_id);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.occurrence : ' || l_next_approver(i).occurrence);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.source : ' || l_next_approver(i).source);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.item_class : ' || l_next_approver(i).item_class);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.item_id: ' || l_next_approver(i).item_id);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.item_class_order_number : ' || l_next_approver(i).item_class_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.item_order_number : ' || l_next_approver(i).item_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.sub_list_order_number : ' || l_next_approver(i).sub_list_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.action_type_order_number : ' || l_next_approver(i).action_type_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.group_or_chain_order_number : ' || l_next_approver(i).group_or_chain_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.member_order_number : ' || l_next_approver(i).member_order_number);
dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_next_approver.approver_order_number : ' || l_next_approver(i).approver_order_number);

        END LOOP;

    --IF l_next_approver.person_id IS NULL       AND
    --   l_next_approver.user_id  IS NULL        AND
    --   l_next_approver.approval_status IS NULL
    --THEN

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get_Approvers:l_approvalProcessCompleteYNOut ' || l_approvalProcessCompleteYNOut);

    IF l_approvalProcessCompleteYNOut=ame_util2.completeNoApprovers THEN

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'AME did not return any approvers in AME_API.getNextApprover call');

       -- If first approval, get default approver from profile
       IF p_approval_rec.action_code = 'SUBMIT' THEN

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Defulting to 1 as default approver');

          -- Get default approver
          x_approvers := approvers_tbl_type ();
          x_approvers.extend;
          x_approvers(1).approver_type := 'USER';
          -- get user from profile (default approver)
	  IF p_approval_rec.object_type = 'PRICE PROTECTION' THEN
	      x_approvers(1).approver_id := to_number(fnd_profile.value('DPP_TXN_DEFAULT_APPROVER'));
	  END IF;
          x_approvers(1).approver_level := 0;
          x_final_approval_flag := 'N';

       END IF;
       -- If final approval, convey that information
       IF p_approval_rec.action_code = 'APPROVE' THEN

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Setting to final approval');

          x_final_approval_flag := 'Y';
       END IF;
      ELSE

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get_Approvers : l_next_approver.COUNT ' || l_next_approver.COUNT);
        FOR i IN 1..l_next_approver.COUNT LOOP
           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get_Approvers : l_next_approver.orig_system ' || l_next_approver(i).orig_system);
           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get_Approvers : l_next_approver.orig_system_id ' || l_next_approver(i).orig_system_id);
        END LOOP;

      IF l_approvalProcessCompleteYNOut = ame_util.booleanTrue THEN
         x_final_approval_flag := 'Y';
      ELSE
         x_final_approval_flag := 'N';
      END IF;
       -- Construct the out record of approvers
       x_approvers := approvers_tbl_type();
       --x_approvers.extend;

        FOR i IN 1..l_next_approver.COUNT LOOP
         l_currApprRec := l_next_approver(i);

		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'getapprovers inside for loop l_currApprRec.orig_system ' || l_currApprRec.orig_system);

             x_approvers.extend;
          IF (l_currApprRec.orig_system = 'FND_USR') then
            x_approvers(i).approver_type := 'USER';
            x_approvers(i).approver_id := l_currApprRec.orig_system_id;
        else
            x_approvers(i).approver_type := 'PERSON';
            x_approvers(i).approver_id := l_currApprRec.orig_system_id;
	end if;
       x_approvers(i).approver_level := l_currApprRec.approver_order_number;--l_approver_level;
      END LOOP;
     END IF;

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_Approvers_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Approvers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Get_Approvers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Get_Approvers;
---------------------------------------------------------------------
-- PROCEDURE
--    Get_AllApprovers
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_AllApprovers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,p_approversOut        OUT NOCOPY approversTable
)
IS
l_api_name               CONSTANT varchar2(80) := 'Get_AllApprovers';
l_api_version            CONSTANT number := 1.0;
l_application_id         NUMBER := 9000;
l_approversOut           ame_util.approversTable2;
l_approver_id            NUMBER;
l_first_name             VARCHAR2(150);
l_last_name              VARCHAR2(150);
l_approver_email         VARCHAR2(240);
l_approver_group_name    VARCHAR2(50);
l_approver_sequence      NUMBER;
l_approvalProcessCompleteYNOut VARCHAR2(100);
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.GET_ALLAPPROVERS';

BEGIN
-- Standard begin of API savepoint
   SAVEPOINT  Get_AllApprovers_PVT;
-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
   THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

--Initialize message list if p_init_msg_list is TRUE.
  IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;
--Initialize API return status to sucess
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_application_id:'|| l_application_id);
  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_id:'|| p_approval_rec.object_id);
  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_type:'|| p_approval_rec.object_type);

--Get all the approvers for this transaction from Approvals Manager
  ame_api2.getAllApprovers7
    (applicationIdIn                => l_application_id
    ,transactionTypeIn              => p_approval_rec.object_type
    ,transactionIdIn                => p_approval_rec.object_id
    ,approvalProcessCompleteYNOut   => l_approvalProcessCompleteYNOut
    ,approversOut                   => l_approversOut);

  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'ame_api2.getAllApprovers7 l_approversOut.COUNT : '|| l_approversOut.COUNT);
  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'ame_api2.getAllApprovers7 l_approvalProcessCompleteYNOut : '|| l_approvalProcessCompleteYNOut);

  IF l_approversOut.COUNT = 0   THEN         --No approver found in AME

     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'AME did not return any approvers in AME_API.getAllApprovers call');
     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get the default approver from the profile value');

     -- Get default approver from profile (default approver)
     IF p_approval_rec.object_type = 'PRICE PROTECTION' THEN
        l_approver_id := to_number(fnd_profile.value('DPP_TXN_DEFAULT_APPROVER'));
        --Retrieve the first name and the last name of the approver from the per_persons_f table.
        BEGIN
           SELECT first_name,
                  last_name
             INTO l_first_name,
                  l_last_name
             FROM per_people_f
            WHERE person_id = l_approver_id
              AND rownum <2;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              FND_MESSAGE.set_name('DPP', 'DPP_AME_NO_APP');
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
              fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
              fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
              fnd_message.set_token('ERRNO', sqlcode);
              fnd_message.set_token('REASON', sqlerrm);
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        p_approversOut(1).first_name := l_first_name;
        p_approversOut(1).last_name := l_last_name;
     ELSE
        FND_MESSAGE.set_name('DPP', 'DPP_AME_NO_APP');
        FND_MSG_PUB.add;

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'No default approver set for the object type : '||p_approval_rec.object_type);

     END IF;
  ELSE                 -- Approver set up found in AME

     dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'AME returned approvers');

     --Assign the value to the out table type
     FOR i IN l_approversOut.FIRST..l_approversOut.LAST LOOP
        --Check if the person id is returned
        IF l_approversOut(i).orig_system_id IS NOT NULL THEN

           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Person ID : '||l_approversOut(i).orig_system_id);
           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Orig System : '||l_approversOut(i).orig_system);

           BEGIN
              SELECT email_address
                INTO l_approver_email
                FROM wf_roles
                WHERE orig_system_id = l_approversOut(i).orig_system_id
                AND orig_system = l_approversOut(i).orig_system;

           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_approver_email ' || l_approver_email);

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                    l_approver_email := NULL;
                    FND_MESSAGE.set_name('DPP', 'DPP_NO_APP_DETAIL');
                    FND_MSG_PUB.add;
                    RAISE FND_API.G_EXC_ERROR;
                 WHEN OTHERS THEN
                    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                    fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
                    fnd_message.set_token('ERRNO', sqlcode);
                    fnd_message.set_token('REASON', sqlerrm);
                    FND_MSG_PUB.add;
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END;
        ELSE                      -- Both the person id and the user id are null

           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'No details retrieved for the Approver ');

           FND_MESSAGE.set_name('DPP', 'DPP_NO_APP_DETAIL');
           FND_MSG_PUB.add;
           l_approver_email := NULL;
        END IF;     --l_approversOut(i).person_id IS NOT NULL
        --Retrieve the approval group name
        BEGIN
           SELECT name
             INTO l_approver_group_name
             FROM ame_approval_groups
            WHERE approval_group_id = l_approversOut(i).group_or_chain_id;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.set_name('DPP', 'DPP_NO_APP_GRP_DETAIL');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --Retrieve the order number
        BEGIN
           SELECT order_number
             INTO l_approver_sequence
             FROM AME_APPROVAL_GROUP_MEMBERS
            WHERE approval_group_id = l_approversOut(i).group_or_chain_id
              AND orig_system_id = l_approversOut(i).orig_system_id; --nvl(l_approversOut(i).orig_system_id,l_approversOut(i).user_id);
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
             FND_MESSAGE.set_name('DPP', 'DPP_NO_APP_SEQ');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --Assign the approver details to the out variable
          p_approversOut(i).user_id := l_approversOut(i).orig_system_id;
          p_approversOut(i).person_id := l_approversOut(i).orig_system_id;
          p_approversOut(i).first_name := l_approversOut(i).display_name;
          p_approversOut(i).last_name := '    ';
          p_approversOut(i).api_insertion := l_approversOut(i).api_insertion;
          p_approversOut(i).authority := l_approversOut(i).authority;
          p_approversOut(i).approval_status := l_approversOut(i).approval_status;
          p_approversOut(i).approval_type_id := l_approversOut(i).action_type_id;
          p_approversOut(i).group_or_chain_id := l_approversOut(i).group_or_chain_id;
          p_approversOut(i).occurrence := l_approversOut(i).occurrence;
          p_approversOut(i).source := l_approversOut(i).source;
          p_approversOut(i).approver_email := l_approver_email;
          p_approversOut(i).approver_group_name := l_approver_group_name;
          p_approversOut(i).approver_sequence := l_approver_sequence;
     END LOOP;
  END IF;
-- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

--Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_AllApprovers_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_AllApprovers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Get_AllApprovers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Get_AllApprovers;

---------------------------------------------------------------------
-- PROCEDURE
--    Clear_All_Approvals
--
-- PURPOSE
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Clear_All_Approvals (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,x_msg_data               OUT NOCOPY   VARCHAR2

   ,p_txn_hdr_id             IN  NUMBER
)
IS
l_api_name CONSTANT varchar2(80) := 'Clear_All_Approvals';
l_api_version CONSTANT number := 1.0;
l_application_id number := 9000;
l_object_type    varchar2(30) := 'PRICE PROTECTION';
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.CLEAR_ALL_APPROVALS';

BEGIN
    -- Standard begin of API savepoint Update_User_Action_PVT
    SAVEPOINT  Clear_All_Approvals_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;


             AME_API2.clearAllApprovals(applicationIdIn   => l_application_id
                                ,transactionIdIn   => p_txn_hdr_id
                                ,transactionTypeIn => l_object_type
                                );

    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Clear_All_Approvals_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Clear_All_Approvals_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Clear_All_Approvals_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Clear_All_Approvals;

---------------------------------------------------------------------
-- PROCEDURE
--    Add_Access
--
-- PURPOSE
--    adds approvers access to table
--
-- PARAMETERS
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_return_status     OUT NOCOPY VARCHAR2

   ,p_approval_rec      IN  approval_rec_type
   ,p_approvers         IN  approvers_tbl_type
)
IS
l_api_name CONSTANT varchar2(80) := 'Add_Access';
l_api_version CONSTANT number := 1.0;
l_approval_access_id NUMBER;
l_workflow_itemkey   VARCHAR2(80);
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.ADD_ACCESS';

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_Access_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_approval_rec.object_type IS NULL THEN
       IF DPP_ERROR_ON THEN
          dpp_utility_pvt.error_message('OZF_OBJECT_TYPE_NOT_FOUND');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF p_approval_rec.object_id IS NULL THEN
       IF DPP_ERROR_ON THEN
          dpp_utility_pvt.error_message('OZF_OBJECT_ID_NOT_FOUND');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Validate if the approvers record is valid
    FOR i in 1..p_approvers.count LOOP

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'i ' || i);
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'add access for loop if approver type ' || p_approvers(i).approver_type);

        IF p_approvers(i).approver_type <> 'USER' and  p_approvers(i).approver_type <> 'PERSON' THEN
           IF DPP_ERROR_ON THEN
              dpp_utility_pvt.error_message('OZF_APPROVER_NOT_USER');
              x_return_status := FND_API.g_ret_sts_error;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

        IF p_approvers(i).approver_level IS NULL THEN
           IF DPP_ERROR_ON THEN
              dpp_utility_pvt.error_message('OZF_APPROVAL_LEVEL_NOT_FOUND');
              x_return_status := FND_API.g_ret_sts_error;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
    END LOOP;

    --Insert data into DPP_APPROVAL_ACCESS_all
    FOR i in 1..p_approvers.count LOOP

       BEGIN

		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'before Inserting data into DPP_APPROVAL_ACCESS table');
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_approval_access_id ' || l_approval_access_id);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'G_USER_ID ' || G_USER_ID);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'G_LOGIN_ID ' || G_LOGIN_ID);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_type ' || p_approval_rec.object_type);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approval_rec.object_id ' || p_approval_rec.object_id);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approvers(i).approver_level ' || p_approvers(i).approver_level);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approvers(i).approver_type ' || p_approvers(i).approver_type);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'p_approvers(i).approver_id ' || p_approvers(i).approver_id);
		 dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'l_workflow_itemkey ' || l_workflow_itemkey);

          INSERT INTO DPP_APPROVAL_ACCESS(
             approval_access_id
            ,object_version_number
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,object_type
            ,object_id
            ,approval_level
            ,approver_type
            ,approver_id
            ,approval_access_flag
            ,workflow_itemkey
          ) VALUES (
             DPP_APPROVAL_ACCESS_seq.NEXTVAL
            ,1
            ,SYSDATE
            ,G_USER_ID
            ,SYSDATE
            ,G_USER_ID
            ,G_LOGIN_ID
            ,p_approval_rec.object_type
            ,p_approval_rec.object_id
            ,p_approvers(i).approver_level
            ,p_approvers(i).approver_type
            ,p_approvers(i).approver_id
            ,'Y'
            ,l_workflow_itemkey
          );

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'after Inserting data into DPP_APPROVAL_ACCESS table');

       EXCEPTION
          WHEN OTHERS THEN
             IF DPP_ERROR_ON THEN
                dpp_utility_pvt.error_message('DPP_APPROVAL_ACCESS_INSERT_ERR');
                x_return_status := FND_API.g_ret_sts_error;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       END;
    END LOOP;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Add_Access_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Add_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Add_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Add_Access;
---------------------------------------------------------------------
-- PROCEDURE
--    Revoke_Access
--
-- PURPOSE
--    Revokes access to current approvers
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Revoke_Access (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER

   ,p_object_type            IN  VARCHAR2
   ,p_object_id              IN  NUMBER
)
IS
l_api_name CONSTANT varchar2(80) := 'Revoke_Access';
l_api_version CONSTANT number := 1.0;
l_approval_access_id number;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.REVOKE_ACCESS';

CURSOR csr_curr_approvers (p_object_type IN VARCHAR2, p_object_id IN NUMBER )IS
SELECT approval_access_id
FROM   DPP_APPROVAL_ACCESS
WHERE  approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id
AND action_code is not null;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Revoke_Access_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
            FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
            FND_MESSAGE.Set_Token('TEXT',l_api_name||': Start');
            FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Update records in DPP_APPROVAL_ACCESS_all to revoke access
    OPEN csr_curr_approvers(p_object_type, p_object_id);
       LOOP

		  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'inside revoke access');

          FETCH csr_curr_approvers INTO l_approval_access_id;
          EXIT WHEN csr_curr_approvers%NOTFOUND;

		  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'inside revoke access l_approval_access_id > ' || l_approval_access_id);

          -- Update approval access table to revoke access
          UPDATE DPP_APPROVAL_ACCESS
          SET    approval_access_flag = 'N'
          WHERE  approval_access_id = l_approval_access_id;

          -- Reset value to null
          l_approval_access_id := null;
       END LOOP;
    CLOSE csr_curr_approvers;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Inside Commit ');

       COMMIT WORK;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Revoke_Access_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Revoke_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Revoke_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Revoke_Access;
-----------------------------------------------
-- Return event name if the entered event exist
-- Otherwise return NOTFOUND
-----------------------------------------------
FUNCTION Check_Event(p_event_name IN VARCHAR2)
RETURN VARCHAR2
IS

CURSOR c_event_name IS
SELECT name
FROM wf_events
WHERE name = p_event_name;

l_event_name  VARCHAR2(240);

BEGIN

   OPEN c_event_name;
      FETCH c_event_name INTO l_event_name;
      IF c_event_name%NOTFOUND THEN
         l_event_name := 'NOTFOUND';
      END IF;
   CLOSE c_event_name;

   RETURN l_event_name;

END Check_Event;
------------------------------------------------------
-- Add Application-Context parameter to the enter list
------------------------------------------------------
PROCEDURE Construct_Param_List (
   x_list              IN OUT NOCOPY  WF_PARAMETER_LIST_T,
   p_user_id           IN VARCHAR2  DEFAULT NULL,
   p_resp_id           IN VARCHAR2  DEFAULT NULL,
   p_resp_appl_id      IN VARCHAR2  DEFAULT NULL,
   p_security_group_id IN VARCHAR2  DEFAULT NULL,
   p_org_id            IN VARCHAR2  DEFAULT NULL)
IS
l_user_id           VARCHAR2(255) := p_user_id;
l_resp_appl_id      VARCHAR2(255) := p_resp_appl_id;
l_resp_id           VARCHAR2(255) := p_resp_id;
l_security_group_id VARCHAR2(255) := p_security_group_id;
l_org_id            VARCHAR2(255) := p_org_id;
l_param             WF_PARAMETER_T;
l_rang              NUMBER;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.CONSTRUCT_PARAM_LIST';

BEGIN
   l_rang :=  0;

   IF l_user_id IS NULL THEN
     l_user_id := fnd_profile.value('USER_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName('USER_ID');
   l_param.SetValue(l_user_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_id IS NULL THEN
      l_resp_id := fnd_profile.value('RESP_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName('RESP_ID');
   l_param.SetValue(l_resp_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_resp_appl_id IS NULL THEN
      l_resp_appl_id := fnd_profile.value('RESP_APPL_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName('RESP_APPL_ID');
   l_param.SetValue(l_resp_appl_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF  l_security_group_id IS NULL THEN
       l_security_group_id := fnd_profile.value('SECURITY_GROUP_ID');
   END IF;
   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName('SECURITY_GROUP_ID');
   l_param.SetValue(l_security_group_id);
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

   IF l_org_id IS NULL THEN
      l_org_id :=  fnd_profile.value('ORG_ID');
   END IF;

   l_param := WF_PARAMETER_T( NULL, NULL );
   -- fill the parameters list
   x_list.extend;
   l_param.SetName('ORG_ID');
   l_param.SetValue(l_org_id );
   l_rang  := l_rang + 1;
   x_list(l_rang) := l_param;

END Construct_Param_List;
---------------------------------------------------------------------
-- PROCEDURE
--    Raise_Event
--
-- PURPOSE
--    Raise business event
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Raise_Event (
    x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
   ,p_event_name             IN  VARCHAR2
   ,p_event_key              IN  VARCHAR2
   --,p_data                   IN  CLOB DEFAULT NULL
   ,p_approval_rec           IN  approval_rec_type)
IS
l_api_name CONSTANT varchar2(80) := 'Raise_Event';
l_api_version CONSTANT number := 1.0;

l_item_key      VARCHAR2(240);
l_event         VARCHAR2(240);

l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
l_parameter_t     wf_parameter_t := wf_parameter_t(null, null);
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.RAISE_EVENT';

BEGIN

   SAVEPOINT Raise_Event_PVT;

   l_event := Check_Event(p_event_name);

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Event : ' || l_event);

--dpp_utility_pvt.error_message('Event Name', l_event);

   IF l_event = 'NOTFOUND' THEN
      IF DPP_ERROR_ON THEN
         dpp_utility_pvt.error_message('OZF_WF_EVENT_NAME_NULL', 'NAME', p_event_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_parameter_t.setName('OBJECT_TYPE');
   l_parameter_t.setValue(p_approval_rec.object_type);
   l_parameter_list.extend;
   l_parameter_list(1) := l_parameter_t;

   l_parameter_t.setName('OBJECT_ID');
   l_parameter_t.setValue(p_approval_rec.object_id);
   l_parameter_list.extend;
   l_parameter_list(2) := l_parameter_t;

   l_parameter_t.setName('STATUS_CODE');
   l_parameter_t.setValue(p_approval_rec.status_code);
   l_parameter_list.extend;
   l_parameter_list(3) := l_parameter_t;
    -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Event Raise :' || p_event_name);
   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Event Key  :' || p_event_key);

   -- Raise business event
   Wf_Event.Raise
   ( p_event_name   =>  p_event_name,
     p_event_key    =>  p_event_key,
     p_parameters   =>  l_parameter_list,
     p_event_data   =>  NULL);
     -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'event raised....');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Raise_Event_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Raise_Event_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Raise_Event_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Raise_Event;
---------------------------------------------------------------------
-- PROCEDURE
--    Send_Notification
--
-- PURPOSE
--    Sends notifications to approvers
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Send_Notification (
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status      OUT NOCOPY   VARCHAR2
   ,x_msg_data           OUT NOCOPY   VARCHAR2
   ,x_msg_count          OUT NOCOPY   NUMBER

   ,p_transaction_header_id   IN NUMBER
   ,p_msg_callback_api   IN VARCHAR2
   ,p_approval_rec       IN approval_rec_type
)
IS
l_api_name CONSTANT varchar2(80) := 'Send_Notification';
l_api_version CONSTANT number := 1.0;
l_object_type varchar2(30) := p_approval_rec.object_type;
l_object_id   number       := p_approval_rec.object_id;
l_status      varchar2(30) := p_approval_rec.status_code;
l_msg_callback_api varchar2(240) := p_msg_callback_api;
l_final_approval number;
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.SEND_NOTIFICATION';

CURSOR csr_final_approval (p_object_type varchar2, p_object_id number) IS
SELECT count(1)
FROM   dpp_approval_access
WHERE  object_type = p_object_type
AND    object_id = p_object_id
AND    approval_access_flag = 'Y';

CURSOR csr_approvers (p_object_type varchar2, p_object_id number) IS
SELECT fu.user_name
FROM   dpp_approval_access oaa
,      fnd_user fu
WHERE  oaa.object_type = p_object_type
AND    oaa.object_id = p_object_id
AND    oaa.approver_type = 'USER'
AND    oaa.approver_id = fu.user_id
AND    oaa.approval_access_flag = 'Y'
UNION
SELECT jre.user_name
FROM   dpp_approval_access oaa
,      jtf_rs_resource_extns jre
WHERE  oaa.object_type = p_object_type
AND    oaa.object_id = p_object_id
AND    oaa.approver_type = 'PERSON'
AND    oaa.approver_id = jre.source_id
AND    oaa.approval_access_flag = 'Y'
group by jre.user_name;

l_adhoc_role      varchar2(200);
l_role_list       varchar2(3000);
l_msg_type        varchar2(12) := 'DPPTXAPP';
l_msg_name        varchar2(30);
l_item_key        varchar2(200);
l_item_type       varchar2(30);

l_group_notify_id number;
l_context         varchar2(1000);
l_user_role       varchar2(240);

l_execute_str     varchar2(3000);

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Send_Notification_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_user_role is null THEN
       l_user_role := '%';
    ELSE
       l_user_role := l_user_role; -- p_user_role;
    END IF;

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Before constructing message ' || l_user_role || ' ' || l_object_id || '  ' || l_status);

    /*
    If Approved Status , Chek if it if Final Approval or  Not
    if Final Approval Then Send Approved Notification else Send Submitted Notification
    */
    if l_status  = 'APPROVED'  then
       OPEN csr_final_approval (l_object_type, l_object_id);
          FETCH csr_final_approval INTO l_final_approval;
       CLOSE csr_final_approval;
       if l_final_approval <> 0  then
            l_status := 'SUBMITTED_FOR_APPROVAL';
       end if;
    end if;

          l_msg_name := l_status||'01';
          l_role_list := '';

                FOR l_row IN csr_approvers(l_object_type, l_object_id) LOOP
                    l_role_list := l_role_list || ',' || l_row.user_name;
                END LOOP;
                l_role_list := substr(l_role_list,2);
 --          END IF;

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Users List for sending notification' || l_role_list);

          -- users returned from the search
         IF length(l_role_list) <> 0 THEN
             l_item_key := l_msg_type||'|'||l_msg_name||'|'||l_object_id||
                      '|'||to_char(sysdate,'YYYYMMDDHH24MISS');

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_item_key ' || l_item_key );

             IF l_object_type = 'PRICE PROTECTION' THEN
                l_item_type := 'DPPTXAPP';
             END IF;

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Creating process for itemtype:' || l_item_type || ' itemkey: ' || l_item_key);

             -- Create WF process to send notification
             wf_engine.CreateProcess ( ItemType => l_item_type,
                                       ItemKey  => l_item_key,
                                       process  => 'NOOP_PROCESS',
                                       user_key  => l_item_key);

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Executing msg callback' || l_msg_callback_api );

             -- execute callback api to set the message attributes
             EXECUTE IMMEDIATE 'BEGIN ' ||
                           l_msg_callback_api || '(:itemtype, :itemkey, :transaction_header_id, :status); ' ||
                          'END;'
             USING l_item_type, l_item_key, l_object_id, l_status;

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Adding adhoc users' || l_role_list );

             -- create an adhoc role with named after itemkey
             l_adhoc_role := l_item_key;

                        wf_directory.CreateAdHocRole(role_name         => l_adhoc_role,
                                          role_display_name => l_adhoc_role,
                                          role_users        => l_role_list);

             l_context := l_msg_type || ':' || l_item_key || ':';

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Sending Notification to adhoc role ' || l_msg_type || ' ' || l_msg_name);
             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Sent notification to role : ' || l_adhoc_role);

             -- set the message to be sent
             l_group_notify_id := wf_notification.sendGroup(
                                        role         => l_adhoc_role,
                                        msg_type     => l_msg_type,
                                        msg_name     => l_msg_name,
                                        due_date     => null,
                                        callback     => 'wf_engine.cb',
                                        context      => l_context,
                                        send_comment => NULL,
                                        priority     => NULL );

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Sending  notification to role : ' || l_adhoc_role);
             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Using message: ' || l_msg_name || '. Notify id: ' || l_group_notify_id );

             -- start the notification process to send message
             wf_engine.StartProcess(itemtype => l_item_type,
                                    itemkey  => l_item_key);
          -- no users returned from the search
          END IF;

    -- Update  WorkFlow Item Key in approval Access Table
    update DPP_APPROVAL_ACCESS
    set workflow_itemkey = substr(l_item_key,1,239)
    where object_type = l_object_type
    and object_id = l_object_id
    and approval_level = ( select max (approval_level)
              from DPP_APPROVAL_ACCESS
              where object_type = l_object_type
              and object_id = l_object_id);
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Send_Notification_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Send_Notification_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Send_Notification_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Send_Notification;
---------------------------------------------------------------------
-- PROCEDURE
--    Process_User_Action

--
-- PURPOSE
--    Handles the approvals and rejections of objects
--
-- PARAMETERS
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE  Process_User_Action (
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,x_return_status          OUT NOCOPY   VARCHAR2
  ,x_msg_data               OUT NOCOPY   VARCHAR2
  ,x_msg_count              OUT NOCOPY   NUMBER

  ,p_approval_rec           IN  approval_rec_type
  ,p_approver_id            IN  NUMBER
  ,x_final_approval_flag    OUT NOCOPY VARCHAR2
)
IS
l_api_name            CONSTANT VARCHAR2(80) := 'Process_User_Action';
l_api_version         CONSTANT NUMBER := 1.0;
l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;

l_approvers_tbl       approvers_tbl_type;
l_event_name          VARCHAR2(240) ;
l_event_key           VARCHAR2(240);
l_msg_callback_api    VARCHAR2(240);
l_benefit_id          NUMBER;
l_final_approval_flag VARCHAR2(1) := 'N';
l_txn_number          VARCHAR2(240);
l_effective_date      DATE;
l_org_id              NUMBER;
errbuff               VARCHAR2(4000);
retcode               VARCHAR2(10);
l_login_id 		NUMBER := FND_GLOBAL.LOGIN_ID;
l_user_id 		NUMBER := FND_PROFILE.VALUE('USER_ID');
l_module 		CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_APPROVAL_PVT.PROCESS_USER_ACTION';

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Process_User_Action_PVT;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
            l_api_version,
            p_api_version,
            l_api_name,
            G_PKG_NAME)
    THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': Start');

    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Retrieve the details of the transaction
    BEGIN
       SELECT transaction_number,
              effective_start_date,
              to_number(org_id)
         INTO l_txn_number,
              l_effective_date,
              l_org_id
         FROM dpp_transaction_headers_all
        WHERE transaction_header_id = p_approval_rec.object_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', 'Invalid Transaction Header ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    -- Update AME/approval tbl of users action and revoke access to existing approvers

    IF p_approval_rec.action_code = 'APPROVE' OR
       p_approval_rec.action_code = 'REJECT'  THEN

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Update User Action ' || p_approval_rec.action_code  );

       -- Update_User_Action  - Update the user action in approval table
       Update_User_Action(
           p_api_version       => p_api_version
          ,p_init_msg_list     => FND_API.G_FALSE
          ,p_validation_level  => p_validation_level
          ,x_return_status     => l_return_status
          ,x_msg_data          => x_msg_data
          ,x_msg_count         => x_msg_count
          ,p_approval_rec      => p_approval_rec);

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

       IF p_approval_rec.action_code = 'REJECT' THEN
          l_final_approval_flag := 'Y';
       END IF;
    END IF;

    -- If the request is submitted/approved - get next approvers
    IF p_approval_rec.action_code = 'SUBMIT' OR
       p_approval_rec.action_code = 'APPROVE'  THEN

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Get Approvers ' || p_approval_rec.action_code  );

       -- Get_Approvers - List of Approvers or Default Approver
       Get_Approvers(
           p_api_version         => p_api_version
          ,p_init_msg_list       => FND_API.G_FALSE
          ,p_validation_level    => p_validation_level
          ,x_return_status       => l_return_status
          ,x_msg_data            => x_msg_data
          ,x_msg_count           => x_msg_count
          ,p_approval_rec        => p_approval_rec
          ,x_approvers           => l_approvers_tbl
          ,x_final_approval_flag => l_final_approval_flag);

		dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'After Get_Approvers >> ' || l_approvers_tbl.count  );

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END IF;

    -- Add access to users who have approval privileges
    IF p_approval_rec.action_code = 'SUBMIT'   OR
       p_approval_rec.action_code = 'APPROVE'   THEN

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Add Access ' || p_approval_rec.action_code  );

       IF l_final_approval_flag <> 'Y' THEN
         --If no Approver Found Do not add record in Access table
        -- FOR i IN 1..l_approvers_tbl.COUNT LOOP
	  if l_approvers_tbl.count > 0 then --(i).approver_id is not null then
          -- Add_Access  - List Approvers sent from Get_Approvers api
             Add_Access(
                 p_api_version       => p_api_version
	         ,p_init_msg_list     => FND_API.G_FALSE
	         ,p_commit            => FND_API.G_FALSE
	         ,p_validation_level  => p_validation_level
	         ,x_return_status     => l_return_status
	         ,x_msg_data          => x_msg_data
	         ,x_msg_count         => x_msg_count
	         ,p_approval_rec      => p_approval_rec
	         ,p_approvers         => l_approvers_tbl);

             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;

             dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Access Added ' || x_return_status  );

	  END IF; --End if some Approver is found
     -- END LOOP;
      END IF;

    END IF;

    IF p_approval_rec.object_type = 'PRICE PROTECTION' THEN

       l_event_name  := 'oracle.apps.dpp.request.Transaction.approval';

	   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'assigning the event name :'||l_event_name);

    END IF;

    l_event_key := p_approval_rec.object_type || ':' || p_approval_rec.object_id || ':' || to_char(sysdate, 'DD:MON:YYYY HH:MI:SS');

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'process_user_action l_final_approval_flag : '|| l_final_approval_flag);
    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'process_user_action p_approval_rec.action_code : '|| p_approval_rec.action_code);

    IF p_approval_rec.object_type = 'PRICE PROTECTION' THEN
       IF l_final_approval_flag <> 'Y' or p_approval_rec.action_code <> 'APPROVE' THEN
          -- Raise_Event -> Event_Subscription -> Send_Notification
          Raise_Event (
             x_return_status     => l_return_status
             ,x_msg_data          => x_msg_data
             ,x_msg_count         => x_msg_count
             ,p_event_name        => l_event_name
             ,p_event_key         => l_event_key
             ,p_approval_rec      => p_approval_rec );

       END IF;
    ELSE
        Raise_Event (
           x_return_status     => l_return_status
          ,x_msg_data          => x_msg_data
          ,x_msg_count         => x_msg_count
          ,p_event_name        => l_event_name
          ,p_event_key         => l_event_key
          ,p_approval_rec      => p_approval_rec );

    END IF;

x_final_approval_flag := l_final_approval_flag;
--Check for the Final approval flag
  IF x_final_approval_flag = 'Y' AND p_approval_rec.action_code = 'APPROVE' THEN
     IF l_effective_date <= sysdate THEN
        BEGIN
           UPDATE dpp_transaction_headers_all
              SET transaction_status = 'APPROVED',
                  object_version_number = object_version_number + 1,
                  last_updated_by = l_user_id,
                  last_update_date = sysdate,
                  last_update_login = l_login_id
            WHERE transaction_header_id = p_approval_rec.object_id;

            IF SQL%ROWCOUNT = 0 THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Unable to Update  the column transaction_status in dpp_transaction_headers_all Table');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;

           DPP_EXECUTIONPROCESS_PVT.Update_HeaderLog(
                  p_api_version_number => 1.0
              ,   p_init_msg_list      => FND_API.G_FALSE
              ,   p_commit             => FND_API.G_FALSE
              ,   p_validation_level   => FND_API.G_VALID_LEVEL_FULL
              ,   x_return_status      => l_return_status
              ,   x_msg_count          => x_msg_count
              ,   x_msg_data           => x_msg_data
              ,   p_transaction_header_id => p_approval_rec.object_id
            ) ;

            IF G_DEBUG THEN
              fnd_file.put_line(fnd_file.log, ' Update_HeaderLog. Return Status: ' || l_return_status || ' Error Msg: ' || x_msg_data);
            END IF;

            IF l_return_status = Fnd_Api.g_ret_sts_error THEN
              RAISE Fnd_Api.g_exc_error;
            ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
              RAISE Fnd_Api.g_exc_unexpected_error;
            END IF;

        EXCEPTION
           WHEN FND_API.G_EXC_ERROR THEN
               RAISE Fnd_Api.g_exc_error;
           WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               RAISE Fnd_Api.g_exc_unexpected_error;
           WHEN OTHERS THEN
               ROLLBACK;
               fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
               fnd_message.set_token('ROUTINE', 'DPP_APPROVAL_PVT');
               fnd_message.set_token('ERRNO', sqlcode);
               fnd_message.set_token('REASON', sqlerrm);
               FND_MSG_PUB.add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END;
        --Call the Initiate execution process program to make the transaction Active
        DPP_EXECUTIONPROCESS_PVT.Initiate_ExecutionProcess(errbuff,
                                                           retcode,
                                                           l_org_id,
                                                           l_txn_number
                                                           );
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, substr(('Return status for Initiate_ExecutionProcess : ' || errbuff),1,4000));

        IF retcode = 0 THEN
           x_final_approval_flag := 'A';

           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Transaction is made Active ');

        ELSE

           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Initiate_ExecutionProcess Errored out. Transaction not made Active ');

        END IF;  --retcode = 0
     ELSE

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  'Transaction is Future dated and hence not made Active ');

     END IF;  --l_effective_date <= sysdate
  END IF;  --x_final_approval_flag := 'Y'
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message

    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module,  l_api_name||': End');

    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Process_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Process_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
   WHEN OTHERS THEN
        ROLLBACK TO  Process_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF DPP_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
        END IF;
--
END Process_User_Action;

END DPP_APPROVAL_PVT;

/
