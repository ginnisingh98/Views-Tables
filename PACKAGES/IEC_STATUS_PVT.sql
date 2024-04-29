--------------------------------------------------------
--  DDL for Package IEC_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: IECOCSTS.pls 120.1 2006/03/28 08:03:37 minwang noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : HANDLE_STATUS_TRANSITIONS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Called by the Status plugin to execute status
--                transitions.
--  Parameters  : P_SERVER_ID     IN      NUMBER        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE HANDLE_STATUS_TRANSITIONS
   ( P_SERVER_ID          IN            NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_Schedule_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Makes call to AMS_CAMP_SCHEDULE_PUB.Update_Camp_Schedule to change the value of the
--                particular schedule's status value.
--
--  Parameters  : p_schedule_id      IN      NUMBER          Required
--                p_status           IN      NUMBER          Required
--                p_user_id          IN      NUMBER          Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_Schedule_Status
   ( p_schedule_id     IN            NUMBER
   , p_status          IN            NUMBER
   , p_user_id         IN            NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_List_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Updates the Advanced Outbound list status, and
--                makes call to AMS_LISTHEADER_PVT.UpdateListheader
--                to update the Marketing list status as well.
--
--  Parameters  : p_list_id      IN      NUMBER          Required
--                p_status       IN      VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_List_Status
   ( p_list_id     IN           NUMBER
   , p_status      IN           VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_List_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Updates the Advanced Outbound list status, and
--                makes call to AMS_LISTHEADER_PVT.UpdateListheader
--                to update the Marketing list status as well.
--                Accepts a parameter p_api_init_flag that is used
--                to flag whether or not a call to a public api
--                initiated the status change (i.e. start purge).
--                In most cases, this flag isn't relevant and the
--                overloaded procedure Update_List_Status that accepts
--                only p_list_id and p_status parameters should be used.
--
--  Parameters  : p_list_id       IN      NUMBER          Required
--                p_status        IN      VARCHAR2        Required
--                p_api_init_flag IN      VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_List_Status
   ( p_list_id       IN NUMBER
   , p_status        IN VARCHAR2
   , p_api_init_flag IN VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Start_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the list status to 'EXECUTING' and update
--                the execution start time.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Start_ListExecution (p_list_id IN NUMBER);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Stop_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the list status to 'LOCKED' and make sure
--                that all entries are checked back into list.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Stop_ListExecution (p_list_id IN NUMBER);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Pause_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the schedule status to 'ON_HOLD'.
--
--  Parameters  : p_schedule_id IN NUMBER
--                p_user_id     IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Pause_ScheduleExecution
   ( p_schedule_id IN NUMBER
   , p_user_id     IN NUMBER
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Clean_ListEntries
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Remove database entries and set the target group status to 'DELETED'.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Clean_ListEntries (p_list_id IN NUMBER);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Stop_ScheduleExecution_Pub
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Called by public api to stop schedule execution.
--
--  Parameters  : p_schedule_id   IN            NUMBER
--                p_commit        IN            BOOLEAN
--                x_return_status    OUT NOCOPY VARCHAR2
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Stop_ScheduleExecution_Pub
   ( p_schedule_id   IN            NUMBER
   , p_commit        IN            BOOLEAN
   , x_return_status    OUT NOCOPY VARCHAR2);


END IEC_STATUS_PVT;

 

/
