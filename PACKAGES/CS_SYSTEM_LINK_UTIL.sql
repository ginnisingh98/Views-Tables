--------------------------------------------------------
--  DDL for Package CS_SYSTEM_LINK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SYSTEM_LINK_UTIL" AUTHID CURRENT_USER AS
/* $Header: cscsiuts.pls 115.4 2001/03/13 17:09:38 pkm ship   $ */


PROCEDURE Associate_System_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Disassociate_System_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);


PROCEDURE Associate_Name_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Disassociate_Name_With_User
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_party_id               IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Associate_System_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Disassociate_System_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_id              IN   NUMBER,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Associate_Name_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count		         OUT  NUMBER,
	x_msg_data		         OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

PROCEDURE Disassociate_Name_With_SR
(
    p_api_version_number     IN   NUMBER,
    p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
    p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
    p_system_name            IN   VARCHAR2,
    p_service_request_id     IN   NUMBER,
    x_return_status          OUT  VARCHAR2,
    x_msg_count			     OUT  NUMBER,
	x_msg_data			     OUT  VARCHAR2,
    x_java_msg               OUT  VARCHAR2
);

end CS_System_Link_UTIL;

 

/
