--------------------------------------------------------
--  DDL for Package AMS_TCOP_SCHEDULER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_TCOP_SCHEDULER_PKG" AUTHID CURRENT_USER AS
/* $Header: amsvtcss.pls 115.1 2003/11/17 18:54:51 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_SCHEDULER_PKG
-- Purpose
--
-- This package contains all the program units for traffic cop
-- Scheduler
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
-- Start of Comments
-- Name
-- Enqueue
--
-- Purpose
-- This procedure adds a request to the Traffic Cop Processing Queue
--
Procedure Enqueue(
  p_schedule_id NUMBER,
  p_item_type   VARCHAR2,
  p_item_id     VARCHAR2
) ;

-- ===============================================================
-- Start of Comments
-- Name
-- Is_This_Schedule_Ready_To_Run
--
-- Purpose
-- This function returns 'Y' if the Schedule is ready to run
-- It returns 'N' if the Schedule is not scheduled to Run
--
FUNCTION 	Is_This_Schedule_Ready_To_Run(
          	 p_schedule_id NUMBER
)
RETURN VARCHAR2;

PROCEDURE DEQUEUE (errbuf     OUT   NOCOPY   VARCHAR2,
                   retcode    OUT   NOCOPY   NUMBER
                  );

PROCEDURE   UPDATE_STATUS(p_schedule_id   NUMBER,
                          p_status        VARCHAR2
                        );



END AMS_TCOP_SCHEDULER_PKG;

 

/
