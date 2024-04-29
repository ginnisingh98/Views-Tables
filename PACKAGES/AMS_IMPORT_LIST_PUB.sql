--------------------------------------------------------
--  DDL for Package AMS_IMPORT_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORT_LIST_PUB" AUTHID CURRENT_USER AS
/* $Header: amspimps.pls 115.5 2002/11/12 23:34:57 jieli noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Import_List_PUB
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
--             ams_import_rec_type
--   -------------------------------------------------------
--   Parameters:
--       import_list_header_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       view_application_id
--       name
--       version
--       import_type
--       owner_user_id
--       custom_setup_id
--       country
--       list_source_type_id
--       status_code
--       status_date
--       user_status_id
--       source_system
--       vendor_id
--       pin_id
--       org_id
--       scheduled_time
--       loaded_no_of_rows
--       loaded_date
--       rows_to_skip
--       processed_rows
--       headings_flag
--       expiry_date
--       purge_date
--       description
--       keywords
--       transactional_cost
--       transactional_currency_code
--       functional_cost
--       functional_currency_code
--       terminated_by
--       enclosed_by
--       data_filename
--       process_immed_flag
--       dedupe_flag
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
--       usage
--       rented_list_flag
--       server_flag
--       log_file_name
--       number_of_failed_records
--       number_of_duplicate_records
--       enable_word_replacement_flag
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
       name                            VARCHAR2(240) := FND_API.G_MISS_CHAR,
       version                         VARCHAR2(10) := FND_API.G_MISS_CHAR,
       import_type                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       owner_user_id                   NUMBER := FND_API.G_MISS_NUM,
       custom_setup_id                 NUMBER := FND_API.G_MISS_NUM,
       country                         NUMBER := FND_API.G_MISS_NUM,
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
       usage                           NUMBER := FND_API.G_MISS_NUM,
       rented_list_flag                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       server_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       log_file_name                   NUMBER := FND_API.G_MISS_NUM,
       number_of_failed_records        NUMBER := FND_API.G_MISS_NUM,
       number_of_duplicate_records     NUMBER := FND_API.G_MISS_NUM,
       enable_word_replacement_flag    VARCHAR2(1) := FND_API.G_MISS_CHAR
);

g_miss_ams_import_rec          ams_import_rec_type;
TYPE  ams_import_tbl_type      IS TABLE OF ams_import_rec_type INDEX BY BINARY_INTEGER;
g_miss_ams_import_tbl          ams_import_tbl_type;

TYPE ams_import_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      last_update_date   NUMBER := NULL
);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Import_List
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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

END AMS_Import_List_PUB;

 

/
