--------------------------------------------------------
--  DDL for Package JTA_CAL_ATTENDEES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_CAL_ATTENDEES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtavcats.pls 115.5 2002/12/07 01:24:19 rdespoto ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavcats.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package contains calendar assignment procedures.             |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 12-Apr-2002   arpatel          Created.                               |
 +======================================================================*/

   TYPE Resource_rec         IS RECORD
    (
         resource_id             NUMBER,
         resource_type           VARCHAR2(30)
    );

   TYPE Resource_tbl         IS TABLE OF   Resource_rec
                               INDEX BY BINARY_INTEGER;

   TYPE Task_Assign_rec         IS RECORD
    (
         task_assignment_id      NUMBER
    );

   TYPE Task_Assign_tbl      IS TABLE OF   Task_Assign_rec
                               INDEX BY BINARY_INTEGER;

   PROCEDURE create_cal_assignment (
      p_task_id                      IN       NUMBER,
      p_resources                    IN       Resource_tbl,
      p_add_option                   IN       VARCHAR2,
      p_invitor_res_id               IN       NUMBER,
      x_return_status                OUT  NOCOPY    VARCHAR2,
      x_task_assignment_ids          OUT  NOCOPY    Task_Assign_tbl
   );

   PROCEDURE delete_cal_assignment
    (p_object_version_number        IN       NUMBER,
     p_task_assignments             IN       Task_Assign_tbl,
     p_delete_option                IN       VARCHAR2,
     p_no_of_attendies              IN       NUMBER,
     x_return_status                OUT   NOCOPY   VARCHAR2
     );

   PROCEDURE update_cal_assignment (
      p_object_version_number        IN OUT NOCOPY   NUMBER,
      p_task_assignment_id           IN       NUMBER,
      p_resource_id                  IN       NUMBER,
      p_resource_type                IN       VARCHAR2,
      p_assignment_status_id         IN       NUMBER,
      x_return_status                OUT   NOCOPY   VARCHAR2
   ) ;

End  ;

 

/
