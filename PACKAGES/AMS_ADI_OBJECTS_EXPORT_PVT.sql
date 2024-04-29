--------------------------------------------------------
--  DDL for Package AMS_ADI_OBJECTS_EXPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_OBJECTS_EXPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadxs.pls 120.0 2005/07/01 03:52:23 appldev noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_ADI_OBJECTS_EXPORT_PVT';
g_log_level  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;

AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);



--========================================================================
-- PROCEDURE
--    Inserts_Schedules_Export_List
-- Purpose
--    Inserts Schedules in AMS_ADI_OBJECTS_EXPORT table
-- HISTORY
--
--========================================================================
PROCEDURE insert_export_schedules(
  P_SCHEDULE_IDS IN JTF_NUMBER_TABLE,
  P_COMMIT IN VARCHAR2   := FND_API.G_FALSE,
  X_EXPORT_BATCH_ID OUT NOCOPY NUMBER
);


END AMS_ADI_OBJECTS_EXPORT_PVT;

 

/
