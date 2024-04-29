--------------------------------------------------------
--  DDL for Package ENG_ATTACHMENT_IMPLEMENTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_ATTACHMENT_IMPLEMENTATION" AUTHID CURRENT_USER as
/*$Header: ENGUATTS.pls 120.7.12010000.2 2010/02/03 08:00:51 maychen ship $ */
  /********************************************************************
  * Debug APIs    : Open_Debug_Session, Close_Debug_Session,
  *                 Write_Debug
  * Parameters IN :
  * Parameters OUT:
  * Purpose       : These procedures are for test and debug
  *********************************************************************/

-- Workflow related
  G_ENG_WF_USER_ID        CONSTANT NUMBER        := -10000;
  G_ENG_WF_LOGIN_ID       CONSTANT NUMBER        := '';
-- Concurrent Program, right now set it to be the same as workflow
  G_ENG_CP_USER_ID        CONSTANT NUMBER        := -10000;
  G_ENG_CP_LOGIN_ID       CONSTANT NUMBER        := '';

-- Open_Debug_Session
Procedure Open_Debug_Session (
    p_output_dir IN VARCHAR2 := NULL
   ,p_file_name  IN VARCHAR2 := NULL
);

-- Close Debug_Session
Procedure Close_Debug_Session ;

-- Write Debug Message
Procedure Write_Debug (
    p_debug_message      IN  VARCHAR2 ) ;

Procedure Cancel_Review_Approval(
    p_api_version               IN NUMBER
   ,p_change_id                 IN NUMBER
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
);

Procedure Update_Attachment_Status (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Update_Attachment_Status.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_workflow_status			IN   VARCHAR2                           -- workflow status
   ,p_approval_status           IN   NUMBER                           -- approval status
   ,p_api_caller                IN VARCHAR2 DEFAULT 'UI'
);

Procedure Implement_Attachment_Change (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Implement_Attachment_Change.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_approval_status           IN   NUMBER                             -- approval status
);

Procedure Copy_Attachment (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Copy_Attachment.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,x_new_attachment_id         OUT  NOCOPY  NUMBER
   ,p_source_attachment_id       IN   NUMBER                             -- source attached document id
   ,p_source_status              IN   VARCHAR2                           -- source attachment status
   ,p_dest_entity_name		     IN   VARCHAR2                           -- destination entity name
   ,p_dest_pk1_value             IN   VARCHAR2                           -- destination pk1 value
   ,p_dest_pk2_value             IN   VARCHAR2                           -- destination pk2 value
   ,p_dest_pk3_value             IN   VARCHAR2                           -- destination pk3 value
   ,p_dest_pk4_value             IN   VARCHAR2                           -- destination pk4 value
   ,p_dest_pk5_value             IN   VARCHAR2                           -- destination pk5 value
);

Procedure Copy_Attachments_And_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Copy_Attachments_And_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                          	-- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id					IN   VARCHAR2
   ,p_inv_item_id				IN   VARCHAR2
   ,p_curr_rev_id				IN   VARCHAR2
   ,p_new_rev_id                IN   VARCHAR2
);

Procedure Migrate_Attachment_And_Change (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Migrate_Attachment_And_Change.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                          	-- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id					IN   VARCHAR2
   ,p_inv_item_id				IN   VARCHAR2
   ,p_curr_rev_id				IN   VARCHAR2
   ,p_new_rev_id                IN   VARCHAR2
);
Procedure Delete_Attachments_And_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments_And_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                          	-- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
   ,p_org_id					IN   VARCHAR2
   ,p_inv_item_id				IN   VARCHAR2
   ,p_revision_id               IN   VARCHAR2
);

Procedure Delete_Attachments_For_Curr_CO (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments_For_Curr_CO.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                          	-- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
);

Procedure Delete_Attachments (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachments.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_org_id					IN   VARCHAR2
   ,p_inv_item_id				IN   VARCHAR2
   ,p_revision_id               IN   VARCHAR2
);

Procedure Delete_Attachment (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Attachment.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_attachment_id				IN   NUMBER
);

Procedure Delete_Changes (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Delete_Changes.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER                          	-- header's change_id
   ,p_rev_item_seq_id           IN   NUMBER                             -- revised item sequence id
);

Procedure Get_Attachment_Status (
    p_change_id                 IN   NUMBER
   ,p_header_status				IN   NUMBER
   ,x_attachment_status         OUT  NOCOPY VARCHAR2
);

Procedure Complete_Attachment_Approval (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2 := NULL                   --
   ,p_debug_filename            IN   VARCHAR2 := 'ENGUATTB.Complete_Attachment_Approval.log'
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_approval_status           IN   VARCHAR2                           -- approval status
);


Procedure Project_deliverable_tracking(
    p_change_id                 IN   NUMBER
   ,p_attachment_id             IN   NUMBER
   ,p_document_id               IN   NUMBER
   ,p_attach_status             IN   VARCHAR2
   ,p_category_id               IN   NUMBER
   ,p_repository_id             IN   NUMBER
   ,p_dm_document_id            IN   NUMBER
   ,p_source_media_id           IN   NUMBER
   ,p_file_name                 IN   VARCHAR2
   ,p_created_by                IN   NUMBER
   ,x_return_status             OUT  NOCOPY  VARCHAR2
   ,x_msg_count                 OUT  NOCOPY  NUMBER
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   );

Procedure Validate_floating_version (
    p_api_version               IN   NUMBER                             --
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2
   ,p_change_id                 IN   NUMBER
   ,p_rev_item_seq_id           IN   NUMBER  := NULL
);

END  ENG_ATTACHMENT_IMPLEMENTATION;

/
