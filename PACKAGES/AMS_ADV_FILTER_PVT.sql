--------------------------------------------------------
--  DDL for Package AMS_ADV_FILTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADV_FILTER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadfs.pls 115.8 2003/09/10 05:44:22 kbasavar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Adv_Filter_PVT
-- Purpose
--
-- History
-- 20-Aug-2003 rosharma Fixed bug 3104201.
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
--             filter_rec_type
--   -------------------------------------------------------
--   Parameters:
--       query_param_id - Parameter Id
--       query_id       - Query Id from jtf_perz_query table.
--       parameter_name - FieldId from ams_list_src_fields_vl
--       parameter_type - Comma Seperated Value which contains the Unique
--                        combination od objType+colId(any unique ID..in some
--                        cases objId)+dataSourceId
--       parameter_value - Value of the Field.(Filter)
--       parameter_condition - Filter Condition
--       parameter_sequence - Filter Sequence. Not used right now.
--       created_by     - Created By. Standard Column
--       last_updated_by - Last Updated By Id
--       last_update_date - Last Update Date
--       last_update_login - Last Update Login
--       security_group_id - Security Group Id.

--===================================================================
TYPE filter_rec_type IS RECORD
(
       query_param_id                  NUMBER        := FND_API.G_MISS_NUM,
       query_id                        NUMBER        := FND_API.G_MISS_NUM,
       parameter_name                  VARCHAR2(60)  := FND_API.G_MISS_CHAR,
       parameter_type                  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       parameter_value                 VARCHAR2(60)  := FND_API.G_MISS_CHAR,
       parameter_condition             VARCHAR2(5)   := FND_API.G_MISS_CHAR,
       parameter_sequence              NUMBER        := FND_API.G_MISS_NUM,
       created_by                      NUMBER        := FND_API.G_MISS_NUM,
       last_updated_by                 NUMBER        := FND_API.G_MISS_NUM,
       last_update_date                DATE          := FND_API.G_MISS_DATE,
       last_update_login               NUMBER        := FND_API.G_MISS_NUM,
       security_group_id               NUMBER        := FND_API.G_MISS_NUM
);

  g_miss_filter_rec             filter_rec_type;

  TYPE  filter_rec_tbl_type     IS TABLE OF filter_rec_type INDEX BY BINARY_INTEGER;
  g_miss_filter_rec_tbl         filter_rec_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Filter_Row
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
--       p_filter_rec              IN   filter_rec_type  Required
--
--   OUT
--       x_return_status           OUT  NOCOPY VARCHAR2
--       x_msg_count               OUT  NOCOPY NUMBER
--       x_msg_data                OUT  NOCOPY  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Create_Filter_Row
   (
       p_api_version_number         IN   NUMBER,
       p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
       p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
       p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
       x_return_status              OUT  NOCOPY  VARCHAR2,
       x_msg_count                  OUT  NOCOPY  NUMBER,
       x_msg_data                   OUT  NOCOPY  VARCHAR2,
       p_filter_rec                 IN   filter_rec_type  := g_miss_filter_rec,
       x_query_param_id             OUT  NOCOPY  NUMBER
     );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Filter_Row
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
--       p_filter_rec              IN   filter_rec_type  Required
--
--   OUT NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Update_Filter_Row(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER        := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_filter_rec                 IN    filter_rec_type
    );



--   ==============================================================================
--   API Name
--           Delete_Filter_Row
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
--       p_query_param_id          IN   NUMBER
--
--   OUT  NOCOPY
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--   ==============================================================================


PROCEDURE Delete_Filter_Row
   (
      p_api_version_number         IN   NUMBER,
      p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
      p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      x_return_status              OUT NOCOPY  VARCHAR2,
      x_msg_count                  OUT NOCOPY  NUMBER,
      x_msg_data                   OUT NOCOPY  VARCHAR2,
      p_query_param_id             IN  NUMBER
      );



--   ==============================================================================
--  validation procedures
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. We can also validate table instead of record. There will be an option for user to choose.
--   ==============================================================================

PROCEDURE Validate_Filter_Row
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_filter_rec                 IN   filter_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
);

--   ==============================================================================
--  validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Validate the unique keys, lookups here
--   ==============================================================================

PROCEDURE Check_filter_Items (
    p_filter_rec       IN    filter_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT  NOCOPY  VARCHAR2
    );



--   ==============================================================================
-- Record level validation procedures
--
-- p_validation_mode is a constant defined in null_UTILITY_PVT package
--                  For create: G_CREATE, for update: G_UPDATE
-- Note: 1. This is automated generated item level validation procedure.
--          The actual validation detail is needed to be added.
--       2. Developer can manually added inter-field level validation.
--   ==============================================================================

PROCEDURE Validate_Filter_Row_Rec
   (
      p_api_version_number         IN   NUMBER,
      p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
      x_return_status              OUT NOCOPY  VARCHAR2,
      x_msg_count                  OUT NOCOPY  NUMBER,
      x_msg_data                   OUT NOCOPY  VARCHAR2,
      p_filter_rec                  IN    filter_rec_type
    );




PROCEDURE Get_filter_data
(
     p_objType       IN VARCHAR2,
     p_objectId      IN NUMBER,
     p_dataSourceId  IN NUMBER,
     x_return_status OUT NOCOPY  VARCHAR2,
     x_msg_count     OUT NOCOPY  NUMBER,
     x_msg_data      OUT NOCOPY  VARCHAR2,
     x_filters       OUT NOCOPY  filter_rec_tbl_type
);

PROCEDURE copy_filter_data (
   p_api_version        IN NUMBER,
   p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
   p_commit             IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_objType             IN VARCHAR2,
   p_old_objectId        IN NUMBER,
   p_new_objectId        IN NUMBER,
   p_dataSourceId        IN NUMBER,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2
);

END AMS_Adv_Filter_PVT;


 

/
