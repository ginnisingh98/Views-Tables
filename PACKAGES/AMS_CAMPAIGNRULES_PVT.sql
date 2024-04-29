--------------------------------------------------------
--  DDL for Package AMS_CAMPAIGNRULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CAMPAIGNRULES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvcbrs.pls 115.36 2004/07/15 21:56:48 asaha ship $ */


-----------------------------------------------------------------------
-- PROCEDURE
--    handle_camp_status
--
-- PURPOSE
--    Validate the campaign status.
--
-- NOTES
--    1. If the user status is not specified, default it;
--       otherwise validate it.
--    2. The system status code will be determined by the user status.
-----------------------------------------------------------------------
PROCEDURE handle_camp_status(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    handle_camp_inherit_flag
--
-- PURPOSE
--    Validate the inherit_attributes_flag.
--
-- NOTES
--    1. The inherit_attributes_flag will be set to 'Y' only for
--       execution campaigns under multi-channel campaigns.
--    2. The parent_campaign_id will be validated if not null, and
--       the rollup_type of the parent campaign will also be checked.
-----------------------------------------------------------------------
PROCEDURE handle_camp_inherit_flag(
   p_parent_id      IN  NUMBER,
   p_rollup_type    IN  VARCHAR2,
   x_inherit_flag   OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    create_camp_association
--
-- PURPOSE
--    Create an object association record when an event is associated
--    to a campaign.
--
-- NOTES
--    1. May need to delete the old association for update.
-----------------------------------------------------------------------
PROCEDURE create_camp_association(
   p_campaign_id       IN  NUMBER,
   p_event_id          IN  NUMBER,
   p_event_type        IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_camp_source_code
--
-- PURPOSE
--    Handle the business rules regarding source code update.
--
-- NOTES
--    1. cascade_source_code_flag cannot be changed if schedules exist.
--    2. When global_flag is updated, a new source code will be
--       generated if source code is not cascaded to existing schedules.
--    3. source_code cannot be updated if it is cascaded to existing
--       schedules.
-----------------------------------------------------------------------
PROCEDURE update_camp_source_code(
   p_campaign_id              IN  NUMBER,
   p_source_code              IN  VARCHAR2,
   p_global_flag              IN  VARCHAR2,
   x_source_code              OUT NOCOPY VARCHAR2,
   p_related_source_object    IN  VARCHAR2 := NULL,
   p_related_source_id        IN  NUMBER   := NULL,
   x_return_status            OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_update
--
-- PURPOSE
--    Check if campaign record can be updated.
--
-- NOTES
--    1. Lock certain fields after available.
-----------------------------------------------------------------------
PROCEDURE check_camp_update(
   p_camp_rec       IN  AMS_Campaign_PVT.camp_rec_type,
   p_complete_rec   IN  AMS_Campaign_PVT.camp_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_template_flag
--
-- PURPOSE
--    Check the rules related to template campaigns.
--
-- NOTES
--    1. Channel is required before SUBMITTED-TA for non-template campaigns.
--    2. Template campaigns can only be associated to template campaigns.
-----------------------------------------------------------------------
PROCEDURE check_camp_template_flag(
   p_parent_id         IN  NUMBER,
   p_channel_id        IN  NUMBER,
   p_template_flag     IN  VARCHAR2,
   p_status_code       IN  VARCHAR2,
   p_rollup_type       IN  VARCHAR2,
   p_media_type        IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_media_type
--
-- PURPOSE
--    Check the columns related to media type.
--
-- NOTES
--    1. For rollup campaigns, media information is optional;
--       for execution campaigns, media information is mandatory.
--    2. Event_type can be defined only when the media type is events.
--    3. Events associated to a campaign cannot be associated to other
--       campaigns.
-----------------------------------------------------------------------
PROCEDURE check_camp_media_type(
   p_campaign_id       IN  NUMBER,
   p_parent_id         IN  NUMBER,
   p_rollup_type       IN  VARCHAR2,
   p_media_type        IN  VARCHAR2,
   p_media_id          IN  NUMBER,
   p_channel_id        IN  NUMBER,
   p_event_type        IN  VARCHAR2,
   p_arc_channel_from  IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_fund_source
--
-- PURPOSE
--    Check campaign fund_source_type and fund_source_id.
--
-- NOTES
--    1. fund_source_type could be 'FUND', 'CAMP', 'EVEH', 'EVEO'.
--    2. fund_source_type can't be null if fund_source_id is provided.
-----------------------------------------------------------------------
PROCEDURE check_camp_fund_source(
   p_fund_source_type  IN  VARCHAR2,
   p_fund_source_id    IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_calendar
--
-- PURPOSE
--    Check campaign_calendar, start_period_name, end_period_name.
--
-- NOTES
--    1. The start date of the start period should be no later than
--       the end date of the end period.
-----------------------------------------------------------------------
PROCEDURE check_camp_calendar(
   p_campaign_calendar   IN  VARCHAR2,
   p_start_period_name   IN  VARCHAR2,
   p_end_period_name     IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_end_date            IN  DATE,
   x_return_status       OUT NOCOPY VARCHAR2
);


-----------------------------------------------------------------------
-- PROCEDURE
--    check_camp_version
--
-- PURPOSE
--    Check the business rules related to campaign_version.
--
-- NOTES
--    1. Pass p_campaign_id as NULL for creating.
-----------------------------------------------------------------------
PROCEDURE check_camp_version(
   p_campaign_id         IN  NUMBER,
   p_campaign_name       IN  VARCHAR2,
   p_status_code         IN  VARCHAR2,
   p_start_date          IN  DATE,
   p_city_id             IN  NUMBER,
   p_version_no          IN  NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_status_vs_parent
--
-- PURPOSE
--    Check campaign status against its parent campaign.
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE check_camp_status_vs_parent(
   p_parent_id              IN  NUMBER,
   p_status_code            IN  VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_parent
--
-- PURPOSE
--    Check campaign dates against its parent campaign.
--
-- NOTES
--    1. The actual_exec_start_date and actual_exec_end_date will
--       be checked. Other dates exist only for upgrade purpose.
--    2. It's part of the inter-record level validation for creating
--       and updating.
--    3. For any error, write the error message to message list,
--       and continue to check others.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_parent(
   p_parent_id      IN  NUMBER,
   p_rollup_type      IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_child
--
-- PURPOSE
--    Validate campaign dates against its sub-campaigns.
--
-- NOTES
--    1. The actual_exec_start_date and actual_exec_end_date will
--       be checked. Other dates exist only for upgrade purpose.
--    2. It's part of the inter-record level validation for updating.
--    3. For any error, write the error message to message list,
--       and continue to check others.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_child(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);

--==============================================================================
-- PROCEDURE
--    Check_BU_Vs_Parent
--
-- PURPOSE
--    Check if the Business unit of campaign/program is same as that of parent
--
-- HISTORY
--    23-May-2001  ptendulk  Created.
--===============================================================================
PROCEDURE Check_BU_Vs_Parent(
   p_program_id            IN  NUMBER,
   p_business_unit_id   IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
) ;

--=====================================================================
-- PROCEDURE
--    Check_BU_Vs_Child
--
-- PURPOSE
--    Check if the Business unit of children is same as that of parent
--
-- HISTORY
--    23-May-2001  ptendulk  Created.
--=====================================================================
PROCEDURE Check_BU_Vs_Child(
   p_camp_id            IN  NUMBER,
   p_business_unit_id   IN  NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2
);
---------------------------------------------------------------------
-- PROCEDURE
--    check_camp_dates_vs_csch
--
-- PURPOSE
--    Check campaign dates against campaign schedule dates.
--
-- NOTES
--    1. The actual_exec_start_date and actual_exec_end_date will
--       be checked. Other dates exist only for upgrade purpose.
--    2. It's part of the inter-record level validation for updating.
--    3. For any error, write the error message to message list,
--       and continue to check others.
---------------------------------------------------------------------
PROCEDURE check_camp_dates_vs_csch(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    handle_csch_source_code
--
-- PURPOSE
--    Check if the schedule source code is valid.
--
-- NOTES
--    1. If the parent campaign has its cascade_source_code_flag set
--       to 'Y', then schedules should use the campaign source code.
--       Otherwise schedules must have their own unique source codes.
---------------------------------------------------------------------
PROCEDURE handle_csch_source_code(
   p_source_code    IN  VARCHAR2,
   p_camp_id        IN  NUMBER,
   x_cascade_flag   OUT NOCOPY VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
);

-- 10/02/2002
-- Commented this proc because this method is not being used any where and it refers to
-- old AMS_CampaignSchedule_PVT which is no more there. Please refer Bug# 2605184
---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_update
--
-- PURPOSE
--    Check if schedule record can be updated.
--
-- NOTES
--    1. Source code can't be updated.
---------------------------------------------------------------------
-- PROCEDURE check_csch_update(
--    p_csch_rec       IN  AMS_CampaignSchedule_PVT.csch_rec_type,
--    x_return_status  OUT VARCHAR2
-- );


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_camp_id
--
-- PURPOSE
--    Check if the schedule can be attached to a campaign.
--
-- NOTES
--    1. Schedules can be attached to execution campaigns only.
--    2. If the campaign media type is 'EVENTS', schedules can not
--       be attached.
---------------------------------------------------------------------
PROCEDURE check_csch_camp_id(
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_deliv_id
--
-- PURPOSE
--    Check the deliverable_id column in ams_campaign_schedules.
--
-- NOTES
--    1. The deliverable used by a campaign schedule has to be one
--       of the deliverables associated to its parent campaign.
---------------------------------------------------------------------
PROCEDURE check_csch_deliv_id(
   p_deliv_id       IN  NUMBER,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_offer_id
--
-- PURPOSE
--    Check the activity_offer_id column in ams_campaign_schedules.
--
-- NOTES
--    1. Schedule can promote an offer from the list of the offers
--       for the campaign found in ams_act_offers table.
---------------------------------------------------------------------
PROCEDURE check_csch_offer_id(
   p_offer_id       IN  NUMBER,
   p_camp_id        IN  NUMBER,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    check_csch_dates_vs_camp
--
-- PURPOSE
--    Check campaign schedule dates against campaign dates.
--
-- NOTES
--    1. The actual_start_date_time and actual_end_date_time will
--       be checked. Others exist only for upgrade purpose.
--    2. It's part of the inter-record level validation for creating
--       and updating schedules.
--    3. For any error, write the error message to message list,
--       and continue to check others.
---------------------------------------------------------------------
PROCEDURE check_csch_dates_vs_camp(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    activate_campaign
--
-- PURPOSE
--    Perform the following tasks when campaigns become active:
--    1. Change the show_campaign_flag of all other versions to 'N'.
---------------------------------------------------------------------
PROCEDURE activate_campaign(
   p_campaign_id    IN  NUMBER
);


-----------------------------------------------------------------------
-- PROCEDURE
--    udpate_camp_status
--
-- PURPOSE
--    Update campaign status through workflow.
-----------------------------------------------------------------------
PROCEDURE update_camp_status(
   p_campaign_id      IN  NUMBER,
   p_user_status_id   IN  NUMBER,
   p_budget_amount    IN  NUMBER,
   p_parent_id        IN  NUMBER
);


---------------------------------------------------------------------
-- PROCEDURE
--    push_source_code
--
-- PURPOSE
--    After creating campaigns or schedules, push the source code
--    into ams_source_codes table.
---------------------------------------------------------------------
PROCEDURE push_source_code(
   p_source_code    IN  VARCHAR2,
   p_arc_object     IN  VARCHAR2,
   p_object_id      IN  NUMBER,
   p_related_source_code    IN    VARCHAR2 := NULL,
   p_related_source_object  IN    VARCHAR2 := NULL,
   p_related_source_id      IN    NUMBER   := NULL
);


-----------------------------------------------------------------------
-- FUNCTION
--    get_parent_media_type
--
-- PURPOSE
--    Used to enforce that all children under a rollup campaign share
--    the same media type if it is specified for the rollup.
-----------------------------------------------------------------------
FUNCTION get_parent_media_type(
   p_parent_id     IN  NUMBER
)
RETURN VARCHAR2;


-----------------------------------------------------------------------
-- FUNCTION
--    check_camp_parent
--
-- PURPOSE
--    Check if a campaign can be the parent of another campaign.
-----------------------------------------------------------------------
FUNCTION check_camp_parent(
   p_camp_id     IN  NUMBER,
   p_parent_id   IN  NUMBER
)
RETURN VARCHAR2;


-----------------------------------------------------------------------
-- FUNCTION
--    check_camp_attribute
--
-- PURPOSE
--    Check if an attribute can be attached to a campaign.
--
-- NOTES
--    1. The valid values for p_attribute are: 'ACCESS', 'ATTACHMENT',
--       'METRIC', 'OFFER', 'PRODUCT', 'SCHEDULE', 'TRIGGER'.
--    2. Raise FND_API.g_exc_error if p_camp_id is invalid.
--    3. Rollup campaigns won't have any attributes except
--       access and metric.
--    4. Execution campaigns under a multi-channel campaign won't
--       have any attributes.
--    5. Only direct marketing campaigns can have triggers.
--    6. If the media type is 'EVENTS', no schedule can be attached.
-----------------------------------------------------------------------
FUNCTION check_camp_attribute(
   p_camp_id     IN  NUMBER,
   p_attribute   IN  VARCHAR2
)
RETURN VARCHAR2;

--=======================================================================
-- PROCEDURE
--    Convert_Camp_Currency
-- NOTES
--    This procedure is created to convert the transaction currency into
--    functional currency.
-- HISTORY
--    09/27/2000    PTENDULK   Created.
--=======================================================================
PROCEDURE Convert_Camp_Currency(
   p_tc_curr     IN    VARCHAR2,
   p_tc_amt      IN    NUMBER,
   x_fc_curr     OUT NOCOPY   VARCHAR2,
   x_fc_amt      OUT NOCOPY   NUMBER
) ;

--=======================================================================
-- PROCEDURE
--    Get_Camp_Child_Count
-- NOTES
--    This function is created to return the child count given a campaign
--    id . It is used to tune Campaign Hierarchy tree.
--
-- HISTORY
--    04-Feb-2001    PTENDULK   Created.
--=======================================================================
FUNCTION Get_Camp_Child_Count(   p_campaign_id IN    VARCHAR2 )
   RETURN NUMBER ;

--=====================================================================
-- PROCEDURE
--    Check_Prog_Dates_Vs_Eveh
--
-- PURPOSE
--    The api is created to check the dates of program vs dates of
--    events. Events dates has to be between program dates.
--
-- HISTORY
--    07-Feb-2001  ptendulk    Created.
--=====================================================================
PROCEDURE Check_Prog_Dates_Vs_Eveh(
   p_camp_id        IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
) ;

--=====================================================================
-- PROCEDURE
--    Update_Owner
--
-- PURPOSE
--    The api is created to update the owner of the campaign from the
--    access table if the owner is changed in update.
--
-- HISTORY
--    04-Mar-2001  ptendulk    Created.
--=====================================================================
PROCEDURE Update_Owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2 := NULL ,
   p_campaign_id       IN  NUMBER,
   p_owner_id          IN  NUMBER   );


-----------------------------------------------------------------------
-- PROCEDURE
--   validate_realted_event
--
-- PURPOSE
--    Validate the realted event. Check the foreign key against the
--    event tables depending on the event_type passed
--
-- NOTES
-- HISTORY
--    12-Apr-2001  rrajesh    Created.
-----------------------------------------------------------------------
PROCEDURE validate_realted_event(
   p_related_event_id      IN  NUMBER,
   p_related_event_type    IN  VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2
);

--=====================================================================
-- PROCEDURE
--    Update_Rollup
--
-- PURPOSE
--    The api is created to update the rollup for the metrics if the
--    parent of the campaign is changed
--
-- HISTORY
--    31-May-2001  ptendulk    Created.
--=====================================================================
PROCEDURE Update_Rollup(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_campaign_id       IN  NUMBER,
   p_parent_id         IN  NUMBER   ) ;


--========================================================================
-- PROCEDURE
--    update_status
--
-- NOTE
--
-- HISTORY
--  02-oct-2001    soagrawa    Created.
--
--========================================================================

PROCEDURE update_status(         p_campaign_id             IN NUMBER,
                                 p_new_status_id           IN NUMBER,
                                 p_new_status_code         IN VARCHAR2
                                 );

--========================================================================
-- Function
--    Get_Event_Source_Code
--
-- PURPOSE
--    Get the source code for the related event associated to the campaign.
--
-- NOTES
-- HISTORY
--    22-May-2001  ptendulk    Created.
--    08-Oct-2001  ptendulk    Modified cursor queries for event offers and one off.
--========================================================================

FUNCTION Get_Event_Source_Code(
   p_event_type      VARCHAR2,
   p_event_id        NUMBER
   ) RETURN VARCHAR2 ;

--========================================================================
-- PROCEDURE
--    Check_Children_Tree
--
-- PURPOSE
--    This api is to check if the hierarchy for the parent child camp is
--    valid. It validates that parent campaign is not one of the
--    childrens of the campaign.
--
-- NOTE
--
-- HISTORY
--  25-Oct-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Check_Children_Tree(p_campaign_id          IN NUMBER,
                              p_parent_campaign_id   IN NUMBER
                                 ) ;
END AMS_CampaignRules_PVT;

 

/
