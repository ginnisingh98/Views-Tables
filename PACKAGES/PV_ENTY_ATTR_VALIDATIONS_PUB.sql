--------------------------------------------------------
--  DDL for Package PV_ENTY_ATTR_VALIDATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENTY_ATTR_VALIDATIONS_PUB" AUTHID CURRENT_USER AS
 /* $Header: pvxvvlds.pls 115.1 2002/12/10 19:29:25 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_ENTY_ATTR_VALIDATIONS_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Enty_Attr_Validation
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER                  Required
--       p_init_msg_list       IN   VARCHAR2                Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2                Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER                  Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enty_attr_validation_rec   IN   enty_attr_validation_rec_type  Required
--
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_Attr_Validations(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_enty_attr_validation_rec   IN   PV_ENTY_ATTR_VALIDATIONS_PVT.enty_attr_validation_rec_type  := PV_ENTY_ATTR_VALIDATIONS_PVT.g_miss_enty_attr_vldtn_rec
	,p_attribute_Id				  IN NUMBER
	,p_entity_Id				  IN NUMBER
	,p_entity                     IN VARCHAR2

    );



END PV_ENTY_ATTR_VALIDATIONS_PUB;

 

/
