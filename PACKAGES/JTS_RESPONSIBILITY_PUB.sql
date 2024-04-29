--------------------------------------------------------
--  DDL for Package JTS_RESPONSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_RESPONSIBILITY_PUB" AUTHID CURRENT_USER as
/* $Header: jtsprsps.pls 115.4 2002/01/24 19:15:58 pkm ship       $ */

-- Start of Comments
--
--    API name    :
--    Type        : Public
--
--
-- Required:
--
--
-- End of Comments

PROCEDURE Create_Responsibility
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_appl_id                IN      NUMBER,
    p_menu_id                IN      NUMBER,
    p_start_date            IN      DATE,
    p_end_date                IN      DATE,
    p_resp_key                IN      VARCHAR2,
    p_resp_name                IN      VARCHAR2,
    p_description            IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2,
    x_resp_id               OUT NUMBER
);

PROCEDURE Update_Responsibility
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_resp_id               IN      NUMBER,
    p_appl_id               IN      NUMBER,
    p_last_update_date      IN      DATE,
    p_menu_id               IN      NUMBER,
    p_start_date            IN      DATE,
    p_end_date              IN      DATE,
    p_resp_name             IN      VARCHAR2,
    p_description           IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2
);


PROCEDURE Create_Resp_Functions
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_app_id                IN      NUMBER,
    p_resp_id               IN    NUMBER,
    p_action_id             IN      NUMBER,
    p_rule_type             IN      VARCHAR2,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2,
    x_rowid                 OUT  VARCHAR2
);


PROCEDURE Delete_Resp_Functions
(   p_api_version_number    IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2      :=FND_API.G_FALSE,
    p_commit                IN    VARCHAR2       := FND_API.G_FALSE,
    p_app_id                IN    NUMBER,
    p_resp_id               IN    NUMBER,
    p_rule_type             IN    VARCHAR2,
    p_action_id             IN    NUMBER,
    x_return_status         OUT   VARCHAR2,
    x_msg_count             OUT   NUMBER,
    x_msg_data              OUT   VARCHAR2
);

END JTS_RESPONSIBILITY_PUB;


 

/
