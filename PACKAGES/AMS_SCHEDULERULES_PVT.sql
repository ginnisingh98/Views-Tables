--------------------------------------------------------
--  DDL for Package AMS_SCHEDULERULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCHEDULERULES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvsbrs.pls 120.5 2006/03/08 01:34:16 anchaudh ship $ */

--========================================================================
-- PROCEDURE
--    Handle_Status
-- Purpose
--    Created to get the system status code for the user status id
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--
--========================================================================
PROCEDURE Handle_Status(
   p_user_status_id    IN     NUMBER,
   p_sys_status_code   IN     VARCHAR2,
   x_status_code       OUT NOCOPY    VARCHAR2,
   x_return_status     OUT NOCOPY    VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Handle_Schedule_Source_Code
-- Purpose
--    Created to get the source code for the schedules.
-- HISTORY
--    30-Jan-2000   ptendulk    Created.
--
--========================================================================
PROCEDURE Handle_Schedule_Source_Code(
   p_source_code    IN  VARCHAR2,
   p_camp_id        IN  NUMBER,
   p_setup_id       IN  NUMBER,
   p_cascade_flag   IN  VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Push_Source_Code
-- Purpose
--    Created to push the source code for the schedule
--    after the schedule is created.
--
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--
--========================================================================
PROCEDURE Push_Source_Code(
           p_source_code    IN  VARCHAR2,
           p_arc_object     IN  VARCHAR2,
           p_object_id      IN  NUMBER,
           p_related_source_code    IN    VARCHAR2 := NULL,
           p_related_source_object  IN    VARCHAR2 := NULL,
           p_related_source_id      IN    NUMBER   := NULL
) ;

--========================================================================
-- PROCEDURE
--    Check_Source_Code
--
-- Purpose
--    Created to check the source code for the schedule before updation
--
-- HISTORY
--    19-Jan-2000   ptendulk    Created.
--    13-dec-2001   soagrawa    added parameter x_source_code
--========================================================================
PROCEDURE Check_Source_Code(
   p_schedule_rec   IN  AMS_Camp_Schedule_PVT.schedule_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_source_code    OUT NOCOPY VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Check_Sched_Dates_Vs_Camp
--
-- Purpose
--    Created to check if the schedules start and end date are within
--    campaigns start date and end date.
--
-- HISTORY
--    02-Feb-2001   ptendulk    Created.

--========================================================================
PROCEDURE Check_Sched_Dates_Vs_Camp(
   p_campaign_id    IN  NUMBER,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE,
   x_return_status  OUT NOCOPY VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Check_Schedule_Update
--
-- Purpose
--    Created to check if the user can update the schedule details
--    It also checks for the locked columns and if user tries to update
--    API will be errored out.
--
-- HISTORY
--    13-Feb-2001   ptendulk    Created.

--========================================================================
PROCEDURE Check_Schedule_Update(
   p_schedule_rec    IN   AMS_Camp_Schedule_PVT.schedule_rec_type,
   x_return_status   OUT NOCOPY  VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Check_Schedule_Activity
--
-- PURPOSE
--    This api is created to validate the activity type , activity
--    and marketing medium attached to the schedule.
--
-- HISTORY
--  13-Feb-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Check_Schedule_Activity(
   p_schedule_id       IN  NUMBER,
   p_activity_type     IN  VARCHAR2,
   p_activity_id       IN  NUMBER,
   p_medium_id         IN  NUMBER,
   p_arc_channel_from  IN  VARCHAR2,
   p_status_code       IN  VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2
) ;

--========================================================================
-- PROCEDURE
--    Activate_Schedule
--
-- PURPOSE
--    This api is created to be used by concurrent program to activate
--    schedules. It will internally call the Activate schedules api to
--    activate the schedule.

--
-- HISTORY
--  17-Mar-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Activate_Schedule
               (errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    NUMBER) ;

--========================================================================
-- PROCEDURE
--    Update_Schedule_Status
--
-- PURPOSE
--    This api is created to be used for schedule status changes.
--
-- HISTORY
--  28-Mar-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Update_Schedule_Status(
   p_schedule_id      IN  NUMBER,
   p_campaign_id      IN  NUMBER,
   p_user_status_id   IN  NUMBER,
   p_budget_amount    IN  NUMBER,
   p_asn_group_id     IN  VARCHAR2 DEFAULT NULL -- anchaudh added for leads bug.
);

--========================================================================
-- PROCEDURE
--    Create_list
--
-- PURPOSE
--    This api is called after the creation of the Direct marketing schedules
--    to create the default target group for the schedule. User can go to the
--    target group screen to modify the details.
--
-- NOTE
--    The list of Type Target is created in list header and the association is
--    created in the ams_act_lists table.
--
-- HISTORY
--  18-May-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Create_list
               (p_schedule_id     IN     NUMBER,
                p_schedule_name   IN     VARCHAR2,
                p_owner_id        IN     NUMBER) ;


--========================================================================
-- PROCEDURE
--    Create_Schedule_Access
--
-- PURPOSE
--    This api is called in Create schedule api to give the access for
--    schedule to the team members of the campaign.
--
-- NOTE
--
-- HISTORY
--  11-Sep-2001    ptendulk    Created.
--
--========================================================================
PROCEDURE Create_Schedule_Access(p_schedule_id        IN NUMBER,
                                 p_campaign_id        IN NUMBER,
                                 p_owner_id           IN NUMBER,
                                 p_init_msg_list      IN VARCHAR2,
                                 p_commit             IN VARCHAR2,
                                 p_validation_level   IN NUMBER,

                                 x_return_status     OUT NOCOPY VARCHAR2,
                                 x_msg_count         OUT NOCOPY NUMBER,
                                 x_msg_data          OUT NOCOPY VARCHAR2
                                 );


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

PROCEDURE update_status(         p_schedule_id             IN NUMBER,
                                 p_new_status_id           IN NUMBER,
                                 p_new_status_code         IN VARCHAR2,
				 p_asn_group_id            IN VARCHAR2 DEFAULT NULL -- anchaudh added for leads bug.
                                 );

--========================================================================
-- PROCEDURE
--    target_group_exist
--
-- NOTE
--
-- HISTORY
--  31-jan-2002    soagrawa    Modified signature and added to specs
--
--========================================================================

FUNCTION Target_Group_Exist (p_schedule_id IN NUMBER
                             , p_obj_type IN VARCHAR2 :='CSCH')
RETURN VARCHAR2;


--========================================================================
-- PROCEDURE
--    write_interaction
--
-- NOTE
--
-- HISTORY
--  12-mar-2002    soagrawa    Created.
--
--========================================================================

PROCEDURE write_interaction(
               p_schedule_id               IN     NUMBER
               );



--=====================================================================
-- PROCEDURE
--    Update_Schedule_Owner
--
-- PURPOSE
--    The api is created to update the owner of the schedule from the
--    access table if the owner is changed in update.
--
-- HISTORY
--    06-Jun-2002  soagrawa    Created. Refer to bug# 2406677
--=====================================================================
PROCEDURE Update_Schedule_Owner(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_object_type       IN  VARCHAR2 := NULL ,
   p_schedule_id       IN  NUMBER,
   p_owner_id          IN  NUMBER   );


--=====================================================================
-- PROCEDURE
--    Init_Schedule_val
--
-- PURPOSE
--    This api will be used by schedule execution workflow to initialize the schedule
--    parameter values.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Init_Schedule_val(itemtype    IN     VARCHAR2,
                            itemkey     IN     VARCHAR2,
                            actid       IN     NUMBER,
                            funcmode    IN     VARCHAR2,
                            result      OUT NOCOPY    VARCHAR2);

--=====================================================================
-- PROCEDURE
--    Check_Schedule_Status
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check schedule status
--    The schedule can be in available or active status. if the schedule is available
--    workflow will update the status to active.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_Schedule_Status(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2);

--=====================================================================
-- PROCEDURE
--    Update_Schedule_Status
--
-- PURPOSE
--    This api will be used by schedule execution workflow to update schedule status
--    It will update the schedule status to Active.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Update_Schedule_Status(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT  NOCOPY   VARCHAR2);

--=====================================================================
-- PROCEDURE
--    Check_Schedule_Act_Type
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check schedule activity
--    Based on the activity type different apis will be called.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_Schedule_Act_Type(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2) ;

--=====================================================================
-- PROCEDURE
--    Execute_Direct_Marketing
--
-- PURPOSE
--    This api will be used by schedule execution workflow to execute schedule
--    of type Direct Marketing
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Execute_Direct_Marketing(itemtype  IN     VARCHAR2,
                                itemkey      IN     VARCHAR2,
                                actid        IN     NUMBER,
                                funcmode     IN     VARCHAR2,
                                result       OUT NOCOPY    VARCHAR2) ;

--=====================================================================
-- PROCEDURE
--    Execute_Sales
--
-- PURPOSE
--    This api will be used by schedule execution workflow to execute schedule
--    of type Sales
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Execute_Sales(itemtype     IN     VARCHAR2,
                        itemkey      IN     VARCHAR2,
                        actid        IN     NUMBER,
                        funcmode     IN     VARCHAR2,
                        result       OUT NOCOPY    VARCHAR2) ;


--=====================================================================
-- PROCEDURE
--    generate_leads
--
-- PURPOSE
--    This api will be used by schedule execution workflow generate leads.
--
-- HISTORY
--    08-Sep-2003  asaha       Created.
--=====================================================================
PROCEDURE generate_leads(
   p_obj_id  IN NUMBER,
   p_obj_type  IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2,
   itemtype     IN     VARCHAR2,--anchaudh changed the signature of this api for the leads bug.
   itemkey      IN     VARCHAR2);--anchaudh changed the signature of this api for the leads bug.

--=====================================================================
-- PROCEDURE
--    Check_WF_Error
--
-- PURPOSE
--    This api will be used by schedule execution workflow to check error
--    The api will check the error flag and based on the value, the error
--    notifications will be sent to schedule owner.
--
-- HISTORY
--    23-Aug-2003  ptendulk       Created.
--    19-Sep-2003  dbiswas        Added nocopy
--=====================================================================
PROCEDURE Check_WF_Error(itemtype    IN     VARCHAR2,
                         itemkey     IN     VARCHAR2,
                         actid       IN     NUMBER,
                         funcmode    IN     VARCHAR2,
                         result      OUT NOCOPY   VARCHAR2);


--=====================================================================
-- Procedure
--    WF_REPEAT_INIT_VAR
--
-- PURPOSE
--    This api is used by scheduler workflow to initialize the attributes
--    Returns the processId information in the schedules table
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE Wf_Repeat_Init_var(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2);

--=====================================================================
-- Procedure
--    WF_REPEAT_CHECK_EXECUTE
--
-- PURPOSE
--    This api is used by scheduler workflow to check if the schedule
--    should execute or not based on status and dates
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE Wf_Repeat_Check_Execute(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2);

--=====================================================================
-- Procedure
--    WF_REPEAT_SCHEDULER
--
-- PURPOSE
--    This api is used by scheduler workflow to check when the next schedule run should be
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE Wf_Repeat_Scheduler(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2);

--=====================================================================
-- Procedure
--    WF_REPEAT_CHECK_CREATE_CSCH
--
-- PURPOSE
--    This api is used by scheduler workflow to check whether to create the next child schedule
--    based on schedule date boundaries. (campaign end date in case parent's end date is null
--
-- HISTORY
--    07-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE WF_REPEAT_CHECK_CREATE_CSCH(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2);

--=====================================================================
-- Procedure
--    WF_REPEAT_CREATE_CSCH
--
-- PURPOSE
--    This api is used by scheduler workflow to create the next child schedule
--
-- HISTORY
--    11-Oct-2003  dbiswas       Created.
--=====================================================================
PROCEDURE WF_REPEAT_CREATE_CSCH(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY   VARCHAR2);

--=====================================================================
-- Procedure
--    WF_REPEAT_RAISE_EVENT
--
-- PURPOSE
--    This api is used by scheduler workflow to raise the event for the next sched run
--
-- HISTORY
--    11-Oct-2003  dbiswas       Created.
--=====================================================================

   PROCEDURE WF_REPEAT_RAISE_EVENT(itemtype    IN     VARCHAR2,
                                   itemkey     IN     VARCHAR2,
                                   actid       IN     NUMBER,
                                   funcmode    IN     VARCHAR2,
                                   result      OUT NOCOPY    VARCHAR2);

--========================================================================
-- PROCEDURE
--    WRITE_LOG
-- Purpose
--   This method will be used to write logs for this api
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================
PROCEDURE WRITE_LOG             ( p_api_name      IN VARCHAR2 := NULL,
                                  p_log_message   IN VARCHAR2  := NULL);


--========================================================================
-- PROCEDURE
--    AMS_SELECTOR
-- Purpose
--   This method will be used as callback API for Workflow
-- HISTORY
--    09-Apr-2004   asaha    Created.
--
--========================================================================
/* Commented for sql rep 14423973. Bug 4956974
PROCEDURE AMS_SELECTOR
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result in OUT NOCOPY varchar2) ;
*/

--========================================================================
-- PROCEDURE
--    RAISE_BE_ON_STATUS_CHANGE
-- Purpose
--   This method will be used to raise business event on UserStatus change
-- HISTORY
--    17-Mar-2005   spendem    Created for enh # 3805347
--
--========================================================================

PROCEDURE RAISE_BE_ON_STATUS_CHANGE(p_obj_id           IN     NUMBER,
                                    p_obj_type         IN     VARCHAR2,
                                    p_old_status_code  IN     VARCHAR2,
                                    p_new_status_code  IN     VARCHAR2);




--========================================================================
-- PROCEDURE
--    validate_activation_rules
-- Purpose
--    Created to validate the activation rules going forward in R12
-- HISTORY
--    27-Jul-2005   anchaudh    Created.
--
--========================================================================
PROCEDURE validate_activation_rules(
   p_scheduleid    IN     NUMBER,
   x_status_code   OUT NOCOPY    VARCHAR2
);



--=================================================================================
-- PROCEDURE
--    collateral_activation_rule
-- Purpose
--    Created to validate the collateral content status before activity activation
-- HISTORY
--    27-Jul-2005   anchaudh    Created.
--
--=================================================================================
PROCEDURE collateral_activation_rule(
   p_scheduleid    IN     NUMBER,
   x_status_code   OUT NOCOPY    VARCHAR2,
   x_msg_count     OUT NOCOPY    NUMBER,
   x_msg_data      OUT NOCOPY    VARCHAR2
);

-------------------------------------------------------------
-- Start of Comments
-- Name
-- HANDLE_COLLATERAL
--
-- Purpose
-- This function is called from Business Event
-------------------------------------------------------------
FUNCTION HANDLE_COLLATERAL(p_subscription_guid   IN       RAW,
                                    p_event               IN OUT NOCOPY  WF_EVENT_T
) RETURN VARCHAR2;

--========================================================================
-- PROCEDURE
--    CHECK_NOTIFICATION_PREFERENCE
-- Purpose
--   This method will be used to check the notification preference for an activity
-- HISTORY
--    08-Aug-2005   srivikri    Created
--
--========================================================================

PROCEDURE CHECK_NOTIFICATION_PREFERENCE(itemtype    IN     VARCHAR2,
                                itemkey     IN     VARCHAR2,
                                actid       IN     NUMBER,
                                funcmode    IN     VARCHAR2,
                                result      OUT NOCOPY    VARCHAR2);


END AMS_ScheduleRules_PVT ;

 

/
