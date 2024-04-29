--------------------------------------------------------
--  DDL for Package Body PA_CI_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_ACTIONS_PVT" AS
/* $Header: PACIACVB.pls 120.0 2005/06/03 13:27:41 appldev noship $ */


PROCEDURE CREATE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              out NOCOPY NUMBER,
    P_CI_ID                     in NUMBER,
    P_TYPE_CODE			in VARCHAR2,
    P_ASSIGNED_TO		in NUMBER,
    P_DATE_REQUIRED 		in DATE,
    P_SIGN_OFF_REQUIRED_FLAG    in VARCHAR2,
    P_COMMENT_TEXT              in VARCHAR2,
    P_SOURCE_CI_ACTION_ID       in NUMBER default NULL,
    P_CREATED_BY 		in NUMBER default fnd_global.user_id,
    P_CREATION_DATE 	        in DATE default sysdate,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
)
    IS
      -- Enter the procedure variables here. As shown below
    l_error_msg_code varchar2(30);
    l_ci_comment_id number;
    l_ci_action_id number;
    l_party_id number;
    l_action_number number;
    l_system_number_id number;
    l_ci_record_version_number number;
    l_num_of_actions number;
    l_comment_text varchar2(32767);
    l_process_name  varchar2(100);


     --bug 3297238
     l_item_key              pa_wf_processes.item_key%TYPE;

    Cursor getRecordVersionNumber IS
    select record_version_number
    from pa_control_items
    where ci_id = p_ci_id;

    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PVT.CREATE_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT ADD_ACTION;
        END IF;
        x_msg_count := 0;

        if (P_ASSIGNED_TO IS NULL) then
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                     ,p_msg_name       => 'PA_CI_ACTION_INVALID_ASSIGNEE');
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
        end if;





	if (p_ci_id IS NOT NULL) then
		l_action_number := PA_CI_ACTIONS_UTIL.get_next_ci_action_number(p_ci_id);
	end if;

        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

            PA_CI_ACTIONS_PKG.INSERT_ROW(
            P_CI_ACTION_ID => l_ci_action_id,
            P_CI_ID => P_CI_ID,
            P_CI_ACTION_NUMBER => l_action_number,
            P_STATUS_CODE => 'CI_ACTION_OPEN',
            P_TYPE_CODE => P_TYPE_CODE,
            P_ASSIGNED_TO => P_ASSIGNED_TO,
            P_DATE_REQUIRED => P_DATE_REQUIRED,
            P_SIGN_OFF_REQUIRED_FLAG => P_SIGN_OFF_REQUIRED_FLAG,
            P_DATE_CLOSED => NULL,
            P_SIGN_OFF_FLAG	=> 'N',
            P_SOURCE_CI_ACTION_ID => P_SOURCE_CI_ACTION_ID,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_CREATED_BY => P_CREATED_BY,
            P_CREATION_DATE => P_CREATION_DATE,
            P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
            P_RECORD_VERSION_NUMBER => 1);
	end if;

        if (P_COMMENT_TEXT IS NULL) THEN
		l_comment_text := ' ';
	else
		l_comment_text := p_comment_text;
	end if;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
                PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_comment_id => l_ci_comment_id,
                p_ci_id =>P_CI_ID,
                p_type_code => 'REQUESTOR',
                p_comment_text => l_comment_text,
                p_ci_action_id => l_ci_action_id,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
                );
        END IF;

	OPEN getRecordVersionNumber;
	FETCH getRecordVersionNumber into l_ci_record_version_number;
	CLOSE getRecordVersionNumber;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
		PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS (
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_id =>P_CI_ID,
       		p_num_of_actions => 1,
		p_record_version_number =>l_ci_record_version_number,
		x_num_of_actions => l_num_of_actions,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);
	End if;

   -- Changes for bug# 3691192 FP M Changes
   -- Depending upon Sign-off required different processes have been created in the PA Issue and Change Action Workflow
   if P_SIGN_OFF_REQUIRED_FLAG = 'Y' then
      l_process_name := 'PA_CI_ACTION_ASMT_SIGN_OFF';
   else
      l_process_name := 'PA_CI_ACTION_ASMT_NO_SIGN_OFF';
   end if;
   -- Launch the workflow notification if it is not validate only mode and no errors occured till now.
   -- Bug 3297238. FP M Changes.
   IF ( p_validate_only = FND_API.G_FALSE AND  x_return_status = FND_API.g_ret_sts_success  )THEN
          pa_control_items_workflow.START_NOTIFICATION_WF
                  (  p_item_type		=> 'PAWFCIAC'
                    ,p_process_name	=> l_process_name
                    ,p_ci_id		     => p_ci_id
                    ,p_action_id		=> l_ci_action_id
                    ,x_item_key		=> l_item_key
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data );
	  if(x_return_status <>  FND_API.g_ret_sts_success) then
               raise FND_API.G_EXC_ERROR;
	  end if;
   END IF;

        -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE
        THEN
            ROLLBACK TO ADD_ACTION;
        END IF;
        x_return_status := 'E';

    WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO ADD_ACTION;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'CREATE_CI_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
END CREATE_CI_ACTION;

PROCEDURE CLOSE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_calling_context     IN     VARCHAR2,
    P_CI_ACTION_ID              in NUMBER,
    P_SIGN_OFF_FLAG			    in VARCHAR2,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_COMMENT_TEXT              in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
)
    IS
    Cursor check_record_changed IS
    select rowid
    from pa_ci_actions
    where ci_action_id = p_ci_action_id
    and record_version_number = p_record_version_number
    for update;

    Cursor ci_action IS
    select ci_id, type_code, assigned_to, date_required,
    sign_off_required_flag, source_ci_action_id, created_by, creation_date
    from pa_ci_actions
    where ci_action_id = p_ci_action_id;

    l_party_id number;
    l_created_by number;
    l_creation_date date;
    l_ci_id number;
    l_type_code varchar2(30);
    l_assigned_to number;
    l_date_required date;
    l_sign_off_required_flag varchar2(1);
    l_source_ci_action_id number;
    l_error_msg_code varchar2(30);
    l_rowid rowid;
    l_ci_comment_id number;
    l_ci_record_version_number number;
    l_num_of_actions number;
    l_comment_text varchar2(32767);

     --bug 3297238
     l_item_key              pa_wf_processes.item_key%TYPE;

    Cursor getRecordVersionNumber IS
    select record_version_number
    from pa_control_items
    where ci_id = l_ci_id;
    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PVT.CLOSE_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_msg_count :=0 ;
        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT CLOSE_CI_ACTION;
        END IF;

        -- Validate the Input Values
        OPEN ci_action;
        FETCH ci_action INTO l_ci_id, l_type_code, l_assigned_to,
        l_date_required, l_sign_off_required_flag, l_source_ci_action_id,
        l_created_by, l_creation_date;
        IF ci_action%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_ACTION_FOUND');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE ci_action;
            return;
        END IF;

        --LOCK the ROW

        OPEN check_record_changed;
        FETCH check_record_changed INTO l_rowid;
        IF check_record_changed%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE check_record_changed;
            return;
        END IF;
        if (check_record_changed%ISOPEN) then
            CLOSE check_record_changed;
        end if;
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
            PA_CI_ACTIONS_PKG.UPDATE_ROW(
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_CI_ID => l_ci_id,
            P_STATUS_CODE => 'CI_ACTION_CLOSED',
            P_TYPE_CODE => l_type_code,
            P_ASSIGNED_TO => l_assigned_to,
            P_DATE_REQUIRED => l_date_required,
            P_SIGN_OFF_REQUIRED_FLAG => l_sign_off_required_flag,
            P_DATE_CLOSED => sysdate,
            P_SIGN_OFF_FLAG => P_SIGN_OFF_FLAG,
            P_SOURCE_CI_ACTION_ID => l_source_ci_action_id,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_CREATED_BY => l_created_by,
            P_CREATION_DATE => l_creation_date,
            P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => p_last_update_login,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER);
        End if;

        if (P_COMMENT_TEXT IS NULL) THEN
		l_comment_text := ' ';
	else
		l_comment_text := p_comment_text;
	end if;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
                PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_comment_id => l_ci_comment_id,
                p_ci_id => l_ci_id,
                p_type_code => 'CLOSURE',
                p_comment_text => l_comment_text,
                p_ci_action_id => P_CI_ACTION_ID,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
                );
        END IF;
	OPEN getRecordVersionNumber;
	FETCH getRecordVersionNumber into l_ci_record_version_number;
	CLOSE getRecordVersionNumber;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
		PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS (
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_id =>l_CI_ID,
       		p_num_of_actions => -1,
		p_record_version_number =>l_ci_record_version_number,
		x_num_of_actions => l_num_of_actions,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);
	End if;


   -- Launch the workflow notification if it is not validate only mode and no errors occured till now and calling context is CLOSE.
   -- Bug 3297238. FP M Changes.
   IF ( p_validate_only = FND_API.G_FALSE AND  x_return_status = FND_API.g_ret_sts_success AND P_calling_context = 'CLOSE'  )THEN
          pa_control_items_workflow.START_NOTIFICATION_WF
                  (  p_item_type		=> 'PAWFCIAC'
                    ,p_process_name	=> 'PA_CI_ACTION_CLOSE_FYI'
                    ,p_ci_id		     => l_ci_id
                    ,p_action_id		=> p_ci_action_id
                    ,x_item_key		=> l_item_key
                    ,x_return_status    => x_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data );
          if(x_return_status <>  FND_API.g_ret_sts_success) then
                raise FND_API.G_EXC_ERROR;
          end if;
   END IF;

       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;


    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO CLOSE_CI_ACTION;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO CLOSE_CI_ACTION;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'CLOSE_CI_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END CLOSE_CI_ACTION;


PROCEDURE REASSIGN_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER,
    P_SIGN_OFF_FLAG	 	in VARCHAR2 := 'N',
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_ASSIGNED_TO               in NUMBER,
    P_DATE_REQUIRED             in DATE,
    P_COMMENT_TEXT              in VARCHAR2,
    P_CLOSURE_COMMENT           in VARCHAR2,
    P_CREATED_BY 		in NUMBER default fnd_global.user_id,
    P_CREATION_DATE 	        in DATE default sysdate,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
)
    IS
    Cursor check_record_changed IS
    select rowid
    from pa_ci_actions
    where ci_action_id = p_ci_action_id
    and record_version_number = p_record_version_number
    for update;

    Cursor ci_action IS
    select ci_id, type_code, assigned_to, date_required,
    sign_off_required_flag, source_ci_action_id
    from pa_ci_actions
    where ci_action_id = p_ci_action_id;

    l_new_ci_action_id number;
    l_ci_id number;
    l_type_code varchar2(30);
    l_assigned_to number;
    l_date_required date;
    l_sign_off_required_flag varchar2(1);
    l_source_ci_action_id number;
    l_error_msg_code varchar2(30);
    l_rowid rowid;
    l_created_by number;
    l_creation_date date;
    l_assigned_to_party  NUMBER;


    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PVT.REASSIGN_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_data := 0;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT REASSIGN_CI_ACTION;
        END IF;

        -- Validate the Input Values
        OPEN ci_action;
        FETCH ci_action INTO l_ci_id, l_type_code, l_assigned_to,
        l_date_required, l_sign_off_required_flag, l_source_ci_action_id;
        IF ci_action%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_ACTION_FOUND');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE ci_action;
            return;
        END IF;


        --LOCK the ROW

        OPEN check_record_changed;
        FETCH check_record_changed INTO l_rowid;
        IF check_record_changed%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE check_record_changed;
            return;
        END IF;
        if (check_record_changed%ISOPEN) then
            CLOSE check_record_changed;
        end if;

        -- Validate if the action is being reassigned to the same person and check if date is before system date.
        select assigned_to
        into l_assigned_to_party
        from pa_ci_actions
        where ci_action_id = p_ci_action_id;


         if (p_assigned_to is not null and (l_assigned_to_party = p_assigned_to OR ((P_DATE_REQUIRED is not null) and (P_DATE_REQUIRED < sysdate))))then

            if  l_assigned_to_party = p_assigned_to THEN
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_ACTION_REASSIGN_INV');
                x_return_status := FND_API.G_RET_STS_ERROR;
           end if;

           if (P_DATE_REQUIRED is not null) and (P_DATE_REQUIRED < sysdate) then
             PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_CI_ACTION_DATE_REQ_INV');
             x_return_status := FND_API.G_RET_STS_ERROR;
           end if;

           return;
        end if;
        --validation for action assignee and date ends here.


        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
            PA_CI_ACTIONS_PVT.CLOSE_CI_ACTION
            (
            p_api_version => P_API_VERSION,
            p_init_msg_list => P_INIT_MSG_LIST,
            p_commit => P_COMMIT,
            p_validate_only => P_VALIDATE_ONLY,
            p_max_msg_count => P_MAX_MSG_COUNT,
            P_calling_context => 'REASSIGN',
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_SIGN_OFF_FLAG => P_SIGN_OFF_FLAG,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
            P_COMMENT_TEXT => P_CLOSURE_COMMENT,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );
        END IF;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

            PA_CI_ACTIONS_PVT.CREATE_CI_ACTION
            (
            P_API_VERSION => P_API_VERSION,
            P_INIT_MSG_LIST => P_INIT_MSG_LIST,
            P_COMMIT => P_COMMIT,
            P_VALIDATE_ONLY => P_VALIDATE_ONLY,
            P_MAX_MSG_COUNT => P_MAX_MSG_COUNT,
            P_CI_ACTION_ID => l_new_ci_action_id,
            P_CI_ID => l_ci_id,
            P_TYPE_CODE => l_type_code,
            P_ASSIGNED_TO => P_ASSIGNED_TO,
            P_DATE_REQUIRED => P_DATE_REQUIRED,
            P_SIGN_OFF_REQUIRED_FLAG => l_sign_off_required_flag,
            P_COMMENT_TEXT => P_COMMENT_TEXT,
            P_SOURCE_CI_ACTION_ID => P_CI_ACTION_ID,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );
        end if;

       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO REASSIGN_CI_ACTION;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO REASSIGN_CI_ACTION;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'REASSIGN_CI_ACTION',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END REASSIGN_CI_ACTION;

PROCEDURE CANCEL_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_CANCEL_COMMENT		in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
)
    IS
    Cursor check_record_changed IS
    select rowid
    from pa_ci_actions
    where ci_action_id = p_ci_action_id
    and record_version_number = p_record_version_number
    for update;

    Cursor ci_action IS
    select ci_id, type_code, assigned_to, date_required,
    sign_off_required_flag, source_ci_action_id, created_by, creation_date, sign_off_flag
    from pa_ci_actions
    where ci_action_id = p_ci_action_id;

    l_party_id number;
    l_created_by number;
    l_creation_date date;
    l_ci_id number;
    l_type_code varchar2(30);
    l_assigned_to number;
    l_date_required date;
    l_sign_off_required_flag varchar2(1);
    l_source_ci_action_id number;
    l_error_msg_code varchar2(30);
    l_rowid rowid;
    l_ci_comment_id number;
    l_sign_off_flag varchar2(1);
    l_ci_record_version_number number;
    l_num_of_actions number;
    l_comment_text varchar2(32767);

    Cursor getRecordVersionNumber IS
    select record_version_number
    from pa_control_items
    where ci_id = l_ci_id;

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_count :=0 ;
        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT CANCEL_CI_ACTION;
        END IF;

        -- Validate the Input Values
        OPEN ci_action;
        FETCH ci_action INTO l_ci_id, l_type_code, l_assigned_to,
        l_date_required, l_sign_off_required_flag, l_source_ci_action_id,
        l_created_by, l_creation_date,l_sign_off_flag;
        IF ci_action%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_NO_ACTION_FOUND');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE ci_action;
            return;
        END IF;

        l_party_id := PA_UTILS.get_party_id(P_LAST_UPDATED_BY);
        if (l_party_id IS NULL) then
            x_return_status := FND_API.G_RET_STS_ERROR;
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_RESOURCE_INVALID_PERSON');
            return;
        end if;

        --LOCK the ROW

        OPEN check_record_changed;
        FETCH check_record_changed INTO l_rowid;
        IF check_record_changed%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE check_record_changed;
            return;
        END IF;
        if (check_record_changed%ISOPEN) then
            CLOSE check_record_changed;
        end if;
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
            PA_CI_ACTIONS_PKG.UPDATE_ROW(
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_CI_ID => l_ci_id,
            P_STATUS_CODE => 'CI_ACTION_CANCELED',
            P_TYPE_CODE => l_type_code,
            P_ASSIGNED_TO => l_assigned_to,
            P_DATE_REQUIRED => l_date_required,
            P_SIGN_OFF_REQUIRED_FLAG => l_sign_off_required_flag,
            P_DATE_CLOSED => sysdate,
            P_SIGN_OFF_FLAG => l_sign_off_flag,
            P_SOURCE_CI_ACTION_ID => l_source_ci_action_id,
            P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
            P_CREATED_BY => l_created_by,
            P_CREATION_DATE => l_creation_date,
            P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
            P_LAST_UPDATE_LOGIN => P_LAST_UPDATE_LOGIN,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER);

        END IF;

        if (P_CANCEL_COMMENT IS NULL) THEN
		l_comment_text := ' ';
	else
		l_comment_text := P_CANCEL_COMMENT;
	end if;

	If (x_return_status = fnd_api.g_ret_sts_success
       	AND p_validate_only <> fnd_api.g_true) then
		PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
               	p_api_version => P_API_VERSION,
               	p_init_msg_list => P_INIT_MSG_LIST,
               	p_commit => P_COMMIT,
               	p_validate_only => P_VALIDATE_ONLY,
               	p_max_msg_count => P_MAX_MSG_COUNT,
               	p_ci_comment_id => l_ci_comment_id,
               	p_ci_id => l_ci_id,
              	p_type_code => 'CLOSURE',
               	p_comment_text => l_comment_text,
               	p_ci_action_id => P_CI_ACTION_ID,
               	x_return_status => x_return_status,
               	x_msg_count => x_msg_count,
               	x_msg_data => x_msg_data
               	);
	END IF;
	OPEN getRecordVersionNumber;
	FETCH getRecordVersionNumber into l_ci_record_version_number;
	CLOSE getRecordVersionNumber;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
		PA_CONTROL_ITEMS_PVT.UPDATE_NUMBER_OF_ACTIONS (
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_id =>l_ci_id,
       		p_num_of_actions => -1,
		p_record_version_number =>l_ci_record_version_number,
		x_num_of_actions => l_num_of_actions,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);
	End if;


       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO CLOSE_CI_ACTION;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO CLOSE_CI_ACTION;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'CLOSE_CI_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END CANCEL_CI_ACTION;

PROCEDURE UPDATE_CI_COMMENT(
                p_api_version         IN     NUMBER :=  1.0,
                p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
                p_commit              IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
                p_ci_comment_id       IN     NUMBER,
                p_comment_text        IN     VARCHAR2,
		p_record_version_number IN	NUMBER,
                P_LAST_UPDATED_BY     in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE    in DATE default sysdate,
                P_LAST_UPDATE_LOGIN   in NUMBER default fnd_global.user_id,
                x_return_status       OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2)
IS
	l_error_msg_code varchar2(30);
	l_party_id number;
	l_creation_date date;
	l_created_by number;
	l_type_code varchar2(30);
	l_ci_id number;
	l_ci_action_id number;
	l_rowid rowid;

	Cursor old_comment IS
	select ci_id, type_code, created_by, creation_date, ci_action_id from pa_ci_comments
	where ci_comment_id = p_ci_comment_id;

	Cursor check_record_changed IS
    	select rowid
    	from pa_ci_comments
    	where ci_comment_id = p_ci_comment_id
    	and record_version_number = p_record_version_number
    	for update;
BEGIN

	x_return_status := fnd_api.g_ret_sts_success;
        x_msg_data := 0;


        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT UPDATE_CI_COMMENT;
        END IF;

	OPEN old_comment;
	FETCH old_comment INTO l_ci_id, l_type_code,
	l_created_by, l_creation_date, l_ci_action_id;
	IF old_comment%NOTFOUND THEN
		PA_UTILS.Add_Message (p_app_short_name => 'PA'
			,p_msg_name	=> 'PA_NO_COMMENT_FOUND');
		CLOSE old_comment;
		return;
	END IF;
	CLOSE old_comment;

        OPEN check_record_changed;
        FETCH check_record_changed INTO l_rowid;
        IF check_record_changed%NOTFOUND THEN
	        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_PR_RECORD_CHANGED');
	        x_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE check_record_changed;
            return;
        END IF;
        if (check_record_changed%ISOPEN) then
            CLOSE check_record_changed;
        end if;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

            PA_CI_COMMENTS_PKG.UPDATE_ROW(
                P_CI_COMMENT_ID => P_CI_COMMENT_ID,
                P_CI_ID => l_ci_id,
                P_TYPE_CODE => l_type_code,
                P_COMMENT_TEXT => P_COMMENT_TEXT,
                P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
                P_CREATED_BY => l_created_by,
                P_CREATION_DATE	=> l_creation_date,
                P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
                P_LAST_UPDATE_LOGIN	=> P_LAST_UPDATE_LOGIN,
		P_RECORD_VERSION_NUMBER => p_record_version_number,
                P_CI_ACTION_ID => l_ci_action_id);
         End If;
       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO UPDATE_CI_COMMENT;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO UPDATE_CI_COMMENT;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'UPDATE_CI_COMMENT',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;


END UPDATE_CI_COMMENT;



PROCEDURE ADD_CI_COMMENT(
                p_api_version         IN     NUMBER :=  1.0,
                p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
                p_commit              IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
                p_ci_comment_id       out NOCOPY     NUMBER,
                p_ci_id               IN     NUMBER,
                p_type_code           IN     VARCHAR2,
                p_comment_text        IN     VARCHAR2,
                p_ci_action_id        IN     NUMBER,
                P_CREATED_BY 		in NUMBER default fnd_global.user_id,
                P_CREATION_DATE 	in DATE default sysdate,
                P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE 	in DATE default sysdate,
                P_LAST_UPDATE_LOGIN    	in NUMBER default fnd_global.user_id,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2)
IS
    l_error_msg_code varchar2(30);
    l_party_id number;
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_data := 0;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT ADD_CI_COMMENT;
        END IF;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true
	AND P_COMMENT_TEXT IS NOT NULL) then
            PA_CI_COMMENTS_PKG.INSERT_ROW(
                P_CI_COMMENT_ID => P_CI_COMMENT_ID,
                P_CI_ID => P_CI_ID,
                P_TYPE_CODE => P_TYPE_CODE,
                P_COMMENT_TEXT => P_COMMENT_TEXT,
                P_LAST_UPDATED_BY => P_LAST_UPDATED_BY,
                P_CREATED_BY => P_CREATED_BY,
                P_CREATION_DATE	=> P_CREATION_DATE,
                P_LAST_UPDATE_DATE => P_LAST_UPDATE_DATE,
                P_LAST_UPDATE_LOGIN	=> P_LAST_UPDATE_LOGIN,
                P_CI_ACTION_ID => P_CI_ACTION_ID);
         End If;
       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'ADD_CI_COMMENT',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END ADD_CI_COMMENT;

PROCEDURE CANCEL_ALL_ACTIONS(
                p_api_version         IN     NUMBER :=  1.0,
                p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
                p_commit              IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
                p_ci_id               IN     NUMBER,
		p_cancel_comment      IN     VARCHAR2 := NULL,
                P_CREATED_BY 		in NUMBER default fnd_global.user_id,
                P_CREATION_DATE 	in DATE default sysdate,
                P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE 	in DATE default sysdate,
                P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2)
IS
    l_error_msg_code varchar2(30);
    l_ci_action_id number;
    l_record_version_number number(15);
    l_ci_commment_id number(15);
    l_cancel_comment varchar2(32767);

     CURSOR  cancel_action IS
     SELECT ci_action_id, record_version_number
     FROM   PA_CI_ACTIONS pca
     WHERE  pca.ci_id = p_ci_id
     AND    status_code = 'CI_ACTION_OPEN';


    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_data := 0;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT CLOSE_ALL_ACTIONS;
        END IF;

	if (p_cancel_comment IS NULL) then
		FND_MESSAGE.SET_NAME('PA','PA_CI_CANCEL_ALL_ACTIONS');
		l_cancel_comment := FND_MESSAGE.GET;
	else
		l_cancel_comment := p_cancel_comment;
	end if;
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
	     OPEN cancel_action;
             LOOP
            	FETCH cancel_action INTO l_ci_action_id,
			l_record_version_number;
            	EXIT WHEN cancel_action%NOTFOUND;
	        PA_CI_ACTIONS_PVT.CANCEL_CI_ACTION
        	(
	            p_api_version => P_API_VERSION,
        	    p_init_msg_list => P_INIT_MSG_LIST,
	            p_commit => P_COMMIT,
	            p_validate_only => P_VALIDATE_ONLY,
	            p_max_msg_count => P_MAX_MSG_COUNT,
	            P_CI_ACTION_ID => l_ci_action_id,
	            P_RECORD_VERSION_NUMBER => l_record_version_number,
	            P_CANCEL_COMMENT => P_CANCEL_COMMENT,
	            x_return_status => x_return_status,
	            x_msg_count => x_msg_count,
	            x_msg_data => x_msg_data);
            END LOOP;
	    CLOSE cancel_action;
        End If;
       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'DELETE_ALL_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END CANCEL_ALL_ACTIONS;



PROCEDURE DELETE_ALL_ACTIONS(
                p_api_version         IN     NUMBER :=  1.0,
                p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
                p_commit              IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
                p_ci_id               IN     NUMBER,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2)
IS
    l_error_msg_code varchar2(30);
    l_ci_action_id number;
    l_ci_comment_id number;

     CURSOR  delete_action IS
     SELECT ci_action_id
     FROM   PA_CI_ACTIONS
     WHERE  ci_id = p_ci_id;

     CURSOR delete_comment IS
     SELECT ci_comment_id
     FROM PA_CI_COMMENTS
     WHERE ci_action_id = l_ci_action_id;

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_data := 0;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT DELETE_ALL_ACTIONS;
        END IF;

        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

	     OPEN delete_action;
             LOOP
            	FETCH delete_action INTO l_ci_action_id;
            	EXIT WHEN delete_action%NOTFOUND;
		PA_CI_ACTIONS_PKG.DELETE_ROW(
			P_CI_ACTION_ID => l_ci_action_id);
	    	OPEN delete_comment;
		LOOP
			FETCH delete_comment INTO l_ci_comment_id;
			EXIT WHEN delete_comment%NOTFOUND;
			PA_CI_COMMENTS_PKG.DELETE_ROW(
				P_CI_COMMENT_ID => l_ci_comment_id);
		END LOOP;
		CLOSE delete_comment;
              END LOOP;
	      CLOSE delete_action;

         End If;
       -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;

    EXCEPTION WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := 'E';
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
            ROLLBACK TO ADD_CI_COMMENT;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PVT',
                               p_procedure_name => 'DELETE_ALL_ACTIONS',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
END DELETE_ALL_ACTIONS;


END PA_CI_ACTIONS_PVT; -- Package Body PA_CI_ACTIONS_PVT

/
