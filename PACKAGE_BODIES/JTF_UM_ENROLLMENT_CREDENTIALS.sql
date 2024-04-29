--------------------------------------------------------
--  DDL for Package Body JTF_UM_ENROLLMENT_CREDENTIALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_ENROLLMENT_CREDENTIALS" as
/* $Header: JTFUMECB.pls 120.2 2005/10/29 03:45:13 snellepa ship $ */

MODULE_NAME  CONSTANT VARCHAR2(50) := 'JTF.UM.PLSQL.JTF_UM_ENROLLMENT_CREDENTIALS';
l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(MODULE_NAME);

PROCEDURE REVOKE_RESPONSIBILITY
          (
           X_USER_ID           NUMBER,
           X_RESPONSIBILITY_ID NUMBER,
           X_APPLICATION_ID    NUMBER
          )
IS
BEGIN
IF Fnd_User_Resp_Groups_Api.Assignment_Exists(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID
  ) THEN

 /*
 Removed this direct update call as fnd_user_resp_groups is no
 longer a table. Converted this call to use an API instead.

UPDATE FND_USER_RESP_GROUPS SET END_DATE = SYSDATE
WHERE USER_ID = X_USER_ID
AND   RESPONSIBILITY_ID = X_RESPONSIBILITY_ID
AND   RESPONSIBILITY_APPLICATION_ID = X_APPLICATION_ID;
*/

      Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
                         user_id => X_USER_ID,
                         responsibility_id => X_RESPONSIBILITY_ID,
                         responsibility_application_id => X_APPLICATION_ID,
                         start_date => sysdate,
                         end_date => sysdate, -- Revoke the responsibility
                         description => null );
END IF;

END REVOKE_RESPONSIBILITY;

PROCEDURE ASSIGN_RESPONSIBILITY
          (
           X_USER_ID           NUMBER,
           X_RESPONSIBILITY_ID NUMBER,
           X_APPLICATION_ID    NUMBER
          )
IS
BEGIN

Fnd_User_Resp_Groups_Api.Upload_Assignment(
  user_id => X_USER_ID,
  responsibility_id => X_RESPONSIBILITY_ID,
  responsibility_application_id => X_APPLICATION_ID,
  start_date => sysdate,
  end_date => null,
  description => null );

END ASSIGN_RESPONSIBILITY;


PROCEDURE ASSIGN_RESPONSIBILITY
          (
           X_USER_ID           NUMBER,
           X_RESPONSIBILITY_KEY VARCHAR2,
           X_APPLICATION_ID    NUMBER
          )
IS

p_responsibility_id NUMBER;
CURSOR RESP_KEY IS SELECT RESPONSIBILITY_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY;

FETCH RESP_KEY INTO p_responsibility_id;

CLOSE RESP_KEY;

IF NVL(p_responsibility_id,0) <> 0 THEN

          ASSIGN_RESPONSIBILITY
          (
           X_USER_ID           => X_USER_ID,
           X_RESPONSIBILITY_ID => p_responsibility_id,
           X_APPLICATION_ID    => X_APPLICATION_ID  );
END IF;

END ASSIGN_RESPONSIBILITY;


PROCEDURE REVOKE_RESPONSIBILITY
          (
           X_USER_ID            NUMBER,
           X_RESPONSIBILITY_KEY VARCHAR2,
           X_APPLICATION_ID     NUMBER
          )
IS

p_responsibility_id NUMBER;
CURSOR RESP_KEY_ID IS SELECT RESPONSIBILITY_ID
FROM FND_RESPONSIBILITY_VL
WHERE RESPONSIBILITY_KEY = X_RESPONSIBILITY_KEY;
BEGIN

OPEN RESP_KEY_ID;

FETCH RESP_KEY_ID INTO p_responsibility_id;

CLOSE RESP_KEY_ID;

IF NVL(p_responsibility_id,0) <> 0 THEN

          REVOKE_RESPONSIBILITY
          (
           X_USER_ID           => X_USER_ID,
           X_RESPONSIBILITY_ID => p_responsibility_id,
           X_APPLICATION_ID    => X_APPLICATION_ID
          );
END IF;

END REVOKE_RESPONSIBILITY;

PROCEDURE ASSIGN_ENROLLMENT_CREDENTIALS
          (
           X_USER_NAME VARCHAR2,
           X_USER_ID   NUMBER,
           X_SUBSCRIPTION_ID NUMBER
           )
IS

l_procedure_name CONSTANT varchar2(30) := 'ASSIGN_ENROLLMENT_CREDENTIALS';
p_subscription_resp_id  NUMBER;
p_subscription_app_id   NUMBER;
p_principal_name        VARCHAR2(255);
l_is_del_flag_set       BOOLEAN;
l_role_id               NUMBER;
l_version               FND_RESPONSIBILITY_VL.VERSION%TYPE;
l_def_resp_id           NUMBER;
l_def_app_id            NUMBER;
l_def_resp_key          FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE;
l_def_resp_name         FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE;

CURSOR SUBSCRIPTION_RESP is select FR.RESPONSIBILITY_ID, FR.APPLICATION_ID, FR.VERSION FROM
JTF_UM_SUBSCRIPTION_RESP SB,
FND_RESPONSIBILITY_VL FR
WHERE SB.SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
AND   SB.RESPONSIBILITY_KEY = FR.RESPONSIBILITY_KEY
AND   SB.APPLICATION_ID = FR.APPLICATION_ID
AND   (SB.EFFECTIVE_END_DATE IS NULL OR SB.EFFECTIVE_END_DATE > SYSDATE)
AND   SB.EFFECTIVE_START_DATE < SYSDATE;

CURSOR SUBSCRIPTION_ROLES IS SELECT PRINCIPAL_NAME
FROM JTF_UM_SUBSCRIPTION_ROLE
WHERE SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
AND   (EFFECTIVE_END_DATE IS NULL OR EFFECTIVE_END_DATE > SYSDATE)
AND   EFFECTIVE_START_DATE < SYSDATE;

BEGIN

JTF_DEBUG_PUB.LOG_ENTERING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );

 if l_is_debug_parameter_on then
 JTF_DEBUG_PUB.LOG_PARAMETERS( p_module    => MODULE_NAME,
                                     p_message   => 'X_USER_NAME:' || X_USER_NAME || '+' || 'X_USER_ID:' || X_USER_ID || '+' || 'X_SUBSCRIPTION_ID:' || X_SUBSCRIPTION_ID
                                    );
 end if;


-- Assign Responsibilites based on user type
OPEN SUBSCRIPTION_RESP;
LOOP
FETCH SUBSCRIPTION_RESP INTO p_subscription_resp_id, p_subscription_app_id, l_version;
EXIT WHEN SUBSCRIPTION_RESP%NOTFOUND;

ASSIGN_RESPONSIBILITY
       (
        X_USER_ID => X_USER_ID,
        X_RESPONSIBILITY_ID => p_subscription_resp_id,
        X_APPLICATION_ID  => p_subscription_app_id
        );
-- Revoke Pending approval responsibility, if any, as at least
-- one enrollment has been assigned.


JTF_UM_USERTYPE_CREDENTIALS.REVOKE_RESPONSIBILITY
         ( X_USER_ID    => X_USER_ID,
           X_RESPONSIBILITY_KEY => 'JTF_PENDING_APPROVAL',
           X_APPLICATION_ID    => 690
          );


         -- Make this responsibility a default one, if a user does not
         -- have one and it is a web based responsibility

    IF l_version = 'W' THEN

         JTF_UM_USERTYPE_CREDENTIALS.get_default_login_resp(
                       p_user_id      => X_USER_ID,
                       x_resp_id      => l_def_resp_id,
                       x_app_id       => l_def_app_id,
                       x_resp_key     => l_def_resp_key,
                       x_resp_name    => l_def_resp_name
                                           );

        IF l_def_resp_id IS NULL AND l_def_app_id IS NULL THEN

           JTF_UM_USERTYPE_CREDENTIALS.set_default_login_resp(
                       p_user_id         => X_USER_ID,
                       p_resp_id         => p_subscription_resp_id,
                       p_app_id          => p_subscription_app_id
                                 );
        END IF;
    END IF;

END LOOP;
CLOSE SUBSCRIPTION_RESP;

-- Assign Roles based on user type

OPEN SUBSCRIPTION_ROLES;

LOOP
FETCH SUBSCRIPTION_ROLES INTO p_principal_name;
EXIT WHEN SUBSCRIPTION_ROLES%NOTFOUND;

JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => X_USER_NAME,
                       ROLE_NAME       => p_principal_name,
                       OWNERTABLE_NAME => 'JTF_UM_SUBSCRIPTIONS_B',
                       OWNERTABLE_KEY  => X_SUBSCRIPTION_ID);

END LOOP;
CLOSE SUBSCRIPTION_ROLES;

-- Update the status

UPDATE JTF_UM_SUBSCRIPTION_REG SET STATUS_CODE='APPROVED'
WHERE SUBSCRIPTION_ID = X_SUBSCRIPTION_ID
AND USER_ID = X_USER_ID;

-- Grant the delegation role, if the flag is set

   JTF_UM_SUBSCRIPTIONS_PKG.get_grant_delegation_flag
                         (
                            p_subscription_id  => X_SUBSCRIPTION_ID,
                            p_user_id          => X_USER_ID,
                            x_result           => l_is_del_flag_set
                          );

    IF l_is_del_flag_set THEN

         JTF_UM_SUBSCRIPTIONS_PKG.get_delegation_role(
                       p_subscription_id  => X_SUBSCRIPTION_ID,
                       x_delegation_role  => l_role_id
                             );


           IF l_role_id IS NOT NULL THEN

               -- Grant delegation role to a user
               JTF_UM_UTIL_PVT.GRANT_ROLES(
                       p_user_name      => X_USER_NAME ,
                       p_role_id        => l_role_id,
                       p_source_name    => 'JTF_UM_SUBSCRIPTIONS_B',
                       p_source_id      => X_SUBSCRIPTION_ID
                     );

               -- Assign the deleagtion access role

               JTF_AUTH_BULKLOAD_PKG.ASSIGN_ROLE
                     ( USER_NAME       => X_USER_NAME,
                       ROLE_NAME       => 'JTA_UM_DELEGATION_ACCESS',
                       OWNERTABLE_NAME => 'JTF_UM_SUBSCRIPTIONS_B',
                       OWNERTABLE_KEY  => X_SUBSCRIPTION_ID);
           END IF;

    END IF;

JTF_DEBUG_PUB.LOG_EXITING_METHOD( p_module    => MODULE_NAME,
                                     p_message   => l_procedure_name
                                    );


END ASSIGN_ENROLLMENT_CREDENTIALS;

PROCEDURE REJECT_ENROLL_DEL_PEND_USER (P_USERNAME in  VARCHAR2)

IS

CURSOR FIND_ENROLL_APPWF_INFO IS
SELECT reg.WF_ITEM_TYPE, to_char (reg.SUBSCRIPTION_REG_ID)
FROM   JTF_UM_SUBSCRIPTION_REG reg, FND_USER fu
WHERE  fu.USER_NAME = P_USERNAME
AND    fu.USER_ID = reg.USER_ID
AND    STATUS_CODE = 'PENDING'
AND    (reg.EFFECTIVE_END_DATE is null
OR      reg.EFFECTIVE_END_DATE > sysdate);

itemtype varchar2 (8);
itemkey  varchar2 (240);

BEGIN

  OPEN FIND_ENROLL_APPWF_INFO;
  FETCH FIND_ENROLL_APPWF_INFO INTO itemtype, itemkey;
  WHILE FIND_ENROLL_APPWF_INFO%FOUND LOOP

    JTF_UM_WF_APPROVAL.COMPLETEAPPROVALACTIVITY (itemtype, itemkey, 'REJECTED', 'User deleted');
    FETCH FIND_ENROLL_APPWF_INFO INTO itemtype, itemkey;

  END LOOP;
  CLOSE FIND_ENROLL_APPWF_INFO;

END REJECT_ENROLL_DEL_PEND_USER;

  --
  -- Procedure
  --    assign_user_enrollment
  --
  -- Description
  --    This API calls other api's that will perform:
  --      createUserEnrollment;
  --      if (isApprovalRequired)
  --        assignEnrollCredentials;
  --      else
  --        launchWFProcess;
  --
  -- IN
  --    p_user_id         -- userid
  --    p_username        -- username
  --    p_usertype_id     -- usertype id
  --    p_enrollment_id -- enrollment id
  --    p_delegate_flag   -- delegate flag (T/F)
  --    p_approval_id     -- enrollment's approval id,
  --                         if p_approval_id is null approval is not required.
  --                         if p_approval_id is not null, approval is required.
  --
  -- OUT
  --    x_enrollment_reg_id -- enrollment reg id
  procedure assign_user_enrollment (p_user_id           in  number,
                                    p_username          in  varchar2,
                                    p_usertype_id       in  number,
                                    p_enrollment_id     in  number,
                                    p_delegate_flag     in  varchar2,
                                    p_approval_id       in  number,
                                    x_enrollment_reg_id out NOCOPY number) is

  METHOD_NAME         varchar2 (22) := 'ASSIGN_USER_ENROLLMENT';
  l_wf_item_type      jtf_um_subscription_reg.wf_item_type%TYPE;
  l_usertype_status   jtf_um_usertype_reg.status_code%TYPE;

  cursor get_wf_item_type is
    select wf_item_type
    from   jtf_um_approvals_b
    where  approval_id = p_approval_id
    and    effective_start_date < sysdate
    and    nvl (effective_end_date, sysdate + 1) > sysdate;

  cursor get_user_usertype_status is
    select status_code
    from   jtf_um_usertype_reg
    where  user_id = p_user_id
    and    effective_start_date <= sysdate
    and    nvl (effective_end_date, sysdate + 1) > sysdate;

  begin

    -- Log the entering
    JTF_DEBUG_PUB.LOG_ENTERING_METHOD (MODULE_NAME, METHOD_NAME);

    -- Log parameters
   if l_is_debug_parameter_on then
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_user_id=' || p_user_id);
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_username=' || p_username);
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_usertype_id=' || p_usertype_id);
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_enrollment_id=' || p_enrollment_id);
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_delegate_flag=' || p_delegate_flag);
    JTF_DEBUG_PUB.LOG_PARAMETERS (MODULE_NAME || '.' || METHOD_NAME,
                                  'p_approval_id=' || p_approval_id);

   end if;
    -- get the workflow itemtype from jtf_um_approvals_b table
    if (p_approval_id is null) then
      -- no approval required
      l_wf_item_type := '';
    else
      -- approval required
      open get_wf_item_type;
      fetch get_wf_item_type into l_wf_item_type;
      if (get_wf_item_type%notfound) then
        JTF_DEBUG_PUB.LOG_EXCEPTION (MODULE_NAME || '.' || METHOD_NAME, 'Workflow itemtype is missing for approval id ' || p_approval_id);
        close get_wf_item_type;
        raise_application_error (-20000, 'Workflow itemtype is missing for approval id ' || p_approval_id);
      end if;
      close get_wf_item_type;
    end if;

    -- insert into the jtf_um_subscription_reg table
    JTF_UM_SUBSCRIPTIONS_PKG.INSERT_SUBREG_ROW (
        X_SUBSCRIPTION_ID       => p_enrollment_id,
        X_LAST_APPROVER_COMMENT => null,
        X_APPROVER_USER_ID      => null,
        X_EFFECTIVE_END_DATE    => null,
        X_WF_ITEM_TYPE          => l_wf_item_type,
        X_EFFECTIVE_START_DATE  => SYSDATE,
        X_SUBSCRIPTION_REG_ID   => x_enrollment_reg_id,
        X_USER_ID               => p_user_id,
        X_STATUS_CODE           => 'PENDING',
        X_CREATION_DATE         => SYSDATE,
        X_CREATED_BY            => FND_GLOBAL.USER_ID,
        X_LAST_UPDATE_DATE      => SYSDATE,
        X_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
        X_LAST_UPDATE_LOGIN     => FND_GLOBAL.CONC_LOGIN_ID,
        X_GRANT_DELEGATION_FLAG => p_delegate_flag);

    open get_user_usertype_status;
    fetch get_user_usertype_status into l_usertype_status;
    if (get_user_usertype_status%notfound) then
      JTF_DEBUG_PUB.LOG_EXCEPTION (MODULE_NAME || '.' || METHOD_NAME, 'Usertype status is missing for ' || p_username);
      close get_user_usertype_status;
      raise_application_error (-20000, 'Usertype status is missing for ' || p_username);
    end if;
    close get_user_usertype_status;

    if (p_approval_id is null) then

      -- no approval required, assignEnrollCredentials
      if (l_usertype_status = 'APPROVED' or l_usertype_status = 'UPGRADE') then
        -- usertype doesn't need approval
        ASSIGN_ENROLLMENT_CREDENTIALS (X_USER_NAME       => p_username,
                                       X_USER_ID         => p_user_id,
                                       X_SUBSCRIPTION_ID => p_enrollment_id);
      end if;

    else

      -- approval required, launch workflow.
      JTF_UM_WF_APPROVAL.CREATEPROCESS (requestType     => 'ENROLLMENT',
                                        requestID       => p_enrollment_id,
                                        requesterUserID => p_user_id,
                                        requestRegID    => x_enrollment_reg_id);

      if (l_usertype_status = 'APPROVED' or l_usertype_status = 'UPGRADE') then
        -- usertype doesn't need approval
        JTF_UM_WF_APPROVAL.launchProcess (requestType  => 'ENROLLMENT',
                                          requestRegID => x_enrollment_reg_id);
      end if;
    end if;

    JTF_DEBUG_PUB.LOG_EXITING_METHOD (MODULE_NAME, METHOD_NAME);

  end assign_user_enrollment;

END JTF_UM_ENROLLMENT_CREDENTIALS;

/
