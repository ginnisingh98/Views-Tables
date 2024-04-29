--------------------------------------------------------
--  DDL for Package AMS_ACTIVATE_EVENTSCHED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTIVATE_EVENTSCHED_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvevcs.pls 115.3 2004/03/02 14:38:30 anchaudh ship $ */

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
--  09-Jan-2002    gmadana    Created.
--
--========================================================================
PROCEDURE Activate_Schedule
               (errbuf            OUT NOCOPY    VARCHAR2,
                retcode           OUT NOCOPY    VARCHAR2) ;

--========================================================================
-- PROCEDURE
--    Activate_Schedule
--
-- PURPOSE
--    This api is created to activate available schedules.
--
-- Note
--    This procedure will be called by concurrent program to activate the
--    schedule.
--
-- HISTORY
--  09-Jan-2002    gmadana    Created.
--
--========================================================================
PROCEDURE Activate_Schedule
               (
               p_api_version             IN     NUMBER,
               p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
               p_commit                  IN     VARCHAR2 := FND_API.G_False,

               x_return_status           OUT NOCOPY    VARCHAR2,
               x_msg_count               OUT NOCOPY    NUMBER  ,
               x_msg_data                OUT NOCOPY    VARCHAR2) ;


END AMS_Activate_EventSched_PVT ;

 

/
