--------------------------------------------------------
--  DDL for Package JTA_SYNC_TASK_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_TASK_CATEGORY" AUTHID CURRENT_USER AS
/* $Header: jtavstys.pls 115.5 2002/12/13 22:28:22 cjang ship $ */
/*======================================================================+
|  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|          jtavstys.pls                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|          This package is for task categories.                         |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date          Developer        Change                                 |
| ------        ---------------  -------------------------------------- |
| 12-Mar-2002   arpatel          created                                |
*=======================================================================*/

   FUNCTION get_category_id (
      p_category_name   IN  VARCHAR2,
      p_profile_id      IN  NUMBER
   ) RETURN NUMBER;

   PROCEDURE create_category (
         p_category_name      IN OUT NOCOPY VARCHAR2,
         p_resource_id        IN     NUMBER
      );

   FUNCTION get_profile_id (
      p_resource_id   IN  NUMBER
   ) RETURN NUMBER;




END jta_sync_task_category;   -- Package spec

 

/
