--------------------------------------------------------
--  DDL for Package AMS_THLDACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_THLDACT_PVT" AUTHID CURRENT_USER as
/* $Header: amsvthas.pls 115.12 2003/07/03 14:23:07 cgoyal ship $ */

-- Start of Comments
--
-- NAME
--   AMS_thldact_PVT
--
-- PURPOSE
--   This package is a Private API for managing Trigger Actions information in
--   AMS.  It contains specification for pl/sql records and tables
--
--   Procedures:
--
--     ams_trigger_Actions:
--
--     Create_thldact (see below for specification)
--     Update_thldact (see below for specification)
--     Delete_thldact (see below for specification)
--     Lock_thldact (see below for specification)
--     Validate_thldact (see below for specification)
--	   Check_thldact_Items (see below for specification)
--	   Check_thldact_Record (see below for specification)
--	   Init_thldact_Rec (see below for specification)
--	   Complete_thldact_rec (see below for specification)
--
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        ptendulk   created
--   12/27/1999        ptendulk   Modified (added new Columns Del_id,..)
--   09/08/2000        ptendulk   Added Additional 4 columns for fulfillment
--   22/04/03          cgoyal     added ACTION_NOTIF_USER_ID column for 11.5.8 backport
-- End of Comments
--
-- ams_trigger_actions
--
TYPE thldact_rec_type IS RECORD
(
-- PK
   trigger_action_id             NUMBER ,
   last_update_date              DATE ,
   last_updated_by               NUMBER ,
   creation_date                 DATE,
   created_by                    NUMBER,
   last_update_login             NUMBER,
   object_version_number         NUMBER,

   process_id                    NUMBER,
   trigger_id                    NUMBER,
   order_number                  NUMBER,

   notify_flag                   VARCHAR2(1),
   --ACTION_NOTIF_USER_ID          NUMBER := NULL,
   generate_list_flag            VARCHAR2(1),
   action_need_approval_flag     VARCHAR2(1),
   action_approver_user_id       NUMBER,
   execute_action_type           VARCHAR2(30),
   list_header_id                NUMBER,
   list_connected_to_id          NUMBER,
   arc_list_connected_to         VARCHAR2(30),
   deliverable_id                NUMBER,
   activity_offer_id             NUMBER,
   dscript_name                  VARCHAR2(256),
   program_to_call               VARCHAR2(30)
  ,cover_letter_id               NUMBER
  ,mail_subject                  VARCHAR2(240)
  ,mail_sender_name              VARCHAR2(120)
  ,from_fax_no                   VARCHAR2(25)
   --soagrawa 30-apr-2003 for trigger backporting
  , action_for_id                NUMBER
   );


--
-- Start of Comments
--
--SQL> desc ams_trigger_actions ;
-- Name                                                  Null?    Type
-- ----------------------------------------------------- -------- -----------------
-- TRIGGER_ACTION_ID                                     NOT NULL NUMBER
-- LAST_UPDATE_DATE                                      NOT NULL DATE
-- LAST_UPDATED_BY                                       NOT NULL NUMBER(15)
-- CREATION_DATE                                         NOT NULL DATE
-- CREATED_BY                                            NOT NULL NUMBER(15)
-- LAST_UPDATE_LOGIN                                              NUMBER(15)
-- OBJECT_VERSION_NUMBER                                          NUMBER(9)
-- PROCESS_ID                                                     NUMBER
-- TRIGGER_ID                                            NOT NULL NUMBER
-- ORDER_NUMBER                                                   NUMBER(15)
-- NOTIFY_FLAG                                           NOT NULL VARCHAR2(1)
-- ACTION_NOTIF_USER_ID						  NUMBER
-- G-ENERATE_LIST_FLAG                                    NOT NULL VARCHAR2(1)
-- ACTION_NEED_APPROVAL_FLAG                             NOT NULL VARCHAR2(1)
-- ACTION_APPROVER_USER_ID                                        NUMBER
-- EXECUTE_ACTION_TYPE                                            VARCHAR2(30)
-- LIST_HEADER_ID                                                 NUMBER
-- LIST_CONNECTED_TO_ID                                           NUMBER
-- ARC_LIST_CONNECTED_TO                                          VARCHAR2(30)
-- PROGRAM_TO_CALL                                                VARCHAR2(30)
 ----
---
-- End of Comments
--


-- global constants
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
-------------------------------- AMS_TRIGGER_ACTIONS-------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------


/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Create_thldact
--    Type        : Private
--    Function    : Create a row in ams_trigger_actions table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version          IN NUMBER       := NULL           		Required
--    p_init_msg_list        IN VARCHAR2     := FND_API.G_FALSE,
--    p_commit			     IN VARCHAR2     := FND_API.G_FALSE, Optional
--    p_validation_level     IN NUMBER       := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_thldact_Rec               IN     thldact_rec_type,
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--
--    API's OUT parameters
--    x_trigger_action_id      	  OUT    NUMBER
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
-- End Of Comments

PROCEDURE Create_thldact
( p_api_version                   IN     NUMBER,
  p_init_msg_list                 IN     VARCHAR2 := FND_API.G_False,
  p_commit			     	 	  IN     VARCHAR2 := FND_API.G_False,
  p_validation_level              IN     NUMBER	  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                 OUT NOCOPY    VARCHAR2,
  x_msg_count                     OUT NOCOPY    NUMBER,
  x_msg_data                      OUT NOCOPY    VARCHAR2,

  p_thldact_Rec                   IN     thldact_rec_type,
  x_trigger_action_id	          OUT NOCOPY    NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Update_thldact
--    Type        : Private
--    Function    : Update a row in ams_trigger_actions table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN          :
--    standard IN parameters
--    p_api_version       IN NUMBER       := NULL           		Required
--    p_init_msg_list     IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_commit			  IN VARCHAR2     := FND_API.G_FALSE Optional
--    p_validation_level  IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--    API's IN parameters
--    p_thldact_rec       IN     thldact_rec_type

--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--    x_msg_count                    OUT    NUMBER
--    x_msg_data                     OUT    VARCHAR2(2000)
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
-- End Of Comments

PROCEDURE Update_thldact
( p_api_version                IN     NUMBER,
  p_init_msg_list              IN     VARCHAR2   := FND_API.G_False,
  p_commit			     	   IN     VARCHAR2   := FND_API.G_False,
  p_validation_level           IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY    VARCHAR2,
  x_msg_count                  OUT NOCOPY    NUMBER,
  x_msg_data                   OUT NOCOPY    VARCHAR2,

  p_thldact_rec                IN     thldact_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Delete_thldact
--    Type        : Private
--    Function    : Delete a row in ams_trigger_actions table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version               IN 	NUMBER       := NULL   		Required
--    p_init_msg_list             IN 	VARCHAR2     := FND_API.G_FALSE Optional
--    p_commit			     	  IN 	VARCHAR2     := FND_API.G_FALSE Optional
--    API's IN parameters
--      p_trigger_action_id   		IN     NUMBER,
--      p_object_version_number     IN     NUMBER
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
-- End Of Comments

PROCEDURE Delete_thldact
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2    := FND_API.G_False,
  p_commit		              IN     VARCHAR2    := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_action_id   		  IN     NUMBER,
  p_object_version_number     IN     NUMBER
);


/******************************************************************************/
-- Start of Comments
--
--    API name    : Lock_thldact
--    Type        : Private
--    Function    : Lock a row in ams_trigger_actions
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER    := NULL           			   Required
--    p_init_msg_list     IN VARCHAR2  := FND_API.G_FALSE   Optional
--
--    API's IN parameters
--    p_trigger_action_id   		  IN     NUMBER
--    p_object_version_number     IN     NUMBER
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
-- End Of Comments



PROCEDURE Lock_thldact
( p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_False,

  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,

  p_trigger_action_id 	  	  IN     NUMBER,
  p_object_version_number	  IN 	 NUMBER
);


/******************************************************************************/
-- Start of Comments
--
--    API name    : Validate_thldact
--    Type        : Private
--    Function    : Validate a row in ams_trigger_actions table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--    p_api_version       IN NUMBER   := NULL          		Required
--    p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE    Optional
--    p_validation_level  IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
--
--    API's IN parameters
--    p_thldact_Rec                  IN     thldact_rec_type
--
--    OUT        :
--    standard OUT parameters
--    x_return_status             OUT    VARCHAR2(1)
--    x_msg_count                 OUT    NUMBER
--    x_msg_data                  OUT    VARCHAR2(2000)
--
--    API's OUT parameters
--    x_thldact_rec              OUT    thldact_rec_type
--
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
-- End Of Comments

PROCEDURE Validate_thldact
( p_api_version                  IN     NUMBER,
  p_init_msg_list                IN     VARCHAR2    := FND_API.G_False,
  p_validation_level             IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
  x_return_status                OUT NOCOPY    VARCHAR2,
  x_msg_count                    OUT NOCOPY    NUMBER,
  x_msg_data                     OUT NOCOPY    VARCHAR2,

  p_thldact_Rec                  IN     thldact_rec_type

);

/******************************************************************************/
-- Start of Comments
--
--    Name        : Validate_thldact_Items
--    Type        : Private
--    Function    : Validate columns in ams_trigger_actions
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldact_rec       		   IN   thldact_rec_type,
--    p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create
--    OUT        :
--    x_return_status           OUT    VARCHAR2
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_thldact_Items(
   p_thldact_rec     IN  thldact_rec_type,
   p_validation_mode IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status   OUT NOCOPY VARCHAR2
);

/*****************************************************************************************/
-- Start of Comments
--
--    API name    : Validate_thldact_Record
--    Type        : Private
--    Function    : Validate a row in ams_trigger_actions table
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    standard IN parameters
--
--    API's IN parameters
--    p_thldact_rec		IN  thldact_rec_type
--	  p_complete_rec    IN  thldact_rec_type,
--
--    OUT        :
--    standard OUT parameters
--    x_return_status                OUT    VARCHAR2(1)
--
--    Version    :     Current version     1.0
--                     Initial version     1.0
--
--    Business rules:
-- 1. ...
--
-- End Of Comments

PROCEDURE Check_thldact_Record(
   p_thldact_rec    IN  thldact_rec_type,
   p_complete_rec   IN  thldact_rec_type,
   x_return_status  OUT NOCOPY VARCHAR2
);


/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Init_thldact_Rec
--    Type        : Private
--    Function    : CInitialize the Record type before Updation
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldact_rec               IN     thldact_rec_type Required
--    p_thldact_req_item_rec      IN     thldact_validate_rec_type,
--
--    OUT        :
--    x_return_status                        OUT    VARCHAR2
--
--
-- End Of Comments

PROCEDURE Init_thldact_Rec(
   x_thldact_rec  OUT NOCOPY  thldact_rec_type
);

/*****************************************************************************************/
-- Start of Comments
--
--    Name        : Complete_thldact_rec
--    Type        : Private
--    Function    : Complete the record as we don't pass whole record for Updation
--
--    Pre-reqs    : None
--    Paramaeters :
--    IN        :
--    p_thldact_rec               IN     thldact_rec_type Required
--
--    OUT        :
--    x_complete_rec  			  OUT    thldact_rec_type
--
-- End Of Comments
PROCEDURE Complete_thldact_rec(
   p_thldact_rec   IN  thldact_rec_type,
   x_complete_rec  OUT NOCOPY thldact_rec_type
)
;



END AMS_thldact_PVT;

 

/
