--------------------------------------------------------
--  DDL for Package CCT_SERVERDATAINPUT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_SERVERDATAINPUT_PUB" AUTHID CURRENT_USER AS
/* $Header: ccticiis.pls 120.0 2005/06/02 09:35:09 appldev noship $*/

G_PKG_NAME CONSTANT VARCHAR(80) := 'CCT_ServerDataInput_PUB';

/* start of comments
                Record data for an Outbound (time, site, campaign, list) tuple combination.
Api name        : Advanced_Outbound_Input
Type            : Public
Pre-regs        : None
Function        : Record data to ICI Advanced Outbound table
Parameters      :
                :p_api_version                     IN     NUMBER           Required
                        Used by the API to compare the version numbers of incoming
                        calls to its current version number, returns an unexpected error
                        if they are incompatible.

                :p_init_msg_list                   IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        The API message list must be initialized every time a program
                        calls an API.

                :p_commit                          IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        Before returning to its caller, an API should check the value
                        of p_commit.  If it is set to TRUE it should commit its work.

                :p_validation_level                IN     NUMBER           Optional
                        Default = FND_API.G_VALID_LEVEL_FULL
                        Determins which validation steps should be executed and which
                        should be skipped.  Public APIs by definition have to perform FULL
                        validation on all the data passed to them

                : x_return_status                  OUT    VARCHAR2
                        Returns the result of all operations performed by the API

                : x_msg_count                      OUT    NUMBER
                        Holds the number of messages in the API message list.

                : x_msg_data                       OUT    VARCHAR2
                        Holds the message in an encoded format.

                : p_time                           IN     DATE             Optional
                        Default = NULL
                        The time, to the minute, for this data. Input will be truncated
                        to the minute, and the data must be for the minute {yyyy-mon-dd
                        hh:mm:00.0} to {yyyy-mon-dd hh:mm:59.9}, local to the advanced
                        outbound server.

                : p_site_id                        IN     NUMBER           Optional
                        Default = NULL
                        ID of the site. This is an index to the site definition table.

                : p_site_name                      IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the site.

                : p_campaign_id                    IN     NUMBER           Optional
                        Default = NULL
                        ID of the campaign. This is an index to the campaign definition table.

                : p_campaign_name                  IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the campaign.

                : p_list_id                        IN     NUMBER           Optional
                        Default = NULL
                        ID of the list. This is an index to the list definition table.

                : p_list_name                      IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the list.

                : p_busy_count                     IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_connect_count                  IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_answering_machine_count        IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_modem_count                    IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_sit_count                      IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute. Standard identification tone?

                : p_rna_count                      IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute. Ring no answer.

                : p_other_count                    IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_predictive_dials               IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute. Dials in predictive mode.

                : p_progressive_dials              IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute. Dials in progressive mode.

                : p_preview_dials                  IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute. Dials in preview mode.

                : p_preview_time                   IN     NUMBER           Optional
                        Default = NULL
                        Total time agents spent previewing calls, this minute. In seconds.

                : p_withdrawn_dials                IN     NUMBER           Optional
                        Default = NULL
                        Totals dials that were later withdrawn, this minute.

                : p_wait_time_average              IN     NUMBER           Optional
                        Default = NULL
                        Average idle time for agents this minute. In seconds.

                : p_wait_time_std_dev              IN     NUMBER           Optional
                        Default = NULL
                        Standard deviation of idle time for agents this minute. In seconds.

                : p_wait_time_cumulative_avg       IN     NUMBER           Optional
                        Default = NULL
                        Average idle time for agents cumulative for today. In seconds.

                : p_wait_time_cumulative_stddev    IN     NUMBER           Optional
                        Default = NULL
                        Standard deviation of idle time for agents cumulative for today.
                        In seconds.

                : p_wait_time_minimum              IN     NUMBER           Optional
                        Default = NULL
                        Minimum idle time for agents this minute. In seconds.

                : p_wait_time_maximum              IN     NUMBER           Optional
                        Default = NULL
                        Maximum idle time for agents this minute. In seconds.

                : p_wait_time_total                IN     NUMBER           Optional
                        Default = NULL
                        Total idle time for agents this minute. In seconds.

                : p_number_agents_predictive       IN     NUMBER           Optional
                        Default = NULL
                        Number of agents working (predictive), sampled sometime this
                        minute.

                : p_number_agents_outbound         IN     NUMBER           Optional
                        Default = NULL
                        Number of agents working (outbound), sampled sometime this
                        minute.

                : p_number_working_dialers         IN     NUMBER           Optional
                        Default = NULL
                        Number of dialers working, sampled sometime this minute.

                : p_abandon_count                  IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_abandon_percentage             IN     NUMBER           Optional
                        Default = NULL
                        Percentage in this minute.

                : p_callback_count                 IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.

                : p_callback_percentage            IN     NUMBER           Optional
                        Default = NULL
                        Percentage in this minute.

                : p_outcome_1_count                IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.  User-defined outcome 1.

                : p_outcome_2_count                IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.  User-defined outcome 2.

                : p_outcome_3_count                IN     NUMBER           Optional
                        Default = NULL
                        Total occurences in this minute.  User-defined outcome 3.

                : p_records_start_of_day           IN     NUMBER           Optional
                        Default = NULL
                        Constant number.

                : p_records_remaining              IN     NUMBER           Optional
                        Default = NULL
                        Number of records remaining in list. Sampled sometime this minute.

                : p_predicted_exhaustion_date      IN     DATE             Optional
                        Default = NULL
                        Estimate until the list is exhausted.

                : p_recs_to_be_released_in_1       IN     NUMBER           Optional
                        Default = NULL
                        Estimated number of records to be released in the next minute.

                : p_recs_to_be_released_in_5       IN     NUMBER           Optional
                        Default = NULL
                        Estimated number of records to be released in the next 5 minutes.

                : p_recs_to_be_released_in_15      IN     NUMBER           Optional
                        Default = NULL
                        Estimated number of records to be released in the next 15 minutes.

                : p_recs_to_be_released_in_60      IN     NUMBER           Optional
                        Default = NULL
                        Estimated number of records to be released in the next hour.

Version         : Current Version 1.0
                  Previous Version n/a
                  Initial Version 1.0

end of comments */

PROCEDURE Advanced_Outbound_Input
(    p_api_version                    IN     NUMBER,
     p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
     p_commit                         IN     VARCHAR2        := FND_API.G_FALSE,
     p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                  OUT nocopy   VARCHAR2,
     x_msg_count                      OUT nocopy   NUMBER,
     x_msg_data                       OUT nocopy   VARCHAR2,

     p_time                           IN     DATE            := NULL,

     p_site_id                        IN     NUMBER          := NULL,
     p_site_name                      IN     VARCHAR2        := NULL,
     p_campaign_id                    IN     NUMBER          := NULL,
     p_campaign_name                  IN     VARCHAR2        := NULL,
     p_list_id                        IN     NUMBER          := NULL,
     p_list_name                      IN     VARCHAR2        := NULL,

     p_busy_count                     IN     NUMBER          := NULL,
     p_connect_count                  IN     NUMBER          := NULL,
     p_answering_machine_count        IN     NUMBER          := NULL,
     p_modem_count                    IN     NUMBER          := NULL,
     p_sit_count                      IN     NUMBER          := NULL,
     p_rna_count                      IN     NUMBER          := NULL,
     p_other_count                    IN     NUMBER          := NULL,

     p_predictive_dials               IN     NUMBER          := NULL,
     p_progressive_dials              IN     NUMBER          := NULL,
     p_preview_dials                  IN     NUMBER          := NULL,
     p_preview_time                   IN     NUMBER          := NULL,
     p_withdrawn_dials                IN     NUMBER          := NULL,

     p_wait_time_average              IN     NUMBER          := NULL,
     p_wait_time_std_dev              IN     NUMBER          := NULL,
     p_wait_time_cumulative_avg       IN     NUMBER          := NULL,
     p_wait_time_cumulative_stddev    IN     NUMBER          := NULL,
     p_wait_time_minimum              IN     NUMBER          := NULL,
     p_wait_time_maximum              IN     NUMBER          := NULL,
     p_wait_time_total                IN     NUMBER          := NULL,

     p_number_agents_predictive       IN     NUMBER          := NULL,
     p_number_agents_outbound         IN     NUMBER          := NULL,
     p_number_working_dialers         IN     NUMBER          := NULL,
     p_abandon_count                  IN     NUMBER          := NULL,
     p_abandon_percentage             IN     NUMBER          := NULL,
     p_callback_count                 IN     NUMBER          := NULL,
     p_callback_percentage            IN     NUMBER          := NULL,

     p_outcome_1_count                IN     NUMBER          := NULL,
     p_outcome_2_count                IN     NUMBER          := NULL,
     p_outcome_3_count                IN     NUMBER          := NULL,

     p_records_start_of_day           IN     NUMBER          := NULL,
     p_records_remaining              IN     NUMBER          := NULL,
     p_predicted_exhaustion_date      IN     DATE            := NULL,
     p_recs_to_be_released_in_1       IN     NUMBER          := NULL,
     p_recs_to_be_released_in_5       IN     NUMBER          := NULL,
     p_recs_to_be_released_in_15      IN     NUMBER          := NULL,
     p_recs_to_be_released_in_60      IN     NUMBER          := NULL
);

/* ************************************************** */

/* start of comments
                Record data for a Blending (time, site, media type, LOS category)
                tuple combination.
Api name        : Interaction_Blending_Input
Type            : Public
Pre-regs        : None
Function        : Record data to ICI Interaction Blending table
Parameters      :
                :p_api_version                     IN     NUMBER           Required
                        Used by the API to compare the version numbers of incoming
                        calls to its current version number, returns an unexpected error
                        if they are incompatible.

                :p_init_msg_list                   IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        The API message list must be initialized every time a program
                        calls an API.

                :p_commit                          IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        Before returning to its caller, an API should check the value
                        of p_commit.  If it is set to TRUE it should commit its work.

                :p_validation_level                IN     NUMBER           Optional
                        Default = FND_API.G_VALID_LEVEL_FULL
                        Determins which validation steps should be executed and which
                        should be skipped.  Public APIs by definition have to perform FULL
                        validation on all the data passed to them

                : x_return_status                  OUT    VARCHAR2
                        Returns the result of all operations performed by the API

                : x_msg_count                      OUT    NUMBER
                        Holds the number of messages in the API message list.

                : x_msg_data                       OUT    VARCHAR2
                        Holds the message in an encoded format.

                : p_time                           IN     DATE             Optional
                        Default = NULL
                        The time, to the minute, for this data. Input will be truncated
                        to the minute, and the data must be for the minute {yyyy-mon-dd
                        hh:mm:00.0} to {yyyy-mon-dd hh:mm:59.9}, local to the advanced
                        outbound server.

                : p_site_id                        IN     NUMBER           Optional
                        Default = NULL
                        ID of the site. This is an index to the site definition table.

                : p_site_name                      IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the site.

                : p_media_type_id                  IN     NUMBER           Optional
                        Default = NULL
                        ID of the media type. This is an index to the media type
                        definition table.

                : p_media_type                     IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the media type.

                : p_los_id                         IN     NUMBER           Optional
                        Default = NULL
                        ID of the level of service category. This is an index to the
                        level of service definition table.

                : p_los_name                       IN     VARCHAR2         Optional
                        Default = NULL
                        Level of service category name.

                : p_direction                      IN     NUMBER           Optional
                        Default = NULL
                        Type of LOS: Inbound (:= 1) or Outbound (:= 0)

                : p_items_queued_count             IN     NUMBER           Optional
                        Default = NULL
                        Number of items queued for this media type.

                : p_items_serviced_count           IN     NUMBER           Optional
                        Default = NULL
                        Number of items serviced for this media type.

                : p_items_serviced_within_LOS      IN     NUMBER           Optional
                        Default = NULL
                        Number of items serviced within LOS constraints for this media
                        type.

                : p_items_not_serv_within_LOS      IN     NUMBER           Optional
                        Default = NULL
                        Number of items not serviced within LOS constraints for this
                        media type.

                : p_number_agents_working          IN     NUMBER           Optional
                        Default = NULL
                        Number of agents currently working items of this media type.

                : p_minimum_agents_required        IN     NUMBER           Optional
                        Default = NULL
                        Minimum number of agents required by LOS category.

                : p_items_left_to_be_serviced      IN     NUMBER           Optional
                        Default = NULL
                        Number of items left to be serviced for an outbound LOS
                        category quota.

                : p_items_serviced_today           IN     NUMBER           Optional
                        Default = NULL
                        Number of items serviced, cumulative for today.

Version         : Current Version 1.0
                  Previous Version n/a
                  Initial Version 1.0

end of comments */

PROCEDURE Interaction_Blending_Input
(    p_api_version                    IN     NUMBER,
     p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
     p_commit                         IN     VARCHAR2        := FND_API.G_FALSE,
     p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                  OUT nocopy   VARCHAR2,
     x_msg_count                      OUT nocopy   NUMBER,
     x_msg_data                       OUT nocopy   VARCHAR2,

     p_time                           IN     DATE            := NULL,

     p_site_id                        IN     NUMBER          := NULL,
     p_site_name                      IN     VARCHAR2        := NULL,
     p_media_type_id                  IN     NUMBER          := NULL,
     p_media_type                     IN     VARCHAR2        := NULL,
     p_los_id                         IN     NUMBER          := NULL,
     p_los_name                       IN     VARCHAR2        := NULL,

     p_direction                      IN     NUMBER          := NULL,

     p_items_queued_count             IN     NUMBER          := NULL,
     p_items_serviced_count           IN     NUMBER          := NULL,
     p_items_serviced_within_LOS      IN     NUMBER          := NULL,
     p_items_not_serv_within_LOS      IN     NUMBER          := NULL,
     p_number_agents_working          IN     NUMBER          := NULL,
     p_minimum_agents_required        IN     NUMBER          := NULL,

     p_items_left_to_be_serviced      IN     NUMBER          := NULL,
     p_items_serviced_today           IN     NUMBER          := NULL
);

/* ************************************************** */


/* start of comments
                Record data for a Multi Channel Manager (time, interaction classification)
                tuple combination.
Api name        : Multi_Channel_Manager_Input
Type            : Public
Pre-regs        : None
Function        : Record data to ICI Multi Channel Manager table
Parameters      :
                :p_api_version                     IN     NUMBER           Required
                        Used by the API to compare the version numbers of incoming
                        calls to its current version number, returns an unexpected error
                        if they are incompatible.

                :p_init_msg_list                   IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        The API message list must be initialized every time a program
                        calls an API.

                :p_commit                          IN     VARCHAR2         Optional
                        Default = FND_API.G_FALSE
                        Before returning to its caller, an API should check the value
                        of p_commit.  If it is set to TRUE it should commit its work.

                :p_validation_level                IN     NUMBER           Optional
                        Default = FND_API.G_VALID_LEVEL_FULL
                        Determins which validation steps should be executed and which
                        should be skipped.  Public APIs by definition have to perform FULL
                        validation on all the data passed to them

                : x_return_status                  OUT    VARCHAR2
                        Returns the result of all operations performed by the API

                : x_msg_count                      OUT    NUMBER
                        Holds the number of messages in the API message list.

                : x_msg_data                       OUT    VARCHAR2
                        Holds the message in an encoded format.

                : p_time                           IN     DATE             Optional
                        Default = NULL
                        The time, to the minute, for this data. Input will be truncated
                        to the minute, and the data must be for the minute {yyyy-mon-dd
                        hh:mm:00.0} to {yyyy-mon-dd hh:mm:59.9}, local to the advanced
                        outbound server.

                : p_interaction_center_id          IN     NUMBER           Optional
                        Default = NULL
                        ID of the interaction center. This is an index to the interaction
                        center definition table.

                : p_interaction_center_name        IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the interaction center.

                : p_interaction_class_id           IN     NUMBER           Optional
                        Default = NULL
                        ID of the interaction classification. This is an index to the
                        interaction classification definition table.

                : p_interaction_class_name         IN     VARCHAR2         Optional
                        Default = NULL
                        Name of the interaction classification.

                : p_interactions_received          IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions received this minute.

                : p_interactions_offered           IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions offered to agents this minute.

                : p_interactions_answered          IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions answered by agents this minute.

                : p_interactions_transferred       IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions transferred this minute.

                : p_interactions_handled           IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions handled (by agents or automation) this minute.

                : p_interactions_abandoned         IN     NUMBER           Optional
                        Default = NULL
                        Number of interactions abandoned this minute. Technically,
                        abandoned calls are not interactions.

                : p_speed_to_answer_avg            IN     NUMBER           Optional
                        Default = NULL
                        Average speed to answer a call this minute. In seconds.
                        = p_speed_to_answer_total / p_interactions_answered

                : p_speed_to_answer_std_dev        IN     NUMBER           Optional
                        Default = NULL
                        Standard deviation for average speed to answer.

                : p_speed_to_answer_total          IN     NUMBER           Optional
                        Default = NULL
                        Total speed to answer time, in seconds.

                : p_wait_to_abandon_avg            IN     NUMBER           Optional
                        Default = NULL
                        Average wait to abandon a call this minute. In seconds.
                        = p_wait_to_abandon_total / p_interactions_abandoned

                : p_wait_to_abandon_std_dev        IN     NUMBER           Optional
                        Default = NULL
                        Standard deviation for average wait to abandon.

                : p_wait_to_abandon_total          IN     NUMBER           Optional
                        Default = NULL
                        Total wait to abandon, in seconds.

                : p_percent_occupancy_rate         IN     NUMBER           Optional
                        Default = NULL
                        0.0 <= percent <= 1.0
                        = p_total_talk_time / (p_total_talk_time + p_total_idle_time)

                : p_percent_utilization_rate       IN     NUMBER           Optional
                        Default = NULL
                        0.0 <= percent <= 1.0
                        = (p_total_talk_time + p_total_idle_time) / p_total_log_time

                : p_percent_transfer_rate          IN     NUMBER           Optional
                        Default = NULL
                        0.0 <= percent <= 1.0
                        = p_interactions_transferred  / p_interactions_answered

                : p_total_talk_time                IN     NUMBER           Optional
                        Default = NULL
                        Total talk time in seconds.

                : p_total_hold_time                IN     NUMBER           Optional
                        Default = NULL
                        Total hold time in seconds.

                : p_total_idle_time                IN     NUMBER           Optional
                        Default = NULL
                        Total idle time in seconds.

                : p_total_wrap_time                IN     NUMBER           Optional
                        Default = NULL
                        Total wrap time in seconds.

                : p_total_log_time                 IN     NUMBER           Optional
                        Default = NULL
                        Total log time in seconds.

Version         : Current Version 1.0
                  Previous Version n/a
                  Initial Version 1.0

end of comments */

PROCEDURE Multi_Channel_Manager_Input
(    p_api_version                    IN     NUMBER,
     p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
     p_commit                         IN     VARCHAR2        := FND_API.G_FALSE,
     p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
     x_return_status                  OUT nocopy   VARCHAR2,
     x_msg_count                      OUT nocopy   NUMBER,
     x_msg_data                       OUT nocopy   VARCHAR2,

     p_time                           IN     DATE            := NULL,

     p_interaction_center_id          IN     NUMBER          := NULL,
     p_interaction_center_name        IN     VARCHAR2        := NULL,
     p_interaction_class_id           IN     NUMBER          := NULL,
     p_interaction_class_name         IN     VARCHAR2        := NULL,

     p_interactions_received          IN     NUMBER          := NULL,
     p_interactions_offered           IN     NUMBER          := NULL,
     p_interactions_answered          IN     NUMBER          := NULL,
     p_interactions_transferred       IN     NUMBER          := NULL,
     p_interactions_handled           IN     NUMBER          := NULL,
     p_interactions_abandoned         IN     NUMBER          := NULL,

     p_speed_to_answer_avg            IN     NUMBER          := NULL,
     p_speed_to_answer_std_dev        IN     NUMBER          := NULL,
     p_speed_to_answer_total          IN     NUMBER          := NULL,

     p_wait_to_abandon_avg            IN     NUMBER          := NULL,
     p_wait_to_abandon_std_dev        IN     NUMBER          := NULL,
     p_wait_to_abandon_total          IN     NUMBER          := NULL,

     p_percent_occupancy_rate         IN     NUMBER          := NULL,
     p_percent_utilization_rate       IN     NUMBER          := NULL,
     p_percent_transfer_rate          IN     NUMBER          := NULL,

     p_total_talk_time                IN     NUMBER          := NULL,
     p_total_hold_time                IN     NUMBER          := NULL,
     p_total_idle_time                IN     NUMBER          := NULL,
     p_total_wrap_time                IN     NUMBER          := NULL,
     p_total_log_time                 IN     NUMBER          := NULL
);

End CCT_ServerDataInput_PUB;

 

/
