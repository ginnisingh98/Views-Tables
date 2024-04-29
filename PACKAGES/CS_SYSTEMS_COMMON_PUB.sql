--------------------------------------------------------
--  DDL for Package CS_SYSTEMS_COMMON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SYSTEMS_COMMON_PUB" AUTHID CURRENT_USER as
 /* $Header: cscommns.pls 115.4 2001/03/13 17:09:35 pkm ship      $ */
    TYPE Sys_Info_Cursor IS REF CURSOR;

    function get_party_id (p_user_id          IN NUMBER)  return NUMBER;
    function get_system_id (p_system_name     IN VARCHAR2)  return NUMBER;

    procedure is_system_enabled(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_commit                 IN   VARCHAR := FND_API.G_FALSE,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

    procedure is_system_valid(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR := FND_API.G_FALSE,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

   procedure get_current_system (
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR,
                     x_system_id              OUT  NUMBER,
                     x_system_name            OUT  VARCHAR2,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

  procedure get_all_systems_for_user(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_user_id                IN   NUMBER,
                     p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
                     x_system_data            OUT  Sys_Info_Cursor,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

    procedure get_all_child_systems(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2  := FND_API.G_FALSE,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR   := FND_API.G_FALSE,
                     x_system_data            OUT  Sys_Info_Cursor,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

   procedure is_user_associated_to_system(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_user_id                IN   NUMBER,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

   procedure association_exists(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );

   procedure user_exists(
                     p_api_version_number     IN   NUMBER,
                     p_init_msg_list          IN   VARCHAR2,
                     p_system_id              IN   NUMBER,
                     p_system_name            IN   VARCHAR2,
                     p_commit                 IN   VARCHAR,
                     x_return_status          OUT  VARCHAR2,
                     x_msg_count              OUT  NUMBER,
                     x_msg_data               OUT  VARCHAR2
                    );


end CS_SYSTEMS_COMMON_PUB;

 

/
