--------------------------------------------------------
--  DDL for Package Body JTF_UM_USER_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_USER_ADMIN_PVT" as
  /* $Header: JTFVUUAB.pls 120.5 2005/12/07 05:18:47 vimohan ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'JTF_UM_USER_ADMIN_PVT';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVUUAB.pls';

  G_USER_ID  NUMBER := FND_GLOBAL.USER_ID;
  G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
  G_MODULE   VARCHAR2(40) := 'JTF.UM.PLSQL.USERADMIN';
  l_is_debug_parameter_on boolean := JTF_DEBUG_PUB.IS_LOG_PARAMETERS_ON(G_MODULE);


  /**
   * Function    : getUserStatusCode
   * Type        : Private
   * Pre_reqs    :
   * Description : Return the status code of a user.
   * Parameters  :
   * input parameters
   *   p_userid
   *     description: FND User ID to return the status code
   *     required   : Y
   * output parameters
   *   status code
   *     description: The usertype status code of the user.
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  FUNCTION getUserStatusCode (p_userid in number) return varchar2 is

  l_status_code VARCHAR2 (30) := null;

  cursor getUserStatusCodeCursor is
    select status_code
    from   jtf_um_usertype_reg
    where  user_id = p_userid
    and    nvl (effective_end_date, sysdate + 1) > sysdate;

  BEGIN
    OPEN getUserStatusCodeCursor;
    FETCH getUserStatusCodeCursor INTO l_status_code;
    if (getUserStatusCodeCursor%notfound) then
      -- Cannot find the status code of the user.
      close getUserStatusCodeCursor;
      RETURN null;
    end if;
    CLOSE getUserStatusCodeCursor;

    RETURN l_status_code;
  END  getUserStatusCode;

  /**
   * Function    : getUserID
   * Type        : Private
   * Pre_reqs    :
   * Description : Return the user id of a user.
   * Parameters  :
   * input parameters
   *   p_username
   *     description: FND User name
   *     required   : Y
   * output parameters
   *   userid
   *     description: The userid of the provided username
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  function getUserID (p_username in varchar2) return number is

  l_userid number;

  cursor getUserIDCursor is
    select user_id
    from   fnd_user
    where  user_name = p_username
    and    (nvl (end_date, sysdate + 1) > sysdate or
           to_char(END_DATE) = to_char(FND_API.G_MISS_DATE))     ;

  begin
    open getUserIDCursor;
    fetch getUserIDCursor into l_userid;
    IF (getUserIDCursor%notfound) THEN
      -- Cannot find the userid of the user.
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_UA_MISSING_USERID');
        FND_MESSAGE.Set_Token('0', G_PKG_NAME, FALSE);
        FND_MESSAGE.Set_Token('1', 'p_username', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      close getUserIDCursor;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    close getUserIDCursor;

    return l_userid;
  end  getUserID;

  /**
   * Procedure   :  INACTIVE_USER
   * Type        :  Private
   * Pre_reqs    :  WF_DIRECTORY.CreateAdHocUser and
   *                WF_DIRECTORY.SetAdHocUserAttr
   * Description : Inactive an user with these Scenarios
   *   1. Usertype Request is PENDING
   *    - call FND_USER_PKG.DisableUser API
   *    - Kill the usertype WF
   *    - Set the usertype_reg table status to REJECTED
   *    - Find all the *PENDING* Enrollments, and REJECT these
   *      (believe we have a USERTYPE_REJECTED status or similar)
   *      in the subscription_reg table
   *    - revoke the "PENDING_APPROVAL" responsibility
   *
   *   2. Usertype Request is UPGRADE_PENDING
   *    - call FND_USER_PKG.DisableUser API
   *    - Set the usertype_reg table status to REJECTED
   *    - Reject the old approval task
   *
   *   3. Usertype Request is APPROVED or UPGRADE
   *    - call FND_USER_PKG.DisableUser API
   *    - Do not set the usertype_reg table status (leave as APPROVED)
   *    - Find all the *PENDING* Enrollments, and REJECT these (REJECTED status)
   *      in the subscription_reg table
   *    - Do not change the status for any approved / rejected enrollments
   * Parameters  :
   * input parameters
   *   p_username
   *     description:  The inactive username.
   *     required   :  Y
   * output parameters
   * Errors : possible errors raised by this API
   * Other Comments :
   */
  PROCEDURE INACTIVE_USER (p_api_version_number in number,
                           p_init_msg_list      in varchar2 default FND_API.G_FALSE,
                           p_commit             in varchar2 default FND_API.G_FALSE,
                           p_validation_level   in number   default FND_API.G_VALID_LEVEL_FULL,
                           p_username           in varchar2,
                           x_return_status      out NOCOPY varchar2,
                           x_msg_data           out NOCOPY varchar2,
                           x_msg_count          out NOCOPY number) is

  l_api_version_number NUMBER         := 1.0;
  l_api_name           VARCHAR2 (50)  := 'INACTIVE_USER';
  l_username           VARCHAR2 (100) := p_username;
  l_userid             NUMBER;
  l_itemtype           VARCHAR2 (8);
  l_itemkey            VARCHAR2 (240);
  l_status_code        VARCHAR2 (30);
  l_task_id            NUMBER;
  l_party_id           NUMBER;
  l_sort_data          JTF_TASKS_PUB.SORT_DATA;
  l_task_table         JTF_TASKS_PUB.TASK_TABLE_TYPE;
  l_total_retrieved    NUMBER;
  l_total_returned     NUMBER;
  l_version_num        NUMBER;

  cursor getUTWFInfo is
    select wf_item_type, to_char (usertype_reg_id)
    from   jtf_um_usertype_reg
    where  user_id = l_userid
    and    status_code = 'PENDING'
    and    nvl (effective_end_date, sysdate + 1) > sysdate;

  cursor getEnrollWFInfo is
    select wf_item_type, subscription_reg_id
    from   jtf_um_subscription_reg
    where  user_id = l_userid
    and    status_code = 'PENDING'
    and    nvl (effective_end_date, sysdate + 1) > sysdate;

  cursor getPartyID is
    select customer_id
    from   fnd_user
    where  user_id = l_userid
    and    (nvl (end_date, sysdate + 1) > sysdate OR
           to_char(END_DATE) = to_char(FND_API.G_MISS_DATE)) ;

  BEGIN
    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Entering API send_Password ...');

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Standard Start of API savepoint
    SAVEPOINT INACTIVE_USER;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- Beginning of API body
    --
    -- Validate required fields
    IF (p_username is null) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('JTF', 'JTA_UM_REQUIRED_FIELD');
        FND_MESSAGE.Set_Token('API_NAME', G_PKG_NAME, FALSE);
        FND_MESSAGE.Set_Token('FIELD', 'p_username', FALSE);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Get the userid
    l_userid := getUserID (p_username);

    -- Get the user usertype status code
    l_status_code := getUserStatusCode (l_userid);

    IF (l_status_code = 'PENDING') THEN

      -- 1. abort Usertype WF Process first
      -- query all itemtype and itemkey before aborting WF
      OPEN getUTWFInfo;
      FETCH getUTWFInfo INTO l_itemtype, l_itemkey;
      -- abort WF only if we can find the itemtype and itemkey.
      IF (getUTWFInfo%found) THEN
        JTF_UM_WF_APPROVAL.abort_process (l_itemtype, l_itemkey);
      END IF;
      CLOSE getUTWFInfo;

      -- 2. Set the usertype_reg table status to REJECTED
      UPDATE JTF_UM_USERTYPE_REG
      SET    status_code = 'REJECTED',
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             last_approver_comment = 'USER DELETED',
             effective_end_date = sysdate
      WHERE  user_id = l_userid
      AND    nvl (effective_end_date, sysdate + 1) > sysdate
      AND    status_code = 'PENDING';

      -- 3. Find all the PENDING enrollments and set USER_REJECTED.
      UPDATE JTF_UM_SUBSCRIPTION_REG
      SET    status_code = 'USER_REJECTED',
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             last_approver_comment = 'USER DELETED',
             effective_end_date = sysdate
      WHERE  user_id = l_userid
      AND    nvl (effective_end_date, sysdate + 1) > sysdate
      AND    status_code = 'PENDING';

      -- 4. Revoke the PENDING_APPROVAL responsibility.
      JTF_UM_USERTYPE_CREDENTIALS.REVOKE_RESPONSIBILITY (
          X_USER_ID            => l_userid,
          X_RESPONSIBILITY_KEY => 'JTF_PENDING_APPROVAL',
          X_APPLICATION_ID     => 690);

    ELSIF (l_status_code = 'UPGRADE_APPROVAL_PENDING') THEN

      -- 1. Set the usertype_reg table status to REJECTED
      UPDATE JTF_UM_USERTYPE_REG
      SET    status_code = 'REJECTED',
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             last_approver_comment = 'USER DELETED',
             effective_end_date = sysdate
      WHERE  user_id = l_userid
      AND    nvl (effective_end_date, sysdate + 1) > sysdate
      AND    status_code = 'PENDING';

      -- 2. Reject the old approval task
      -- To reject the old approval,
      -- first, we need the user's party_id
      open getPartyID;
      fetch getPartyID into l_party_id;
      close getPartyID;

      -- second, with the party_id, we can query the task_id.
      l_sort_data(1).field_name   := 'task_id';
      l_sort_data(1).asc_dsc_flag := 'A';
      l_sort_data(2).field_name   := 'task_name';
      l_sort_data(2).asc_dsc_flag := 'D';

      JTF_TASKS_PUB.query_task (P_API_VERSION => 1.0,
                                p_start_pointer => 1,
                                p_rec_wanted => 10,
                                p_show_all => 'Y',
                                p_object_type_code => 'ISUPPORT',
                                p_task_status_id => 10,
                                p_task_type_id => 1,
                                P_sort_data => l_sort_data,
                                p_customer_id => l_party_id,
                                p_source_object_id => l_party_id,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                x_task_table => l_task_table,
                                x_total_retrieved => l_total_retrieved,
                                x_total_returned => l_total_returned,
                                x_object_version_number => l_version_num);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- now, we can update the task with the task_id
      task_mgr.update_task ('1.0', '1',
                            l_task_table(l_task_table.first).task_id,
                            'USER DELETED', 'REJECT', x_msg_data,
                            x_return_status, x_msg_count);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF (l_status_code = 'APPROVED') OR (l_status_code = 'UPGRADE') THEN
      -- 1. abort Enrollment WF Process
      -- query all itemtype and itemkey before aborting WF
      FOR enrollRegRow in getEnrollWFInfo LOOP
        jtf_um_wf_approval.abort_process (enrollRegRow.wf_item_type, to_char(enrollRegRow.subscription_reg_id));
      END LOOP;

      -- 2. Find all the PENDING enrollments and set USER_REJECTED.
      UPDATE JTF_UM_SUBSCRIPTION_REG
      SET    status_code = 'USER_REJECTED',
             last_updated_by = fnd_global.user_id,
             last_update_date = sysdate,
             last_approver_comment = 'USER DELETED',
             effective_end_date = sysdate
      WHERE  user_id = l_userid
      AND    nvl (effective_end_date, sysdate + 1) > sysdate
      AND    status_code = 'PENDING';

    END IF;

    -- End date the user with the FND_API
    FND_USER_PKG.DisableUser (p_username);

    --
    -- End of API body
    --

    -- Standard check for p_commit
    IF FND_API.to_Boolean (p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                               p_data  => x_msg_data);

    -- call the user hook if it is a public api. Private APIs do not require a user hook call.

    -- Write to debug log
    -- JTF_DEBUG_PUB.add_debug_msg('EVENT', G_MODULE, 'Exiting API send_Password ...');

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
      JTF_DEBUG_PUB.HANDLE_EXCEPTIONS (P_API_NAME => L_API_NAME,
                                       P_PKG_NAME => G_PKG_NAME,
                                       P_EXCEPTION_LEVEL => JTF_DEBUG_PUB.G_EXC_OTHERS,
                                       P_SQLCODE => SQLCODE,
                                       P_SQLERRM => SQLERRM,
                                       X_MSG_COUNT => X_MSG_COUNT,
                                       X_MSG_DATA => X_MSG_DATA,
                                       X_RETURN_STATUS => X_RETURN_STATUS);

  END INACTIVE_USER;


/**
 * This API creates an entry into the jtf_usertype_reg table. It also sets the
 * responsibility to "pending". If approval is required a workflow is initiated
 * if not the credentials are assigned.
 */

PROCEDURE Create_System_User(p_username in varchar2,
                             p_usertype_id in number,
                             p_user_id  in number,
                             x_user_reg_id out NOCOPY number,
                             x_approval_id out NOCOPY number) is

l_wf_item_type varchar2(200);
l_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
l_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--x_usertype_reg_id NUMBER;
l_respKey varchar2(50) := 'JTF_PENDING_APPROVAL';
l_status  varchar2(10) := 'PENDING';
l_application_id  number := 690;
l_usertype_key varchar2(100);

cursor c_wf_item_type is
SELECT WF_ITEM_TYPE
FROM JTF_UM_APPROVALS_B APR,
     JTF_UM_USERTYPES_B UT
WHERE UT.APPROVAL_ID = APR.APPROVAL_ID
AND UT.USERTYPE_ID = p_usertype_id;

cursor c_usertype is
SELECT APPROVAL_ID, USERTYPE_KEY
FROM JTF_UM_USERTYPES_B
WHERE USERTYPE_ID = p_usertype_id;

l_method varchar2(25) := 'Create_system_user';
Begin

  JTF_DEBUG_PUB.log_entering_method(g_module, l_method);
  for i in c_wf_item_type loop
    l_wf_item_type := i.wf_item_type;
  end loop;

     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'before insert um reg row');
     end if;


  JTF_UM_USERTYPES_PKG.INSERT_UMREG_ROW(
    X_USERTYPE_ID => p_usertype_id,
    X_LAST_APPROVER_COMMENT => null,
    X_APPROVER_USER_ID => null,
    X_EFFECTIVE_END_DATE => null,
    X_WF_ITEM_TYPE => l_wf_item_type,
    X_EFFECTIVE_START_DATE => sysdate,
    X_USERTYPE_REG_ID => x_user_reg_id,
    X_USER_ID => p_user_id,
    X_STATUS_CODE => l_status,
    X_CREATION_DATE => sysdate,
    X_CREATED_BY    => l_user_id,
    X_LAST_UPDATE_DATE => sysdate,
    X_LAST_UPDATED_BY => l_user_id,
    X_LAST_UPDATE_LOGIN => l_login_id);

     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'After insert um reg row');
     end if;


	-- for bug 4378387 , end_date all subscriptions for the current
	-- user type which might have been granted to the user before
	-- this is done to ensure that all roles/resp are granted once again
	-- details in bug.
	UPDATE JTF_UM_SUBSCRIPTION_REG
	SET effective_END_DATE =SYSDATE, last_update_login=l_user_id,last_update_date=sysdate
	WHERE USER_ID = p_user_id and status_code='APPROVED'
	and effective_start_date < sysdate and nvl(effective_end_date,sysdate +1) > sysdate
	AND SUBSCRIPTION_ID IN
	(select SUBSCRIPTION_ID from JTF_UM_USERTYPE_SUBSCRIP
			where userTYpe_id=p_usertype_id and
			effective_start_date < sysdate and nvl(effective_end_date,sysdate +1) > sysdate);




     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'returning from insert um reg row reg id '|| x_user_reg_id);
     end if;



   for i in c_usertype loop
    x_approval_id := i.approval_id;
    l_usertype_key := i.usertype_key;
   end loop;

   if (x_approval_id is null or x_approval_id = -1) then
     JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_USERTYPE_CREDENTIALS(p_username, p_user_id, p_usertype_id);
   else
     if l_is_debug_parameter_on then
     JTF_DEBUG_PUB.LOG_DEBUG (2, G_MODULE, 'involing jtf_um_wf_approval.CreateProcess usertype_id ' || p_usertype_id||' p_user_id ' || p_user_id || ' reg id '|| x_user_reg_id || ' approval id ' || x_approval_id);
     end if;
         JTF_UM_USERTYPE_CREDENTIALS.ASSIGN_DEFAULT_RESPONSIBILITY(p_user_id,l_respKey,l_application_id);
     jtf_um_wf_approval.CreateProcess (requestType     => 'USERTYPE',
                                       requestID       => p_usertype_id,
                                       requesterUserID => p_user_id,
                                       requestRegID    => x_user_reg_id);
   end if;

   JTF_DEBUG_PUB.log_exiting_method(g_module, l_method);

end create_system_user;


PROCEDURE queryUTTemplateInfo(p_usertype_id   in number,
                              x_usertype_key  out NOCOPY varchar2,
                              x_usertype_name out NOCOPY varchar2,
                              x_template_id   out NOCOPY number,
                              x_page_name     out NOCOPY varchar2,
                              x_template_handler out NOCOPY varchar2,
                              x_explicit_enr_count out NOCOPY number
                             ) is


  CURSOR c_uttemplate is
  SELECT UT.USERTYPE_KEY, UT.USERTYPE_NAME, TMPL.TEMPLATE_ID,
         TMPL.PAGE_NAME, TMPL.TEMPLATE_HANDLER
  FROM JTF_UM_USERTYPES_VL UT, JTF_UM_USERTYPE_TMPL UTMPL,
       JTF_UM_TEMPLATES_B TMPL
  WHERE UT.usertype_id = p_usertype_id
  AND   UT.usertype_id = UTMPL.usertype_id
  AND   UTMPL.template_id = TMPL.template_id
  AND   SYSDATE between nvl(UT.EFFECTIVE_START_DATE, sysdate)
                    and nvl(UT.EFFECTIVE_END_DATE, sysdate)
  AND   SYSDATE between nvl(TMPL.EFFECTIVE_START_DATE, sysdate)
                    and nvl(TMPL.EFFECTIVE_END_DATE, sysdate)
  AND   SYSDATE between nvl(UTMPL.EFFECTIVE_START_DATE, sysdate)
                    and nvl(UTMPL.EFFECTIVE_END_DATE, sysdate);

  l_method varchar2(40) := 'queryUTTemplateInfo';
begin
  JTF_DEBUG_PUB.log_entering_method(g_module, l_method);

  for i in c_uttemplate loop
    x_usertype_key   := i.usertype_key;
    x_usertype_name  := i.usertype_name;
    x_template_id    := i.template_id;
    x_page_name      := i.page_name;
    x_template_handler := i.template_handler;
  end loop;


  JTF_DEBUG_PUB.log_exiting_method(g_module, l_method);
end queryUTTemplateInfo;

end JTF_UM_USER_ADMIN_PVT;

/
