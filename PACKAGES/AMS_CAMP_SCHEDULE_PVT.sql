--------------------------------------------------------
--  DDL for Package AMS_CAMP_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMP_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvschs.pls 120.4 2006/05/31 11:41:04 srivikri ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Camp_Schedule_PVT
-- Purpose
--    Business api spec for Schedule
-- History
--    22-Jan-2001     ptendulk      Created.
--    04-Mar-2001     ptendulk      Added Additional parameters for Budget Amount, related event task
--    12-APR-2001     julou         Added 3 fields to schedule_rec_type for related source code
--    09-oct-2001     soagrawa      Removed security-group id related code from everywhere
--  02-dec-2002  dbiswas    NOCOPY and debug-level changes for performance
--  27-jun-2003   anchaudh   Added 4 new fields(columns) in the  schedule_rec_type
--  12-aug-2003   dbiswas    Added 3 new columns for schedule_rec_type
--  25-aug-2003   dbiswas    Added 1 new column sales_methodology_id
--  29-May-2006   srivikri   added column delivery_mode

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
--             schedule_rec_type
--   -------------------------------------------------------
--   Parameters:
--       schedule_id
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
--       object_version_number
--       campaign_id
--       user_status_id
--       status_code
--       status_date
--       source_code
--       use_parent_code_flag
--       start_date_time
--       end_date_time
--       timezone_id
--       activity_type_code
--       activity_id
--       arc_marketing_medium_from
--       marketing_medium_id
--       custom_setup_id
--       triggerable_flag
--       trigger_id
--       notify_user_id
--       approver_user_id
--       owner_user_id
--       active_flag
--       cover_letter_id
--       reply_to_mail
--       mail_sender_name
--       mail_subject
--       from_fax_no
--       accounts_closed_flag
--       org_id
--       objective_code
--       country_id
--       campaign_calendar
--       start_period_name
--       end_period_name
--       priority
--       workflow_item_key
--       transaction_currency_code
--       functional_currency_code
--       budget_amount_tc
--       budget_amount_fc
--       language_code
--       task_id
--       related_event_from
--       related_event_id
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
--       activity_attribute_category
--       activity_attribute1
--       activity_attribute2
--       activity_attribute3
--       activity_attribute4
--       activity_attribute5
--       activity_attribute6
--       activity_attribute7
--       activity_attribute8
--       activity_attribute9
--       activity_attribute10
--       activity_attribute11
--       activity_attribute12
--       activity_attribute13
--       activity_attribute14
--       activity_attribute15
--       security_group_id
--       trig_repeat_flag
--       tgrp_exclude_prev_flag
--       orig_csch_id
--       cover_letter_version
--       usage
--       purpose
--       last_activation_date
--       sales_methodology_id
--       notify_on_activation_flag
--       delivery_mode
--    Required
--
--    Defaults
--
--    Note: This is automatic generated record definition, it includes all columns
--          defined in the table, developer must manually add or delete some of the attributes.
--
--   End of Comments

--===================================================================
TYPE schedule_rec_type IS RECORD
(
       schedule_id                     NUMBER := FND_API.G_MISS_NUM,
       last_update_date                DATE := FND_API.G_MISS_DATE,
       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date                   DATE := FND_API.G_MISS_DATE,
       created_by                      NUMBER := FND_API.G_MISS_NUM,
       last_update_login               NUMBER := FND_API.G_MISS_NUM,
       object_version_number           NUMBER := FND_API.G_MISS_NUM,
       campaign_id                     NUMBER := FND_API.G_MISS_NUM,
       user_status_id                  NUMBER := FND_API.G_MISS_NUM,
       status_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       status_date                     DATE := FND_API.G_MISS_DATE,
       source_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
       use_parent_code_flag            VARCHAR2(1) := FND_API.G_MISS_CHAR,
       start_date_time                 DATE := FND_API.G_MISS_DATE,
       end_date_time                   DATE := FND_API.G_MISS_DATE,
       timezone_id                     NUMBER := FND_API.G_MISS_NUM,
       activity_type_code              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       activity_id                     NUMBER := FND_API.G_MISS_NUM,
       arc_marketing_medium_from       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       marketing_medium_id             NUMBER := FND_API.G_MISS_NUM,
       custom_setup_id                 NUMBER := FND_API.G_MISS_NUM,
       triggerable_flag                VARCHAR2(1) := FND_API.G_MISS_CHAR,
       trigger_id                      NUMBER := FND_API.G_MISS_NUM,
       notify_user_id                  NUMBER := FND_API.G_MISS_NUM,
       approver_user_id                NUMBER := FND_API.G_MISS_NUM,
       owner_user_id                   NUMBER := FND_API.G_MISS_NUM,
       active_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
       cover_letter_id                 NUMBER := FND_API.G_MISS_NUM,
       reply_to_mail                   VARCHAR2(120) := FND_API.G_MISS_CHAR,
       mail_sender_name                VARCHAR2(120) := FND_API.G_MISS_CHAR,
       mail_subject                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       from_fax_no                     VARCHAR2(25) := FND_API.G_MISS_CHAR,
       accounts_closed_flag            VARCHAR2(1) := FND_API.G_MISS_CHAR,
       org_id                          NUMBER := FND_API.G_MISS_NUM,
       objective_code                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
       country_id                      NUMBER := FND_API.G_MISS_NUM,
       campaign_calendar               VARCHAR2(20) := FND_API.G_MISS_CHAR,
       start_period_name               VARCHAR2(15) := FND_API.G_MISS_CHAR,
       end_period_name                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       priority                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       workflow_item_key               VARCHAR2(240) := FND_API.G_MISS_CHAR,
       transaction_currency_code       VARCHAR2(15)  := FND_API.G_MISS_CHAR,
       functional_currency_code        VARCHAR2(15)  := FND_API.G_MISS_CHAR,
       budget_amount_tc                NUMBER := FND_API.G_MISS_NUM,
       budget_amount_fc                NUMBER := FND_API.G_MISS_NUM,
       language_code                   VARCHAR2(4) := FND_API.G_MISS_CHAR,
       task_id                         NUMBER := FND_API.G_MISS_NUM,
       related_event_from              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       related_event_id                NUMBER := FND_API.G_MISS_NUM,
       attribute_category              VARCHAR2(30) := FND_API.G_MISS_CHAR,
       attribute1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
       attribute4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
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
       activity_attribute_category     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       activity_attribute1             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute2             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute3             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute4             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute5             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute6             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute7             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute8             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute9             VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute10            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute11            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute12            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute13            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute14            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       activity_attribute15            VARCHAR2(150) := FND_API.G_MISS_CHAR,
       -- security_group_id               NUMBER        := FND_API.G_MISS_NUM,
       schedule_name                   VARCHAR2(120) := FND_API.G_MISS_CHAR,
       description                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
       related_source_code             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       related_source_object           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       related_source_id               NUMBER        := FND_API.G_MISS_NUM,
       query_id                        NUMBER        := FND_API.G_MISS_NUM,
       include_content_flag            VARCHAR2(1)   := FND_API.G_MISS_CHAR,
       content_type                    VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       test_email_address              VARCHAR2(250) := FND_API.G_MISS_CHAR,
       greeting_text                   VARCHAR2(4000):= FND_API.G_MISS_CHAR,
      footer_text                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
     -- following are added by anchaudh on 27-jun-2003
       trig_repeat_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
       tgrp_exclude_prev_flag         VARCHAR2(1) := FND_API.G_MISS_CHAR,
       orig_csch_id                NUMBER := FND_API.G_MISS_NUM,
       cover_letter_version                NUMBER := FND_API.G_MISS_NUM,
     -- added by dbiswas on Aug12, 2003
       usage                            VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       purpose                          VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       last_activation_date             DATE := FND_API.G_MISS_DATE,
       sales_methodology_id             NUMBER := FND_API.G_MISS_NUM,
       printer_address                  VARCHAR2(255)  := FND_API.G_MISS_CHAR,
       notify_on_activation_flag        VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       sender_display_name            VARCHAR2(240) := FND_API.G_MISS_CHAR,--anchaudh
       asn_group_id                   VARCHAR2(240) := FND_API.G_MISS_CHAR,--anchaudh for leads bug
       delivery_mode                  VARCHAR2(30)  := FND_API.G_MISS_CHAR
);

g_miss_schedule_rec          schedule_rec_type;
TYPE  schedule_tbl_type      IS TABLE OF schedule_rec_type INDEX BY BINARY_INTEGER;
g_miss_schedule_tbl          schedule_tbl_type;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Camp_Schedule
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
--       p_schedule_rec            IN   schedule_rec_type  Required
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

PROCEDURE Create_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_rec               IN   schedule_rec_type  := g_miss_schedule_rec,
    x_schedule_id                   OUT NOCOPY  NUMBER
     );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Camp_Schedule
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
--       p_schedule_rec            IN   schedule_rec_type  Required
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

PROCEDURE Update_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_rec               IN    schedule_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Camp_Schedule
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
--       p_SCHEDULE_ID                IN   NUMBER
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

PROCEDURE Delete_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_schedule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Camp_Schedule
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
--       p_schedule_rec            IN   schedule_rec_type  Required
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

PROCEDURE Lock_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_schedule_id                IN  NUMBER,
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

PROCEDURE Validate_camp_schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_schedule_rec               IN   schedule_rec_type,
    p_validation_mode            IN   VARCHAR2,
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

PROCEDURE Check_schedule_Items (
    P_schedule_rec     IN    schedule_rec_type,
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

PROCEDURE Validate_schedule_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_schedule_rec               IN    schedule_rec_type
    );

--===================================================================
-- NAME
--    Check_Schedule_Inter_Entity
--
-- PURPOSE
--    Inter Entitiy validations for schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Check_Schedule_Inter_Entity( p_schedule_rec    IN  schedule_rec_type,
                                       p_complete_rec    IN  schedule_rec_type,
                                       p_validation_mode IN  VARCHAR2,
                                       x_return_status   OUT NOCOPY VARCHAR2
) ;
--===================================================================
-- NAME
--    Init_schedule_rec
--
-- PURPOSE
--    Initialize schedules rec, used for testing.
--
-- NOTES
--
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Init_Schedule_Rec(x_schedule_rec OUT NOCOPY schedule_rec_type) ;

--===================================================================
-- NAME
--    Complete_schedule_Rec
--
-- PURPOSE
--    Private api to complete rec for Campaign schedules.
--
-- NOTES
--
-- HISTORY
--   22-Jan-2001     PTENDULK   Created
--===================================================================
PROCEDURE Complete_schedule_Rec (
    P_schedule_rec     IN    schedule_rec_type,
     x_complete_rec    OUT NOCOPY    schedule_rec_type
    );


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Copy_Camp_Schedule
--
--   Description
--           To support the "Copy Schedule" functionality from the schedule overview
--           and detail pages.
--
--   History
--      30-Apr-2001   soagrawa  Created this procedure
--
--
--   ==============================================================================
--

PROCEDURE Copy_Camp_Schedule(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN   AMS_CpyUtility_PVT.copy_attributes_table_type,
    p_copy_columns_table         IN   AMS_CpyUtility_PVT.copy_columns_table_type,

    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
     );


END AMS_Camp_Schedule_PVT;

 

/
