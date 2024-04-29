--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK" AUTHID CURRENT_USER AS
/* $Header: cacvstss.pls 120.6 2005/09/27 07:30:21 rhshriva noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cacvstss.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package contains top level API for syncing                   |
 |           tasks(todos) and appointments.                              |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 5-Nov-2004    sachoudh         Created.                               |
 +======================================================================*/

   G_LOGIN_RESOURCE_ID NUMBER;


TYPE task_rec IS RECORD (
   syncId              NUMBER         -- The unique sync ID
  ,recordIndex         NUMBER       := Fnd_Api.G_MISS_num     -- Index equal to the relative record
  ,task_id       NUMBER
                      -- number of record set starting at 0.
  ,syncAnchor          DATE          -- sync anchor date
  ,timeZoneId          NUMBER := 0       -- Default time zone is GMT
  ,eventType           VARCHAR2(30)       --'New', 'Delete', 'Modify'

  -- Task common fields
  ,objectCode          VARCHAR2(30)   -- Type: 'TASK' or 'APPOINTMENT'
  ,subject             VARCHAR2(2000)  := Fnd_Api.G_MISS_char -- Subject/name field
  ,description         VARCHAR2(4000) := Fnd_Api.G_MISS_char -- Description
  ,dateSelected        VARCHAR2(1) := Fnd_Api.G_MISS_char
  ,plannedStartDate    DATE       := Fnd_Api.G_MISS_date -- Start date
  ,plannedEndDate      DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,scheduledStartDate  DATE       := Fnd_Api.G_MISS_date -- Start date
  ,scheduledEndDate    DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,actualStartDate     DATE       := Fnd_Api.G_MISS_date -- Start date
  ,actualEndDate       DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,statusId            NUMBER     := Fnd_Api.G_MISS_num  -- Task status
  ,priorityId          NUMBER     := Fnd_Api.G_MISS_num  -- Task priority (0-99)
  ,alarmFlag           VARCHAR2(1)    := Fnd_Api.G_MISS_char -- Task alarm flag (Y/N)
  ,alarmDate           DATE       := Fnd_Api.G_MISS_date -- Alarm trigger date
  ,privateFlag         VARCHAR2(1)    := Fnd_Api.G_MISS_char -- Private flag (Y/N)
  ,category            VARCHAR2(255)  := Fnd_Api.G_MISS_char -- Task category name
  ,resourceId          NUMBER   := Fnd_Api.G_MISS_num
  ,resourceType        VARCHAR2(2000)  := Fnd_Api.G_MISS_char
  ,task_assignment_id  NUMBER
  ,resultId            NUMBER(1)      -- Result Identifier:
                       -- 0 Success, no message will be displayed
                       -- 1 Success, message will be displayed
                       -- 2 Soft Failure, msg will be displayed
                       --   and sync process will continue
                       -- 3 Hard Failure, msg will be displayed
                       --   and sync process will terminate
  ,resultSystemMessage VARCHAR2(255)  -- System message (API message code)
  ,resultUserMessage   VARCHAR2(2000) -- Valid and Meaningful message to the usr

  -- fields added for recurring tasks
  ,unit_of_measure     VARCHAR2(30)      := Fnd_Api.G_MISS_char   -- unit of measure MON , DAY  , WEEK etc
  ,occurs_every        NUMBER        := Fnd_Api.G_MISS_num    --occurs every month/day/week
  --,occurs_number       NUMBER        := Fnd_Api.G_MISS_num    --occurs number
  ,start_date          DATE          := Fnd_Api.G_MISS_date -- start date
  ,end_date            DATE          := Fnd_Api.G_MISS_date -- end date
  ,sunday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,monday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,tuesday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,wednesday           VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,thursday            VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,friday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,saturday            VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,date_of_month       NUMBER        := Fnd_Api.G_MISS_num    --date of month
  ,occurs_which        NUMBER        := Fnd_Api.G_MISS_num    --date of month
  ,locations           VARCHAR2(4000) := Fnd_Api.G_MISS_char   -- locations list for the appt.
  ,principal_id       NUMBER
  ,free_busy_type      VARCHAR2(30)   := Fnd_Api.G_MISS_char
  ,dial_in             VARCHAR2(100)  :=Fnd_Api.G_MISS_char);



TYPE exclusion_rec IS RECORD (
   syncId              NUMBER         -- The unique sync ID
  ,exclusion_date      DATE          := Fnd_Api.G_MISS_date -- exclusion date
  ,recordIndex         NUMBER       := Fnd_Api.G_MISS_num     -- Index equal to the relative record
  ,task_id       NUMBER
                      -- number of record set starting at 0.
  ,syncAnchor          DATE          -- sync anchor date
  ,timeZoneId          NUMBER := 0       -- Default time zone is GMT
  ,eventType           VARCHAR2(30)       --'New', 'Delete', 'Modify'
  ,objectCode          VARCHAR2(30)   -- Type: 'TASK' or 'APPOINTMENT'
  ,subject             VARCHAR2(2000)  := Fnd_Api.G_MISS_char -- Subject/name field
  ,description         VARCHAR2(4000) := Fnd_Api.G_MISS_char -- Description
  ,dateSelected        VARCHAR2(1) := Fnd_Api.G_MISS_char
  ,plannedStartDate    DATE       := Fnd_Api.G_MISS_date -- Start date
  ,plannedEndDate      DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,scheduledStartDate  DATE       := Fnd_Api.G_MISS_date -- Start date
  ,scheduledEndDate    DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,actualStartDate     DATE       := Fnd_Api.G_MISS_date -- Start date
  ,actualEndDate       DATE       := Fnd_Api.G_MISS_date -- End/Completed date
  ,statusId            NUMBER     := Fnd_Api.G_MISS_num  -- Task status
  ,priorityId          NUMBER     := Fnd_Api.G_MISS_num  -- Task priority (0-99)
  ,alarmFlag           VARCHAR2(1)    := Fnd_Api.G_MISS_char -- Task alarm flag (Y/N)
  ,alarmDate           DATE       := Fnd_Api.G_MISS_date -- Alarm trigger date
  ,privateFlag         VARCHAR2(1)    := Fnd_Api.G_MISS_char -- Private flag (Y/N)
  ,category            VARCHAR2(255)  := Fnd_Api.G_MISS_char -- Task category name
  ,resourceId          NUMBER   := Fnd_Api.G_MISS_num
  ,resourceType        VARCHAR2(2000)  := Fnd_Api.G_MISS_char
  ,task_assignment_id  NUMBER
  ,resultId            NUMBER(1)      -- Result Identifier:
                       -- 0 Success, no message will be displayed
                       -- 1 Success, message will be displayed
                       -- 2 Soft Failure, msg will be displayed
                       --   and sync process will continue
                       -- 3 Hard Failure, msg will be displayed
                       --   and sync process will terminate
  ,resultSystemMessage VARCHAR2(255)  -- System message (API message code)
  ,resultUserMessage   VARCHAR2(2000) -- Valid and Meaningful message to the usr

  -- fields added for recurring tasks
  ,unit_of_measure     VARCHAR2(30)      := Fnd_Api.G_MISS_char   -- unit of measure MON , DAY  , WEEK etc
  ,occurs_every        NUMBER        := Fnd_Api.G_MISS_num    --occurs every month/day/week
  ,start_date          DATE          := Fnd_Api.G_MISS_date -- start date
  ,end_date            DATE          := Fnd_Api.G_MISS_date -- end date
  ,sunday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,monday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,tuesday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,wednesday           VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,thursday            VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,friday              VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,saturday            VARCHAR2(1)       := Fnd_Api.G_MISS_char -- flag (Y/N)
  ,date_of_month       NUMBER        := Fnd_Api.G_MISS_num    --date of month
  ,occurs_which        NUMBER        := Fnd_Api.G_MISS_num    --date of month
  ,locations           VARCHAR2(4000) := Fnd_Api.G_MISS_char   -- locations list for the appt.
  ,principal_id       NUMBER
  ,free_busy_type      VARCHAR2(30)   := Fnd_Api.G_MISS_char
  ,dial_in             VARCHAR2(100)  :=Fnd_Api.G_MISS_char
);
-- The task_tbl is table of task_rec type
TYPE task_tbl IS TABLE OF task_rec
          INDEX BY BINARY_INTEGER;
-- The exclusion_tbl is table of reclusion_rec type
TYPE exclusion_tbl IS TABLE OF exclusion_rec
          INDEX BY BINARY_INTEGER;

TYPE attendee_rec IS RECORD (
   task_id                     NUMBER
  ,attendee_role               VARCHAR2(2000)  := Fnd_Api.G_MISS_char
  ,attendee_status             NUMBER   := Fnd_Api.G_MISS_num
  ,resourceId                  NUMBER   := Fnd_Api.G_MISS_num
  ,resourceType                VARCHAR2(2000)  := Fnd_Api.G_MISS_char
  ,first_name                  VARCHAR2(150)
  ,middle_name                  VARCHAR2(60)
  ,last_name                    VARCHAR2(150)
  ,primary_phone_country_code  VARCHAR2(10)
  ,primary_phone_area_code     VARCHAR2(10)
  ,primary_phone_number        VARCHAR2(40)
  ,primary_phone_extension     VARCHAR2(20)
  ,email_address               VARCHAR2(2000)
  ,job_title                   VARCHAR2(100)


);


TYPE attendee_tbl IS TABLE OF attendee_rec
          INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------
--  API name    : get_count_appt
--  Type    : Public
--  Function    : Gets count of new/modified/deleted records after last sync date
--  Notes:  :
--------------------------------------------------------------------------
PROCEDURE get_count (
      p_request_type     IN VARCHAR2 -- Input: Request Type - APPOINTMENTS/TASKS
     ,p_syncAnchor       IN DATE     -- Input: current sync date,
     ,p_principal_id     IN NUMBER
     ,x_total           OUT NOCOPY NUMBER
     ,x_totalNew        OUT NOCOPY NUMBER
     ,x_totalModified   OUT NOCOPY NUMBER
     ,x_totalDeleted    OUT NOCOPY NUMBER
   );

--------------------------------------------------------------------------
--  API name    : get_list
--  Type    : Public
--  Function    : Gets list of appointments/tasks since last sync date between start and
--        end record indexes (provided by intellisync).
--  Notes:  :
--------------------------------------------------------------------------
   PROCEDURE get_list (
      p_request_type   IN VARCHAR2 -- Input: Request Type - APPOINTMENT/TASK
     ,p_syncAnchor     IN DATE     -- Input: current sync date,
     ,p_principal_id   IN NUMBER
     ,p_sync_type        IN VARCHAR2 --'SS' for slow sync, 'IS' for Incremental sync
     ,x_data          OUT NOCOPY Cac_Sync_Task.task_tbl
     ,x_exclusion_data    OUT NOCOPY Cac_Sync_Task.exclusion_tbl
     ,x_attendee_data     OUT NOCOPY Cac_Sync_Task.attendee_tbl
   );

--------------------------------------------------------------------------
--  API name    : create_ids
--  Type    : Private
--  Function    : Create requested number of IDs using sequence.
--  Notes:
--------------------------------------------------------------------------
PROCEDURE create_ids (
      p_num_req IN     NUMBER,
      x_results IN OUT NOCOPY Cac_Sync_Task.task_tbl
   );

--------------------------------------------------------------------------
--  API name    : update_data
--  Type    : Private
--  Function    : Update (create or modify) task data sent by sync engine.
--  Notes:
--------------------------------------------------------------------------
 PROCEDURE update_data (p_tasks IN OUT NOCOPY Cac_Sync_Task.task_tbl,p_exclusions IN OUT NOCOPY Cac_Sync_Task.exclusion_tbl);

--------------------------------------------------------------------------
--  API name    : delete_data
--  Type    : Private
--  Function    : Delete tasks indicated by sync engine.
--  Notes:
--------------------------------------------------------------------------
PROCEDURE delete_data (p_tasks IN OUT NOCOPY Cac_Sync_Task.task_tbl);

END Cac_Sync_Task;

 

/
