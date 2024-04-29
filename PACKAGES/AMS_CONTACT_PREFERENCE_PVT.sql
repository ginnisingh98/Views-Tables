--------------------------------------------------------
--  DDL for Package AMS_CONTACT_PREFERENCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CONTACT_PREFERENCE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpps.pls 115.7 2002/12/23 22:56:13 vbhandar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTACT_PREFERENCE_PVT
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
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             ams_contact_pref_rec_type
--   -------------------------------------------------------
--   Parameters:
--
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================

TYPE contact_preference_rec_type IS RECORD (

contact_preference_id	    NUMBER,
contact_level_table	    VARCHAR2(30),
contact_level_table_id	    NUMBER,
contact_type		    VARCHAR2(30),
preference_code		    VARCHAR2(30),
preference_topic_type	    VARCHAR2(30),
preference_topic_type_id    NUMBER,
preference_topic_type_code  VARCHAR2(30),
preference_start_date	    DATE,
preference_end_date	    DATE,
preference_start_time_hr    NUMBER,
preference_end_time_hr	    NUMBER,
preference_start_time_mi    NUMBER,
preference_end_time_mi      NUMBER,
max_no_of_interactions	    NUMBER,
max_no_of_interact_uom_code VARCHAR2(30),
requested_by		    VARCHAR2(30),
reason_code		    VARCHAR2(30),
status		            VARCHAR2(1),
created_by_module           VARCHAR2(150),
application_id              NUMBER

);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           create_contact_preference
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
--       p_ams_contact_pref_rec            IN   ams_contact_pref_rec_type  Required
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


PROCEDURE create_contact_preference(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_pref_rec       IN   contact_preference_rec_type ,
    p_request_id                 IN   NUMBER,
    x_contact_preference_id      OUT NOCOPY  NUMBER

     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           update_contact_preference
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
--       p_ams_contact_pref_rec    IN   ams_contact_pref_rec_type  Required
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


PROCEDURE update_contact_preference(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_contact_pref_rec       IN   contact_preference_rec_type ,
    p_request_id                 IN   NUMBER,
    px_object_version_number     IN OUT NOCOPY  NUMBER
    );


END AMS_CONTACT_PREFERENCE_PVT;

 

/
