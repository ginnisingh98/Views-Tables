--------------------------------------------------------
--  DDL for Package PVX_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PVX_MISC_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvmiss.pls 120.0.12000000.2 2007/07/24 00:09:20 hekkiral ship $ */

/* ADMIN RECORD*/
TYPE admin_rec_type IS RECORD
(
 partner_profile_id      NUMBER        DEFAULT NULL       -- Partner profile
,logged_resource_id      NUMBER        DEFAULT NULL       -- Logged user
,cm_id                   NUMBER        DEFAULT NULL       -- Channel Manager
,ph_support_rep          NUMBER        DEFAULT NULL       -- Phone Support Rep
,cmm_id                  NUMBER        DEFAULT NULL       -- Channel Marketing Manager
,partner_id              NUMBER        DEFAULT NULL       -- Party_ID in the HZ_Party_RelationShip, use it as source_id for resource creation
,partner_relationship_id NUMBER        DEFAULT NULL       -- Relationship_ID of the relationship
,contact_id              NUMBER        DEFAULT NULL       -- Contact_ID for the resource
,user_id                 NUMBER        DEFAULT NULL       -- user_id for resource creation
,resource_type           VARCHAR2(30)  DEFAULT NULL       -- Type of resource
,role_resource_id        NUMBER        DEFAULT NULL       -- Resource for which the role is to be related
,role_resource_type      VARCHAR2(30)  DEFAULT NULL       -- Resource type for which the role is to be related
,role_code               VARCHAR2(30)  DEFAULT NULL       -- Role code to which the role_resource_id is to be related
,resource_number         VARCHAR2(30)  DEFAULT NULL       -- Resource number
,group_id                NUMBER        DEFAULT NULL       -- Group_ID
,group_number            VARCHAR2(30)  DEFAULT NULL       -- Group_Number
,group_usage             VARCHAR2(240) DEFAULT 'PRM'      -- Group Usage
,source_name             VARCHAR2(360) DEFAULT NULL       -- Source Name (Must while creating resource)
,resource_name           VARCHAR2(360) DEFAULT NULL       -- Resource Name
,source_org_name	 VARCHAR2(360) DEFAULT NULL       -- Organization Name
,source_org_id		 NUMBER	       DEFAULT NULL       -- Organization relationship id
,user_name               VARCHAR2(100) DEFAULT NULL       -- User Name
,source_first_name       VARCHAR2(360) DEFAULT NULL       -- First Name
,source_middle_name      VARCHAR2(360) DEFAULT NULL       -- Middle Name
,source_last_name        VARCHAR2(360) DEFAULT NULL       -- Last Name
,party_site_id           NUMBER        DEFAULT NULL       -- Party Site ID for the address
,object_version_number   NUMBER        DEFAULT 1          -- Object version number
);


/* FND RECORD*/
TYPE fnd_rec_type IS RECORD
(
  user_id               NUMBER        DEFAULT NULL
 ,user_name             VARCHAR2(100) DEFAULT NULL
 ,owner                 VARCHAR2(100) DEFAULT NULL
 ,start_date            DATE          DEFAULT NULL
 ,end_date              DATE          DEFAULT NULL
 ,email_address         VARCHAR2(240) DEFAULT NULL
 ,resp_app_short_name   VARCHAR2(100) DEFAULT NULL
 ,resp_key              VARCHAR2(30)  DEFAULT NULL
 ,security_group        VARCHAR2(100) DEFAULT NULL
 ,resp_id               NUMBER        DEFAULT NULL
 ,resp_app_id           NUMBER        DEFAULT NULL
);

---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Access
--
-- PURPOSE
--    Create/delete/update access for the specified sales_force_id.
--
-- PARAMETERS
--    p_admin_rec: the new record to be administered
--    x_access_id: return the access_id
--
-- NOTES
--    1. object_version_number will be set to 1.
--    2. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------
PROCEDURE Admin_Access(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_access_id         OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    Admin_Resource
--
-- PURPOSE
--    Create a resource for the party_id of Relationship in the HZ_PARTY_RELATIONSHIPS
--
-- PARAMETERS
--    p_admin_rec: the new record to be administered
--    x_resource_id: return the x_resource_id
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Admin_Resource(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_resource_id       OUT NOCOPY NUMBER
  ,x_resource_number   OUT NOCOPY VARCHAR2
);


-------------------------------------------------------------------
-- PROCEDURE
--    Admin_Role
--
-- PURPOSE
--    Create a Role
--
-- PARAMETERS
--    p_admin_rec: the new record to be administered
--    x_role_relate_id: return the x_role_relate_id
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE Admin_Role(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_role_relate_id    OUT NOCOPY NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    Admin_Group
--
-- PURPOSE
--    Create a Group, Group Usage, Group Member (map resource to a group)
--
-- PARAMETERS
--    p_admin_rec: the new record to be administered
--    x_group_id: return the x_group_id
--    x_group_number: return the x_group_number
--    x_group_usage_id: return the x_group_usage_id
--    x_group_member_id: return the x_group_member_id
--
-- NOTES
--    This wrapper internally calls the following :
--    a) JTF_RS_GROUPS_PUB.Create_Resource_Group
--    b) JTF_RS_GROUP_USAGES_PUB.Create_Group_Usage
--    c) JTF_RS_GROUP_MEMBERS_PUB.Create_Resource_Group_Members
--------------------------------------------------------------------
PROCEDURE Admin_Group(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_group_id          OUT NOCOPY NUMBER
  ,x_group_number      OUT NOCOPY VARCHAR2
  ,x_group_usage_id    OUT NOCOPY NUMBER
  ,x_group_member_id   OUT NOCOPY NUMBER
);

-------------------------------------------------------------------
-- PROCEDURE
--    Admin_Group_Member
--
-- PURPOSE
--    Create a Group Member (map resource to a group)
--
-- PARAMETERS
--    p_admin_rec: the new record to be administered
--    x_group_member_id: return the x_group_member_id
--
-- NOTES
--    This wrapper internally calls the following :
--    a) JTF_RS_GROUP_MEMBERS_PUB.Create_Resource_Group_Members
--------------------------------------------------------------------
PROCEDURE Admin_Group_Member(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_group_member_id   OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_User
--
-- PURPOSE
--    Update Fnd_user Record
--
-- PARAMETERS
--    p_fnd_rec : the new record to be administered
--
--
-- NOTES
--    1. object_version_number will be set to 1.
---------------------------------------------------------------------
PROCEDURE  Update_User(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fnd_rec           IN  fnd_rec_type

);


-------------------------------------------------------------------
-- PROCEDURE
--    Disable_Responsibility
--
-- PURPOSE
--    Disables the user responsibility
--
-- PARAMETERS
--    p_fnd_rec: the fnd record for disabling the responsibility
--
-- NOTES
--
--
--------------------------------------------------------------------
PROCEDURE Disable_Responsibility(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_fnd_rec           IN  fnd_rec_type
  ,p_mode              IN  VARCHAR2 := FND_API.G_MISS_CHAR
);


-------------------------------------------------------------------
-- PROCEDURE
--    Update_Partner_Status
--
-- PURPOSE
--    Procedure to update partner status in pv_partner_profiles table
--    using the Update Partner Status (PVXUPDPS) concurrent program
--
-- PARAMETERS
--    None
--
-- NOTES
--
--
--------------------------------------------------------------------

PROCEDURE update_partner_status (
  ERRBUF      OUT NOCOPY   VARCHAR2,
  RETCODE     OUT NOCOPY   VARCHAR2
);

-------------------------------------------------------------------
-- PROCEDURE
--    Cr_As_Accts_With_Partner_User
--
-- PURPOSE
--    Procedure to Create and Associate the customer Accounts with
--    Partner Users.
--
-- PARAMETERS
--    None
--
-- NOTES
--
--
--------------------------------------------------------------------

PROCEDURE Cr_As_Accts_With_Partner_User (
  ERRBUF      OUT NOCOPY   VARCHAR2,
  RETCODE     OUT NOCOPY   VARCHAR2
);

END PVX_Misc_PVT;

 

/
