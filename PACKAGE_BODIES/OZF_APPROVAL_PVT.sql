--------------------------------------------------------
--  DDL for Package Body OZF_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_APPROVAL_PVT" AS
/* $Header: ozfvappb.pls 120.5 2008/01/11 05:11:03 ateotia ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_APPROVAL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ozfvappb.pls';

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
--G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR_ON BOOLEAN :=FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR_ON BOOLEAN := FND_MSG_PUB.check_msg_level(fnd_msg_pub.g_msg_lvl_error);
G_DEBUG BOOLEAN := true ;--FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);

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
l_ame_approver_rec ame_util.approverRecord;
l_ame_forward_rec ame_util.approverRecord default ame_util.emptyApproverRecord;
l_approval_status varchar2(30);
l_application_id number := 682;
l_approver_type varchar2(30);
l_act_approver_id number;
l_is_super_user varchar2(1) := 'N';
l_super_user_count number;
l_approver_rec_count number;
l_permission varchar2(30);
l_min_reassign_level  number;
l_action_code varchar2(30);


CURSOR csr_person_user (p_source_id IN NUMBER )IS
select user_id
from jtf_rs_resource_extns
where source_id = p_source_id
and sysdate >= start_date_active
and sysdate <= nvl(end_date_active, sysdate)
and rownum < 2;

CURSOR csr_curr_approvers (p_object_type IN VARCHAR2, p_object_id IN NUMBER )IS
SELECT approval_access_id, approver_id, approver_type,action_code
FROM   ozf_approval_access
WHERE  approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id;


CURSOR csr_count_approvers (p_object_type IN VARCHAR2, p_object_id IN NUMBER )IS
SELECT count(1)
FROM   ozf_approval_access
WHERE  approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id;

CURSOR csr_check_reassign_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(min(approval_level),0)
FROM   ozf_approval_access
WHERE  object_type = p_object_type
AND    object_id   = p_object_id;

CURSOR csr_approver_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(max(approval_level),0)
FROM   ozf_approval_access
WHERE  object_type = p_object_type
AND    object_id   = p_object_id;

CURSOR crs_get_int_super_users(pc_permission varchar2, pc_userid number) is
      select count(1)
      from jtf_auth_principal_maps jtfpm,
      jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
      jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
      jtf_auth_permissions_b jtfperm, jtf_rs_resource_extns pj,
      fnd_user usr
      where PJ.user_name = jtfp1.principal_name
      and pj.category = 'EMPLOYEE'
      and usr.user_id       = pj.user_id
      and (usr.end_date > sysdate OR usr.end_date IS NULL)
      and jtfp1.is_user_flag=1
      and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
      and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
      and jtfp2.is_user_flag=0
      and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name = pc_permission
      and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
      and jtfd.domain_name='CRM_DOMAIN'
      and usr.user_id = pc_userid;


BEGIN
    -- Standard begin of API savepoint
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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    --Check if InComing User is Super User or Not
    if p_approval_rec.object_type = 'SPECIAL_PRICE'  then
       l_permission := 'OZF_SPECIAL_PRICE_SUPERUSER';
    else
       l_permission := 'OZF_SOFTFUND_SUPERUSER';
    end if;

    OPEN crs_get_int_super_users (l_permission, p_approval_rec.action_performed_by);
       FETCH crs_get_int_super_users INTO l_super_user_count ;
    CLOSE crs_get_int_super_users;
    if l_super_user_count = 0 then
       l_is_super_user := 'N';
    else
       l_is_super_user := 'Y';
    end if;



    /* Id super user and No Approvers are Present in Approval Access Table , that means
    No  Approver was defined for Request ( inc default Approver )
    */
    if l_is_super_user  = 'Y'  then
        OPEN csr_count_approvers(p_approval_rec.object_type, p_approval_rec.object_id);
	FETCH csr_count_approvers INTO l_approver_rec_count ;
	CLOSE csr_count_approvers;
	if l_approver_rec_count = 0  then
	    FND_MSG_PUB.Count_And_Get (
	       p_encoded => FND_API.G_FALSE,
	       p_count => x_msg_count,
	       p_data  => x_msg_data
	    );

	    RETURN;
	end if;
    end if;

    -- Get Current Approvers and update their access
    OPEN csr_curr_approvers(p_approval_rec.object_type, p_approval_rec.object_id);
       LOOP
          FETCH csr_curr_approvers INTO l_approval_access_id, l_approver_id, l_approver_type,l_action_code;
          EXIT WHEN csr_curr_approvers%NOTFOUND;

          --If Approver Type is Person Check, Get user Id of Person
          if l_approver_type = 'PERSON'  then
	     -- getting User id for the Person
             OPEN csr_person_user (l_approver_id);
                FETCH csr_person_user INTO l_act_approver_id ;
             CLOSE csr_person_user;
	  else
	     --Actual Approver is a User
	     l_act_approver_id := l_approver_id;
          end if;

          --IF l_approver_id = p_approval_rec.action_performed_by THEN
	  --As Action is always Performed by Approver check with User Id only
	  -- or action is performed by Super User
          IF l_is_super_user = 'Y'  OR l_act_approver_id = p_approval_rec.action_performed_by THEN
             -- Update approval access table to revoke access
             UPDATE ozf_approval_access
             SET    action_code = p_approval_rec.action_code
             ,      action_date = SYSDATE
             ,      action_performed_by = p_approval_rec.action_performed_by
             WHERE  approval_access_id = l_approval_access_id;

             l_approver_found := 'Y';
          END IF;
          -- Reset value to null
          l_approval_access_id := null;

       END LOOP;
    CLOSE csr_curr_approvers;

    IF l_approver_found = 'N' THEN

       -- get current approval level
       OPEN csr_approver_level (p_approval_rec.object_type, p_approval_rec.object_id);
          FETCH csr_approver_level INTO l_approver_level;
       CLOSE csr_approver_level;

       -- construct approvers table
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
       UPDATE ozf_approval_access
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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Approval done by user in approval list? ' || l_approver_found );
       ozf_utility_pvt.debug_message( 'Approver User Id ' || p_approval_rec.action_performed_by );
       ozf_utility_pvt.debug_message( 'Approver Action ' || p_approval_rec.action_code );
       ozf_utility_pvt.debug_message( 'Approver Type ' || l_approver_type );
       ozf_utility_pvt.debug_message( 'Act Approver User Id ' || l_act_approver_id );
       ozf_utility_pvt.debug_message( 'Act Approver Person/User Id ' || l_approver_id );
       ozf_utility_pvt.debug_message( 'Is Super User ' || l_is_super_user );
       ozf_utility_pvt.debug_message( 'Minimum Reassign Level ' || l_min_reassign_level );
       ozf_utility_pvt.debug_message( 'l_action_code ' || l_action_code );
    END IF;

    /*
    Check for minimum Reassign Level is added because , if it is 0 then the case is No AME Rule was
    found for Transaction adn Default approver was found from profile
    03/20/04 by feliu: to check l_action_code. when budget line get rejected, we can not go to ame to update status.
    */
    if l_min_reassign_level <> 0  AND l_action_code is NULL then

	    -- Update AME with approvers action
	    /*
	    type approverRecord is record(
	    user_id fnd_user.user_id%type,
	    person_id per_all_people_f.person_id%type,
	    first_name per_all_people_f.first_name%type,
	    last_name per_all_people_f.last_name%type,
	    api_insertion varchar2(1),
	    authority varchar2(1),
	    approval_status varchar2(50),
	    approval_type_id integer,
	    group_or_chain_id integer,
	    occurrence integer,
	    source varchar2(500));
	    */
	    if  l_approver_type = 'PERSON'  then
	       l_ame_approver_rec.person_id := l_approver_id;
	    else
	       if l_is_super_user = 'Y' then
		   l_ame_approver_rec.user_id := l_act_approver_id;
		else
		   l_ame_approver_rec.user_id := p_approval_rec.action_performed_by;
	       end if ;
	    end if;

	    l_ame_approver_rec.authority := ame_util.authorityApprover;

	    IF  p_approval_rec.action_code = 'FORWARD' THEN -- FORWARD
		l_ame_approver_rec.approval_status := AME_UTIL.forwardStatus;
		l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;

		-- Reassignment of Request. create a forwadee record
		--use the Forwarder User id
		l_ame_forward_rec.user_id  :=  G_FORWARD_USER;
		IF l_approver_found = 'N' THEN
		   l_ame_forward_rec.api_insertion  := ame_util.apiAuthorityInsertion;
		ELSE
		  l_ame_forward_rec.api_insertion  := ame_util.apiAuthorityInsertion;
		END IF;
		l_ame_forward_rec.authority := ame_util.authorityApprover;


	    ELSIF p_approval_rec.action_code = 'REJECT' THEN
		-- Rejection of Request
		IF l_approver_found = 'N' THEN
		   l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;
		ELSE
		   l_ame_approver_rec.api_insertion  := ame_util.oamGenerated;
		END IF;
		l_ame_approver_rec.approval_status := AME_UTIL.rejectStatus;

	    ELSIF p_approval_rec.action_code = 'RETURN' THEN
		-- Rejection of Request
		IF l_approver_found = 'N' THEN
		   l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;
		ELSE
		   l_ame_approver_rec.api_insertion  := ame_util.oamGenerated;
		END IF;
		l_ame_approver_rec.approval_status := AME_UTIL.rejectStatus;

	    ELSIF p_approval_rec.action_code = 'APPROVE' THEN
		-- Approval of Request
		IF l_approver_found = 'N' THEN
		   l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;
		ELSE
		   l_ame_approver_rec.api_insertion  := ame_util.oamGenerated;
		END IF;
		l_ame_approver_rec.approval_status := AME_UTIL.approvedStatus;
	    END IF;


	    -- Update AME of Approval Status
	    AME_API.updateApprovalStatus(applicationIdIn   => l_application_id
				   ,transactionIdIn   => p_approval_rec.object_id
				   ,approverIn        => l_ame_approver_rec
				   ,transactionTypeIn => p_approval_rec.object_type
				   ,forwardeeIn       => l_ame_forward_rec
				   );
	end if; -- End if minimum reassign Level not 0

       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Revoke Access ' || p_approval_rec.action_code  );
       END IF;
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


     IF l_min_reassign_level <> 0  THEN
        IF p_approval_rec.action_code = 'REJECT' OR p_approval_rec.action_code = 'RETURN' THEN
             AME_API.clearAllApprovals(applicationIdIn   => l_application_id
                                ,transactionIdIn   => p_approval_rec.object_id
                                ,transactionTypeIn => p_approval_rec.object_type
                                );
        END IF;

    END IF;

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Update_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Update_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
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
l_application_id number := 682;
l_object_type    varchar2(30) := p_approval_rec.object_type;
l_object_id      number := p_approval_rec.object_id;
l_next_approver  AME_UTIL.approverRecord;
l_approver_level number;
l_resource_id number;
--l_ame_approver_rec ame_util.approverRecord;
--l_ame_forward_rec ame_util.approverRecord default ame_util.emptyApproverRecord;

CURSOR csr_approver_level (p_object_type in varchar2, p_object_id in number) IS
SELECT nvl(max(approval_level),0)
FROM   ozf_approval_access
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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
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


    -- Get Approver list from Approvals Manager
    AME_API.getNextApprover(applicationIdIn   => l_application_id
                           ,transactionIdIn   => p_approval_rec.object_id
                           ,transactionTypeIn => p_approval_rec.object_type
                           ,nextApproverOut   => l_next_approver
                           );


    IF l_next_approver.person_id IS NULL       AND
       l_next_approver.user_id  IS NULL        AND
       l_next_approver.approval_status IS NULL
    THEN
       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'AME did not return any approvers');
       END IF;

       -- If first approval, get default approver from profile
       IF p_approval_rec.action_code = 'SUBMIT' THEN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Defulting to 1 as default approver');
          END IF;
          -- Get default approver
          x_approvers := approvers_tbl_type ();
          x_approvers.extend;
          x_approvers(1).approver_type := 'USER';
          -- get user from profile (defaulat approver)
	  IF p_approval_rec.object_type = 'SPECIAL_PRICE' THEN
	      x_approvers(1).approver_id := to_number(fnd_profile.value('OZF_SP_DEFAULT_APPROVER'));
	   ELSIF p_approval_rec.object_type = 'SOFT_FUND' THEN
	      x_approvers(1).approver_id := to_number(fnd_profile.value('OZF_SF_DEFAULT_APPROVER'));
	  END IF;


          x_approvers(1).approver_level := 0;
          x_final_approval_flag := 'N';

/*
	  --Insert Default Approver into Group
	  l_ame_approver_rec.user_id := x_approvers(1).approver_id;
	  l_ame_approver_rec.authority := ame_util.authorityApprover;
	  l_ame_approver_rec.api_insertion  := ame_util.apiAuthorityInsertion;
	  l_ame_approver_rec.approval_status := AME_UTIL.noResponseStatus;

          AME_API.updateApprovalStatus(applicationIdIn   => l_application_id
                           ,transactionIdIn   => p_approval_rec.object_id
                           ,approverIn        => l_ame_approver_rec
                           ,transactionTypeIn => p_approval_rec.object_type
                           ,forwardeeIn       => l_ame_forward_rec
                           );
*/

       END IF;

       -- If final approval, convey that information
       IF p_approval_rec.action_code = 'APPROVE' THEN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Setting to final approval');
          END IF;
          x_final_approval_flag := 'Y';
       END IF;
    ELSE
       /*
       -- Get resoutce id
       l_resource_id := ozf_utility_pvt.get_resource_id (l_next_approver.user_id);

       -- raise error if resource is null
       IF l_resource_id IS NULL THEN
          IF OZF_ERROR_ON THEN
             ozf_utility_pvt.error_message('OZF_APPROVER_NOT_RESOURCE');
             x_return_status := FND_API.g_ret_sts_error;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
       */

       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'AME returned approvers');
       END IF;
       x_final_approval_flag := 'N';
       -- Construct the out record of approvers
       x_approvers := approvers_tbl_type ();
       x_approvers.extend;
       if l_next_approver.user_id   is null then
            x_approvers(1).approver_type := 'PERSON';
            x_approvers(1).approver_id := l_next_approver.person_id;
        else
            x_approvers(1).approver_type := 'USER';
            x_approvers(1).approver_id := l_next_approver.user_id;
	end if;
       x_approvers(1).approver_level := l_approver_level;
    END IF;

    -- Debug Message
    /*
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End' ||  x_approvers(1).approver_id);
    END IF;
    */
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_Approvers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Get_Approvers_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Get_Approvers;
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

CURSOR c_id IS
SELECT ozf_approval_access_s.NEXTVAL
FROM dual;

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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get Primary Key
    OPEN c_id;
       FETCH c_id INTO l_approval_access_id;
    CLOSE c_id;

    IF p_approval_rec.object_type IS NULL THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_OBJECT_TYPE_NOT_FOUND');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF p_approval_rec.object_id IS NULL THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_OBJECT_ID_NOT_FOUND');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Validate if the approvers record is valid
    FOR i in 1..p_approvers.count LOOP
        IF p_approvers(i).approver_type <> 'USER' and  p_approvers(i).approver_type <> 'PERSON' THEN
           IF OZF_ERROR_ON THEN
              ozf_utility_pvt.error_message('OZF_APPROVER_NOT_USER');
              x_return_status := FND_API.g_ret_sts_error;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
        --IF NOT resource_valid(p_approvers(i).approver_id) THEN
        --   IF OZF_ERROR_ON THEN
        --      ozf_utility_pvt.error_message('OZF_APPROVER_NOT_RESOURCE');
        --      x_return_status := FND_API.g_ret_sts_error;
        --      RAISE FND_API.G_EXC_ERROR;
        --   END IF;
        --END IF;
        IF p_approvers(i).approver_level IS NULL THEN
           IF OZF_ERROR_ON THEN
              ozf_utility_pvt.error_message('OZF_APPROVAL_LEVEL_NOT_FOUND');
              x_return_status := FND_API.g_ret_sts_error;
              RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;
    END LOOP;

    --Insert data into ozf_approval_access_all
    FOR i in 1..p_approvers.count LOOP
       BEGIN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Inserting data into OZF_APPROVAL_ACCESS table');
          END IF;
          --
          INSERT INTO OZF_APPROVAL_ACCESS(
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
             l_approval_access_id
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
       EXCEPTION
          WHEN OTHERS THEN
             IF OZF_ERROR_ON THEN
                ozf_utility_pvt.error_message('OZF_APPROVAL_ACCESS_INSERT_ERR');
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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Add_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Add_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
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

CURSOR csr_curr_approvers (p_object_type IN VARCHAR2, p_object_id IN NUMBER )IS
SELECT approval_access_id
FROM   ozf_approval_access
WHERE  approval_access_flag = 'Y'
AND    object_type = p_object_type
AND    object_id = p_object_id;

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

    -- Update records in ozf_approval_access_all to revoke access
    OPEN csr_curr_approvers(p_object_type, p_object_id);
       LOOP
          FETCH csr_curr_approvers INTO l_approval_access_id;
          EXIT WHEN csr_curr_approvers%NOTFOUND;

          -- Update approval access table to revoke access
          UPDATE ozf_approval_access
          SET    approval_access_flag = 'N'
          WHERE  approval_access_id = l_approval_access_id;

          -- Reset value to null
          l_approval_access_id := null;
       END LOOP;
    CLOSE csr_curr_approvers;

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Revoke_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Revoke_Access_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
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

BEGIN

   SAVEPOINT Raise_Event_PVT;

   l_event := Check_Event(p_event_name);

   IF l_event = 'NOTFOUND' THEN
      IF OZF_ERROR_ON THEN
         ozf_utility_pvt.error_message('OZF_WF_EVENT_NAME_NULL', 'NAME', p_event_name);
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

   -- Raise business event
   Wf_Event.Raise
   ( p_event_name   =>  p_event_name,
     p_event_key    =>  p_event_key,
     p_parameters   =>  l_parameter_list,
     p_event_data   =>  NULL);

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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Raise_Event_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Raise_Event_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
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

   ,p_benefit_id         IN NUMBER
   ,p_partner_id         IN NUMBER
   ,p_msg_callback_api   IN VARCHAR2
   ,p_user_callback_api  IN VARCHAR2
   ,p_approval_rec       IN approval_rec_type
)
IS
l_api_name CONSTANT varchar2(80) := 'Send_Notification';
l_api_version CONSTANT number := 1.0;
l_object_type varchar2(30) := p_approval_rec.object_type;
l_object_id   number       := p_approval_rec.object_id;
l_status      varchar2(30) := p_approval_rec.status_code;
l_msg_callback_api varchar2(240) := p_msg_callback_api;
l_user_callback_api varchar2(240) := p_user_callback_api;
l_partner_id number := p_partner_id;
l_benefit_id number:= p_benefit_id;

l_final_approval number;

CURSOR csr_message (p_object_id number, p_status varchar2, p_user_role varchar2) IS
SELECT user_role
,      wf_message_type
,      wf_message_name
FROM   pv_notification_setups
WHERE  benefit_id = p_object_id
AND    entity_status = p_status
AND    user_role like p_user_role;


CURSOR csr_final_approval (p_object_type varchar2, p_object_id number) IS
SELECT count(1)
FROM ozf_approval_access
WHERE  object_type = p_object_type
AND    object_id = p_object_id
AND    approval_access_flag = 'Y';



CURSOR csr_cm (p_partner_id number) IS
SELECT fnd_user.user_name
FROM   pv_partner_accesses acc
,      jtf_rs_resource_extns res
,      fnd_user
WHERE  acc.partner_id = p_partner_id
AND    acc.resource_id = res.resource_id
AND    res.user_id = fnd_user.user_id;


CURSOR csr_approvers (p_object_type varchar2, p_object_id number) IS
SELECT fu.user_name
FROM   ozf_approval_access oaa
,      fnd_user fu
--,      jtf_rs_resource_extns jre
WHERE  oaa.object_type = p_object_type
AND    oaa.object_id = p_object_id
AND    oaa.approver_type = 'USER'
--AND    fu.user_id = jre.user_id
--AND    oaa.approver_id = jre.resource_id
AND    oaa.approver_id = fu.user_id
AND    oaa.approval_access_flag = 'Y'
UNION
SELECT jre.user_name
FROM   ozf_approval_access oaa
,      jtf_rs_resource_extns jre
WHERE  oaa.object_type = p_object_type
AND    oaa.object_id = p_object_id
AND    oaa.approver_type = 'PERSON'
AND    oaa.approver_id = jre.source_id
AND    oaa.approval_access_flag = 'Y'
group by jre.user_name;



l_adhoc_role      varchar2(200);
l_role_list       varchar2(3000);
l_user_type       varchar2(30);
l_msg_type        varchar2(30);
l_msg_name        varchar2(30);
l_item_key        varchar2(200);
l_item_type       varchar2(30);

l_group_notify_id number;
l_context         varchar2(1000);
l_user_role       varchar2(240);

l_execute_str     varchar2(3000); -- bug 5058027

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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
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

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Before constructing message ' || l_user_role || ' ' || l_object_id || '  ' || l_status);
    END IF;

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

    OPEN csr_message(p_benefit_id, l_status, l_user_role);
       LOOP
          FETCH csr_message INTO l_user_type, l_msg_type, l_msg_name;
          EXIT WHEN csr_message%NOTFOUND;

          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message('Executing Callback API ' || l_user_callback_api);
          END IF;

          l_role_list := '';

          -- execute callback api to get users to send notification
          -- BUG 5058027 (+)
          -- EXECUTE IMMEDIATE 'SELECT ' || l_user_callback_api ||
          --               '(:itemtype, :entity_id, :usertype, :status) FROM dual'
          -- INTO l_role_list
          -- USING l_object_type, l_object_id, l_user_type, l_status ;

   --       l_execute_str := 'BEGIN ' ||
   --                        l_user_callback_api||'(:itemtype, :entity_id, :usertype, :status); '||
   --                        'END;';
   --       EXECUTE IMMEDIATE l_execute_str USING IN l_object_type, IN l_object_id, IN l_user_type, IN l_status;
   --
   -- Bug 5534346: Undone above changes - callback to a function doesnt work this way

          EXECUTE IMMEDIATE 'SELECT ' || l_user_callback_api ||
                        '(:itemtype, :entity_id, :usertype, :status) FROM dual'
          INTO l_role_list
          USING l_object_type, l_object_id, l_user_type, l_status ;

          -- execute pre-defined user list criterias
          IF l_role_list IS NULL THEN
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('No users found from Callback API ' || l_user_callback_api);
             END IF;

             IF l_user_type = 'CHANNEL_MANAGER' then
                FOR l_row IN csr_cm(l_partner_id) LOOP
                    l_role_list := l_role_list || ',' || l_row.user_name;
                END LOOP;
                l_role_list := substr(l_role_list,2);
             ELSIF l_user_type = 'BENEFIT_APPROVER' THEN
                FOR l_row IN csr_approvers(l_object_type, l_object_id) LOOP
                    l_role_list := l_role_list || ',' || l_row.user_name;
                END LOOP;
                l_role_list := substr(l_role_list,2);
             ELSE
                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message('No users found ');
                END IF;
             END IF;
          END IF;

          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message('Users List ' || l_user_type || 'for sending notification' || l_role_list);
          END IF;

          -- users returned from the search
          IF length(l_role_list) <> 0 THEN
             l_item_key := l_msg_type||'|'||l_user_type||'|'||l_msg_name||'|'||l_object_id||
                      '|'||to_char(sysdate,'YYYYMMDDHH24MISS');

             IF l_object_type = 'SPECIAL_PRICE' THEN
                l_item_type := 'OZFSPBEN';
             ELSIF l_object_type = 'SOFT_FUND' THEN
                l_item_type := 'OZFSFBEN';
             END IF;

             -- l_item_type := 'PVREFFRL';

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('Creating process for itemtype:' || l_item_type || ' itemkey: ' || l_item_key);
             END IF;

             -- Create WF process to send notification
             wf_engine.CreateProcess ( ItemType => l_item_type,
                                       ItemKey  => l_item_key,
                                       process  => 'NOOP_PROCESS',
                                       user_key  => l_item_key);

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('Executing msg callback' || l_msg_callback_api );
             END IF;

             -- execute callback api to set the message attributes
             EXECUTE IMMEDIATE 'BEGIN ' ||
                           l_msg_callback_api || '(:itemtype, :itemkey, :entity_id, :usertype, :status); ' ||
                          'END;'
             USING l_item_type, l_item_key, l_object_id, l_user_type, l_status;

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('Adding adhoc users' || l_role_list );
             END IF;

             -- create an adhoc role with named after itemkey
             l_adhoc_role := l_item_key;
             wf_directory.CreateAdHocRole(role_name         => l_adhoc_role,
                                          role_display_name => l_adhoc_role,
                                          role_users        => l_role_list);

             l_context := l_msg_type || ':' || l_item_key || ':';

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('Sending Notification to adhoc role ' || l_msg_type || ' ' || l_msg_name);
             END IF;

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

             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('Sent notification to role: ' || l_adhoc_role);
                ozf_utility_pvt.debug_message('Using message: ' || l_msg_name || '. Notify id: ' || l_group_notify_id );
             END IF;

             -- start the notification process to send message
             wf_engine.StartProcess(itemtype => l_item_type,
                                    itemkey  => l_item_key);
          -- no users returned from the search
          ELSE
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message('No users found for user type: ' || l_user_type);
             END IF;
          END IF;
       END LOOP;
    CLOSE csr_message;

    -- Update  WorkFlow Item Key in approval Access Table
    update ozf_approval_access
    set workflow_itemkey = substr(l_item_key,1,239)
    where object_type = l_object_type
    and object_id = l_object_id
    and approval_level = ( select max (approval_level)
              from ozf_approval_access
              where object_type = l_object_type
              and object_id = l_object_id);

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Send_Notification_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
--   ozf_utility_pvt.debug_message('Error OTHERS >>>>>>>>> ' ||  substr(sqlerrm,1,140));
        ROLLBACK TO  Send_Notification_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
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
l_api_name CONSTANT varchar2(80) := 'Process_User_Action';
l_api_version CONSTANT number := 1.0;
l_approvers_tbl  approvers_tbl_type;

--l_event_name varchar2(240);
l_event_name varchar2(240) ;
l_event_key  varchar2(240);
l_msg_callback_api varchar2(240);
l_user_callback_api varchar2(240);
l_benefit_id number;
l_partner_id number;
l_final_approval_flag varchar2(1) := 'N';
l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;

CURSOR csr_forward_reassign (p_request_id in number , p_object_type in varchar2) IS
select nvl(approval_level,1) + 1
from ozf_approval_access
where object_id = p_request_id
and object_type = p_object_type
and approval_access_flag = 'Y'
and rownum < 2;

CURSOR csr_request (p_request_id in number) IS
select benefit_id
,      partner_id
from   ozf_request_headers_all_b
where  request_header_id = p_request_id;

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
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    /*
    Action Code will be Notify when , the Final Approval has Happened
    */
    IF p_approval_rec.action_code = 'NOTIFY'  THEN
        x_final_approval_flag := 'Y';

        IF p_approval_rec.object_type = 'SPECIAL_PRICE' THEN
            l_event_name  := 'oracle.apps.ozf.request.SpecialPrice.approval';
        ELSIF p_approval_rec.object_type = 'SOFT_FUND' THEN
            l_event_name  := 'oracle.apps.ozf.request.SoftFund.approval';
        END IF;

        l_event_key := p_approval_rec.object_type || ':' || p_approval_rec.object_id || ':' || to_char(sysdate, 'DD:MON:YYYY HH:MI:SS');

        -- Raise_Event -> Event_Subscription -> Send_Notification
        Raise_Event (
           x_return_status     => l_return_status
          ,x_msg_data          => x_msg_data
          ,x_msg_count         => x_msg_count
          ,p_event_name        => l_event_name
          ,p_event_key         => l_event_key
          ,p_approval_rec      => p_approval_rec );

        return;
    END IF;

    -- Update AME/approval tbl of users action and revoke access to existing approvers
    IF p_approval_rec.action_code = 'APPROVE' OR
       p_approval_rec.action_code = 'REJECT'  OR
       p_approval_rec.action_code = 'RETURN'  OR
       p_approval_rec.action_code = 'FORWARD'
    THEN
       -- Add the new approver to forwarder rec
       IF p_approval_rec.action_code = 'FORWARD' THEN
            G_FORWARD_USER := p_approver_id;
          -- Assign new approver for the object
            l_approvers_tbl := approvers_tbl_type();
            l_approvers_tbl.extend;
            l_approvers_tbl(1).APPROVER_TYPE := 'USER';
            l_approvers_tbl(1).APPROVER_ID := p_approver_id;
	    OPEN csr_forward_reassign (p_approval_rec.object_id, p_approval_rec.object_type);
		FETCH csr_forward_reassign INTO l_approvers_tbl(1).APPROVER_LEVEL;
	   CLOSE csr_forward_reassign;

            --l_approvers_tbl(1).APPROVER_LEVEL := 5;  -- how to decide level for reassign???

          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Forward Request ' || p_approval_rec.action_code  );
          END IF;

          -- Raise error if no approvers are sent for reassignment.
          IF l_approvers_tbl.count = 0 THEN
             IF OZF_ERROR_ON THEN
                ozf_utility_pvt.error_message('OZF_NO_APPR_FOUND_FOR_FORWARD');
                x_return_status := FND_API.g_ret_sts_error;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;
       END IF;

       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Update User Action ' || p_approval_rec.action_code  );
       END IF;

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

       IF p_approval_rec.action_code = 'REJECT' OR p_approval_rec.action_code = 'RETURN' THEN
          l_final_approval_flag := 'Y';
       END IF;

    END IF;

    -- If the request is submitted/approved - get next approvers
    IF p_approval_rec.action_code = 'SUBMIT' OR
       p_approval_rec.action_code = 'APPROVE'
    THEN

       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Get Approvers ' || p_approval_rec.action_code  );
       END IF;

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

       IF l_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    END IF;

    -- Add access to users who have approval privileges
    IF p_approval_rec.action_code = 'SUBMIT'   OR
       p_approval_rec.action_code = 'APPROVE' OR
       p_approval_rec.action_code = 'FORWARD'
    THEN
       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Add Access ' || p_approval_rec.action_code  );
       END IF;

       IF l_final_approval_flag <> 'Y' THEN
         --If no Approver Found Do not add record in Access table
	  if l_approvers_tbl(1).approver_id is not null then
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
	         ,p_approvers         => l_approvers_tbl );

             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;
	  END IF; --End if some Approver is found

       END IF;

       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Access Added ' || x_return_status  );
       END IF;
    END IF;

    IF p_approval_rec.object_type = 'SPECIAL_PRICE' THEN
       l_event_name  := 'oracle.apps.ozf.request.SpecialPrice.approval';
    ELSIF p_approval_rec.object_type = 'SOFT_FUND' THEN
       l_event_name  := 'oracle.apps.ozf.request.SoftFund.approval';
    END IF;

    l_event_key := p_approval_rec.object_type || ':' || p_approval_rec.object_id || ':' || to_char(sysdate, 'DD:MON:YYYY HH:MI:SS');

    IF p_approval_rec.object_type = 'SPECIAL_PRICE' THEN
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

    /*
    l_msg_callback_api := 'OZF_APPROVAL_PVT.REQUEST_SET_MSG_ATTRS';
    l_user_callback_api := 'OZF_APPROVAL_PVT.REQUEST_RETURN_USERLIST';

    OPEN csr_request (p_approval_rec.object_id);
       FETCH csr_request INTO l_benefit_id, l_partner_id;
    CLOSE csr_request;

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Send Notification liu feng' || l_benefit_id ||'Parner ' ||  l_partner_id  );
    END IF;

    -- Call PRM api to send notification based on setups
    PV_BENFT_STATUS_CHANGE.status_change_raise(
       p_api_version_number => p_api_version,
       p_init_msg_list      => FND_API.g_false,
       p_commit             => FND_API.g_false,
       p_validation_level   => p_validation_level,
       p_event_name         => l_event_name,
       p_benefit_id         => l_benefit_id,
       p_entity_id          => p_approval_rec.object_id,
       p_status_code        => p_approval_rec.status_code,
       p_partner_id         => l_partner_id,
       p_msg_callback_api   => l_msg_callback_api,
       p_user_callback_api  => l_user_callback_api,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count,
       x_msg_data           => x_msg_data);


    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Raise Notification Event  ' || x_return_status  );
    END IF;

    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

*/
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    x_final_approval_flag := l_final_approval_flag;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
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
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Process_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Process_User_Action_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Process_User_Action;
---------------------------------------------------------------------
/*

set serveroutput on

declare
l_return_status varchar2(100);
l_msg_count number;
l_msg_data varchar2(100);
l_null number;
l_approval_rec OZF_APPROVAL_PVT.approval_rec_type;
l_approvers_tbl OZF_APPROVAL_PVT.approvers_tbl_type;
l_final_approval varchar2(1);
l_approver_id  number;

begin
fnd_msg_pub.initialize;

 --l_approval_rec.object_type := 'SPECIAL_PRICE';
 l_approval_rec.object_type := 'SOFT_FUND';
 l_approval_rec.object_id := 159;

 l_approval_rec.status_code := 'PENDING';
 l_approval_rec.action_code := 'SUBMIT';
 l_approval_rec.action_performed_by := 1000196;

-- l_approval_rec.status_code := 'PENDING';
-- l_approval_rec.action_code := 'APPROVE';
-- l_approval_rec.action_performed_by := 1001773;

-- l_approval_rec.status_code := 'PENDING';
-- l_approval_rec.action_code := 'REJECT';
-- l_approval_rec.action_performed_by := 1001637;
l_approver_id := 1000196;

 OZF_APPROVAL_PVT.Process_User_Action (
	p_api_version => 1.0,
	p_init_msg_list => FND_API.G_FALSE,
	p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	x_return_status => l_return_status,
	x_msg_count => l_msg_count,
	x_msg_data => l_msg_data,
	p_approval_rec => l_approval_rec,
	p_approver_id => l_approver_id,
	x_final_approval_flag => l_final_approval);

  ozf_utility_pvt.debug_message('liufeng: ' || l_return_status);
  ozf_utility_pvt.debug_message(l_msg_count);
  ozf_utility_pvt.debug_message('approval: ' ||l_final_approval);

  for i in 1..l_msg_count loop
   ozf_utility_pvt.debug_message(substr(fnd_msg_pub.get(p_msg_index => i, p_encoded => 'F'), 1, 254));
  end loop;

--  FOR i in 1..l_approvers_tbl.count LOOP
--    ozf_utility_pvt.debug_message('Approver Id ' || l_approvers_tbl(i).APPROVER_ID);
--    ozf_utility_pvt.debug_message('Approver Level ' || l_approvers_tbl(i).APPROVER_LEVEL);
--  END LOOP;

  ozf_utility_pvt.debug_message('Final Approval ' || l_final_approval);

end;


*/

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(+)
---------------------------------------------------------------------
-- PROCEDURE
--    Process_SD_Approval
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure Handles the approval of Ship & Debit Objects.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_SD_Approval (
   p_api_version        IN  NUMBER
  ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,p_object_id          IN  NUMBER
  ,p_action_code        IN  VARCHAR2
  ,x_return_status      OUT NOCOPY VARCHAR2
  ,x_msg_count          OUT NOCOPY NUMBER
  ,x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2(80) := 'Process_SD_Approval';
l_api_version           CONSTANT NUMBER := 1.0;
l_event_key             VARCHAR2(240);
l_return_status         VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_approvers_tbl ame_util.approversTable2;
l_approval_completeYN   VARCHAR2(20) := ame_util.booleanFalse;
l_orig_system_id        NUMBER;
l_orig_system           VARCHAR2(30);
l_user_id               NUMBER;
l_resource_id           NUMBER;
l_person_id             NUMBER;
l_owner_flag            VARCHAR2(1);
l_approver_flag         VARCHAR2(1) := 'Y';
l_insert_mode           VARCHAR2(1); --:= 'Y';
l_approver_count        NUMBER := 0;

CURSOR csr_person_info (p_person_id IN NUMBER )IS
SELECT user_id, resource_id
FROM jtf_rs_resource_extns
WHERE category = 'EMPLOYEE'
AND source_id = p_person_id
AND user_id IS NOT NULL
AND sysdate >= start_date_active
AND sysdate <= nvl(end_date_active, sysdate)
AND rownum < 2;

CURSOR csr_user_info (p_user_id IN NUMBER )IS
SELECT resource_id
FROM jtf_rs_resource_extns
WHERE category = 'EMPLOYEE'
AND user_id = p_user_id
AND sysdate >= start_date_active
AND sysdate <= nvl(end_date_active, sysdate)
AND rownum < 2;

CURSOR csr_get_approver_count(p_object_id IN NUMBER )IS
SELECT count(*)
FROM OZF_SD_REQUEST_ACCESS
WHERE request_header_id = p_object_id
AND approver_flag = 'Y'
AND enabled_flag = 'Y';

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Process_SD_Approval;
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
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- If action code is SUBMIT get the approver list from AME setup
    -- and populate OZF_SD_REQUEST_ACCESS table
    IF (p_action_code = 'SUBMIT') THEN
       IF G_DEBUG THEN
          ozf_utility_pvt.debug_message( 'Get Approvers for request_header_id: ' || p_object_id  );
       END IF;
       Get_All_Approvers(
           p_api_version           => p_api_version
          ,p_init_msg_list         => p_init_msg_list
          ,p_validation_level      => p_validation_level
          ,p_transaction_id        => p_object_id
          ,p_transaction_type_key  => 'SUPPLIER_SHIP_DEBIT'
          ,x_return_status         => l_return_status
          ,x_msg_data              => x_msg_data
          ,x_msg_count             => x_msg_count
          ,x_approvers             => l_approvers_tbl
          ,x_approval_flag         => l_approval_completeYN
       );
       IF l_approvers_tbl.count <> 0 THEN
          FOR i IN 1 .. l_approvers_tbl.count LOOP
             l_orig_system_id := l_approvers_tbl(i).orig_system_id;
             l_orig_system := l_approvers_tbl(i).orig_system;
             -- IF approver has been defined as FND USER in AME Setup
             -- TDD Assumption: Only a valid resource shall be considered as an approver
             IF (l_orig_system = 'FND_USR') THEN
                l_user_id := l_orig_system_id;
                OPEN csr_user_info(l_user_id);
                FETCH csr_user_info INTO l_resource_id;
                CLOSE csr_user_info;
                IF l_resource_id IS NOT NULL THEN
                    l_insert_mode := 'Y';
                ELSE
                    l_insert_mode := 'N';
                END IF;
             -- ELSIF approver has been defined as HR PERSON in AME Setup
             -- TDD Assumption: Only a valid resource shall be considered as an approver
             ELSIF (l_orig_system = 'PER') THEN
                l_person_id := l_orig_system_id;
                OPEN csr_person_info(l_person_id);
                FETCH csr_person_info INTO l_user_id, l_resource_id;
                CLOSE csr_person_info;
                IF l_resource_id IS NOT NULL THEN
                    l_insert_mode := 'Y';
                ELSE
                    l_insert_mode := 'N';
                END IF;
             END IF;
             -- This procedure will do required validation and
             -- insert the record in OZF_SD_REQUEST_ACCESS table
             IF (l_insert_mode = 'Y') THEN
                IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message( 'Invoke Add_SD_Access for AME approver: ' || l_orig_system_id);
                END IF;
                Add_SD_Access(
                   p_api_version       => p_api_version
                  ,p_init_msg_list     => p_init_msg_list
	              ,p_commit            => p_commit
	              ,p_validation_level  => p_validation_level
                  ,p_request_header_id => p_object_id
                  ,p_user_id           => l_user_id
                  ,p_resource_id       => l_resource_id
                  ,p_person_id         => l_person_id
                  ,p_owner_flag        => l_owner_flag
                  ,p_approver_flag     => l_approver_flag
                  ,x_return_status     => l_return_status
	              ,x_msg_data          => x_msg_data
	              ,x_msg_count         => x_msg_count);
                IF l_return_status = FND_API.g_ret_sts_error THEN
                   RAISE FND_API.g_exc_error;
                ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                   RAISE FND_API.g_exc_unexpected_error;
                END IF;
             END IF;
             -- Reset the variable value to 'Y'
             l_insert_mode := 'N';
             -- Reset the variables to null
             l_user_id := NULL;
             l_resource_id := NULL;
             l_person_id := NULL;
          END LOOP;
       END IF;

       -- TDD Assumption: If there is no approver found in AME setup
       -- i.e. either there is no approver defined in AME setup
       -- or there is no valid approver defined in AME setup,
       -- the user defined in the profile OZF_SD_DEFAULT_APPROVER
       -- shall be considered as  default approver.
       OPEN csr_get_approver_count(p_object_id);
       FETCH csr_get_approver_count INTO l_approver_count;
       CLOSE csr_get_approver_count;
       IF (l_approver_count = 0) THEN
          l_user_id := to_number(fnd_profile.value('OZF_SD_DEFAULT_APPROVER'));
          OPEN csr_user_info(l_user_id);
          FETCH csr_user_info INTO l_resource_id;
          CLOSE csr_user_info;
          IF l_resource_id IS NOT NULL THEN
             l_insert_mode := 'Y';
          ELSE
             l_insert_mode := 'N';
          END IF;

          IF (l_insert_mode = 'Y') THEN
             IF G_DEBUG THEN
                ozf_utility_pvt.debug_message( 'Invoke Add_SD_Access for default approver: ' || l_user_id);
             END IF;
             Add_SD_Access(
                p_api_version       => p_api_version
               ,p_init_msg_list     => p_init_msg_list
	           ,p_commit            => p_commit
	           ,p_validation_level  => p_validation_level
               ,p_request_header_id => p_object_id
               ,p_user_id           => l_user_id
               ,p_resource_id       => l_resource_id
               ,p_person_id         => l_person_id
               ,p_owner_flag        => l_owner_flag
               ,p_approver_flag     => l_approver_flag
               ,x_return_status     => l_return_status
	           ,x_msg_data          => x_msg_data
	           ,x_msg_count         => x_msg_count);
             IF l_return_status = FND_API.g_ret_sts_error THEN
                RAISE FND_API.g_exc_error;
             ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
             END IF;
          END IF;
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message('Add_SD_Access is ended for default approver: '||x_return_status);
          END IF;
       END IF;
    END IF;
    l_event_key := p_object_id || ':' || to_char(sysdate, 'DD:MON:YYYY HH:MI:SS');
    -- Raise_SD_Event -> Event_Subscription -> Send_Notification
    Raise_SD_Event (
        p_event_key        => l_event_key
       ,p_object_id        => p_object_id
       ,p_action_code      => p_action_code
       ,x_return_status    => l_return_status
       ,x_msg_data         => x_msg_data
       ,x_msg_count        => x_msg_count);

    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Process_SD_Approval;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Process_SD_Approval;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Process_SD_Approval;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Process_SD_Approval;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_All_Approvers
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure calls ame_api2.getAllApprovers7 to get
--    Approver list from AME Setup.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_All_Approvers(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_transaction_id        IN  VARCHAR2
   ,p_transaction_type_key  IN  VARCHAR2
   ,x_approvers             OUT NOCOPY ame_util.approversTable2
   ,x_approval_flag         OUT NOCOPY VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
)
IS

l_api_name CONSTANT varchar2(80) := 'Get_All_Approvers';
l_api_version CONSTANT number := 1.0;
l_application_id number := 682;

BEGIN

    -- Standard begin of API savepoint
    SAVEPOINT  Get_All_Approvers;
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
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    ame_api2.getAllApprovers7
    (applicationIdIn                => l_application_id
    ,transactionTypeIn              => p_transaction_type_key
    ,transactionIdIn                => p_transaction_id
    ,approvalProcessCompleteYNOut   => x_approval_flag
    ,approversOut                   => x_approvers);

    -- Debug Message
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Get_All_Approvers;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Get_All_Approvers;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Get_All_Approvers;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Get_All_Approvers;

---------------------------------------------------------------------
-- PROCEDURE
--    Add_SD_Access
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure performs the required validation and invokes the
--    overloaded procedure which finally adds the record into
--    OZF_SD_REQUEST_ACCESS table.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_SD_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_request_header_id IN  NUMBER
   ,p_user_id           IN  NUMBER
   ,p_resource_id       IN  NUMBER
   ,p_person_id         IN  NUMBER DEFAULT NULL
   ,p_owner_flag        IN  VARCHAR2
   ,p_approver_flag     IN  VARCHAR2
   ,p_enabled_flag      IN  VARCHAR2 DEFAULT 'Y'
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2)
IS

l_api_name CONSTANT varchar2(80) := 'Add_SD_Access';
l_api_version CONSTANT number := 1.0;
l_access_rec  sd_access_rec_type;
l_user_id NUMBER;
l_resource_id NUMBER;

CURSOR csr_get_user_id (p_resource_id IN NUMBER )IS
select user_id
from jtf_rs_resource_extns
where resource_id = p_resource_id
and sysdate >= start_date_active
and sysdate <= nvl(end_date_active, sysdate)
and rownum < 2;

CURSOR csr_get_resource_id (p_user_id IN NUMBER )IS
select resource_id
from jtf_rs_resource_extns
where user_id = p_user_id
and sysdate >= start_date_active
and sysdate <= nvl(end_date_active, sysdate)
and rownum < 2;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_SD_Access1;
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
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- do required validation
    -- If request_header_id is null
    -- If both user_id and resource_id are null
    -- If both owner_flag and approver_flag are null
    -- Set the appropriate return status and raise an exception
    IF (p_request_header_id IS NULL) THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_SD_REQUEST_HEADER_ID_NULL');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF (p_user_id IS NULL AND p_resource_id IS NULL) THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_SD_USER_RESOURCE_ID_NULL');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    IF (p_owner_flag IS NULL AND p_approver_flag IS NULL) THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_SD_OWNER_APPROVER_NULL');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Get user_id or resource_id for Admin's action i.e. change of owner/assignee
    IF (p_user_id IS NULL OR p_resource_id IS NULL) THEN
       IF (p_user_id IS NULL AND p_resource_id IS NOT NULL) THEN
          OPEN csr_get_user_id (p_resource_id);
          FETCH csr_get_user_id INTO l_user_id;
          CLOSE csr_get_user_id;
       ELSIF (p_resource_id IS NULL AND p_user_id IS NOT NULL) THEN
          OPEN csr_get_resource_id (p_user_id);
          FETCH csr_get_resource_id INTO l_resource_id;
          CLOSE csr_get_resource_id;
       END IF;
    END IF;

    l_access_rec.REQUEST_HEADER_ID := p_request_header_id;

    IF (p_user_id IS NOT NULL) THEN
       l_access_rec.USER_ID := p_user_id;
    ELSE
       l_access_rec.USER_ID := l_user_id;
    END IF;

    IF (p_resource_id IS NOT NULL) THEN
       l_access_rec.RESOURCE_ID := p_resource_id;
    ELSE
       l_access_rec.RESOURCE_ID := l_resource_id;
    END IF;

    IF (l_access_rec.USER_ID IS NULL OR l_access_rec.RESOURCE_ID IS NULL) THEN
       IF OZF_ERROR_ON THEN
          ozf_utility_pvt.error_message('OZF_SD_USER_IS_NOT_RESOURCE');
          x_return_status := FND_API.g_ret_sts_error;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    l_access_rec.PERSON_ID := p_person_id;
    l_access_rec.OWNER_FLAG := p_owner_flag;
    l_access_rec.APPROVER_FLAG := p_approver_flag;
    l_access_rec.ENABLED_FLAG := p_enabled_flag;

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'REQUEST HEADER ID: '||l_access_rec.REQUEST_HEADER_ID);
       ozf_utility_pvt.debug_message( 'USER ID: '||l_access_rec.USER_ID);
       ozf_utility_pvt.debug_message( 'RESOURCE ID: '||l_access_rec.RESOURCE_ID);
       ozf_utility_pvt.debug_message( 'PERSON ID: '||l_access_rec.PERSON_ID);
       ozf_utility_pvt.debug_message( 'OWNER FLAG: '||l_access_rec.OWNER_FLAG);
       ozf_utility_pvt.debug_message( 'APPROVER FLAG: '||l_access_rec.APPROVER_FLAG);
       ozf_utility_pvt.debug_message( 'ENABLED FLAG: '||l_access_rec.ENABLED_FLAG);
    END IF;

    Add_SD_Access(
       p_api_version        => p_api_version
       ,p_init_msg_list     => p_init_msg_list
	   ,p_commit            => p_commit
	   ,p_validation_level  => p_validation_level
	   ,p_access_rec        => l_access_rec
	   ,x_return_status     => x_return_status
	   ,x_msg_data          => x_msg_data
	   ,x_msg_count         => x_msg_count);
       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Add_SD_Access1;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Add_SD_Access1;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Add_SD_Access1;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Add_SD_Access;


---------------------------------------------------------------------
-- PROCEDURE
--    Add_SD_Access
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure performs the required business logic and adds
--    the record into OZF_SD_REQUEST_ACCESS table.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Add_SD_Access(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit            IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_access_rec        IN  sd_access_rec_type
   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER
   ,x_msg_data          OUT NOCOPY VARCHAR2

)
IS
l_api_name              CONSTANT VARCHAR2(20) := 'Add_SD_Access';
l_api_version           CONSTANT NUMBER := 1.0;
l_approval_access_id    NUMBER;
l_workflow_itemkey      VARCHAR2(80);
l_exist_resource_id     NUMBER;
l_exist_user_id         NUMBER;
l_exist_approver_flag   VARCHAR2(1);
l_exist_owner_flag      VARCHAR2(1);
l_exist_version_number  NUMBER;
l_insert_mode           VARCHAR2(1) := 'N';

CURSOR c_id IS
SELECT OZF_SD_REQUEST_ACCESS_S.NEXTVAL
FROM dual;

CURSOR CSR_EXISTING_OWNER (p_object_id IN NUMBER) IS
SELECT resource_id, user_id, approver_flag, object_version_number
FROM OZF_SD_REQUEST_ACCESS
WHERE request_header_id = p_object_id
AND enabled_flag = 'Y'
AND owner_flag = 'Y';

CURSOR CSR_EXISTING_OWNER_APPROVER(p_object_id IN NUMBER, p_resource_id IN NUMBER) IS
SELECT resource_id, owner_flag, approver_flag, object_version_number
FROM OZF_SD_REQUEST_ACCESS
WHERE request_header_id = p_object_id
AND enabled_flag = 'Y'
AND resource_id = p_resource_id;

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Add_SD_Access2;
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
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check for approver record
    IF (p_access_rec.APPROVER_FLAG = 'Y') THEN
       OPEN CSR_EXISTING_OWNER_APPROVER (p_access_rec.REQUEST_HEADER_ID, p_access_rec.RESOURCE_ID);
       FETCH CSR_EXISTING_OWNER_APPROVER INTO
       l_exist_resource_id,
       l_exist_owner_flag,
       l_exist_approver_flag,
       l_exist_version_number;
       CLOSE CSR_EXISTING_OWNER_APPROVER;
       IF l_exist_resource_id IS NOT NULL THEN
          IF (l_exist_owner_flag = 'Y' AND l_exist_approver_flag IS NULL)THEN
             UPDATE OZF_SD_REQUEST_ACCESS
             SET approver_flag = 'Y',
             object_version_number = l_exist_version_number + 1
             WHERE request_header_id = p_access_rec.REQUEST_HEADER_ID
             AND resource_id = p_access_rec.RESOURCE_ID
             AND enabled_flag = 'Y';
          END IF;
       ELSE
          l_insert_mode :='Y';
       END IF;

    --CHECK FOR OWNER RECORD
    ELSIF (p_access_rec.OWNER_FLAG = 'Y') THEN
       OPEN CSR_EXISTING_OWNER (p_access_rec.REQUEST_HEADER_ID);
       FETCH CSR_EXISTING_OWNER INTO
       l_exist_resource_id,
       l_exist_user_id,
       l_exist_approver_flag,
       l_exist_version_number;
       CLOSE CSR_EXISTING_OWNER;
       -- check if, there is any owner exists for this request_header_id
       -- if yes, update the access flags for existing owner
       -- if p_access_rec.RESOURCE_ID and p_access_rec.USER_ID are same as the existing record,
       -- dont update anything
       IF (l_exist_resource_id IS NOT NULL) THEN
          IF (l_exist_resource_id <> p_access_rec.RESOURCE_ID AND l_exist_user_id <> p_access_rec.USER_ID) THEN
             IF l_exist_approver_flag IS NULL THEN
                UPDATE OZF_SD_REQUEST_ACCESS
                SET enabled_flag = NULL,
                object_version_number = l_exist_version_number + 1
                WHERE request_header_id = p_access_rec.REQUEST_HEADER_ID
                AND resource_id = l_exist_resource_id
                AND enabled_flag = 'Y';
             ELSE
                UPDATE OZF_SD_REQUEST_ACCESS
                SET owner_flag = NULL,
                object_version_number = l_exist_version_number + 1
                WHERE request_header_id = p_access_rec.REQUEST_HEADER_ID
                AND resource_id = l_exist_resource_id
                AND enabled_flag = 'Y';
             END IF;
             -- now enter the record for new owner
             -- before that check if there is any approver who has same resource_id
             -- if yes, update the owner_flag for that approver as 'Y'
             -- else enter a new record for new owner
             -- CHECK FOR EXISTING APPROVER WHO HAS THE SAME RESOURCE ID
             -- Reset the variables to null
             l_exist_resource_id := null;
             l_exist_owner_flag := null;
             l_exist_approver_flag := null;
             l_exist_version_number := null;
             OPEN CSR_EXISTING_OWNER_APPROVER (p_access_rec.REQUEST_HEADER_ID, p_access_rec.RESOURCE_ID);
             FETCH CSR_EXISTING_OWNER_APPROVER INTO
             l_exist_resource_id,
             l_exist_owner_flag,
             l_exist_approver_flag,
             l_exist_version_number;
             CLOSE CSR_EXISTING_OWNER_APPROVER;
             IF (l_exist_resource_id IS NOT NULL AND l_exist_approver_flag = 'Y') THEN
                UPDATE OZF_SD_REQUEST_ACCESS
                SET owner_flag = 'Y',
                object_version_number = l_exist_version_number + 1
                WHERE request_header_id = p_access_rec.REQUEST_HEADER_ID
                AND resource_id = p_access_rec.RESOURCE_ID
                AND enabled_flag = 'Y';
             ELSE
                l_insert_mode :='Y';
             END IF;
          END IF;
       ELSE
          l_insert_mode :='Y';
       END IF;
   END IF;

    IF (l_insert_mode = 'Y') THEN
       BEGIN
          IF G_DEBUG THEN
             ozf_utility_pvt.debug_message( 'Inserting data into OZF_SD_REQUEST_ACCESS table');
          END IF;
          -- GET PRIMARY KEY
          OPEN c_id;
          FETCH c_id INTO l_approval_access_id;
          CLOSE c_id;
          INSERT INTO OZF_SD_REQUEST_ACCESS(
                 request_access_id
                ,request_header_id
                ,user_id
                ,resource_id
                ,person_id
                ,owner_flag
                ,approver_flag
                ,enabled_flag
                ,object_version_number
                ,last_update_date
                ,last_updated_by
                ,creation_date
                ,created_by
                ,last_update_login)
          VALUES(
                 l_approval_access_id
                ,p_access_rec.REQUEST_HEADER_ID
                ,p_access_rec.USER_ID
                ,p_access_rec.RESOURCE_ID
                ,p_access_rec.PERSON_ID
                ,p_access_rec.OWNER_FLAG
                ,p_access_rec.APPROVER_FLAG
                ,p_access_rec.ENABLED_FLAG
                ,1
                ,SYSDATE
                ,G_USER_ID
                ,SYSDATE
                ,G_USER_ID
                ,G_LOGIN_ID
           );
       EXCEPTION
          WHEN OTHERS THEN
             IF OZF_ERROR_ON THEN
                ozf_utility_pvt.error_message('OZF_SD_REQ_ACCESS_INSERT_ERR');
                x_return_status := FND_API.g_ret_sts_error;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
       END;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Add_SD_Access2;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Add_SD_Access2;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Add_SD_Access2;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Add_SD_Access;

---------------------------------------------------------------------
-- PROCEDURE
--    Raise_SD_Event
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure raises a business event to send different
--    notifications for Ship & Debit request.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Raise_SD_Event (
    p_event_key              IN  VARCHAR2
   ,p_object_id              IN  NUMBER
   ,p_action_code            IN  VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name CONSTANT varchar2(80) := 'Raise_SD_Event';
l_api_version CONSTANT number := 1.0;
l_item_key      VARCHAR2(240);
l_event         VARCHAR2(240);
l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();
l_parameter_t     wf_parameter_t := wf_parameter_t(null, null);
l_sd_event_name VARCHAR2(240) := 'oracle.apps.ozf.request.ShipDebit.approval';

BEGIN
   SAVEPOINT Raise_SD_Event;
    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_event := Check_Event(l_sd_event_name);
   IF l_event = 'NOTFOUND' THEN
      IF OZF_ERROR_ON THEN
         ozf_utility_pvt.error_message('OZF_WF_EVENT_NAME_NULL', 'NAME', l_sd_event_name);
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_parameter_t.setName('OBJECT_ID');
   l_parameter_t.setValue(p_object_id);
   l_parameter_list.extend;
   l_parameter_list(1) := l_parameter_t;

   l_parameter_t.setName('ACTION_CODE');
   l_parameter_t.setValue(p_action_code);
   l_parameter_list.extend;
   l_parameter_list(2) := l_parameter_t;

   -- Raise business event
   Wf_Event.Raise
   ( p_event_name   =>  l_sd_event_name,
     p_event_key    =>  p_event_key,
     p_parameters   =>  l_parameter_list,
     p_event_data   =>  NULL);

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Raise_SD_Event;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Raise_SD_Event;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Raise_SD_Event;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Raise_SD_Event;

---------------------------------------------------------------------
-- PROCEDURE
--    Send_SD_Notification
--
-- PURPOSE
--    This procedure has been created for Ship & Debit Request.
--    This procedure sends the notifications based on p_action_code.
--
-- PARAMETERS
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Send_SD_Notification (
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit             IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level   IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_object_id          IN  NUMBER
   ,p_action_code        IN  VARCHAR2
   ,x_return_status      OUT NOCOPY   VARCHAR2
   ,x_msg_data           OUT NOCOPY   VARCHAR2
   ,x_msg_count          OUT NOCOPY   NUMBER
)
IS
l_api_name CONSTANT VARCHAR2(80) := 'Send_SD_Notification';
l_api_version CONSTANT NUMBER := 1.0;

CURSOR csr_approvers (p_object_id IN NUMBER) IS
SELECT fu.user_name
FROM   ozf_sd_request_access ora,
       fnd_user fu
WHERE  ora.request_header_id = p_object_id
AND    ora.person_id IS NULL
AND    ora.user_id = fu.user_id
AND    ora.approver_flag = 'Y'
AND    ora.enabled_flag = 'Y'
UNION
SELECT jre.user_name
FROM   ozf_sd_request_access ora,
       jtf_rs_resource_extns jre
WHERE  ora.request_header_id = p_object_id
AND    ora.person_id IS NOT NULL
AND    ora.person_id = jre.source_id
AND    ora.approver_flag = 'Y'
AND    ora.enabled_flag = 'Y'
GROUP BY jre.user_name;

CURSOR csr_access_members(p_object_id IN NUMBER) IS
SELECT fu.user_name
FROM   ozf_sd_request_access ora,
       fnd_user fu
WHERE  ora.request_header_id = p_object_id
AND    ora.person_id IS NULL
AND    ora.user_id = fu.user_id
AND    ora.enabled_flag = 'Y'
UNION
SELECT jre.user_name
FROM   ozf_sd_request_access ora,
       jtf_rs_resource_extns jre
WHERE  ora.request_header_id = p_object_id
AND    ora.person_id IS NOT NULL
AND    ora.person_id = jre.source_id
AND    ora.enabled_flag = 'Y'
GROUP BY jre.user_name;

CURSOR csr_function_id (p_func_name IN VARCHAR2) IS
SELECT function_id FROM fnd_form_functions
WHERE function_name = p_func_name ;

CURSOR csr_request_info(p_object_id IN NUMBER) IS
SELECT orh.request_number,
requester.source_name,
aps.vendor_name,
hou.name,
orh.creation_date,
orh.request_start_date,
orh.request_end_date,
orh.supplier_response_date,
orh.supplier_response_by_date,
orh.authorization_number
FROM   ozf_sd_request_headers_all_b orh
,      ap_suppliers aps
,      jtf_rs_resource_extns requester
,      hr_all_organization_units hou
WHERE
orh.request_header_id = p_object_id
AND orh.requestor_id = requester.resource_id (+)
AND orh.SUPPLIER_ID = aps. vendor_id (+)
AND orh.org_id = hou.organization_id (+);

CURSOR csr_assignee_info(p_object_id IN NUMBER) IS
SELECT assignee.source_name,
orh.asignee_response_date,
orh.asignee_response_by_date
FROM   ozf_sd_request_headers_all_b orh
,      jtf_rs_resource_extns assignee
WHERE
orh.request_header_id = p_object_id
AND orh.asignee_resource_id = assignee.resource_id;

CURSOR request_type_setup_info(p_object_id IN NUMBER) IS
SELECT ACSV.setup_name
FROM ams_custom_setups_vl ACSV,
OZF_SD_REQUEST_HEADERS_ALL_B OSRH
WHERE OSRH.request_header_id = p_object_id
AND ACSV.custom_setup_id= OSRH.request_type_setup_id;

CURSOR lc_get_function_id (pc_func_name IN VARCHAR2) IS
SELECT function_id
FROM fnd_form_functions
WHERE function_name = pc_func_name;

l_adhoc_role        VARCHAR2(200);
l_role_list         VARCHAR2(3000):='';
l_user_type         VARCHAR2(30);
l_item_type         VARCHAR2(30) := 'OZFSDBEN';
l_item_name         VARCHAR2(30);
l_item_key          VARCHAR2(200);
l_group_notify_id   NUMBER;
l_context           VARCHAR2(1000);
l_user_role         VARCHAR2(240);
l_execute_str       VARCHAR2(3000);
l_request_number    VARCHAR2(30);
l_requester_name    VARCHAR2(100);
l_supplier_name     VARCHAR2(100);
l_assignee_name     VARCHAR2(100);
l_operating_unit    VARCHAR2(100);
l_creation_date             DATE;
l_start_date                DATE;
l_end_date                  DATE;
l_supplier_resp_date        DATE;
l_supplier_resp_by_date     DATE;
l_assignee_resp_date        DATE;
l_assignee_resp_by_date     DATE;
l_authorization_number      VARCHAR2(30);
l_request_type_setup_name   VARCHAR2(100);
l_function_id       NUMBER;
l_login_url         VARCHAR2(1000);

BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Send_SD_Notification;
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
       ozf_utility_pvt.debug_message( l_api_name||': Start');
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
            FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'Construct the message for request_header_id: '||p_object_id);
    END IF;
    -- if action code is SUBMIT, send the notification only to approvers (PMs)
    IF (p_action_code = 'SUBMIT') THEN
       FOR l_row IN csr_approvers(p_object_id) LOOP
          l_role_list := l_role_list || ',' || l_row.user_name;
       END LOOP;
       l_item_name := 'SUBMITTED01';
    -- ELSIF action code is ACCEPT/REJECT, send the notification to all access members (PMs+Owner)
    -- Get the assignee information from csr_assignee_info
    ELSIF (p_action_code = 'ACCEPT' OR p_action_code = 'REJECT') THEN
       FOR l_row IN csr_access_members(p_object_id) LOOP
          l_role_list := l_role_list || ',' || l_row.user_name;
       END LOOP;
       IF (p_action_code = 'ACCEPT') THEN
          l_item_name := 'ACCEPTED01';
       ELSIF
          (p_action_code = 'REJECT') THEN
          l_item_name := 'REJECTED01';
       END IF;
       OPEN csr_assignee_info(p_object_id);
       FETCH csr_assignee_info INTO
       l_assignee_name,
       l_assignee_resp_date,
       l_assignee_resp_by_date;
       CLOSE csr_assignee_info;
    END IF;

    l_role_list := substr(l_role_list,2);
    IF length(l_role_list) <> 0 THEN
    l_item_key := l_item_type||'|'||l_item_name||'|'||p_object_id||
                    '|'||to_char(sysdate,'YYYYMMDDHH24MISS');
    END IF;

    OPEN csr_request_info (p_object_id);
    FETCH csr_request_info INTO
    l_request_number,
    l_requester_name,
    l_supplier_name,
    l_operating_unit,
    l_creation_date,
    l_start_date,
    l_end_date,
    l_supplier_resp_date,
    l_supplier_resp_by_date,
    l_authorization_number;
    CLOSE csr_request_info;

    OPEN request_type_setup_info (p_object_id);
    FETCH request_type_setup_info INTO l_request_type_setup_name;
    CLOSE request_type_setup_info;

    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( 'request number: '||l_request_number);
       ozf_utility_pvt.debug_message( 'request type setup name: '||l_request_type_setup_name);
       ozf_utility_pvt.debug_message( 'requester name: '||l_requester_name);
       ozf_utility_pvt.debug_message( 'supplier name: '||l_supplier_name);
       ozf_utility_pvt.debug_message( 'assignee name: '||l_assignee_name);
       ozf_utility_pvt.debug_message( 'operating unit: '||l_operating_unit);
       ozf_utility_pvt.debug_message( 'request creation date: '||TO_CHAR(l_creation_date));
       ozf_utility_pvt.debug_message( 'request start date: '||TO_CHAR(l_start_date));
       ozf_utility_pvt.debug_message( 'request end date: '||TO_CHAR(l_end_date));
       ozf_utility_pvt.debug_message( 'supplier response date: '||TO_CHAR(l_supplier_resp_date));
       ozf_utility_pvt.debug_message( 'supplier_response by date: '||TO_CHAR(l_supplier_resp_by_date));
       ozf_utility_pvt.debug_message( 'assignee response date: '||TO_CHAR(l_assignee_resp_date));
       ozf_utility_pvt.debug_message( 'assignee response by date: '||TO_CHAR(l_assignee_resp_by_date));
       ozf_utility_pvt.debug_message( 'authorization number: '||l_authorization_number);
    END IF;

    IF G_DEBUG THEN
    ozf_utility_pvt.debug_message('Create process for itemtype:' || l_item_type || ' itemkey: ' || l_item_key);
    END IF;
    -- Create WF process to send notification
    wf_engine.CreateProcess ( ItemType => l_item_type,
                              ItemKey  => l_item_key,
                              process  => 'NOOP_PROCESS',
                              user_key  => l_item_key);
    IF G_DEBUG THEN
    ozf_utility_pvt.debug_message('Set attributes for itemtype:' || l_item_type || ' itemkey: ' || l_item_key);
    END IF;

    -- Set WF attributes to send notification
    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_NUMBER',
                              avalue   => l_request_number);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_TYPE',
                              avalue   => l_request_type_setup_name);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUESTER_NAME',
                              avalue   => l_requester_name);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'SUPPLIER_NAME',
                              avalue   => l_supplier_name);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ASSIGNEE_NAME',
                              avalue   => l_assignee_name);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'OPERATING_UNIT',
                              avalue   => l_operating_unit);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_CREATION_DATE',
                              avalue   => l_creation_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_START_DATE',
                              avalue   => l_start_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'REQUEST_END_DATE',
                              avalue   => l_end_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'SUPPLIER_RESPONSE_DATE',
                              avalue   => l_supplier_resp_date);


    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'SUPPLIER_RESPONSE_BY_DATE',
                              avalue   => l_supplier_resp_by_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ASSIGNEE_RESPONSE_DATE',
                              avalue   => l_assignee_resp_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'ASSIGNEE_RESPONSE_BY_DATE',
                              avalue   => l_assignee_resp_by_date);

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'AUTHORIZATION_NUMBER',
                              avalue   => l_authorization_number);

   open lc_get_function_id(pc_func_name => 'OZF_SD_REQ_DETAILS');
   fetch lc_get_function_id into l_function_id;
   close lc_get_function_id;

   l_login_url := fnd_run_function.get_run_function_url
		   (l_function_id,
			-1,
			-1,
			0,
			'SDRequestHdrId='||p_object_id||'&'||'FromPage=Dtail');

    wf_engine.SetItemAttrText( itemtype => l_item_type,
                                   itemkey  => l_item_key,
                                   aname    => 'LOGIN_URL',
                                   avalue   => l_login_url );
     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message('Adding adhoc users' || l_role_list );
     END IF;

    -- create an adhoc role with named after itemkey
    l_adhoc_role := l_item_key;

    wf_directory.CreateAdHocRole(role_name         => l_adhoc_role,
                                 role_display_name => l_adhoc_role,
                                 role_users        => l_role_list);
    l_context := l_item_type || ':' || l_item_key || ':';
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message('Sending Notification to adhoc role ' || l_item_type || ' ' || l_item_name);
    END IF;
    -- set the message to be sent
    l_group_notify_id := wf_notification.sendGroup(
                                        role         => l_adhoc_role,
                                        msg_type     => l_item_type,
                                        msg_name     => l_item_name,
                                        due_date     => null,
                                        callback     => 'wf_engine.cb',
                                        context      => l_context,
                                        send_comment => NULL,
                                        priority     => NULL );
     -- start the notification process to send message
     wf_engine.StartProcess(itemtype => l_item_type,
                            itemkey  => l_item_key);
     IF G_DEBUG THEN
        ozf_utility_pvt.debug_message('Sent notification to role: ' || l_adhoc_role);
        ozf_utility_pvt.debug_message('Using message: ' || l_item_name || '. Notify id: ' || l_group_notify_id );
     END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
       COMMIT WORK;
    END IF;

    -- Debug Message
    IF G_DEBUG THEN
       ozf_utility_pvt.debug_message( l_api_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  Send_SD_Notification;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Send_SD_Notification;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO  Send_SD_Notification;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OZF_UNEXP_ERROR_ON
        THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data
        );
--
END Send_SD_Notification;

-- 'R12.1 Enhancement: Ship & Debit Request' by ateotia(-)


END OZF_APPROVAL_PVT;

/
