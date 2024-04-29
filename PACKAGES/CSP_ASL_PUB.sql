--------------------------------------------------------
--  DDL for Package CSP_ASL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_ASL_PUB" AUTHID CURRENT_USER AS
/* $Header: cspgrecs.pls 115.3 2002/11/26 07:04:48 hhaugeru noship $ */

-- Start of Comments
-- Package name     : CSP_ASL_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  IMPORT_RECOMENDED_QUANTITIES
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--        P_Api_Version_Number         IN   NUMBER,
--        P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
--        P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
--        p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
--        p_item_id                    IN   NUMBER,
--        p_item_segment1              IN   VARCHAR2,
--        p_item_segment2              IN   VARCHAR2,
--        p_item_segment3              IN   VARCHAR2,
--        p_item_segment4              IN   VARCHAR2,
--        p_item_segment5              IN   VARCHAR2,
--        p_item_segment6              IN   VARCHAR2,
--        p_item_segment7              IN   VARCHAR2,
--        p_item_segment8              IN   VARCHAR2,
--        p_item_segment9              IN   VARCHAR2,
--        p_item_segment10             IN   VARCHAR2,
--        p_item_segment11             IN   VARCHAR2,
--        p_item_segment12             IN   VARCHAR2,
--        p_item_segment13             IN   VARCHAR2,
--        p_item_segment14             IN   VARCHAR2,
--        p_item_segment15             IN   VARCHAR2,
--        p_item_segment16             IN   VARCHAR2,
--        p_item_segment17             IN   VARCHAR2,
--        p_item_segment18             IN   VARCHAR2,
--        p_item_segment19             IN   VARCHAR2,
--        p_item_segment20             IN   VARCHAR2,
--        p_organization_id            IN   NUMBER,
--        p_organization_name          IN   VARCHAR2,
--        p_organization_code          IN   VARCHAR2,
--        p_subinventory_code          IN   VARCHAR2,
--        p_recommended_max            IN   NUMBER,
--        p_recommended_min            IN   NUMBER,
--
--   OUT:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
---
---- End of Comments
    G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSP_ASL_PUB';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgrecs.pls';

PROCEDURE IMPORT_RECOMENDED_QUANTITIES(P_Api_Version_Number         IN   NUMBER,
                                       P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                                       P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                                       p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
                                       p_item_id                    IN   NUMBER,
                                       p_item_segment1              IN   VARCHAR2,
                                       p_item_segment2              IN   VARCHAR2,
                                       p_item_segment3              IN   VARCHAR2,
                                       p_item_segment4              IN   VARCHAR2,
                                       p_item_segment5              IN   VARCHAR2,
                                       p_item_segment6              IN   VARCHAR2,
                                       p_item_segment7              IN   VARCHAR2,
                                       p_item_segment8              IN   VARCHAR2,
                                       p_item_segment9              IN   VARCHAR2,
                                       p_item_segment10             IN   VARCHAR2,
                                       p_item_segment11             IN   VARCHAR2,
                                       p_item_segment12             IN   VARCHAR2,
                                       p_item_segment13             IN   VARCHAR2,
                                       p_item_segment14             IN   VARCHAR2,
                                       p_item_segment15             IN   VARCHAR2,
                                       p_item_segment16             IN   VARCHAR2,
                                       p_item_segment17             IN   VARCHAR2,
                                       p_item_segment18             IN   VARCHAR2,
                                       p_item_segment19             IN   VARCHAR2,
                                       p_item_segment20             IN   VARCHAR2,
                                       p_organization_id            IN   NUMBER,
                                       p_organization_name          IN   VARCHAR2,
                                       p_organization_code          IN   VARCHAR2,
                                       p_subinventory_code          IN   VARCHAR2,
                                       p_recommended_max            IN   NUMBER,
                                       p_recommended_min            IN   NUMBER,
                                       x_return_status              OUT NOCOPY  VARCHAR2,
                                       X_Msg_Count                  OUT NOCOPY  NUMBER,
                                       X_Msg_Data                   OUT NOCOPY  VARCHAR2);
PROCEDURE PURGE_OLD_RECOMMENDATIONS(P_Api_Version_Number         IN   NUMBER,
                                    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
                                    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
                                    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status              OUT NOCOPY  VARCHAR2,
                                    x_Msg_Count                  OUT NOCOPY  NUMBER,
                                    x_Msg_Data                   OUT NOCOPY  VARCHAR2);

END CSP_ASL_PUB;

 

/
