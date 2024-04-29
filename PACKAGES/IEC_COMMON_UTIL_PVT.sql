--------------------------------------------------------
--  DDL for Package IEC_COMMON_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_COMMON_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECCMUTS.pls 120.1 2006/03/28 07:32:19 minwang noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_SourceTypeView
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the source type view name for specified
--                target group.  Raises exception if unable to
--                locate view.
--
--  Parameters  : p_list_id              IN     NUMBER                       Required
--                x_source_type_view        OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_SourceTypeView
   ( p_list_id          IN            NUMBER
   , x_source_type_view    OUT NOCOPY VARCHAR2);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : LOCK_SCHEDULE
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Attempt to lock the schedule.
--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required
--                P_SCHED_ID         IN     NUMBER    Required
--                P_SERVER_ID        IN     NUMBER    Required
--                P_LOCK_ATTEMPTS    IN     VARCHAR2  Required
--                P_ATTEMPT_INTERVAL IN     VARCHAR2  Required
--                X_SUCCESS_FLAG        OUT VARCHAR2  Required
--  Future      : Not sure this should be an autonomous transaction.  Leaving
--                for now.
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Lock_Schedule
   ( P_SOURCE_ID        IN            NUMBER
   , P_SCHED_ID         IN            NUMBER
   , P_SERVER_ID        IN            NUMBER
   , P_LOCK_ATTEMPTS    IN            NUMBER
   , P_ATTEMPT_INTERVAL IN            NUMBER
   , X_SUCCESS_FLAG        OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : UNLOCK_SCHEDULE
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Attempt to unlock the schedule.
--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required
--                P_SCHED_ID         IN     NUMBER    Required
--                P_SERVER_ID        IN     NUMBER    Required
--                X_SUCCESS_FLAG        OUT VARCHAR2  Required
--  Future      : Not sure this should be an autonomous transaction.  Leaving
--                for now.
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Unlock_Schedule
   ( P_SOURCE_ID    IN            NUMBER
   , P_SCHED_ID     IN            NUMBER
   , P_SERVER_ID    IN            NUMBER
   , X_SUCCESS_FLAG    OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Lock_Schedule
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Either attempt to gain a lock on the schedule or unlock the schedule.
--
--  Parameters  : P_SOURCE_ID        IN     NUMBER    Required
--                P_SCHED_ID         IN     NUMBER    Required
--                P_SERVER_ID        IN     NUMBER    Required
--                P_LOCK_FLAG        IN     NUMBER    Required
--                X_SUCCESS_FLAG        OUT VARCHAR2  Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Lock_Schedule
   ( P_SOURCE_ID    IN            NUMBER
   , P_SCHED_ID     IN            NUMBER
   , P_SERVER_ID    IN            NUMBER
   , P_LOCK_FLAG    IN            VARCHAR2
   , X_SUCCESS_FLAG    OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_SubsetName
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the name for specified subset.
--                Initializes FND_MESSAGE and raises
--                exception if unable to locate name.
--
--  Parameters  : p_subset_id       IN     NUMBER             Required
--                x_subset_name        OUT VARCHAR2           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_SubsetName
   ( p_subset_id   IN            NUMBER
   , x_subset_name    OUT NOCOPY VARCHAR2);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_ListName
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the name for specified list.
--                Initializes FND_MESSAGE and raises
--                exception if unable to locate name.
--
--  Parameters  : p_list_id       IN     NUMBER             Required
--                x_list_name        OUT VARCHAR2           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_ListName
   ( p_list_id   IN            NUMBER
   , x_list_name    OUT NOCOPY VARCHAR2);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_ScheduleName
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the name for specified schedule.
--                Initializes FND_MESSAGE and raises
--                exception if unable to locate name.
--
--  Parameters  : p_schedule_id       IN     NUMBER             Required
--                x_schedule_name        OUT VARCHAR2           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_ScheduleName
   ( p_schedule_id   IN            NUMBER
   , x_schedule_name    OUT NOCOPY VARCHAR2);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_ScheduleId
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the schedule id for specified list.
--                Initializes FND_MESSAGE and raises
--                exception if unable to locate name.
--
--  Parameters  : p_list_id         IN     NUMBER           Required
--                x_schedule_id        OUT NUMBER           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_ScheduleId
   ( p_list_id     IN            NUMBER
   , x_schedule_id    OUT NOCOPY NUMBER);

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_ListId
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Return the list header id for specified schedule.
--                Initializes FND_MESSAGE and raises
--                exception if unable to locate name.
--
--  Parameters  : p_schedule_id IN     NUMBER           Required
--                x_list_id        OUT NUMBER           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_ListId
   ( p_schedule_id IN            NUMBER
   , x_list_id        OUT NOCOPY NUMBER);

END IEC_COMMON_UTIL_PVT;

 

/
