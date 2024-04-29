--------------------------------------------------------
--  DDL for Package AMS_IMPORT_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORT_LIST_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvimps.pls 120.1 2005/12/29 20:10:27 ryedator noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Import_List_PVT
-- Purpose
--
-- History
--
--    06-JUNE-2002  huili       added three columns "SERVER_NAME", "USER_NAME"
--                              and "PASSWORD" to the ams_import_rec_type def.
--    10-JUNE-2002  huili       added the "file_type" to the "Duplicate_Import_List" module.
--    18-JUNE-2002  huili       added the "RECORD_UPDATE_FLAG" and "ERROR_THRESHOLD" to
--                              the record definition.
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
--             ams_import_rec_type
--   -------------------------------------------------------
--   Parameters:
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE ams_import_rec_type IS RECORD
(
       import_list_header_id           NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       view_application_id             NUMBER := FND_API.G_MISS_NUM,
       name                            VARCHAR2(120) := FND_API.G_MISS_CHAR,
       version                         VARCHAR2(10) := FND_API.G_MISS_CHAR,
       import_type                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       owner_user_id                   NUMBER := FND_API.G_MISS_NUM,
       list_source_type_id             NUMBER := FND_API.G_MISS_NUM,
       status_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       status_date                     DATE := FND_API.G_MISS_DATE,
       user_status_id                  NUMBER := FND_API.G_MISS_NUM,
       source_system                   VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       vendor_id                       NUMBER := FND_API.G_MISS_NUM,
       pin_id                          NUMBER := FND_API.G_MISS_NUM,
       org_id                          NUMBER := FND_API.G_MISS_NUM,
       scheduled_time                  DATE := FND_API.G_MISS_DATE,
       loaded_no_of_rows               NUMBER := FND_API.G_MISS_NUM,
       loaded_date                     DATE := FND_API.G_MISS_DATE,
       rows_to_skip                    NUMBER := FND_API.G_MISS_NUM,
       processed_rows                  NUMBER := FND_API.G_MISS_NUM,
       headings_flag                   VARCHAR2(1) := FND_API.G_MISS_CHAR,
       expiry_date                     DATE := FND_API.G_MISS_DATE,
       purge_date                      DATE := FND_API.G_MISS_DATE,
       description                     VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       keywords                        VARCHAR2(4000) := FND_API.G_MISS_CHAR,
       transactional_cost              NUMBER := FND_API.G_MISS_NUM,
       transactional_currency_code     VARCHAR2(15) := FND_API.G_MISS_CHAR,
       functional_cost                 NUMBER := FND_API.G_MISS_NUM,
       functional_currency_code        VARCHAR2(15) := FND_API.G_MISS_CHAR,
       terminated_by                   VARCHAR2(30) := FND_API.G_MISS_CHAR,
       enclosed_by                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       data_filename                   VARCHAR2(1000) := FND_API.G_MISS_CHAR,
       process_immed_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
       dedupe_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       attribute_category              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       attribute1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute4                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
       custom_setup_id                 NUMBER := FND_API.G_MISS_NUM,
       country                         NUMBER := FND_API.G_MISS_NUM,
       usage                           NUMBER := FND_API.G_MISS_NUM,
       number_of_records               NUMBER := FND_API.G_MISS_NUM,
       data_file_name                  VARCHAR2(1000) := FND_API.G_MISS_CHAR,
       b2b_flag                        VARCHAR2(1) := FND_API.G_MISS_CHAR,
       rented_list_flag                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       server_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       log_file_name                   NUMBER := FND_API.G_MISS_NUM,
       number_of_failed_records        NUMBER := FND_API.G_MISS_NUM,
       number_of_duplicate_records     NUMBER := FND_API.G_MISS_NUM,
       enable_word_replacement_flag    VARCHAR2(1) := FND_API.G_MISS_CHAR,
       validate_file							VARCHAR2(1) := FND_API.G_MISS_CHAR,
		 server_name							AMS_IMP_LIST_HEADERS_ALL.SERVER_NAME%TYPE := FND_API.G_MISS_CHAR,
       user_name								AMS_IMP_LIST_HEADERS_ALL.USER_NAME%TYPE := FND_API.G_MISS_CHAR,
		 password								AMS_IMP_LIST_HEADERS_ALL.PASSWORD%TYPE := FND_API.G_MISS_CHAR,
		 upload_flag							AMS_IMP_LIST_HEADERS_ALL.UPLOAD_FLAG%TYPE := FND_API.G_MISS_CHAR,
		 parent_imp_header_id            AMS_IMP_LIST_HEADERS_ALL.PARENT_IMP_HEADER_ID%TYPE := FND_API.G_MISS_NUM,
		 record_update_flag              AMS_IMP_LIST_HEADERS_ALL.RECORD_UPDATE_FLAG%TYPE := FND_API.G_MISS_CHAR,
		 error_threshold                 AMS_IMP_LIST_HEADERS_ALL.ERROR_THRESHOLD%TYPE := FND_API.G_MISS_NUM,
		 charset                         AMS_IMP_LIST_HEADERS_ALL.CHARSET%TYPE := FND_API.G_MISS_CHAR);

g_miss_ams_import_rec          ams_import_rec_type;
TYPE  ams_import_tbl_type      IS TABLE OF ams_import_rec_type INDEX BY BINARY_INTEGER;
g_miss_ams_import_tbl          ams_import_tbl_type;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Duplicate_Import_List
--   Type
--           public
--   Pre-Req
--
--   Parameters
--
--   Version : Current version 1.0
--   Note: Copy the record with the import_list_header_id passed in and create a new row in the header
--         table.
--
--   End of Comments
--   ==============================================================================
--
/*
PROCEDURE Do_Recurring (
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2,

    p_obj_id		IN   NUMBER,
	 p_repeat_mode         IN   VARCHAR2,
	 p_repeate_time        IN   VARCHAR2,
	 p_repeate_end_time    IN   VARCHAR2,
	 p_repeate_unit        IN   VARCHAR2,
	 p_repeate_interval    IN   NUMBER,
	 p_recur_type          IN   VARCHAR2);
*/

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Duplicate_Import_List
--   Type
--           public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_import_list_header_id   IN   NUMBER  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_ams_import_rec          OUT  ams_import_rec_type
--   Version : Current version 1.0
--   Note: Copy the record with the import_list_header_id passed in and create a new row in the header
--         table.
--
--   End of Comments
--   ==============================================================================
--

PROCEDURE Duplicate_Import_List (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_list_header_id      IN   NUMBER,
    x_ams_import_rec				   OUT NOCOPY  ams_import_rec_type,
	 x_file_type                  OUT NOCOPY  VARCHAR2);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Import_List
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
--       p_ams_import_rec            IN   ams_import_rec_type  Required
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

PROCEDURE Create_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_import_rec               IN   ams_import_rec_type  := g_miss_ams_import_rec,
    x_import_list_header_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Import_List
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
--       p_ams_import_rec            IN   ams_import_rec_type  Required
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

PROCEDURE Update_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ams_import_rec               IN    ams_import_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Import_List
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
--       p_IMPORT_LIST_HEADER_ID                IN   NUMBER
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

PROCEDURE Delete_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_import_list_header_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Import_List
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
--       p_ams_import_rec            IN   ams_import_rec_type  Required
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

PROCEDURE Lock_Import_List(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_import_list_header_id                   IN  NUMBER,
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

PROCEDURE Validate_import_list(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ams_import_rec               IN   ams_import_rec_type,
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

PROCEDURE Check_ams_import_Items (
    P_ams_import_rec     IN    ams_import_rec_type,
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

PROCEDURE Validate_ams_import_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ams_import_rec               IN    ams_import_rec_type
    );
END AMS_Import_List_PVT;

 

/
