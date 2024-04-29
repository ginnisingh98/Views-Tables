--------------------------------------------------------
--  DDL for Package PV_USER_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_USER_MGMT_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvumms.pls 120.9 2006/01/17 13:10:09 ktsao ship $ */

G_PARTNER_PERMISSION CONSTANT VARCHAR2(15) := 'PV_PARTNER_USER';
G_PRIMARY_PERMISSION VARCHAR2(20) := 'IBE_INT_PRIMARY_USER';

TYPE Partner_Rec_type IS RECORD
(
     partner_party_id NUMBER(15,0)
    ,member_type      VARCHAR2(30)
    ,global_prtnr_org_number VARCHAR2(360)
);

TYPE Partner_User_Rec_type IS RECORD
(
    USER_ID             NUMBER(15,0)
   ,PERSON_REL_PARTY_ID NUMBER(15,0)
   ,USER_NAME           VARCHAR2(100)
   ,USER_TYPE_ID        NUMBER
);

TYPE partner_types_Rec_type IS RECORD
(
  partner_type       VARCHAR2(30)
);

TYPE  partner_types_tbl_type   IS TABLE OF partner_types_rec_type  INDEX BY BINARY_INTEGER;


 PROCEDURE register_partner_and_user
 (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_partner_rec                IN   Partner_Rec_type
    ,P_partner_type               IN   VARCHAR2
    ,p_partner_user_rec           IN   partner_User_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
 );


PROCEDURE register_partner_user
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_partner_user_rec           IN   partner_User_rec_type
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
);


PROCEDURE revoke_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,p_user_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
);

PROCEDURE delete_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
);

PROCEDURE assign_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,p_user_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
);

PROCEDURE update_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_assigned_perms             IN   JTF_VARCHAR2_TABLE_1000
    ,p_unassigned_perms           IN   JTF_VARCHAR2_TABLE_1000
    ,p_role_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
);

FUNCTION is_partner_user (p_rel_party_id  IN  NUMBER) RETURN VARCHAR2;


/*+====================================================================
| FUNCTION NAME
|    post_approval
|
| DESCRIPTION
|    This function is seeded as a subscription to the approval event
|
| USAGE
|    -   creates resps and resources when an approval event happens
|
+======================================================================*/

FUNCTION post_approval(
		       p_subscription_guid      IN RAW,
		       p_event                  IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2;


PROCEDURE update_elig_prgm_4_new_ptnr(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER		   := FND_API.g_valid_level_full
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2     := null
);


END PV_USER_MGMT_PVT;

 

/
