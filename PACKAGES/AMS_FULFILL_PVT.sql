--------------------------------------------------------
--  DDL for Package AMS_FULFILL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_FULFILL_PVT" AUTHID CURRENT_USER as
/* $Header: amsvffms.pls 115.18 2002/12/05 00:57:28 dbiswas ship $ */

-- Start of Comments
--
-- NAME
--   AMS_FULFILL_PVT
--
-- PURPOSE
--   This package is a Private API for managing fulfillment in
--   AMS.
--
--   Procedures:
--
--     Ams_Fulfill (see below for specification)
--
-- NOTES
--
--
-- HISTORY
--   12-nov-1999    ptendulk   created
--   27-oct-2000    ptendulk   1.Added user id in Procedure AMS_FULFILL
--                             2.Added new procedure AMS_EXEC_SCHEDULE to be called from
--                                schedule page
--   29-apr-2002    soagrawa   removed some APIs that are no more being used
--                             since we moved to new eblast
--   29-apr-2002    soagrawa   Modified for new schedule eblast
--   30-may-2002    soagrawa   Added parameter profile_id for ams_fulfill api
--
-- End of Comments
--
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-------------------------------- Fulfillment PVT Routines ------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Ams_Fulfill
--    Type        : Private
--    Function    : fulfill the Collaterals as well as Coverletter for the Campaign
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version          IN NUMBER       := NULL           		Required
--    p_init_msg_list        IN VARCHAR2     := FND_API.G_FALSE,
--    p_commit               IN VARCHAR2     := FND_API.G_FALSE, Optional
--
--    API's IN parameters
--    p_list_header_id            IN     number  (Header ID of the List to be fulfilled)
--
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
-- End Of Comments


PROCEDURE AMS_FULFILL
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             x_request_history_id      OUT NOCOPY    NUMBER,
             -- p_list_header_id          IN     NUMBER,
             p_schedule_id             IN     NUMBER,
             p_profile_id              IN     NUMBER := fnd_profile.VALUE('AMF_DEFAULT_MAIL_PROFILE'),
             p_user_id                 IN     NUMBER := FND_GLOBAL.user_id );


-- Start of Comments
--
-- NAME
--   AMS_EXEC_SCHEDULE
--
-- PURPOSE
--   This procedure is wrapper on ams_fulfill
--   It will be called from schedules to execute the list.
--   The procedure first updates the list with the schedule details,
--   it executes the list , and then updates the list sent out date .
--
-- NOTES
--
--
-- HISTORY
--   10/27/2000        ptendulk        created
-- End of Comments
PROCEDURE AMS_EXEC_SCHEDULE
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_list_header_id          IN     NUMBER,
             p_schedule_id             IN     NUMBER,
             p_exec_flag               IN     VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Send_Test_Mail
--
-- PURPOSE
--   This procedure is use to Send the test mail to the test user
--
-- NOTES
--
--
-- HISTORY
--   22-Jun-2001     ptendulk        created
--   29-apr-2002     soagrawa        removed
--
-- End of Comments
/*
PROCEDURE Send_Test_Email
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_email_address           IN     VARCHAR2,
             p_schedule_id             IN     NUMBER) ;
*/
-- Start of Comments
--
-- NAME
--   Send_Test_Mail
--
-- PURPOSE
--   This procedure is link the Cover letter with the query
--
-- NOTES
--   This api is currently inserting into jtf_amv_query
--   once the fulfillment team delivers the api , the
--   insert statement will be replaced with the api call
--
-- HISTORY
--   26-Jun-2001     ptendulk        created
--   29-apr-2002     soagrawa        removed
-- End of Comments
/*
PROCEDURE Attach_Query
            (p_api_version             IN     NUMBER,
             p_init_msg_list           IN     VARCHAR2 := FND_API.G_False,
             p_commit                  IN     VARCHAR2 := FND_API.G_False,

             x_return_status           OUT NOCOPY    VARCHAR2,
             x_msg_count               OUT NOCOPY    NUMBER  ,
             x_msg_data                OUT NOCOPY    VARCHAR2,

             p_query_id                IN     NUMBER,
             p_item_id                 IN     NUMBER
);
*/
END AMS_Fulfill_PVT;

 

/
