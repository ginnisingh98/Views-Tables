--------------------------------------------------------
--  DDL for Package AMS_TRACKING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TRACKING_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvtrks.pls 115.9 2003/12/14 04:07:56 ryedator noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TRACKING_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             interaction_track_rec_type
--   -------------------------------------------------------
--   Parameters:
--     created_by
--     creation_date
--     last_updated_by
--     last_update_date
--     last_update_login
--     object_version_number
--     web_content_id
--     obj_type
--     obj_src_code
--     obj_id
--     offer_src_code
--     offer_id
--     party_id
--     affiliate_id
--     posting_id
--     did
--    flavour
--    web_tracking_id
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE interaction_track_rec_type IS RECORD
(
       created_by		NUMBER := FND_API.G_MISS_NUM,
       creation_date		DATE := FND_API.G_MISS_DATE,
       last_updated_by		NUMBER := FND_API.G_MISS_NUM,
       last_update_date		DATE := FND_API.G_MISS_DATE,
       last_update_login	NUMBER := FND_API.G_MISS_NUM,
       object_version_number	NUMBER := FND_API.G_MISS_NUM,
       web_content_id		NUMBER := FND_API.G_MISS_NUM,
       obj_type			VARCHAR2(30) := FND_API.G_MISS_CHAR,
       obj_src_code		VARCHAR2(30) := FND_API.G_MISS_CHAR,
       obj_id			NUMBER := FND_API.G_MISS_NUM,
       offer_src_code		VARCHAR2(30) := FND_API.G_MISS_CHAR,
       offer_id 		NUMBER := FND_API.G_MISS_NUM,
       party_id			NUMBER := FND_API.G_MISS_NUM,
       affiliate_id		NUMBER := FND_API.G_MISS_NUM,
       posting_id		NUMBER := FND_API.G_MISS_NUM,
       did                   NUMBER := FND_API.G_MISS_NUM,
       flavour			VARCHAR2(30) := FND_API.G_MISS_CHAR,
       web_tracking_id		NUMBER := FND_API.G_MISS_NUM
);

 g_miss_ps_strats_rec     interaction_track_rec_type;

--   ========================================================================
--    Start of Comments
--   ========================================================================
--   API Name
--           Log_interaction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number  IN   NUMBER     Required
--       p_init_msg_list       IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit              IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level    IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_track_rec		IN   interaction_track_rec_type Required
--   OUT
--       x_return_status       OUT  VARCHAR2
--       x_msg_count           OUT  NUMBER
--       x_msg_data            OUT  VARCHAR2
--       x_interaction_id	OUT NUMBER
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   =======================================================================
--

PROCEDURE Log_interaction(
    p_api_version_number  IN   NUMBER,
    p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,

    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    x_interaction_id	  OUT NOCOPY NUMBER,

    p_track_rec       IN   interaction_track_rec_type := g_miss_ps_strats_rec

     );

--   ==========================================================================
--    Start of Comments
--   ==========================================================================
--   API Name
--           get_redirect_url
--   Type
--           Private
--   Pre-Req
--
--   IN
--   p_web_content_id IN NUMBER
--   Parameters
--   OUT
--       x_redirect_url  OUT  VARCHAR2
--       x_action_parameter_code   OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==========================================================================
--
PROCEDURE get_redirect_url(
        p_web_content_id IN NUMBER,
	x_redirect_url OUT NOCOPY VARCHAR2,
	x_action_parameter_code  OUT NOCOPY VARCHAR2
);


--   ==========================================================================
--    Start of Comments
--   ==========================================================================
--   API Name
--           Log_redirect
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--        p_track_rec       IN   interaction_track_rec_type Required
--
--   OUT
--        x_redirect_url	 OUT  VARCHAR2
--        x_interaction_id      OUT  NUMBER
--        x_action_parameter_code  OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==========================================================================
--

PROCEDURE Log_redirect(
    tracking_rec	IN interaction_track_rec_type:=g_miss_ps_strats_rec,
    x_redirect_url	OUT NOCOPY VARCHAR2,
    x_interaction_id	OUT NOCOPY NUMBER ,
    x_action_parameter_code    OUT NOCOPY VARCHAR2
);


--   ==========================================================================
--    Start of Comments
--   ==========================================================================
--   API Name
--           weblite_log
--   Type
--           Private
--   Pre-Req
--
--   IN
--   p_web_content_id IN NUMBER
--   Parameters
--   OUT
--       x_interaction_id  OUT  VARCHAR2
--	 x_msource   OUT NOCOPY NUMBER
--       x_return_status   OUT  VARCHAR2
--	 x_msg_count OUT  VARCHAR2
--	 x_msg_data OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==========================================================================
--
PROCEDURE weblite_log( tracking_rec IN  interaction_track_rec_type := g_miss_ps_strats_rec,
			x_interaction_id  OUT NOCOPY NUMBER,
			x_msource  	  OUT NOCOPY NUMBER,
		        x_return_status   OUT NOCOPY VARCHAR2,
			x_msg_count       OUT NOCOPY NUMBER,
			x_msg_data        OUT NOCOPY VARCHAR2
			);

END AMS_TRACKING_PVT;

 

/
