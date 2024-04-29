--------------------------------------------------------
--  DDL for Package AMS_COLLAB_ASSOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_COLLAB_ASSOC_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcols.pls 120.0.12000000.2 2007/08/03 12:54:19 amlal ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Collab_assoc_PVT
-- Purpose
--
-- History
--
-- NOTE
--   This api has been created for association of collaboration content
--  items and scrips from web adi
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             collab_assoc_rec_type
--   -------------------------------------------------------
--   Parameters:
--      collab_item_id <primary key of association table>
--      Collab_type   < < Valid value shuold be from ams_lookups:lookup type='AMS_COLLABORATION_TYPE' >
--      collab_assoc_value  <script_name, proposal_name>
---     collab_assoc_id     <contentId,proposalId,ScriptID)
--      last_update_date
--      last_updated_by
--      creation_date
--      created_by
--      last_update_login
--      object_version_number
--      obj_type
--      obj_id
--      p_assoc_object2
--      p_assoc_object3
--      p_assoc_object4
--      p_assoc_object5

--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE collab_assoc_rec_type IS RECORD
(
       collab_item_id                  NUMBER,
       Collab_type                     VARCHAR2(20),
       collab_assoc_value             VARCHAR2(240),
       collab_assoc_id                 NUMBER,
       last_update_date                DATE,
       last_updated_by                 NUMBER,
       creation_date                   DATE,
       created_by                      NUMBER,
       last_update_login               NUMBER,
       object_version_number           NUMBER ,
       obj_type                        VARCHAR(100),
       obj_id                          NUMBER,
       p_assoc_object2                 VARCHAR2(254),
       p_assoc_object3                 VARCHAR2(254),
       p_assoc_object4                 VARCHAR2(254),
       p_assoc_object5                 VARCHAR2(254)
);

TYPE  cnt_point_tbl_type      IS TABLE OF collab_assoc_rec_type INDEX BY BINARY_INTEGER;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_collab_Assoc
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_collab_assoc_rec_type            IN   collab_assoc_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_collab_Assoc(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_collab_assoc_rec_type      IN   collab_assoc_rec_type,
    x_collab_item_id                   OUT NOCOPY  NUMBER
     );


END AMS_Collab_assoc_PVT;

 

/
