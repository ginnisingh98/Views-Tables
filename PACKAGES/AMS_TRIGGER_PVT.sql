--------------------------------------------------------
--  DDL for Package AMS_TRIGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TRIGGER_PVT" AUTHID CURRENT_USER as
/* $Header: amsvtgrs.pls 120.1 2006/02/21 22:21:36 srivikri noship $*/

-- Start of Comments
--
-- NAME
--   AMS_Trigger_PVT
--
-- PURPOSE
--   This package is a Private API Wrapper to Call the Three Trigger APIs
--   It Also calls the engine API to Cancel or Start Workflow Process
--
--   Procedures:
--
--     ams_trigger_checks:
--
--     Create_Trigger (see below for specification)
--     Update_Trigger (see below for specification)
--
-- NOTES
--
-- HISTORY
--   12/27/1999        ptendulk            created
--   02/17/2006        srivikri            added procedure activate_trigger
-- End of Comments
--
-- ams_triggers
--
/***************************  PRIVATE ROUTINES  *********************************/

-- Start of Comments
--
-- NAME
--   Create_Trigger
--
-- PURPOSE
--   This procedure is to create a row in ams_triggers,ams_trigger_checks,ams_trigger_actions
--   table that satisfy caller needs
--
-- NOTES
--
--
-- HISTORY
--   07/26/1999        ptendulk      Created
--    10/25/1999       ptendulk      Modified according to new standards
--  15-Feb-2001        ptendulk      Modified as trigger actions table will not be used anymore.
-- End of Comments

PROCEDURE Create_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level         IN     NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

--  p_create_type              IN     VARCHAR2    := 'ALL'  ,
  p_trig_Rec                 IN     Ams_Trig_pvt.trig_rec_type,
  p_thldchk_rec              IN     Ams_Thldchk_pvt.thldchk_rec_type DEFAULT NULL,
  p_thldact_rec              IN     Ams_Thldact_pvt.thldact_rec_type ,

  x_trigger_check_id           OUT NOCOPY    NUMBER,
  x_trigger_action_id          OUT NOCOPY    NUMBER,
  x_trigger_id                 OUT NOCOPY    NUMBER
);

/*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Update_Trigger
--
-- PURPOSE
--   This procedure is to update a ams_triggers,ams_trigger_checks,ams_trigger_actions table
--   that satisfy caller needs . It will also Call the Cancel Workflow Process
--
-- NOTES
--
--
-- HISTORY
--   12/27/1999        ptendulk            created
-- End of Comments

PROCEDURE Update_Trigger
( p_api_version         IN     NUMBER,
  p_init_msg_list       IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit             IN     VARCHAR2    := FND_API.G_FALSE,
  p_validation_level    IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,

  x_return_status       OUT NOCOPY    VARCHAR2,
  x_msg_count           OUT NOCOPY    NUMBER,
  x_msg_data            OUT NOCOPY    VARCHAR2,

  p_trig_rec            IN     Ams_Trig_pvt.trig_rec_type,
  p_thldchk_rec         IN     Ams_Thldchk_pvt.thldchk_rec_type DEFAULT NULL,
  p_thldact_rec         IN     Ams_Thldact_pvt.thldact_rec_type
--  p_updt_type           IN     VARCHAR2

) ;


-- Start of Comments
--
-- NAME
--   Activate_Trigger
--
-- PURPOSE
--   This procedure is to activate the monitor and kick off the workflow process for monitoring the
--   performance of initiative
--
-- HISTORY
--   srivikri   17-Feb-2006    Created
--
-- End of Comments

PROCEDURE Activate_Trigger
( p_api_version              IN     NUMBER,
  p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
  p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,

  x_return_status            OUT NOCOPY    VARCHAR2,
  x_msg_count                OUT NOCOPY    NUMBER,
  x_msg_data                 OUT NOCOPY    VARCHAR2,

  p_trigger_id               IN     NUMBER
);

END AMS_Trigger_PVT;

 

/
