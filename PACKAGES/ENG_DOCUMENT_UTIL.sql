--------------------------------------------------------
--  DDL for Package ENG_DOCUMENT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DOCUMENT_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUDOCS.pls 120.5 2006/11/14 08:43:09 asjohal noship $ */


  -- Global constants --
  -- DOM Document Objects
  G_DOM_DOCUMENT_CATEGORY CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_CATEGORY';
  G_DOM_DOCUMENT_REVISION CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_REVISION';
  G_DOM_DOCUMENT          CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT';
  G_OCS_FILE              CONSTANT VARCHAR2(30)  := 'OCS_FILE';

  -- DOM Document Seeded Roles
  G_DOM_DOCUMENT_VIEWER   CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_VIEWER';
  G_DOM_DOCUMENT_AUTHOR   CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_AUTHOR';
  G_DOM_DOCUMENT_ADMIN    CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_ADMIN';


  -- CM Change Mgmt Type Code for Document Lifeycle Change Object
  G_DOM_DOCUMENT_LIFECYCLE CONSTANT VARCHAR2(30)  := 'DOM_DOCUMENT_LIFECYCLE';



  /********************************************************************
  * API Type      : Private APIs
  * Purpose       : Those APIs are private
  *********************************************************************/
  FUNCTION Is_Dom_Document_Lifecycle( p_change_id                  IN NUMBER
                                    , p_base_change_mgmt_type_code IN VARCHAR2 := NULL
                                    )
  RETURN BOOLEAN ;


  PROCEDURE Get_Document_Revision_Id( p_change_id                 IN  NUMBER
                                    , x_document_id               OUT NOCOPY NUMBER
                                    , x_document_revision_id      OUT NOCOPY NUMBER
                                    ) ;


  -- Get Document Revision Info
  PROCEDURE Get_Document_Rev_Info
  (  p_document_revision_id      IN NUMBER
   , x_document_id               OUT NOCOPY NUMBER
   , x_document_number           OUT NOCOPY VARCHAR2
   , x_document_revision         OUT NOCOPY VARCHAR2
   , x_documnet_name             OUT NOCOPY VARCHAR2
   , x_document_detail_page_url  OUT NOCOPY VARCHAR2
  ) ;


  --
  -- Wrapper API to integrate DOM Document API when Updating Approval Status
  -- of Document LC Phase Change Object
  --
  PROCEDURE Update_Approval_Status
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_approval_status           IN   NUMBER                             -- header approval status
   ,p_wf_route_status           IN   VARCHAR2                           -- workflow routing status (for document types)
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  );


  --
  -- Wrapper API to integrate DOM Document API when Promoting/Demoting
  -- Document LC Phase
  --
  PROCEDURE Change_Doc_LC_Phase
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_lc_phase_code             IN   NUMBER                             -- new phase
   ,p_action_type               IN   VARCHAR2 := NULL                   -- promote/demote action type 'PROMOTE' or 'DEMOTE'
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;


  --
  -- Wrapper API to integrate DOM Document API when starting
  -- Document LC Phase Workflow
  --
  PROCEDURE Start_Doc_LC_Phase_WF
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- DOC LC Object Change Id
   ,p_route_id                  IN   NUMBER                             -- DOC LC Phase WF Route ID
   ,p_lc_phase_code             IN   NUMBER   := NULL                   -- Doc LC Phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;

  --
  -- Wrapper API to integrate DOM Document API when aborting
  -- Document LC Phase Workflow
  --
  PROCEDURE Abort_Doc_LC_Phase_WF
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- DOC LC Object Change Id
   ,p_route_id                  IN   NUMBER                             -- DOC LC Phase WF Route ID
   ,p_lc_phase_code             IN   NUMBER   := NULL                   -- Doc LC Phase
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;


  --
  -- Wrapper API to grant Document Role to Document Revision
  --
  PROCEDURE Grant_Document_Role
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_document_id               IN   NUMBER                             -- Dom Document Id
   ,p_document_revision_id      IN   NUMBER                             -- Dom Document Revision Id
   ,p_change_id                 IN   NUMBER                             -- Change Id
   ,p_change_line_id            IN   NUMBER                             -- Change Line Id
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_role_id                   IN   NUMBER                             -- Role Id to be granted
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;

  --
  -- Wrapper API to revoke Document Role to Document Revision
  --
  PROCEDURE Revoke_Document_Role
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_document_id               IN   NUMBER                             -- Dom Document Id
   ,p_document_revision_id      IN   NUMBER                             -- Dom Document Revision Id
   ,p_change_id                 IN   NUMBER                             -- Change Id
   ,p_change_line_id            IN   NUMBER                             -- Change Line Id
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_role_id                   IN   NUMBER                             -- Role Id to be revoked. If NULL, Revoke all grants per given object info
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;


  PROCEDURE Grant_Attachments_OCSRole
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_entity_name               IN   VARCHAR2
   ,p_pk1value                  IN   VARCHAR2
   ,p_pk2value                  IN   VARCHAR2
   ,p_pk3value                  IN   VARCHAR2
   ,p_pk4value                  IN   VARCHAR2
   ,p_pk5value                  IN   VARCHAR2
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_ocs_role                  IN   VARCHAR2                           -- OCS File Role to be granted
   ,p_source_media_id_tbl       IN   FND_TABLE_OF_NUMBER := null
   ,p_attachment_id_tbl         IN   FND_TABLE_OF_NUMBER := null
   ,p_repository_id_tbl         IN   FND_TABLE_OF_NUMBER := null
   ,p_submitted_by              IN   NUMBER := null
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;


  PROCEDURE Revoke_Attachments_OCSRole
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL
   ,p_debug_filename            IN   VARCHAR2 := NULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_entity_name               IN   VARCHAR2
   ,p_pk1value                  IN   VARCHAR2
   ,p_pk2value                  IN   VARCHAR2
   ,p_pk3value                  IN   VARCHAR2
   ,p_pk4value                  IN   VARCHAR2
   ,p_pk5value                  IN   VARCHAR2
   ,p_party_ids                 IN   FND_TABLE_OF_NUMBER                -- Person's HZ_PARTIES.PARTY_ID Array
   ,p_ocs_role                  IN   VARCHAR2                           -- OCS File Role to be revoked. If NULL, Revoke all grants per given entity info
   ,p_api_caller                IN   VARCHAR2 := NULL                   -- Optionnal for future use
  ) ;


END ENG_DOCUMENT_UTIL;

 

/
