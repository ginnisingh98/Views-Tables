--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcpns.pls 115.16 2002/11/22 23:38:22 dbiswas ship $ */


TYPE camp_rec_type IS RECORD(
   campaign_id                      NUMBER,
   last_update_date                 DATE,
   last_updated_by                  NUMBER,
   creation_date                    DATE,
   created_by                       NUMBER,
   last_update_login                NUMBER,
   object_version_number            NUMBER,
   custom_setup_id                  NUMBER,
   owner_user_id                    NUMBER,
   user_status_id                   NUMBER,
   status_code                      VARCHAR2(30),
   status_date                      DATE,
   active_flag                      VARCHAR2(1),
   private_flag                     VARCHAR2(1),
   partner_flag                     VARCHAR2(1),
   template_flag                    VARCHAR2(1),
   cascade_source_code_flag         VARCHAR2(1),
   inherit_attributes_flag          VARCHAR2(1),
   source_code                      VARCHAR2(30),
   rollup_type                      VARCHAR2(30),
   campaign_type                    VARCHAR2(30),
   media_type_code                  VARCHAR2(30),
   priority                         VARCHAR2(30),
   fund_source_type                 VARCHAR2(30),
   fund_source_id                   NUMBER,
   parent_campaign_id               NUMBER,
   application_id                   NUMBER,
   qp_list_header_id                NUMBER,
   media_id                         NUMBER,
   channel_id                       NUMBER,
   event_type                       VARCHAR2(30),
   arc_channel_from                 VARCHAR2(30),
   dscript_name                     VARCHAR2(256),
   transaction_currency_code        VARCHAR2(15),
   functional_currency_code         VARCHAR2(15),
   budget_amount_tc                 NUMBER,
   budget_amount_fc                 NUMBER,
   forecasted_plan_start_date       DATE,
   forecasted_plan_end_date         DATE,
   forecasted_exec_start_date       DATE,
   forecasted_exec_end_date         DATE,
   actual_plan_start_date           DATE,
   actual_plan_end_date             DATE,
   actual_exec_start_date           DATE,
   actual_exec_end_date             DATE,
   inbound_url                      VARCHAR2(120),
   inbound_email_id                 VARCHAR2(120),
   inbound_phone_no                 VARCHAR2(25),
   duration                         NUMBER,
   duration_uom_code                VARCHAR2(3),
   ff_priority                      VARCHAR2(30),
   ff_override_cover_letter         NUMBER,
   ff_shipping_method               VARCHAR2(30),
   ff_carrier                       VARCHAR2(120),
   content_source                   VARCHAR2(120),
   cc_call_strategy                 VARCHAR2(30),
   cc_manager_user_id               NUMBER,
   forecasted_revenue               NUMBER,
   actual_revenue                   NUMBER,
   forecasted_cost                  NUMBER,
   actual_cost                      NUMBER,
   forecasted_response              NUMBER,
   actual_response                  NUMBER,
   target_response                  NUMBER,
   country_code                     VARCHAR2(30),
   language_code                    VARCHAR2(30),
   attribute_category               VARCHAR2(30),
   attribute1                       VARCHAR2(150),
   attribute2                       VARCHAR2(150),
   attribute3                       VARCHAR2(150),
   attribute4                       VARCHAR2(150),
   attribute5                       VARCHAR2(150),
   attribute6                       VARCHAR2(150),
   attribute7                       VARCHAR2(150),
   attribute8                       VARCHAR2(150),
   attribute9                       VARCHAR2(150),
   attribute10                      VARCHAR2(150),
   attribute11                      VARCHAR2(150),
   attribute12                      VARCHAR2(150),
   attribute13                      VARCHAR2(150),
   attribute14                      VARCHAR2(150),
   attribute15                      VARCHAR2(150),
   campaign_name                    VARCHAR2(240),
   campaign_theme                   VARCHAR2(4000),
   description                      VARCHAR2(4000),
   version_no                       NUMBER,
   campaign_calendar                VARCHAR2(15),
   start_period_name                VARCHAR2(15),
   end_period_name                  VARCHAR2(15),
   city_id                          NUMBER,
   global_flag                      VARCHAR2(1),
   show_campaign_flag               VARCHAR2(1),
   business_unit_id                 NUMBER,
   accounts_closed_flag             VARCHAR2(1),
   task_id                          NUMBER,
   related_event_from               VARCHAR2(30),
   related_event_id                 NUMBER,
   program_attribute_category       VARCHAR2(30),
   program_attribute1               VARCHAR2(150),
   program_attribute2               VARCHAR2(150),
   program_attribute3               VARCHAR2(150),
   program_attribute4               VARCHAR2(150),
   program_attribute5               VARCHAR2(150),
   program_attribute6               VARCHAR2(150),
   program_attribute7               VARCHAR2(150),
   program_attribute8               VARCHAR2(150),
   program_attribute9               VARCHAR2(150),
   program_attribute10              VARCHAR2(150),
   program_attribute11              VARCHAR2(150),
   program_attribute12              VARCHAR2(150),
   program_attribute13              VARCHAR2(150),
   program_attribute14              VARCHAR2(150),
   program_attribute15              VARCHAR2(150)
);


---------------------------------------------------------------------
-- PROCEDURE
--    create_campaign
--
-- PURPOSE
--    Create a new campaign.
--
-- PARAMETERS
--    p_camp_rec: the new record to be inserted
--    x_camp_id: return the campaign_id of the new campaign
--
-- NOTES
--    1. Please don't pass in any FND_API.g_mess_char/num/date.
--    2. object_version_number will be set to 1.
--    3. If campaign_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates. If campaign_id is not
--       passed in, generate a unique one from the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag. If a flag column is not
--       passed in, default it to 'Y' or 'N'.
--    5. If the source_code is passed in, check if it is unique in
--       ams_source_codes table. If source_code is not passed in,
--       generate a unique one. After creating the campaign, the
--       source_code will be pushed into ams_source_codes table.
--    6. The default value for priority is 'STANDARD'.
--    7. Since the status_code and inherit_attributes_flag will be
--       used internally only, this API will disregard the value
--       passed in.
---------------------------------------------------------------------
PROCEDURE create_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type,
   x_camp_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_campaign
--
-- PURPOSE
--    Set the campaign to be inactive so that it won't be available
--    to users.
--
-- PARAMETERS
--    p_camp_id: the campaign_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. Will set the campaign to be inactive, instead of remove it
--       from database.
--------------------------------------------------------------------
PROCEDURE delete_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_commit            IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


-------------------------------------------------------------------
-- PROCEDURE
--    lock_campaign
--
-- PURPOSE
--    Lock a campaign.
--
-- PARAMETERS
--    p_camp_id: the campaign_id
--    p_object_version: the object_version_number
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--------------------------------------------------------------------
PROCEDURE lock_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_id           IN  NUMBER,
   p_object_version    IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    update_campaign
--
-- PURPOSE
--    Update a campaign.
--
-- PARAMETERS
--    p_camp_rec: the record with new items
--
-- NOTES
--    1. Raise exception if the object_version_number doesn't match.
--    2. If an attribute is passed in as FND_API.g_miss_char/num/date,
--       that column won't be updated.
----------------------------------------------------------------------
PROCEDURE update_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_campaign
--
-- PURPOSE
--    Validate a campaign record.
--
-- PARAMETERS
--    p_camp_rec: the record to be validated
--
-- NOTES
--    1. p_camp_rec should be the complete campaign record wothout
--       any FND_API.g_miss_char/num/date items.
----------------------------------------------------------------------
PROCEDURE validate_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  camp_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_items
--
-- PURPOSE
--    Perform the item level checking including unique keys,
--    required columns, foreign keys, domain constraints.
--
-- PARAMETERS
--    p_camp_rec: the record to be validated
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_camp_items(
   p_camp_rec        IN  camp_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_record
--
-- PURPOSE
--    Check the record level business rules.
--
-- PARAMETERS
--    p_camp_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
---------------------------------------------------------------------
PROCEDURE check_camp_record(
   p_camp_rec         IN  camp_rec_type,
   p_complete_rec     IN  camp_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_inter_entity
--
-- PURPOSE
--    Check the inter-entity level business rules.
--
-- PARAMETERS
--    p_camp_rec: the record to be validated; may contain attributes
--       as FND_API.g_miss_char/num/date
--    p_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--    p_validation_mode: JTF_PLSQL_API.g_create/g_update
---------------------------------------------------------------------
PROCEDURE check_camp_inter_entity(
   p_camp_rec        IN  camp_rec_type,
   p_complete_rec    IN  camp_rec_type,
   p_validation_mode IN  VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    init_camp_rec
--
-- PURPOSE
--    Initialize all attributes to be FND_API.g_miss_char/num/date.
---------------------------------------------------------------------
PROCEDURE init_camp_rec(
   x_camp_rec         OUT NOCOPY  camp_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    complete_camp_rec
--
-- PURPOSE
--    For update_campaign, some attributes may be passed in as
--    FND_API.g_miss_char/num/date if the user doesn't want to
--    update those attributes. This procedure will replace the
--    "g_miss" attributes with current database values.
--
-- PARAMETERS
--    p_camp_rec: the record which may contain attributes as
--       FND_API.g_miss_char/num/date
--    x_complete_rec: the complete record after all "g_miss" items
--       have been replaced by current database values
--
-- NOTES
--    1. If a valid status_date is provided, use it. If not, set it
--       to be the original value or SYSDATE depending on whether
--       the user_status_id is changed or not.
---------------------------------------------------------------------
PROCEDURE complete_camp_rec(
   p_camp_rec       IN  camp_rec_type,
   x_complete_rec   OUT NOCOPY camp_rec_type
);


END AMS_Campaign_PVT;

 

/
