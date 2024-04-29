--------------------------------------------------------
--  DDL for Package Body CCT_SERVERDATAINPUT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_SERVERDATAINPUT_PUB" AS
/* $Header: ccticiib.pls 120.0 2005/06/02 09:29:53 appldev noship $ */

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
                        minute. This number includes p_number_agents_predictive.

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
) IS

l_api_name      CONSTANT VARCHAR2(30)   := 'Advanced_Outbound_Input';
l_api_version   CONSTANT NUMBER         := 1.0;
l_encoded                VARCHAR2(1)    := FND_API.G_FALSE;

l_site_id                NUMBER         := -1;
l_campaign_id            NUMBER         := -1;
l_list_id                NUMBER         := -1;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Advanced_Outbound_Input_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    -- Initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Insert record if p_time is given
    BEGIN
        IF p_time IS NOT NULL
        THEN
            -- Check p_site_id for valid value
            IF p_site_id IS NOT NULL
            THEN
                l_site_id := p_site_id;
            ELSIF p_site_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR server_group_id_cur (v_site_name IN VARCHAR2)
                    IS
                        SELECT server_group_id
                          FROM ieo_svr_groups
                         WHERE UPPER (group_name) = UPPER (v_site_name)
                         ORDER BY server_group_id;
                BEGIN
                    OPEN server_group_id_cur (p_site_name);
                    FETCH server_group_id_cur INTO l_site_id;
                    CLOSE server_group_id_cur;
                END;
            END IF;

            -- Check p_campaign_id for valid value
            IF p_campaign_id IS NOT NULL
            THEN
                l_campaign_id := p_campaign_id;
            ELSIF p_campaign_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR campaign_id_cur (v_campaign_name IN VARCHAR2)
                    IS
                        SELECT campaign_id
                          FROM ams_campaigns_all_tl
                         WHERE UPPER (campaign_name) = UPPER (v_campaign_name)
                         ORDER BY campaign_id;
                BEGIN
                    OPEN campaign_id_cur (p_campaign_name);
                    FETCH campaign_id_cur INTO l_campaign_id;
                    CLOSE campaign_id_cur;
                END;
            END IF;

            -- Check p_list_id for valid value
            IF p_list_id IS NOT NULL
            THEN
                l_list_id := p_list_id;
            ELSIF p_list_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR list_header_id_cur (v_list_name IN VARCHAR2)
                    IS
                        SELECT list_header_id
                          FROM ams_list_headers_all
                         WHERE UPPER (list_name) = UPPER (v_list_name)
                         ORDER BY list_header_id;
                BEGIN
                    OPEN list_header_id_cur (p_list_name);
                    FETCH list_header_id_cur INTO l_list_id;
                    CLOSE list_header_id_cur;
                END;
            END IF;

            INSERT INTO bix_server_cp
                  (server_cp_id, minute, site_id, campaign_id, list_id,
                   busy_counts, connect_counts, answering_machine_counts,
                   modem_counts, sit_counts, rna_counts, other_counts,
                   predictive_dials, progressive_dials, preview_dials,
                   preview_time, withdrawn_dials,
                   average_wait_time, std_dev_wait_time,
                   average_cumulative_wait_time, std_dev_cumulative_wait_time,
                   minimum_wait_time, maximum_wait_time, total_wait_time,
                   number_agents_predictive, number_agents_outbound,
                   number_working_dialers, number_abandons, abandon_percentage,
                   number_callbacks, callback_percentage, dials_per_minute,
                   number_calls_outcome_1, number_calls_outcome_2,
                   number_calls_outcome_3,
                   number_records_start_of_day, number_records_remaining,
                   predicted_exhaustion_date, num_recs_to_be_released_next_1,
                   num_rec_to_be_released_next_5, num_rec_to_be_released_next_15,
                   num_rec_to_be_released_next_60)
            SELECT bix_server_cp_s.nextval,  trunc (p_time, 'MI'), l_site_id,
                   l_campaign_id, l_list_id,
                   p_busy_count, p_connect_count, p_answering_machine_count,
                   p_modem_count, p_sit_count, p_rna_count, p_other_count,
                   p_predictive_dials, p_progressive_dials, p_preview_dials,
                   p_preview_time, p_withdrawn_dials,
                   p_wait_time_average, p_wait_time_std_dev,
                   p_wait_time_cumulative_avg, p_wait_time_cumulative_stddev,
                   p_wait_time_minimum, p_wait_time_maximum, p_wait_time_total,
                   p_number_agents_predictive, p_number_agents_outbound,
                   p_number_working_dialers, p_abandon_count, p_abandon_percentage,
                   p_callback_count, p_callback_percentage,
                   p_predictive_dials + p_progressive_dials + p_preview_dials,
                   p_outcome_1_count, p_outcome_2_count, p_outcome_3_count,
                   p_records_start_of_day, p_records_remaining,
                   p_predicted_exhaustion_date,
                   p_recs_to_be_released_in_1, p_recs_to_be_released_in_5,
                   p_recs_to_be_released_in_15, p_recs_to_be_released_in_60
              FROM dual;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_AO_IN_INSERT_ERROR');
                FND_MSG_PUB.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Signify Success
    IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_AO_IN_RECORD_INSERTED');
        FND_MSG_PUB.Add;
    END IF;

    -- End of API body

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Advanced_Outbound_Input_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Advanced_Outbound_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN OTHERS THEN
            ROLLBACK TO Advanced_Outbound_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF     FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

            THEN
                   FND_MSG_PUB.Add_Exc_Msg
                   (      p_pkg_name            => G_PKG_NAME,
                          p_procedure_name      => l_api_name,
                          p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
                   );
            END IF;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

END Advanced_Outbound_Input;

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
) IS

l_api_name      CONSTANT VARCHAR2(30)   := 'Interaction_Blending_Input';
l_api_version   CONSTANT NUMBER         := 1.0;
l_encoded                VARCHAR2(1)    := FND_API.G_FALSE;

l_site_id                NUMBER         := -1;
l_media_type             VARCHAR2(240)  := '';
l_los_id                 NUMBER         := -1;

l_items_serviced_within_LOS NUMBER      := p_items_serviced_within_LOS;
l_items_not_serv_within_LOS NUMBER      := p_items_not_serv_within_LOS;
l_quota                  NUMBER         := 0;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Interaction_Blending_Input_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    -- Initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Insert record if p_time is given
    BEGIN
        IF p_time IS NOT NULL
        THEN
            -- Check p_site_id for valid value
            IF p_site_id IS NOT NULL
            THEN
                l_site_id := p_site_id;
            ELSIF p_site_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR server_group_id_cur (v_site_name IN VARCHAR2)
                    IS
                        SELECT server_group_id
                          FROM ieo_svr_groups
                         WHERE UPPER (group_name) = UPPER (v_site_name)
                         ORDER BY server_group_id;
                BEGIN
                    OPEN server_group_id_cur (p_site_name);
                    FETCH server_group_id_cur INTO l_site_id;
                    CLOSE server_group_id_cur;
                END;
            END IF;

            -- Check p_media_type for valid value
            -- Note that there is no media type table so p_media_type_id
            -- is meaningless. Still, if it's given we can use it instead
            -- of leaving the media type blank.
            IF p_media_type IS NOT NULL
            THEN
                l_media_type := p_media_type;
            ELSIF p_media_type_id IS NOT NULL
            THEN
                l_media_type := p_media_type_id;
            END IF;

            -- Check p_los_id for valid value
            IF p_los_id IS NOT NULL
            THEN
                l_los_id := p_los_id;
            ELSIF p_los_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR wbsc_id_cur (v_los_name IN VARCHAR2)
                    IS
                        SELECT wbsc_id
                          FROM ieb_wb_svc_cats
                         WHERE UPPER (service_category_name) = UPPER (v_los_name)
                         ORDER BY wbsc_id;
                BEGIN
                    OPEN wbsc_id_cur (p_los_name);
                    FETCH wbsc_id_cur INTO l_los_id;
                    CLOSE wbsc_id_cur;
                END;
            END IF;

            -- 20000814 kcwong
            -- For Inbound LOS, p_items_serviced_within_LOS and
            --   p_items_not_serv_within_los are valid, so the corresponding
            --   local variables are already set.
            -- For Outbound LOS, we have to calculate the pseudo values.

            -- This is a stupid hack and I'll probably go to Hell for this.
            -- Outbound LOS only gives us p_items_serviced_count, and a quota
            -- in another table. I have to map those into items_serviced and
            -- items_not_serv so that the work blending report works for
            -- both LOS types.

            IF p_direction = 0
            THEN
                -- Look for a specific day (and time) quota
                DECLARE
                    CURSOR quota_cur (v_los_id NUMBER, v_time IN DATE)
                    IS
                        SELECT covs.quota
                          FROM ieb_outb_svc_coverages covs,
                               ieb_service_plans plan,
                               ieb_wb_svc_cats cats
                         WHERE cats.wbsc_id = v_los_id
                           AND cats.svcpln_svcpln_id = plan.svcpln_id
                           AND covs.svcpln_svcpln_id = plan.svcpln_id
                            -- Get weekday match (for regular) or date match (for specific)
                           AND (covs.regular_schd_day = (TO_NUMBER (TO_CHAR (v_time, 'd')) - 1)
                               OR TRUNC (covs.spec_schd_date, 'dd') = TRUNC (v_time, 'dd'))
                           AND covs.begin_time_hhmm <= TO_NUMBER (TO_CHAR (v_time, 'hh24mi'))
                           AND covs.end_time_hhmm >= TO_NUMBER (TO_CHAR (v_time, 'hh24mi'))
                            -- will get two records if there is a specific match
                         ORDER BY schedule_type DESC;
                BEGIN
                    OPEN quota_cur (l_los_id, p_time);
                    FETCH quota_cur INTO l_quota;
                    CLOSE quota_cur;
                END;

                l_items_serviced_within_LOS := p_items_serviced_count;
                l_items_not_serv_within_LOS := (l_quota / 60.0) - p_items_serviced_count;
            END IF;
            -- 20000814 kcwong End

            INSERT INTO bix_server_ib
                  (server_ib_id, minute, site_id, media_item_type,
                   los_category_id, los_category_direction,
                   number_of_items_queued, number_of_items_serviced,
                   items_serviced_within_los, items_not_serviced_within_los,
                   number_agents_working, minimum_number_of_agents_req,
                   items_left_to_be_serviced, items_serviced_today)
            SELECT bix_server_ib_s.nextval, trunc (p_time, 'MI'), l_site_id,
                   l_media_type, l_los_id, p_direction,
                   p_items_queued_count, p_items_serviced_count,
                   l_items_serviced_within_LOS, l_items_not_serv_within_LOS,
                   p_number_agents_working, p_minimum_agents_required,
                   p_items_left_to_be_serviced, p_items_serviced_today
              FROM dual;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_IB_IN_INSERT_ERROR');
                FND_MSG_PUB.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Signify Success
    IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_IB_IN_RECORD_INSERTED');
        FND_MSG_PUB.Add;
    END IF;

    -- End of API body

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO Interaction_Blending_Input_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO Interaction_Blending_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN OTHERS THEN
            ROLLBACK TO Interaction_Blending_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF     FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

            THEN
                   FND_MSG_PUB.Add_Exc_Msg
                   (      p_pkg_name            => G_PKG_NAME,
                          p_procedure_name      => l_api_name,
                          p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
                   );
            END IF;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

END Interaction_Blending_Input;

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
     x_return_status                  OUT  nocopy  VARCHAR2,
     x_msg_count                      OUT  nocopy  NUMBER,
     x_msg_data                       OUT  nocopy  VARCHAR2,

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
) IS

l_api_name      CONSTANT VARCHAR2(30)   := 'Multi_Channel_Manager_Input';
l_api_version   CONSTANT NUMBER         := 1.0;
l_encoded                VARCHAR2(1)    := FND_API.G_FALSE;

l_interaction_center_id  NUMBER         := -1;
l_interaction_class_name VARCHAR2(240)  := '';

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   MCM_Input_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call  ( l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean( p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
    END IF;

    -- Initialize the API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body

    -- Insert record if p_time is given
    BEGIN
        IF p_time IS NOT NULL
        THEN
            -- Check p_interaction_center_id for valid value
            IF p_interaction_center_id IS NOT NULL
            THEN
                l_interaction_center_id := p_interaction_center_id;
            ELSIF p_interaction_center_name IS NOT NULL
            THEN
                DECLARE
                    CURSOR server_group_id_cur (v_interaction_center_name IN VARCHAR2)
                    IS
                        SELECT server_group_id
                          FROM ieo_svr_groups
                         WHERE UPPER (group_name) = UPPER (v_interaction_center_name)
                         ORDER BY server_group_id;
                BEGIN
                    OPEN server_group_id_cur (p_interaction_center_name);
                    FETCH server_group_id_cur INTO l_interaction_center_id;
                    CLOSE server_group_id_cur;
                END;
            END IF;

            -- Check p_interaction_class_name for valid value
            IF p_interaction_class_name IS NOT NULL
            THEN
                l_interaction_class_name := p_interaction_class_name;
            ELSIF p_interaction_class_id IS NOT NULL
            THEN
                DECLARE
                    CURSOR classification_cur (v_interaction_class_id IN NUMBER)
                    IS
                        SELECT classification
                          FROM cct_classifications
                         WHERE classification_id = v_interaction_class_id
                         ORDER BY classification;
                BEGIN
                    OPEN classification_cur (p_interaction_class_id);
                    FETCH classification_cur INTO l_interaction_class_name;
                    CLOSE classification_cur;
                END;
            END IF;

            INSERT INTO bix_server_mcm
                  (server_mcm_id, minute,
                   interaction_center_id, interaction_classification,
                   interactions_received, interactions_offered,
                   interactions_answered, interactions_transferred,
                   interactions_handled, interactions_abandoned,
                   average_speed_to_answer, std_dev_speed_to_answer,
                   total_speed_to_answer,
                   average_wait_to_abandoned, std_dev_wait_to_abandoned,
                   total_wait_to_abandoned,
                   percent_occupancy_rate, percent_utilization_rate,
                   percent_transfer_rate,
                   talk_time, hold_time, idle_time, wrap_time, log_time)
            SELECT bix_server_cp_s.nextval, trunc (p_time, 'MI'),
                   l_interaction_center_id, l_interaction_class_name,
                   p_interactions_received, p_interactions_offered,
                   p_interactions_answered, p_interactions_transferred,
                   p_interactions_handled, p_interactions_abandoned,
                   p_speed_to_answer_avg, p_speed_to_answer_std_dev,
                   p_speed_to_answer_total,
                   p_wait_to_abandon_avg, p_wait_to_abandon_std_dev,
                   p_wait_to_abandon_total,
                   p_percent_occupancy_rate, p_percent_utilization_rate,
                   p_percent_transfer_rate,
                   p_total_talk_time, p_total_hold_time, p_total_idle_time,
                   p_total_wrap_time, p_total_log_time
              FROM dual;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_MCM_IN_INSERT_ERROR');
                FND_MSG_PUB.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;
    END;

    -- Signify Success
    IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
        FND_MESSAGE.SET_NAME('CCT', 'CCT_SDI_MCM_IN_RECORD_INSERTED');
        FND_MSG_PUB.Add;
    END IF;

    -- End of API body

    -- Standard check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO MCM_Input_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO MCM_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

    WHEN OTHERS THEN
            ROLLBACK TO MCM_Input_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            IF     FND_MSG_PUB.Check_Msg_Level
                   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)

            THEN
                   FND_MSG_PUB.Add_Exc_Msg
                   (      p_pkg_name            => G_PKG_NAME,
                          p_procedure_name      => l_api_name,
                          p_error_text          => 'G_MSG_LVL_UNEXP_ERROR'
                   );
            END IF;

            FND_MSG_PUB.Count_And_Get
                    (   p_encoded       =>      l_encoded,
                        p_count         =>      x_msg_count,
                        p_data          =>      x_msg_data
                    );

END Multi_Channel_Manager_Input;

END CCT_ServerDataInput_PUB;

/
