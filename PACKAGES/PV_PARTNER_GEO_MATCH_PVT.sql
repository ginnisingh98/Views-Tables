--------------------------------------------------------
--  DDL for Package PV_PARTNER_GEO_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_GEO_MATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: pvxvpgms.pls 115.1 2003/10/03 23:01:59 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Geo_Match_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- ===============================================================

-- Default number of records fetch per call
-- G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--===================================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Get_Matched_Geo_Hierarchy_Id
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER                   Required
--       p_init_msg_list           IN   VARCHAR2                 Optional  Default = FND_API_G_FALSE
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
PROCEDURE Get_Matched_Geo_Hierarchy_Id(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_partner_party_id           IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    );

PROCEDURE Get_Ptnr_Matched_Geo_Id (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_partner_id                 IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    );

PROCEDURE Get_Ptnr_Org_Matched_Geo_Id (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2

    ,p_party_id                   IN   NUMBER
    ,p_geo_hierarchy_id           IN   JTF_NUMBER_TABLE
    ,x_geo_hierarchy_id           OUT  NOCOPY  NUMBER
    );

END PV_Partner_Geo_Match_PVT;

 

/
