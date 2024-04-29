--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK_CATEGORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK_CATEGORY" AUTHID CURRENT_USER AS
/* $Header: cacvstys.pls 120.1 2005/07/02 02:21:47 appldev noship $ */
/*======================================================================+
|  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|          cacvstys.pls                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|          This package is for task categories.                         |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date          Developer        Change                                 |
| ------        ---------------  -------------------------------------- |
| 12-Nov-2004   sachoudh         created                                |
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


END cac_sync_task_category;   -- Package spec

 

/
