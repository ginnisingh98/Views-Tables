--------------------------------------------------------
--  DDL for Package AMS_ADI_CAMP_SCHED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ADI_CAMP_SCHED_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvadss.pls 120.0 2005/07/01 03:53:25 appldev noship $ */


g_pkg_name   CONSTANT VARCHAR2(30):='AMS_ADI_Camp_Sched_PVT';
g_log_level  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;


--========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
--========================================================================
PROCEDURE update_campaign_schedules(
x_errbuf        OUT NOCOPY    VARCHAR2,
x_retcode       OUT NOCOPY    NUMBER,
p_upload_batch_id IN NUMBER,
p_ui_instance_id IN NUMBER := 0
);


--========================================================================
-- PROCEDURE
--    handles successful API call for a row during Web ADI ->
--     Marketing integration call
-- Purpose
--    COMMIT successful row in database
-- HISTORY
--
--========================================================================
PROCEDURE import_campaign_schedules(
                x_errbuf        OUT NOCOPY    VARCHAR2,
                x_retcode       OUT NOCOPY    VARCHAR2,
                p_upload_batch_id IN NUMBER,
                p_ui_instance_id IN NUMBER := 0
);



END AMS_ADI_CAMP_SCHED_PVT;

 

/
