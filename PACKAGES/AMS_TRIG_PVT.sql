--------------------------------------------------------
--  DDL for Package AMS_TRIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TRIG_PVT" AUTHID CURRENT_USER as
/* $Header: amsvtrgs.pls 120.1 2005/08/26 02:03:08 anchaudh noship $*/

-- Start of Comments
--
-- NAME
--   AMS_Trig_PVT
--
-- PURPOSE
--   This package is a Private API for managing Triggers information in
--   AMS.  It contains specification for pl/sql records and tables
--
--   Procedures:
--
--     ams_trigger_checks:
--
--     Create_Trigger (see below for specification)
--     Update_Trigger (see below for specification)
--     Delete_Trigger (see below for specification)
--     Lock_Trigger (see below for specification)
--     Validate_Trigger (see below for specification)
--     Check_Trig_Items(see below for specification)
--     Check_Trig_Record (see below for specification)
--     Validate_Trig_Child_Enty (see below for specification)
--     Check_Req_Trig_Items (see below for specification)
--	   Init_Trig_Rec (see below for specification)
--	   Complete_Trig_Rec(see below for specification)
--
-- NOTES
--
-- HISTORY
--   07/26/1999        ptendulk   created
--   04/26/2000        ptendulk   Modified , Added Date columns to support timezone
--  14-Feb-2001        ptendulk   Modified as triggers will have tl table.
--  24-sep-2001        soagrawa   Removed security group id from everywhere
-- End of Comments
--
-- ams_triggers
--
TYPE trig_rec_type IS RECORD
(
-- PK
   trigger_id			     	  NUMBER
--
  ,last_update_date               DATE
  ,last_updated_by                NUMBER
  ,creation_date                  DATE
  ,created_by                     NUMBER
  ,last_update_login              NUMBER
  ,object_version_number          NUMBER
  ,process_id 	            	  NUMBER
  ,trigger_created_for_id         NUMBER
  ,arc_trigger_created_for        VARCHAR2(30)
  ,triggering_type                VARCHAR2(30)
  ,view_application_id            NUMBER
  ,timezone_id                    NUMBER
  ,user_start_date_time           DATE
  ,start_date_time                DATE
  ,user_last_run_date_time        DATE
  ,last_run_date_time             DATE
  ,user_next_run_date_time        DATE
  ,next_run_date_time             DATE
  ,user_repeat_daily_start_time   DATE
  ,repeat_daily_start_time        DATE
  ,user_repeat_daily_end_time     DATE
  ,repeat_daily_end_time          DATE
  ,repeat_frequency_type          VARCHAR2(30)
  ,repeat_every_x_frequency       NUMBER
  ,user_repeat_stop_date_time     DATE
  ,repeat_stop_date_time          DATE
  ,metrics_refresh_type           VARCHAR2(30)
  -- removed by soagrawa on 24-sep-2001
  -- ,security_group_id              NUMBER
  ,trigger_name                   VARCHAR2(120)
  ,description                    VARCHAR2(4000)
  ,notify_flag                    VARCHAR2(1)
  ,EXECUTE_SCHEDULE_FLAG          VARCHAR2(1)
  ,TRIGGERED_STATUS		  VARCHAR2(30)--anchaudh added for monitors,R12.
  ,USAGE		          VARCHAR2(30)--anchaudh added for monitors,R12.
--
);

--
-- Start of Comments
--SQL> desc ams_triggers ;
-- Name                                                  Null?    Type
-- ----------------------------------------------------- -------- ----------------------------
-- TRIGGER_ID                                            NOT NULL NUMBER
-- LAST_UPDATE_DATE                                      NOT NULL DATE
-- LAST_UPDATED_BY                                       NOT NULL NUMBER(15)
-- CREATION_DATE                                         NOT NULL DATE
-- CREATED_BY                                            NOT NULL NUMBER(15)
-- LAST_UPDATE_LOGIN                                              NUMBER(15)
-- OBJECT_VERSION_NUMBER                                          NUMBER(9)
-- PROCESS_ID                                                     NUMBER
-- TRIGGER_CREATED_FOR_ID                                NOT NULL NUMBER
-- ARC_TRIGGER_CREATED_FOR                               NOT NULL VARCHAR2(30)
-- TRIGGERING_TYPE                                       NOT NULL VARCHAR2(30)
-- TRIGGER_NAME                                          NOT NULL VARCHAR2(120)
-- VIEW_APPLICATION_ID                                   NOT NULL NUMBER
-- START_DATE_TIME                                       NOT NULL DATE
-- LAST_RUN_DATE_TIME                                             DATE
-- NEXT_RUN_DATE_TIME                                             DATE
-- REPEAT_DAILY_START_TIME                                        DATE
-- REPEAT_DAILY_END_TIME                                          DATE
-- REPEAT_FREQUENCY_TYPE                                          VARCHAR2(30)
-- REPEAT_EVERY_X_FREQUENCY                                       NUMBER(15)
-- REPEAT_STOP_DATE_TIME                                          DATE
-- METRICS_REFRESH_TYPE                                           VARCHAR2(30)
-- DESCRIPTION                                                    VARCHAR2(4000)
-- NOTIFY_FLAG                                                    VARCHAR2(1)
-- EXECUTE_SCHEULE_FLAG                                           VARCHAR2(1)
-- End of Comments
--


-- global constants
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-------------------------------- AMS_TRIGGERS-------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Create_Trigger
--    Type        : Private
--    Function    : Create a row in ams_triggers table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version          IN NUMBER     := NULL           		Required
--    p_init_msg_list        IN VARCHAR2   := FND_API.G_FALSE,
--    p_commit			     IN VARCHAR2   := FND_API.G_FALSE,
--    p_validation_level     IN NUMBER     := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_Trig_Rec               IN     trig_rec_type%ROWTYPE,
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--
--    API's OUT parameters
--    x_trigger_check_id      	  OUT    NUMBER
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. The following items are required parameters
-- p_Trig_rec.trigger_created_for_id
-- p_Trig_rec.arc_trigger_created_for
-- p_Trig_rec.triggering_type
-- p_Trig_rec.trigger_name
-- p_Trig_rec.view_application_id
-- p_Trig_rec.start_date_time
--
--    Business rules:
-- 1. ...
--
--
-- End Of Comments

PROCEDURE Create_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

  p_trig_Rec                 IN     trig_rec_type,
  x_trigger_id               OUT NOCOPY    NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Update_Trigger
--    Type        : Private
--    Function    : Update a row in ams_triggers table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL           		Required
--    p_init_msg_list     IN VARCHAR2     := FND_API.G_FALSE
--    p_commit			  IN VARCHAR2     := FND_API.G_FALSE,
--    p_validation_level  IN     		  := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--	  p_trig_rec          IN     trig_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Trig_rec.trigger_id,p_trig_rec.object_version_number are required parameters
--             2. p_Trig_rec.trigger_id is not updatable
--
-- End Of Comments

PROCEDURE Update_Trigger
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit              IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_trig_rec            IN     trig_rec_type
) ;

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_Trigger
--    Type        : Private
--    Function    : Delete a row in ams_triggers table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version               IN 	NUMBER       := NULL   		Required
--    p_init_msg_list             IN 	VARCHAR2  	 := FND_API.G_FALSE
--    p_commit			     	  IN 	VARCHAR2 	 := FND_API.G_FALSE
--    API's IN parameters
--    p_Trigger_id                IN     NUMBER
--	  p_object_version_number	  IN	 NUMBER
--
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--    Version    :     Current version   1.0
--                     Initial version   1.0
--
--    Note	 : 1. p_trigger_id, p_object_version_number is a required parameter
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Delete_Trigger
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                    IN     VARCHAR2    := FND_API.G_FALSE,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_id                IN     NUMBER,
  p_object_version_number     IN     NUMBER
) ;


/******************************************************************************/
-- Start of Comments
--
--    API name    : Lock_Trigger
--    Type        : Private
--    Function    : Lock a row in ams_triggers
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER    := NULL           			   Required
--    p_init_msg_list     IN VARCHAR2  := FND_API.G_FALSE   Optional
--
--    API's IN parameters
--    p_Trigger_id        	 	IN  NUMBER
--	  p_object_version_number	IN  NUMBER
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : p_trigger_id,p_object_version_number is a required parameter
--
-- End Of Comments


PROCEDURE Lock_Trigger
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_id                IN     NUMBER,
  p_object_version_number     IN     NUMBER
);


/******************************************************************************/
-- Start of Comments
--
--    API name    : Validate_Trigger
--    Type        : Private
--    Function    : Validate a row in ams_triggers table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER   := NULL          		           Required
--    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE    Optional
--    p_validation_level  IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_Trig_Rec                  IN     trig_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--    API's OUT parameters
--    x_Trig_rec              OUT    trig_rec_type
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : 1. p_Trig_rec.trigger_id is a required parameter
--             2. x_return_status will be FND_API.G_RET_STS_SUCCESS,
--			      FND_API.G_RET_STS_ERROR or FND_API.G_RET_STS_UNEXP_ERROR
--    Business rules:
-- 1. ...
--
--
-- End Of Comments

PROCEDURE Validate_Trigger(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2 := FND_API.g_false,
   p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full,

   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,

   p_trig_rec          IN  trig_rec_type
);

/******************************************************************************/
-- Start of Comments
--
--    Name        : check_trig_items
--    Type        : Private
--    Function    : Validate columns in ams_triggers
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_Trig_rec       	  IN   trig_rec_type
--    p_validation_mode   IN   VARCHAR2 := JTF_PLSQL_API.g_create
--    OUT        :
--    x_return_status           OUT    VARCHAR2
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE check_trig_items(
   p_trig_rec        IN  trig_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Check_Trig_Record
--    Type        : Private
--    Function    : Validate a row in ams_triggers table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--
--    API's IN parameters
--    p_Trig_rec   	   IN   trig_rec_type
--    p_Complete_rec   IN   trig_rec_type
--
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Note	 : x_return_status will be FND_API.G_RET_STS_SUCCESS, FND_API.G_RET_STS_ERROR, or
--                 FND_API.G_RET_STS_UNEXP_ERROR
--
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_Trig_Record(
   p_trig_rec       IN  trig_rec_type,
   p_complete_rec   IN  trig_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Check_REQ_Trig_Items
--    Type        : Private
--    Function    : Check required parameters for caller needs
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_Trig_rec               IN     trig_rec_type Required
--
--    OUT        :
--    x_return_status                        OUT    VARCHAR2
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_Trig_Req_Items
( p_trig_rec                IN     trig_rec_type,
  x_return_status           OUT NOCOPY    VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Init_Trig_Rec
--    Type        : Private
--    Function    : Initialize the Trigger Record type before Update
--
--    Pre-reqs    : None
--    Paramaeters :
--    OUT        :
--    x_return_status                        OUT    VARCHAR2
--
--    Business rules:
-- 1. ...
--
-- End Of Comments
PROCEDURE Init_Trig_Rec(
   x_trig_rec  OUT NOCOPY  trig_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Complete_Trig_Rec
--    Type        : Private
--    Function    : Complete the Trigger Record type if the values are not passed
--	  			    for Updation
--
--    Pre-reqs    : None
--    Paramaeters :
--	  IN		 :
--	  p_trig_rec    	  IN	trig_rec_type
--    OUT        :
--    x_complete_rec      OUT   trig_rec_type
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Complete_Trig_Rec(
   p_trig_rec      IN  trig_rec_type,
   x_complete_rec  OUT NOCOPY trig_rec_type
);


END AMS_Trig_PVT;

 

/
