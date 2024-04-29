--------------------------------------------------------
--  DDL for Package AMW_RISK_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_RISK_TYPE_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvmrts.pls 120.0 2005/05/31 23:13:53 appldev noship $ */

   --===================================================================
--    Start of Comments
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Insert_Delete_Risk_Type
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_riskrev_id              IN   NUMBER     Optional  Default = null
--       p_risk_type_code          IN   VARCHAR2   Required
--       p_select_flag             IN   VARCHAR2   Required
--       p_commit                  IN   VARCHAR2   Required  Default = FND_API_G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALS ;
--
--
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:
--
--   End of Comments
--   ==============================================================================
--
   PROCEDURE insert_delete_risk_type (
      p_risk_rev_id               IN              NUMBER := NULL,
	  p_risk_type_code            IN              VARCHAR2 := NULL,
	  p_select_flag               IN			  VARCHAR2 := NULL,
      p_commit                    IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level          IN              NUMBER := fnd_api.g_valid_level_full,
      p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
      p_api_version_number        IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2
   );


-- ===============================================================
-- Procedure name
--          Revise_Risk_Type
-- Purpose
-- 		  	revise risk type from old RiskRevId to new RiskRevId
-- ===============================================================
PROCEDURE Revise_Risk_Type(
    p_old_risk_rev_id           IN   NUMBER,
    p_risk_rev_id               IN   NUMBER,
    p_commit                    IN              VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN              NUMBER := fnd_api.g_valid_level_full,
    p_init_msg_list             IN              VARCHAR2 := fnd_api.g_false,
    p_api_version_number        IN              NUMBER,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2
);

END amw_risk_type_pvt;

 

/
