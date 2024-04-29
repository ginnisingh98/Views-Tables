--------------------------------------------------------
--  DDL for Package DOM_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_SECURITY_PUB" AUTHID CURRENT_USER AS
/* $Header: DOMDATASECS.pls 120.6 2006/11/08 14:01:02 ysireesh noship $ */


PROCEDURE Grant_Document_Role
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_object_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,   -- Document_Id
   p_pk2_value             IN  VARCHAR2,   -- Revision_Id
   p_pk3_value             IN  VARCHAR2,   -- Change_Id
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_role_id               IN  NUMBER,
   p_start_date            IN  DATE := SYSDATE,
   p_end_date              IN  DATE := NULL,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
 );
-- Start OF comments
-- API name  : Grant_Document_Role
-- TYPE      : Public
-- Pre-reqs  : None
-- FUNCTION  : Grant a Role on object to a given set of users.
--             If this operation fails then the grant is not
--             done and error code is returned.
-- Parameters:
--                  p_api_version               IN  NUMBER
--                  p_init_msg_list             IN  VARCHAR2       FND_API.G_FALSE / FND_API.G_TRUE
--                  p_commit                    IN  VARCHAR2       FND_API.G_FALSE / FND_API.G_TRUE
--                  p_validation_level          IN  NUMBER         FND_API.G_VALID_LEVEL_FULL
--                  p_object_name               IN  VARCHAR2       Object_Name  Required
--                  p_pk1_value                 IN  VARCHAR2                    Required
--                  p_pk2_value                 IN  VARCHAR2                    Required
--                  p_pk3_value                 IN  VARCHAR2                    Required
--                  p_pk4_value                 IN  VARCHAR2                    Required
--                  p_pk5_value                 IN  VARCHAR2                    Required
--                  p_party_ids                 IN  FND_TABLE_OF_NUMBER         Array of Person's HZ_PARTIES.PARTY_IDs
--                  p_role_id                   IN  NUMBER         FND_MENUS.MENU_ID, Role Id to be granted
--                  p_start_date                IN  DATE
--                  p_end_date                  IN  DATE
--                  p_api_caller                IN  VARCHAR2
--
-- Returns:
--                  x_msg_count                 NUMBER
--                  x_msg_data                  VARCHAR2
--                  x_return_status             VARCHAR2
--
-- Version   : Current Version 0.1
-- Previous
-- Version   : None
-- Notes     :
--
-- END OF comments


PROCEDURE Revoke_Document_Role
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_object_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_role_id               IN  NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
 );
-- Start OF comments
-- API name  : Revoke_Document_Role
-- TYPE      : Public
-- Pre-reqs  : None
-- FUNCTION  : Revoke a Role for a given set of users on an object.
--             If this operation fails then the revoke operation
--             is not done and error code is returned.
-- Parameters:
--                  p_api_version               IN  NUMBER
--                  p_init_msg_list             IN  VARCHAR2       FND_API.G_FALSE / FND_API.G_TRUE
--                  p_commit                    IN  VARCHAR2       FND_API.G_FALSE / FND_API.G_TRUE
--                  p_validation_level          IN  NUMBER         FND_API.G_VALID_LEVEL_FULL
--                  p_object_name               IN  VARCHAR2       Object_Name  Required
--                  p_pk1_value                 IN  VARCHAR2                    Required
--                  p_pk2_value                 IN  VARCHAR2                    Required
--                  p_pk3_value                 IN  VARCHAR2                    Required
--                  p_pk4_value                 IN  VARCHAR2                    Required
--                  p_pk5_value                 IN  VARCHAR2                    Required
--                  p_party_ids                 IN  FND_TABLE_OF_NUMBER         Array of Person's HZ_PARTIES.PARTY_IDs
--                  p_role_id                   IN  NUMBER         FND_MENUS.MENU_ID, Role Id to be revoked
--                  p_api_caller                IN  VARCHAR2
--
-- Returns:
--                  x_msg_count                 NUMBER
--                  x_msg_data                  VARCHAR2
--                  x_return_status             VARCHAR2
--
-- Version   : Current Version 0.1
-- Previous
-- Version   : None
-- Notes     :
--
-- END OF comments


PROCEDURE     Get_User_Roles
  (
   p_object_id            IN  NUMBER,
   p_document_id      IN NUMBER,
   p_revision_id      IN NUMBER,
   p_change_id      IN NUMBER,
   p_change_line_id      IN NUMBER,
   p_party_id             IN  NUMBER,
   x_role_ids             OUT NOCOPY FND_ARRAY_OF_NUMBER_25
 ) ;


FUNCTION check_user_privilege
  (
   p_api_version        IN  NUMBER,
   p_privilege          IN  VARCHAR2,
   p_object_name        IN  VARCHAR2,
   p_instance_pk1_value IN  VARCHAR2,
   p_instance_pk2_value IN  VARCHAR2,
   p_instance_pk3_value IN  VARCHAR2,
   p_instance_pk4_value IN  VARCHAR2,
   p_instance_pk5_value IN  VARCHAR2,
   p_party_id           IN  NUMBER
 )
 RETURN VARCHAR2;



PROCEDURE Grant_Attachments_OCSRole
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_ocs_role              IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
);


PROCEDURE Grant_Attachment_Access
(
   p_api_version           IN   NUMBER,
   p_attached_document_id  IN   NUMBER := NULL,
   p_source_media_id       IN   NUMBER,
   p_repository_id         IN   NUMBER,
   p_ocs_role              IN   VARCHAR2,
   p_party_ids             IN   FND_TABLE_OF_NUMBER,
   p_submitted_by          IN   NUMBER,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2,
   x_return_status         OUT  NOCOPY VARCHAR2
);


PROCEDURE Revoke_Attachments_OCSRole
(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_entity_name           IN  VARCHAR2,
   p_pk1_value             IN  VARCHAR2,
   p_pk2_value             IN  VARCHAR2,
   p_pk3_value             IN  VARCHAR2,
   p_pk4_value             IN  VARCHAR2,
   p_pk5_value             IN  VARCHAR2,
   p_ocs_role              IN  VARCHAR2,
   p_party_ids             IN  FND_TABLE_OF_NUMBER,
   p_api_caller            IN  VARCHAR2 := NULL,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
);


FUNCTION  Check_For_Duplicate_Grant
  (
   p_entity_name            IN  VARCHAR2,
   p_pk1_value      IN VARCHAR2,
   p_pk2_value          IN VARCHAR2,
   p_pk3_value            IN VARCHAR2,
   p_pk4_value     IN  VARCHAR2,
   p_pk5_value     IN  VARCHAR2,
   p_file_id                IN  NUMBER,
   p_repos_id            IN NUMBER,
   p_party_id             IN  NUMBER
 )
RETURN NUMBER;


END DOM_SECURITY_PUB;

 

/
