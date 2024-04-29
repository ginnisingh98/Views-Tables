--------------------------------------------------------
--  DDL for Package AMS_CAMP_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMP_SCHEDULE_PUB" AUTHID CURRENT_USER AS
/* $Header: amspschs.pls 120.4 2006/05/31 11:54:02 srivikri ship $ */
/*#
 * This package provides methods to create or update a marketing campaign schedule.
 *
 * Note: The campaign schedule record type is used as an input parameter in campaign schedule
 * creation and update methods.
 *
 *   TYPE schedule_rec_type is RECORD (
 *       schedule_id                     NUMBER  := FND_API.G_MISS_NUM,
 *       last_update_date                DATE := FND_API.G_MISS_DATE,
 *       last_updated_by                 NUMBER := FND_API.G_MISS_NUM,
 *       creation_date                   DATE := FND_API.G_MISS_DATE,
 *       created_by                      NUMBER := FND_API.G_MISS_NUM,
 *       last_update_login               NUMBER := FND_API.G_MISS_NUM,
 *       object_version_number           NUMBER := FND_API.G_MISS_NUM,
 *       campaign_id                     NUMBER := FND_API.G_MISS_NUM,
 *       user_status_id                  NUMBER := FND_API.G_MISS_NUM,
 *       status_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       status_date                     DATE := FND_API.G_MISS_DATE,
 *       source_code                     VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       use_parent_code_flag            VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       start_date_time                 DATE := FND_API.G_MISS_DATE,
 *       end_date_time                   DATE := FND_API.G_MISS_DATE,
 *       timezone_id                     NUMBER := FND_API.G_MISS_NUM,
 *       activity_type_code              VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       activity_id                     NUMBER := FND_API.G_MISS_NUM,
 *       arc_marketing_medium_from       VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       marketing_medium_id             NUMBER := FND_API.G_MISS_NUM,
 *       custom_setup_id                 NUMBER := FND_API.G_MISS_NUM,
 *       triggerable_flag                VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       trigger_id                      NUMBER := FND_API.G_MISS_NUM,
 *       notify_user_id                  NUMBER := FND_API.G_MISS_NUM,
 *       approver_user_id                NUMBER := FND_API.G_MISS_NUM,
 *       owner_user_id                   NUMBER := FND_API.G_MISS_NUM,
 *       active_flag                     VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       cover_letter_id                 NUMBER := FND_API.G_MISS_NUM,
 *       reply_to_mail                   VARCHAR2(120) := FND_API.G_MISS_CHAR,
 *       mail_sender_name                VARCHAR2(120) := FND_API.G_MISS_CHAR,
 *       mail_subject                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
 *       from_fax_no                     VARCHAR2(25) := FND_API.G_MISS_CHAR,
 *       accounts_closed_flag            VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       org_id                          NUMBER := FND_API.G_MISS_NUM,
 *       objective_code                  VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       country_id                      NUMBER := FND_API.G_MISS_NUM,
 *       campaign_calendar               VARCHAR2(20) := FND_API.G_MISS_CHAR,
 *       start_period_name               VARCHAR2(15) := FND_API.G_MISS_CHAR,
 *       end_period_name                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       priority                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       workflow_item_key               VARCHAR2(240) := FND_API.G_MISS_CHAR,
 *       transaction_currency_code       VARCHAR2(15)  := FND_API.G_MISS_CHAR,
 *       functional_currency_code        VARCHAR2(15)  := FND_API.G_MISS_CHAR,
 *       budget_amount_tc                NUMBER := FND_API.G_MISS_NUM,
 *       budget_amount_fc                NUMBER := FND_API.G_MISS_NUM,
 *       language_code                   VARCHAR2(4) := FND_API.G_MISS_CHAR,
 *       task_id                         NUMBER := FND_API.G_MISS_NUM,
 *       related_event_from              VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       related_event_id                NUMBER := FND_API.G_MISS_NUM,
 *       attribute_category              VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       attribute1                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute2                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute3                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
 *       attribute5                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute6                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute7                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute8                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute9                      VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute10                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute11                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute12                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute13                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute14                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       attribute15                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute_category     VARCHAR2(240) := FND_API.G_MISS_CHAR,
 *       activity_attribute1             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute2             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute3             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute4             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute5             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute6             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute7             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute8             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute9             VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute10            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute11            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute12            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute13            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute14            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       activity_attribute15            VARCHAR2(150) := FND_API.G_MISS_CHAR,
 *       schedule_name                   VARCHAR2(120) := FND_API.G_MISS_CHAR,
 *       description                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
 *       related_source_code             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
 *       related_source_object           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
 *       related_source_id               NUMBER        := FND_API.G_MISS_NUM,
 *       query_id                        NUMBER        := FND_API.G_MISS_NUM,
 *       include_content_flag            VARCHAR2(1)  := FND_API.G_MISS_CHAR,
 *       content_type                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       test_email_address              VARCHAR2(250):= FND_API.G_MISS_CHAR,
 *       greeting_text                   VARCHAR2(4000):= FND_API.G_MISS_CHAR,
 *       footer_text                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
 *       trig_repeat_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       tgrp_exclude_prev_flag         VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       orig_csch_id                NUMBER := FND_API.G_MISS_NUM,
 *       cover_letter_version                NUMBER := FND_API.G_MISS_NUM,
 *       usage                          VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       purpose                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
 *       last_activation_date           DATE := FND_API.G_MISS_DATE,
 *       sales_methodology_id           NUMBER := FND_API.G_MISS_NUM,
 *       printer_address                VARCHAR2(255) := FND_API.G_MISS_CHAR,
 *       notify_on_activation_flag      VARCHAR2(1) := FND_API.G_MISS_CHAR,
 *       delivery_mode                  VARCHAR2(30) := FND_API.G_MISS_CHAR
 *       )
 *
 * @rep:scope public
 * @rep:product AMS
 * @rep:lifecycle active
 * @rep:displayname Oracle Marketing Campaign Schedules Public API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_CAMPAIGN
 */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Camp_Schedule_PUB
-- Purpose
--
-- History
--               ptendulk   Created
--  18-May-2001  soagrawa   Modified schedule_rec_type according to
--                          the latest amsvschs.pls
--  22-May-2001  soagrawa   Added parameter p_validation_level to
--                          the create, update, delete and validate apis
--  19-jul-2001  ptendulk   Added columns for eBlast
--  24-sep-2001  soagrawa   Removed security group id from everywhere
--  02-dec-2002  dbiswas    NOCOPY and debug-level changes for performance
--  27-jun-2003   anchaudh   Added 4 new fields(columns) in the  schedule_rec_type
--  25-aug-2003   dbiswas    Added 1 new field(sales_methodology_id) in the  schedule_rec_type
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
--       row_id
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
--       start_period_name
--       end_period_name
--       priority
--       workflow_item_key
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
--       schedule_name
--       description
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
       -- removed by soagrawa on 24-sep-2001
       -- security_group_id               NUMBER        := FND_API.G_MISS_NUM,
       schedule_name                   VARCHAR2(120) := FND_API.G_MISS_CHAR,
       description                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
       related_source_code             VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       related_source_object           VARCHAR2(30)  := FND_API.G_MISS_CHAR,
       related_source_id               NUMBER        := FND_API.G_MISS_NUM,
       query_id                        NUMBER        := FND_API.G_MISS_NUM,
       include_content_flag            VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       content_type                    VARCHAR2(30) := FND_API.G_MISS_CHAR,
       test_email_address              VARCHAR2(250):= FND_API.G_MISS_CHAR,
       greeting_text                   VARCHAR2(4000):= FND_API.G_MISS_CHAR,
      footer_text                     VARCHAR2(4000):= FND_API.G_MISS_CHAR,
       --following are added by anchaudh on 27-jun-2003
       trig_repeat_flag              VARCHAR2(1) := FND_API.G_MISS_CHAR,
       tgrp_exclude_prev_flag         VARCHAR2(1) := FND_API.G_MISS_CHAR,
       orig_csch_id                NUMBER := FND_API.G_MISS_NUM,
       cover_letter_version                NUMBER := FND_API.G_MISS_NUM,
       --following are added by dbiswas on 12-aug-2003
       usage                          VARCHAR2(30) := FND_API.G_MISS_CHAR,
       purpose                        VARCHAR2(30) := FND_API.G_MISS_CHAR,
       last_activation_date           DATE := FND_API.G_MISS_DATE,
       sales_methodology_id           NUMBER := FND_API.G_MISS_NUM,
       printer_address                VARCHAR2(255) := FND_API.G_MISS_CHAR,
       notify_on_activation_flag      VARCHAR2(1) := FND_API.G_MISS_CHAR,
       sender_display_name            VARCHAR2(240) := FND_API.G_MISS_CHAR,--anchaudh
       asn_group_id                   VARCHAR2(240) := FND_API.G_MISS_CHAR,--anchaudh for leads bug
       delivery_mode                  VARCHAR2(30) := FND_API.G_MISS_CHAR
);

g_miss_schedule_rec          schedule_rec_type;
TYPE  schedule_tbl_type      IS TABLE OF schedule_rec_type INDEX BY BINARY_INTEGER;
g_miss_schedule_tbl          schedule_tbl_type;

TYPE schedule_sort_rec_type IS RECORD
(
      -- Please define your own sort by record here.
      schedule_id   NUMBER := NULL
);



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Camp_Schedule
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

/*#
 * This procedure creates a marketing campaign schedule. The details of the campaign schedule
 * will be passed in the p_schedule_rec record type. Check the x_return_status output to
 * see if creation was successful. If successful, a unique identifier for the schedule object
 * will be passed back to the x_schedule_id output parameter.
 *
 * @param p_api_version_number This must match the version number of the API. An unexepcted error is returned if the calling program version number is incompatible with the current API version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be initialized.
 * @param p_commit Flag to indicate if changes should be comitted on success.
 * @param p_validation_level Level of validation required. None: No validation will be performed. Full:  Item and record level validation will be performed.
 * @param p_schedule_rec Record of type AMS_Camp_Schedule_PUB.schedule_rec_type that takes in the details for the Campaign Schedule.
 * @param x_return_status Indicates the return status of the API. The values are one of the following:
 * FND_API.G_RET_STS_SUCCESS: Indicates the API call was successful;
 * FND_API.G_RET_STS_ERROR: Indicates there was a validation error or a missing data error;
 * FND_API.G_RET_STS_UNEXP_ERROR: Indicates the calling program encountered an unxpected or unhandled error.
 * @param x_msg_count Count of error messages in the message list.
 * @param x_msg_data Error messages returned by the API. If more than one message is returned, this parameter is null and messages must be extracted from the message stack.
 * @param x_schedule_id Unique identifier for the newly created Campaign Schedule.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Marketing Campaign Schedule
 */
PROCEDURE Create_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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

/*#
 * This procedure updates a marketing campaign schedule. The details of the campaign schedule
 * will be passed in the p_schedule_rec record type. Check the x_return_status output to
 * see if the update was successful. If successful, the updated schedule object's new object
 * version number will be passed back in x_object_version_number output parameter.
 *
 * @param p_api_version_number This must match the version number of the API. An unexepcted error is returned if the calling program version number is incompatible with the current API version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be initialized.
 * @param p_commit Flag to indicate if changes should be comitted on success.
 * @param p_validation_level Level of validation required. None: No validation will be performed. Full:  Item and record level validation will be performed.
 * @param p_schedule_rec Record of type AMS_Camp_Schedule_PUB.schedule_rec_type that takes in the details for the Campaign Schedule.
 * @param x_return_status Indicates the return status of the API. The values are one of the following:
 * FND_API.G_RET_STS_SUCCESS: Indicates the API call was successful
 * FND_API.G_RET_STS_ERROR: Indicates there was a validation error or a missing data error
 * FND_API.G_RET_STS_UNEXP_ERROR: Indicates the calling program encountered an unxpected or unhandled error.
 * @param x_msg_count Count of error messages in the message list.
 * @param x_msg_data Error messages returned by the API. If more than one message is returned, this parameter is null and messages must be extracted from the message stack.
 * @param x_object_version_number Object version number of the updated campaign schedule
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Marketing Campaign Schedule
 */

PROCEDURE Update_Camp_Schedule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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
    p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
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
--           Public
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
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

    p_schedule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    );

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Camp_Schedule
--
-- PURPOSE
--    Validate a schedule record.
--
-- PARAMETERS
--    p_schedule_rec: the campaign record to be validated
--
-- NOTES
--    1. p_schedule_rec should be the complete schedule record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE Validate_Camp_Schedule(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_validation_mode   IN   VARCHAR2,
   p_schedule_rec      IN  schedule_rec_type
);

---------------------------------------------------------------------
-- PROCEDURE
--    Copy_Camp_Schedule
--
-- PURPOSE
--    copy a schedule record and its attributes
--
-- HISTORY
--    18-SEP-2001   soagrawa   Added, refer to bug# 2000042
----------------------------------------------------------------------

PROCEDURE Copy_Camp_Schedule(
    p_api_version                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_source_object_id           IN   NUMBER,
    p_attributes_table           IN  ams_cpyutility_pvt.copy_attributes_table_type,
    p_copy_columns_table         IN  ams_cpyutility_pvt.copy_columns_table_type,

    x_new_object_id              OUT NOCOPY  NUMBER,
    x_custom_setup_id            OUT NOCOPY  NUMBER
     );




END AMS_Camp_Schedule_PUB;

 

/
