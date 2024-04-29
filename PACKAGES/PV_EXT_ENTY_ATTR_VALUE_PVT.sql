--------------------------------------------------------
--  DDL for Package PV_EXT_ENTY_ATTR_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_EXT_ENTY_ATTR_VALUE_PVT" AUTHID CURRENT_USER AS
 /* $Header: pvxveaxs.pls 115.1 2002/12/10 19:27:15 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Enty_Attr_Value_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
-- ===================================================================
--    Start of Comments
--   -------------------------------------------------------

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Customer_Anual_Revenue
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER                  Required
--       p_init_msg_list           IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_entity                     IN   VARCHAR2 Required
--		 p_entity_id			      IN   NUMBER
--		 p_attr_value				  IN   VARCHAR2
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

PROCEDURE Update_Customer_Anual_Revenue(
     p_api_version_number     IN   NUMBER
    ,p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                 IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status          OUT NOCOPY  VARCHAR2
    ,x_msg_count              OUT NOCOPY  NUMBER
    ,x_msg_data               OUT NOCOPY  VARCHAR2

	,p_entity                     IN   VARCHAR2
	,p_entity_id			      IN   NUMBER
	,p_attr_value				  IN   VARCHAR2
    );



END PV_Ext_Enty_Attr_Value_PVT;

 

/
