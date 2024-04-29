--------------------------------------------------------
--  DDL for Package PV_USER_RESP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_USER_RESP_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpurs.pls 120.0 2005/05/27 15:53:13 appldev noship $*/

-- ===============================================================
-- Start of Comments
-- Package name
--          PV_USER_RESP_PUB
-- Purpose
--
-- History
--         24-OCT-2002    Jessica.Lee         Created
--         02-OCT-2003    Karen.Tsao          Modified for 11.5.10
--         12-NOV-2003    Karen.Tsao          Added function manage_resp_on_address_change()
--                                            for business event subscription.
--         14-NOV-2003    Karen.Tsao          Split manage_store_resp_on_update into manage_store_resp_on_create and
--                                            manage_store_resp_on_delete.
--         19-FEB-2004    Karen.Tsao          Fixed for bug 3436285. Added adjust_user_resps() API.
--         13-AUG-2004    Karen.Tsao          Fixed for bug 3830319. Created manage_merged_party_memb_resp() API for party merge routine.
--         18-AUG-2004    Karen.Tsao          Updated the manage_merged_party_memb_resp() API by adding one extra parameter p_from_partner_id.
--         14-APR-2004    Karen.Tsao          Make update_resp_mapping into concurrent program call exec_cre_upd_del_resp_mapping (same as
--                                            create and delete). Therefore, change API name exec_cre_or_del_resp_mapping to exec_cre_upd_del_resp_mapping.
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PRIMARY CONSTANT VARCHAR2(30) := 'PRIMARY';
G_BUSINESS CONSTANT VARCHAR2(30) := 'BUSINESS';
G_ALL CONSTANT VARCHAR2(30) := 'ALL';
G_PROGRAM CONSTANT VARCHAR2(30) := 'PROGRAMS';
G_STORE CONSTANT VARCHAR2(30) := 'STORES';

FUNCTION get_partner_users (
     p_partner_id		       IN NUMBER,
     p_user_role_code       IN VARCHAR2
)
RETURN JTF_NUMBER_TABLE;

FUNCTION get_partners (
    p_user_id		     IN  NUMBER
)
RETURN JTF_NUMBER_TABLE;

PROCEDURE assign_resp
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                     IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 		 IN   NUMBER,
    p_resp_id		 			 IN   NUMBER,
	 p_app_id				 	 IN   NUMBER,
    X_Return_Status		 		 OUT NOCOPY  VARCHAR2,
    X_Msg_Count			 		 OUT NOCOPY  NUMBER,
    X_Msg_Data			 		 OUT NOCOPY  VARCHAR2
);

PROCEDURE revoke_resp(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list          	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                 	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 			   IN   NUMBER,
    p_resp_id		 				   IN   NUMBER,
    p_app_id				 		   IN   NUMBER,
    p_security_group_id			   IN   NUMBER,
    p_start_date			 		   IN   DATE,
    p_description 				   IN   VARCHAR2,
    x_return_status		 	      OUT NOCOPY  VARCHAR2,
    x_msg_count			 		   OUT NOCOPY  NUMBER,
    x_msg_data			 			   OUT NOCOPY  VARCHAR2
);

PROCEDURE revoke_resp(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list          	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                 	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 			   IN   JTF_NUMBER_TABLE,
    p_resp_id		 				   IN   NUMBER,
    x_return_status		 	      OUT NOCOPY  VARCHAR2,
    x_msg_count			 		   OUT NOCOPY  NUMBER,
    x_msg_data			 			   OUT NOCOPY  VARCHAR2
);

PROCEDURE get_user_role_code(
    p_user_id            IN  NUMBER
   ,x_user_role_code     OUT NOCOPY VARCHAR2
);

PROCEDURE get_default_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
);

PROCEDURE get_default_org_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_org_id             IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
);

PROCEDURE get_program_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,p_program_id                 IN   NUMBER
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
);

PROCEDURE assign_first_user_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
   ,p_responsibility_id          IN   NUMBER
   ,p_partner_id                 IN   NUMBER
   ,p_user_id                    IN   NUMBER
);

PROCEDURE assign_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
);

PROCEDURE assign_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_name                  IN   VARCHAR2
);

PROCEDURE switch_user_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_from_user_role_code        IN   VARCHAR2
   ,p_to_user_role_code          IN   VARCHAR2
);

PROCEDURE manage_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_membership_id              IN   NUMBER
);

PROCEDURE delete_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
);

PROCEDURE update_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
);

PROCEDURE create_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
);

PROCEDURE manage_resp_on_address_change(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_org_party_id               IN   NUMBER
);

PROCEDURE revoke_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
);

PROCEDURE revoke_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_name                  IN   VARCHAR2
);

PROCEDURE manage_store_resp_on_create(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
   ,p_resp_id                    IN   NUMBER
   ,p_program_id                 IN   NUMBER
);

PROCEDURE manage_store_resp_on_delete(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
);


PROCEDURE assign_default_resp (
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
);

PROCEDURE revoke_default_resp (
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
);

PROCEDURE adjust_user_resps
(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2  := Fnd_Api.g_false
   ,p_commit                     IN   VARCHAR2  := Fnd_Api.g_false
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id			 	         IN   NUMBER
   ,p_def_resp_id		 			   IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,p_partner_id				 	   IN   NUMBER
);

procedure exec_cre_upd_del_resp_mapping (
    ERRBUF                       OUT  NOCOPY VARCHAR2
   ,RETCODE                      OUT  NOCOPY VARCHAR2
   ,p_action                     IN   VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
);

procedure exec_asgn_or_rvok_user_resps (
    ERRBUF                       OUT  NOCOPY VARCHAR2
   ,RETCODE                      OUT  NOCOPY VARCHAR2
   ,p_action                     IN   VARCHAR2
   ,p_user_name                  IN   VARCHAR2
);

FUNCTION manage_resp_on_address_change
( p_subscription_guid  in raw,
  p_event              in out NOCOPY wf_event_t
)
RETURN VARCHAR2;

PROCEDURE manage_merged_party_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_from_partner_id            IN   NUMBER
   ,p_to_partner_id              IN   NUMBER
);

END Pv_User_Resp_Pvt;

 

/
