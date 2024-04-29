--------------------------------------------------------
--  DDL for Package PA_CI_ACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_ACTIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: PACIACPS.pls 120.0 2005/06/03 13:30:35 appldev noship $ */

PROCEDURE CREATE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              out NOCOPY NUMBER,
    P_CI_ID                     in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_TYPE_CODE			in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_ASSIGNED_TO        	in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_RESOURCE_TYPE_ID          in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_ASSIGNED_TO_NAME          in VARCHAR DEFAULT FND_API.G_MISS_CHAR,
    P_DATE_REQUIRED 		in DATE DEFAULT FND_API.G_MISS_DATE,
    P_SIGN_OFF_REQUIRED_FLAG    in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_COMMENT_TEXT              in VARCHAR2,
    P_SOURCE_CI_ACTION_ID       in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_CREATED_BY 		in NUMBER default fnd_global.user_id,
    P_CREATION_DATE 	        in DATE default sysdate,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);
   PROCEDURE CANCEL_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_RECORD_VERSION_NUMBER     in NUMBER,
    P_CANCEL_COMMENT		in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	    in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2);

   PROCEDURE CLOSE_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_SIGN_OFF_FLAG		in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_RECORD_VERSION_NUMBER     in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_COMMENT_TEXT              in VARCHAR2,
    P_LAST_UPDATED_BY 	        in NUMBER default fnd_global.user_id,
    P_LAST_UPDATE_DATE 	        in DATE default sysdate,
    P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

    PROCEDURE REASSIGN_CI_ACTION (
    p_api_version         IN     NUMBER :=  1.0,
    p_init_msg_list       IN     VARCHAR2 := fnd_api.g_true,
    p_commit              IN     VARCHAR2 := FND_API.g_false,
    p_validate_only       IN     VARCHAR2 := FND_API.g_true,
    p_max_msg_count       IN     NUMBER := FND_API.g_miss_num,
    P_CI_ACTION_ID              in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_SIGN_OFF_FLAG		in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_RECORD_VERSION_NUMBER     in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_RESOURCE_TYPE_ID          in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_ASSIGNED_TO               in NUMBER DEFAULT FND_API.G_MISS_NUM,
    P_ASSIGNED_TO_NAME          in VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    P_DATE_REQUIRED             in DATE DEFAULT FND_API.G_MISS_DATE,
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
    );

PROCEDURE ADD_CI_COMMENT(
                p_api_version         	IN     NUMBER :=  1.0,
                p_init_msg_list       	IN     VARCHAR2 := fnd_api.g_true,
                p_commit              	IN     VARCHAR2 := FND_API.g_false,
                p_validate_only       	IN     VARCHAR2 := FND_API.g_true,
                p_max_msg_count       	IN     NUMBER := FND_API.g_miss_num,
                x_ci_comment_id       	out NOCOPY    NUMBER,
                p_ci_id               	IN     NUMBER,
                p_type_code           	IN     VARCHAR2,
                p_comment_text        	IN     VARCHAR2,
                p_ci_action_id        	IN     NUMBER := null,
                P_CREATED_BY 		in NUMBER default fnd_global.user_id,
                P_CREATION_DATE 	in DATE default sysdate,
                P_LAST_UPDATED_BY 	in NUMBER default fnd_global.user_id,
                P_LAST_UPDATE_DATE 	in DATE default sysdate,
                P_LAST_UPDATE_LOGIN 	in NUMBER default fnd_global.user_id,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2);

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
                x_msg_data              OUT NOCOPY VARCHAR2);


END; -- Package Specification PA_CI_ACTIONS_PUB
 

/
