--------------------------------------------------------
--  DDL for Package AMS_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SCHEDULER_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvrpts.pls 120.0 2005/06/01 03:39:23 appldev noship $ */

--========================================================================
-- PROCEDURE
--    WRITE_LOG
-- Purpose
--   This method will be used to write logs for this api
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================
PROCEDURE WRITE_LOG             ( p_api_name      IN VARCHAR2,
                                  p_log_message   IN VARCHAR2 );

--========================================================================
-- PROCEDURE
--    Schedule_repeat
-- Purpose
--    Created to get the schedule next run
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================
PROCEDURE Schedule_Repeat             ( p_last_run_date    IN   DATE,
                                        p_frequency        IN NUMBER,
                                        p_frequency_type   IN VARCHAR2,
                                        x_next_run_date    OUT NOCOPY  DATE,
                                        x_return_status    OUT NOCOPY  VARCHAR2,
                                        x_msg_count        OUT     NOCOPY NUMBER,
                                        x_msg_data         OUT NOCOPY  VARCHAR2);



--========================================================================
--PROCEDURE
--    Create_Next_Schedule
-- Purpose
--   This package creates the next schedule to be used by the workflow
-- HISTORY
--    10-Oct-2000   dbiswas    Created.
--
--========================================================================

PROCEDURE Create_Next_Schedule        ( p_parent_sched_id          IN NUMBER,
                                        p_child_sched_st_date      IN   DATE,
                                        p_child_sched_en_date      IN   DATE,
                                        x_child_sched_id          OUT NOCOPY NUMBER,
                                        -- soagrawa added on 18-feb-2004 for bug# 3452264
                                        p_orig_sch_name            IN VARCHAR2 DEFAULT NULL,
                                        p_trig_repeat_flag            IN VARCHAR2 DEFAULT 'N',
                                        x_msg_count      OUT NOCOPY  NUMBER,
                                        x_msg_data      OUT NOCOPY  VARCHAR2,
                                        x_return_status OUT NOCOPY  VARCHAR2
                                       );

--========================================================================
--PROCEDURE
--    Create_Scheduler
-- Purpose
--   This procedure creates a row in the ams_scheduler table using the table handler package
-- HISTORY
--    04-may-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE Create_Scheduler        (           p_obj_type    VARCHAR2,
					      p_obj_id    NUMBER,
					      p_freq    NUMBER,
					      p_freq_type    VARCHAR2,
                                              x_msg_count      OUT NOCOPY  NUMBER,
                                              x_msg_data      OUT NOCOPY  VARCHAR2,
                                              x_return_status OUT NOCOPY  VARCHAR2,
                                              x_scheduler_id  OUT NOCOPY  NUMBER
                                       );


END AMS_Scheduler_PVT ;

 

/
