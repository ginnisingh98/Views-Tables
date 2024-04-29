--------------------------------------------------------
--  DDL for Package Body PA_CI_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_ACTIONS_PUB" AS
--$Header: PACIACPB.pls 120.0 2005/05/30 01:56:39 appldev noship $


PROCEDURE CREATE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              out NOCOPY NUMBER,
    P_CI_ID                     in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_TYPE_CODE			        in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_ASSIGNED_TO        	    in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_RESOURCE_TYPE_ID          in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_ASSIGNED_TO_NAME          in VARCHAR DEFAULT FND_API.G_MISS_CHAR,
    P_DATE_REQUIRED 		    in DATE DEFAULT FND_API.G_MISS_DATE,
    P_SIGN_OFF_REQUIRED_FLAG    in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_COMMENT_TEXT              in VARCHAR2,
    P_SOURCE_CI_ACTION_ID       in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_CREATED_BY 		        in NUMBER default fnd_global.user_id,
    P_CREATION_DATE 	        in DATE default sysdate,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
)
    IS
    l_msg_index_out        NUMBER;
    l_party_id number;
    l_error_message_code varchar2(30);
    l_resource_type_id varchar2(15);
    l_start_date_active date;
      -- Enter the procedure variables here. As shown below
   BEGIN

        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PUB.CREATE_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --Clear the global PL/SQL message table
        IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT CREATE_CI_ACTION;
        END IF;
        x_msg_count := 0;
        l_start_date_active:=sysdate;
        PA_CI_ACTIONS_UTIL.CheckHzPartyName_Or_Id ( p_resource_id        => P_ASSIGNED_TO
                                                ,p_resource_type_id   => P_RESOURCE_TYPE_ID
                                                ,p_resource_name      => P_ASSIGNED_TO_NAME
                                                ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                ,p_date               => l_start_date_active
                                                ,x_party_id           => l_party_id
                                                ,x_resource_type_id   => l_resource_type_id
                                                ,x_return_status      => x_return_status
                                                ,x_msg_count          => x_msg_count
                                                ,x_msg_data           => x_msg_data);


        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND l_party_id <> -999) then

            PA_CI_ACTIONS_PVT.CREATE_CI_ACTION
            (
            P_API_VERSION => P_API_VERSION,
            P_INIT_MSG_LIST => P_INIT_MSG_LIST,
            P_COMMIT => P_COMMIT,
            P_VALIDATE_ONLY => P_VALIDATE_ONLY,
            P_MAX_MSG_COUNT => P_MAX_MSG_COUNT,
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_CI_ID => P_CI_ID,
            P_TYPE_CODE => P_TYPE_CODE,
            P_ASSIGNED_TO => l_party_id,
            P_DATE_REQUIRED => P_DATE_REQUIRED,
            P_SIGN_OFF_REQUIRED_FLAG => P_SIGN_OFF_REQUIRED_FLAG,
            P_COMMENT_TEXT => P_COMMENT_TEXT,
            P_SOURCE_CI_ACTION_ID => P_CI_ACTION_ID,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );
         End If;
         -- IF the number of messaages is 1 then fetch the message code from the stack
         -- and return its text
         x_msg_count :=  FND_MSG_PUB.Count_Msg;
         IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
         END IF;

            -- Reset the error stack when returning to the calling program
         PA_DEBUG.Reset_Err_Stack;
            -- Commit the changes if requested
        if (p_commit = FND_API.G_TRUE
        AND x_return_status = fnd_api.g_ret_sts_success) then
            commit;
        end if;
    EXCEPTION
        WHEN OTHERS THEN
            rollback;
            -- Set the excetption Message and the stack
            FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_CI_ACTIONS_PUB.CREATE_CI_ACTION'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

   END;

   PROCEDURE CANCEL_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_CANCEL_COMMENT	        in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2) IS

    l_msg_index_out        NUMBER;

    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PUB.CANCEL_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        PA_CI_ACTIONS_PVT.CANCEL_CI_ACTION
            (
            p_api_version => P_API_VERSION,
            p_init_msg_list => P_INIT_MSG_LIST,
            p_commit => P_COMMIT,
            p_validate_only => P_VALIDATE_ONLY,
            p_max_msg_count => P_MAX_MSG_COUNT,
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
	    P_CANCEL_COMMENT => P_CANCEL_COMMENT,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );
          -- IF the number of messaages is 1 then fetch the message code from the stack
          -- and return its text
        x_msg_count :=  FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
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
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PUB',
                               p_procedure_name => 'CLOSE_CI_ACTION',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
    END;




   PROCEDURE CLOSE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER,
    P_SIGN_OFF_FLAG			    in VARCHAR2,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_COMMENT_TEXT              in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS
    l_msg_index_out        NUMBER;
    BEGIN
        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PUB.CLOSE_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT CLOSE_CI_ACTION;
        END IF;
        x_return_status := fnd_api.g_ret_sts_success;
        x_msg_count := 0;

        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

            PA_CI_ACTIONS_PVT.CLOSE_CI_ACTION
            (
            p_api_version => P_API_VERSION,
            p_init_msg_list => P_INIT_MSG_LIST,
            p_commit => P_COMMIT,
            p_validate_only => P_VALIDATE_ONLY,
            p_max_msg_count => P_MAX_MSG_COUNT,
            P_CI_ACTION_ID => P_CI_ACTION_ID,
            P_SIGN_OFF_FLAG => P_SIGN_OFF_FLAG,
            P_RECORD_VERSION_NUMBER => P_RECORD_VERSION_NUMBER,
            P_COMMENT_TEXT => P_COMMENT_TEXT,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data
            );

        End If;
        x_msg_count :=  FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
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
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PUB',
                               p_procedure_name => 'CLOSE_CI_ACTION',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
    END;

    PROCEDURE REASSIGN_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER,
    P_SIGN_OFF_FLAG			    in VARCHAR2,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_RESOURCE_TYPE_ID          in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_ASSIGNED_TO               in NUMBER,
    P_ASSIGNED_TO_NAME          in VARCHAR2,
    P_DATE_REQUIRED             in DATE,
    P_COMMENT_TEXT              in VARCHAR2,
    P_CLOSURE_COMMENT           in VARCHAR2,
    P_CREATED_BY 		        in NUMBER default fnd_global.user_id,
    P_CREATION_DATE 	        in DATE default sysdate,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
    ) IS
    l_party_id number;
    l_error_message_code varchar2(30);
    l_resource_type_id varchar2(15);
    l_start_date_active date;
    l_msg_index_out        NUMBER;
    BEGIN

        -- Initialize the Error Stack
        PA_DEBUG.init_err_stack('PA_CI_ACTIONS_PUB.REASSIGN_CI_ACTION');

        -- Initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --Clear the global PL/SQL message table
        IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT REASSIGN_CI_ACTION;
        END IF;
        x_msg_count := 0;
        l_start_date_active:=sysdate;
        PA_CI_ACTIONS_UTIL.CheckHzPartyName_Or_Id ( p_resource_id        => P_ASSIGNED_TO
                                                ,p_resource_type_id   => P_RESOURCE_TYPE_ID
                                                ,p_resource_name      => P_ASSIGNED_TO_NAME
                                                ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                ,p_date               => l_start_date_active
                                                ,x_party_id           => l_party_id
                                                ,x_resource_type_id   => l_resource_type_id
                                                ,x_return_status      => x_return_status
                                                ,x_msg_count          => x_msg_count
                                                ,x_msg_data           => x_msg_data);

        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then

            PA_CI_ACTIONS_PVT.REASSIGN_CI_ACTION
            (
                p_api_version   =>  p_api_version,
                p_init_msg_list =>  p_init_msg_list,
                p_commit        =>  p_commit,
                p_validate_only =>  p_validate_only,
                p_max_msg_count =>  p_max_msg_count,
                P_CI_ACTION_ID  =>  p_ci_action_id,
                P_SIGN_OFF_FLAG =>  p_sign_off_flag,
                P_RECORD_VERSION_NUMBER => p_record_version_number,
                P_ASSIGNED_TO   =>  l_party_id,
                P_DATE_REQUIRED =>  P_DATE_REQUIRED,
                P_COMMENT_TEXT  =>  P_COMMENT_TEXT,
                P_CLOSURE_COMMENT =>    P_CLOSURE_COMMENT,
                P_CREATED_BY    =>  P_CREATED_BY,
                P_CREATION_DATE =>  P_CREATION_DATE,
                P_LAST_UPDATED_BY   =>  P_LAST_UPDATED_BY,
                P_LAST_UPDATE_DATE  =>  P_LAST_UPDATE_DATE,
                P_LAST_UPDATE_LOGIN =>  P_LAST_UPDATE_LOGIN,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data
            );

        End If;
         -- IF the number of messaages is 1 then fetch the message code from the stack
         -- and return its text
        x_msg_count :=  FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
            pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
        END IF;
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
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PUB',
                               p_procedure_name => 'REASSIGN_CI_ACTION',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
    END;


PROCEDURE ADD_CI_COMMENT(
                p_api_version         IN     NUMBER :=  1.0,
                p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
                p_commit              IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
                x_ci_comment_id       out NOCOPY    NUMBER,
                p_ci_id               IN     NUMBER,
                p_type_code           IN     VARCHAR2,
                p_comment_text        IN     VARCHAR2,
                p_ci_action_id        IN     NUMBER := null,
                P_CREATED_BY 		        in NUMBER default fnd_global.user_id,
                P_CREATION_DATE 	        in DATE default sysdate,
                P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE 	        in DATE default sysdate,
                P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2)

    IS
    BEGIN
        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT ADD_CI_COMMENT;
        END IF;
        x_return_status := 'S';
        x_msg_count := 0;

        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
                PA_CI_ACTIONS_PVT.ADD_CI_COMMENT(
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_comment_id => X_CI_COMMENT_ID,
                p_ci_id =>P_CI_ID,
                p_type_code => P_TYPE_CODE,
                p_comment_text => P_COMMENT_TEXT,
                p_ci_action_id => P_CI_ACTION_ID,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
                );
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
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PUB',
                               p_procedure_name => 'ADD_CI_COMMENT',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
    END;


PROCEDURE UPDATE_CI_COMMENT(
                p_api_version         	IN     NUMBER :=  1.0,
                p_init_msg_list       	IN     VARCHAR2 := fnd_api.g_true,
                p_commit              	IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       	IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       	IN     NUMBER := FND_API.g_miss_num,
                p_ci_comment_id       	IN     NUMBER,
                p_comment_text        	IN     VARCHAR2,
		p_record_version_number IN     NUMBER,
                P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE 	in DATE default sysdate,
                P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2)

   IS
    BEGIN
        IF p_commit = FND_API.G_TRUE
        THEN
            SAVEPOINT UPDATE_CI_COMMENT;
        END IF;
        x_return_status := 'S';
        x_msg_count := 0;

        -- Validate the Input Values
        If (x_return_status = fnd_api.g_ret_sts_success
        AND p_validate_only <> fnd_api.g_true) then
                PA_CI_ACTIONS_PVT.UPDATE_CI_COMMENT(
                p_api_version => P_API_VERSION,
                p_init_msg_list => P_INIT_MSG_LIST,
                p_commit => P_COMMIT,
                p_validate_only => P_VALIDATE_ONLY,
                p_max_msg_count => P_MAX_MSG_COUNT,
                p_ci_comment_id => P_CI_COMMENT_ID,
                p_comment_text => P_COMMENT_TEXT,
		p_record_version_number => P_RECORD_VERSION_NUMBER,
                P_LAST_UPDATED_BY   =>  P_LAST_UPDATED_BY,
                P_LAST_UPDATE_DATE  =>  P_LAST_UPDATE_DATE,
                P_LAST_UPDATE_LOGIN =>  P_LAST_UPDATE_LOGIN,
                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data
                );
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
        fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CI_ACTIONS_PUB',
                               p_procedure_name => 'UPDATE_CI_COMMENT',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
        RAISE;
    END;

   -- Enter further code below as specified in the Package spec.
END; -- Package Body PA_CI_ACTIONS_PUB

/
