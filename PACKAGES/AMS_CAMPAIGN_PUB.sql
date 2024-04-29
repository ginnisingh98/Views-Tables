--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGN_PUB" AUTHID CURRENT_USER AS
/* $Header: amspcpns.pls 120.0 2005/05/31 16:09:59 appldev noship $ */
/*#
 * This package provides methods to create or update a marketing campaign.
 *
 * Note: The campaign record type is used as an input parameter in campaign
 * creation and update methods.
 *
 *   TYPE camp_rec_type IS RECORD(
 *       campaign_id                      NUMBER,
 *       last_update_date                 DATE,
 *       last_updated_by                  NUMBER,
 *       creation_date                    DATE,
 *       created_by                       NUMBER,
 *       last_update_login                NUMBER,
 *       object_version_number            NUMBER,
 *       custom_setup_id                  NUMBER,
 *       owner_user_id                    NUMBER,
 *       user_status_id                   NUMBER,
 *       status_code                      VARCHAR2(30),
 *       status_date                      DATE,
 *       active_flag                      VARCHAR2(1),
 *       private_flag                     VARCHAR2(1),
 *       partner_flag                     VARCHAR2(1),
 *       template_flag                    VARCHAR2(1),
 *       cascade_source_code_flag         VARCHAR2(1),
 *       inherit_attributes_flag          VARCHAR2(1),
 *       source_code                      VARCHAR2(30),
 *       rollup_type                      VARCHAR2(30),
 *       campaign_type                    VARCHAR2(30),
 *       media_type_code                  VARCHAR2(30),
 *       priority                         VARCHAR2(30),
 *       fund_source_type                 VARCHAR2(30),
 *       fund_source_id                   NUMBER,
 *       parent_campaign_id               NUMBER,
 *       application_id                   NUMBER,
 *       qp_list_header_id                NUMBER,
 *       media_id                         NUMBER,
 *       channel_id                       NUMBER,
 *       event_type                       VARCHAR2(30),
 *       arc_channel_from                 VARCHAR2(30),
 *       dscript_name                     VARCHAR2(256),
 *       transaction_currency_code        VARCHAR2(15),
 *       functional_currency_code         VARCHAR2(15),
 *       budget_amount_tc                 NUMBER,
 *       budget_amount_fc                 NUMBER,
 *       forecasted_plan_start_date       DATE,
 *       forecasted_plan_end_date         DATE,
 *       forecasted_exec_start_date       DATE,
 *       forecasted_exec_end_date         DATE,
 *       actual_plan_start_date           DATE,
 *       actual_plan_end_date             DATE,
 *       actual_exec_start_date           DATE,
 *       actual_exec_end_date             DATE,
 *       inbound_url                      VARCHAR2(120),
 *       inbound_email_id                 VARCHAR2(120),
 *       inbound_phone_no                 VARCHAR2(25),
 *       duration                         NUMBER,
 *       duration_uom_code                VARCHAR2(3),
 *       ff_priority                      VARCHAR2(30),
 *       ff_override_cover_letter         NUMBER,
 *       ff_shipping_method               VARCHAR2(30),
 *       ff_carrier                       VARCHAR2(120),
 *       content_source                   VARCHAR2(120),
 *       cc_call_strategy                 VARCHAR2(30),
 *       cc_manager_user_id               NUMBER,
 *       forecasted_revenue               NUMBER,
 *       actual_revenue                   NUMBER,
 *       forecasted_cost                  NUMBER,
 *       actual_cost                      NUMBER,
 *       forecasted_response              NUMBER,
 *       actual_response                  NUMBER,
 *       target_response                  NUMBER,
 *       country_code                     VARCHAR2(30),
 *       language_code                    VARCHAR2(30),
 *       attribute_category               VARCHAR2(30),
 *       attribute1                       VARCHAR2(150),
 *       attribute2                       VARCHAR2(150),
 *       attribute3                       VARCHAR2(150),
 *       attribute4                       VARCHAR2(150),
 *       attribute5                       VARCHAR2(150),
 *       attribute6                       VARCHAR2(150),
 *       attribute7                       VARCHAR2(150),
 *       attribute8                       VARCHAR2(150),
 *       attribute9                       VARCHAR2(150),
 *       attribute10                      VARCHAR2(150),
 *       attribute11                      VARCHAR2(150),
 *       attribute12                      VARCHAR2(150),
 *       attribute13                      VARCHAR2(150),
 *       attribute14                      VARCHAR2(150),
 *       attribute15                      VARCHAR2(150),
 *       campaign_name                    VARCHAR2(240),
 *       campaign_theme                   VARCHAR2(4000),
 *       description                      VARCHAR2(4000),
 *       version_no                       NUMBER,
 *       campaign_calendar                VARCHAR2(15),
 *       start_period_name                VARCHAR2(15),
 *       end_period_name                  VARCHAR2(15),
 *       city_id                          NUMBER,
 *       global_flag                      VARCHAR2(1),
 *       show_campaign_flag               VARCHAR2(1),
 *       business_unit_id                 NUMBER,
 *       accounts_closed_flag             VARCHAR2(1),
 *       task_id                          NUMBER,
 *       related_event_from               VARCHAR2(30),
 *       related_event_id                 NUMBER,
 *       program_attribute_category       VARCHAR2(30),
 *       program_attribute1               VARCHAR2(150),
 *       program_attribute2               VARCHAR2(150),
 *       program_attribute3               VARCHAR2(150),
 *       program_attribute4               VARCHAR2(150),
 *       program_attribute5               VARCHAR2(150),
 *       program_attribute6               VARCHAR2(150),
 *       program_attribute7               VARCHAR2(150),
 *       program_attribute8               VARCHAR2(150),
 *       program_attribute9               VARCHAR2(150),
 *       program_attribute10              VARCHAR2(150),
 *       program_attribute11              VARCHAR2(150),
 *       program_attribute12              VARCHAR2(150),
 *       program_attribute13              VARCHAR2(150),
 *       program_attribute14              VARCHAR2(150),
 *       program_attribute15              VARCHAR2(150)
 *    )
 *
 * @rep:scope public
 * @rep:product AMS
 * @rep:lifecycle active
 * @rep:displayname Oracle Marketing Campaigns Public API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY AMS_CAMPAIGN
 */


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
--    1. object_version_number will be set to 1.
--    2. If campaign_id is passed in, the uniqueness will be checked.
--       Raise exception in case of duplicates.
--    3. If campaign_id is not passed in, generate a unique one from
--       the sequence.
--    4. If a flag column is passed in, check if it is 'Y' or 'N'.
--       Raise exception for invalid flag.
--    5. If a flag column is not passed in, default it to 'Y' or 'N'.
--    6. Please don't pass in any FND_API.g_mess_char/num/date.
---------------------------------------------------------------------

/*#
 * This procedure creates a marketing campaign. The details of the campaign will be passed
 * in the p_camp_rec record type. Check the x_return_status output to see if creation
 * was successful. If successful, a unique identifier for the campaign object will
 * be passed back in x_camp_id output parameter.
 *
 * @param p_api_version This must match the version number of the API. An unexepcted error is returned if the calling program version number is incompatible with the current API version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be initialized.
 * @param p_commit Flag to indicate if changes should be comitted on success.
 * @param p_validation_level Level of validation required. None: No validation will be performed. Full:  Item and record level validation will be performed.
 * @param p_camp_rec Record of type AMS_Campaign_PVT.camp_rec_type that takes in the details for the Campaign.
 * @param x_return_status Indicates the return status of the API. The values are one of the following:
 * FND_API.G_RET_STS_SUCCESS: Indicates the API call was successful;
 * FND_API.G_RET_STS_ERROR: Indicates there was a validation error or a missing data error;
 * FND_API.G_RET_STS_UNEXP_ERROR: Indicates the calling program encountered an unxpected or unhandled error.
 * @param x_msg_count Count of error messages in the message list.
 * @param x_msg_data Error messages returned by the API. If more than one message is returned, this parameter is null and messages must be extracted from the message stack.
 * @param x_camp_id Unique identifier for the newly created Campaign
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Marketing Campaign
 */

PROCEDURE create_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type,
   x_camp_id           OUT NOCOPY NUMBER
);


--------------------------------------------------------------------
-- PROCEDURE
--    delete_campaign
--
-- PURPOSE
--    Delete a campaign.
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

/*#
 * This procedure updates a marketing campaign. The details of the campaign will be passed
 * in the p_camp_rec record type. Check the x_return_status output to see if the update
 * was successful.
 *
 * @param p_api_version This must match the version number of the API. An unexepcted error is returned if the calling program version number is incompatible with the current API version number.
 * @param p_init_msg_list Flag to indicate if the message stack should be initialized.
 * @param p_commit Flag to indicate if changes should be comitted on success.
 * @param p_validation_level Level of validation required. None: No validation will be performed. Full:  Item and record level validation will be performed.
 * @param p_camp_rec Record of type AMS_Campaign_PVT.camp_rec_type that takes in the details for the Campaign.
 * @param x_return_status Indicates the return status of the API. The values are one of the following:
 * FND_API.G_RET_STS_SUCCESS: Indicates the API call was successful;
 * FND_API.G_RET_STS_ERROR: Indicates there was a validation error or a missing data error;
 * FND_API.G_RET_STS_UNEXP_ERROR: Indicates the calling program encountered an unxpected or unhandled error.
 * @param x_msg_count Count of error messages in the message list.
 * @param x_msg_data Error messages returned by the API. If more than one message is returned, this parameter is null and messages must be extracted from the message stack.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Marketing Campaign
 */

PROCEDURE update_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type
);


---------------------------------------------------------------------
-- PROCEDURE
--    validate_campaign
--
-- PURPOSE
--    Validate a campaign record.
--
-- PARAMETERS
--    p_camp_rec: the campaign record to be validated
--
-- NOTES
--    1. p_camp_rec should be the complete campaign record. There
--       should not be any FND_API.g_miss_char/num/date in it.
----------------------------------------------------------------------
PROCEDURE validate_campaign(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_camp_rec          IN  AMS_Campaign_PVT.camp_rec_type
);


END AMS_Campaign_PUB;

 

/
