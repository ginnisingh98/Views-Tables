--------------------------------------------------------
--  DDL for Package AMS_ACT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvalss.pls 120.2 2005/09/08 09:40:46 bmuthukr ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Act_List_PVT
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
--TYPE sql_string      IS TABLE OF VARCHAR2(2000) INDEX  BY BINARY_INTEGER;
TYPE child_type      IS TABLE OF VARCHAR2(80) INDEX  BY BINARY_INTEGER;
--===================================================================
--    Start of Comments
--   -------------------------------------------------------
--    Record name
--             act_list_rec_type
--   -------------------------------------------------------
--   Parameters:
--       act_list_header_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       object_version_number
--       last_update_login
--       list_header_id
--       list_used_by_id
--       list_used_by
--       list_act_type
--       list_action_type
--       order_number
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
TYPE act_list_rec_type IS RECORD
(
       act_list_header_id              NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       list_header_id                  NUMBER := FND_API.G_MISS_NUM,
       group_code                      VARCHAR2(10) := FND_API.G_MISS_CHAR,
       list_used_by_id                 NUMBER := FND_API.G_MISS_NUM,
       list_used_by                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       list_act_type                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       list_action_type                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       order_number                    NUMBER := FND_API.G_MISS_NUM
);

g_miss_act_list_rec          act_list_rec_type;
TYPE  act_list_tbl_type      IS TABLE OF act_list_rec_type INDEX BY BINARY_INTEGER;
g_miss_act_list_tbl          act_list_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Act_List
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
--       p_act_list_rec            IN   act_list_rec_type  Required
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

PROCEDURE Create_Act_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_act_list_rec               IN   act_list_rec_type  := g_miss_act_list_rec,
    x_act_list_header_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Act_List
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
--       p_act_list_rec            IN   act_list_rec_type  Required
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

PROCEDURE Update_Act_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_act_list_rec               IN    act_list_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Act_List
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
--       p_ACT_LIST_HEADER_ID                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
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

PROCEDURE Delete_Act_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_act_list_header_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Act_List
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
--       p_act_list_rec            IN   act_list_rec_type  Required
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

PROCEDURE Lock_Act_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_act_list_header_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
-- End of Comments

PROCEDURE Validate_act_list(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_act_list_rec               IN   act_list_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    );

-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
-- End of Comments

PROCEDURE Check_act_list_Items (
    P_act_list_rec     IN    act_list_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    );

-- Start of Comments
--
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in AMS_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
-- End of Comments

PROCEDURE Validate_act_list_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_act_list_rec               IN    act_list_rec_type
    );

PROCEDURE generate_target_group_list
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2
  ) ;
PROCEDURE generate_target_group_list_old
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2
  ) ;


PROCEDURE create_target_group_list
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2   := FND_API.G_TRUE,
  p_commit                 IN      VARCHAR2   := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER     := FND_API.G_VALID_LEVEL_FULL,
  p_list_used_by_name      in      VARCHAR2,
  p_list_used_by           in      VARCHAR2,
  p_list_used_by_id        in      NUMBER,
  p_list_type              in      VARCHAR2   := 'TARGET' ,
  p_owner_user_id          in      NUMBER,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2,
  x_list_header_id         OUT NOCOPY     NUMBER  ) ;
PROCEDURE     init_act_list_Rec (
   x_act_list_rec OUT NOCOPY act_list_rec_type);
PROCEDURE Complete_act_list_Rec (
   p_act_list_rec IN act_list_rec_type,
   x_complete_rec OUT NOCOPY act_list_rec_type);
PROCEDURE process_cell
             (p_action_used_by_id in  number,
              p_act_list_header_id in number,
              p_incl_object_id in number,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2,
              x_std_sql OUT NOCOPY varchar2 ,
              x_include_sql OUT NOCOPY varchar2
               ) ;
PROCEDURE copy_target_group
             (p_from_schedule_id in  number,
              p_to_schedule_id in number,
              p_list_used_by   in VARCHAR2 DEFAULT 'CSCH',
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
               )  ;

PROCEDURE copy_target_group
             (p_from_schedule_id in  number,
              p_to_schedule_id in number,
              p_list_used_by   in VARCHAR2 DEFAULT 'CSCH',
	      p_repeat_flag   in VARCHAR2,
              x_msg_count      OUT NOCOPY number,
              x_msg_data       OUT NOCOPY varchar2,
              x_return_status  IN OUT NOCOPY VARCHAR2
               )  ;
------------------------------------------------------------------------------------------------------------------
--------------------------Procedure to INVOKE TARGETGROUP LOCK Begins here----------------------------------------
------------------------------------------------------------------------------------------------------------------

--===============================================================================================
-- Procedure
--   INVOKE_TARGET_GROUP_LOCK
--
-- PURPOSE
--    This api is called to check for the schedules in ACTIVE State(Campaign or Event).
--
-- ALGORITHM
--    1. Get All parameter Types
--
--  Any error in any of the API callouts?
--   => a) Set RETURN STATUS to E
--
-- OPEN ISSUES
--   1. Should we do a explicit exit on Object_type not found.
--
-- HISTORY
--    19-Apr-2005  ndadwal
--===============================================================================================

FUNCTION INVOKE_TARGET_GROUP_LOCK ( p_subscription_guid   IN       RAW,
				    p_event               IN OUT NOCOPY  WF_EVENT_T) RETURN VARCHAR2;




------------------------------------------------------------------------------------------------------------------
--------------------------Procedure to INVOKE TARGETGROUP LOCK Ends here----------------------------------------
------------------------------------------------------------------------------------------------------------------

PROCEDURE Control_Group_Generation(p_list_header_id  IN NUMBER,
	                           p_pct_random      IN NUMBER,
                                   p_no_random       IN NUMBER,
                                   p_total_rows      IN NUMBER,
                                   x_return_status   OUT NOCOPY VARCHAR2,
				   x_msg_count       OUT NOCOPY NUMBER,
                                   x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE check_supp(p_list_used_by       varchar2,
	             p_list_used_by_id    number,
	             p_list_header_id     number,
	             x_return_status      out nocopy varchar2,
                     x_msg_count          out nocopy number,
                     x_msg_data           out nocopy varchar2);

END AMS_Act_List_PVT;
 

/
