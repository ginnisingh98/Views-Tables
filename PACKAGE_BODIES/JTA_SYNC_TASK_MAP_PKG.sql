--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK_MAP_PKG" AS
/* $Header: jtavstmb.pls 115.15 2002/05/13 10:01:30 pkm ship   $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavstmb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is used to insert/update/delete sync task            |
 |                      mapping record.                                  |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 18-Jan-2002   gjashnan         Created.                               |
 | 22-Feb-2002   cjang            Refactoring                            |
 | 11-Mar-2002   cjang            Bug Fix update_row to update task_id   |
 |                                Remove task_id = p_task_id             |
 |                                   in update_row()                     |
 | 09-May-2002   cjang            Removed the obsolete columns in insert_row
 +======================================================================*/
   PROCEDURE insert_row (
      p_task_sync_id IN NUMBER,
      p_task_id      IN NUMBER,
      p_resource_id  IN NUMBER
   )
   IS
      l_current_date DATE := SYSDATE;
      l_user_id NUMBER := fnd_global.user_id;
      l_login_id NUMBER := fnd_global.login_id;
   BEGIN
      INSERT INTO jta_sync_task_mapping
      (task_sync_id,
       task_id,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       last_update_login,
       resource_id
      )
      VALUES
      (p_task_sync_id,
       p_task_id,
       l_user_id,
       l_current_date,
       l_user_id,
       l_current_date,
       l_login_id,
       p_resource_id
      );
   END insert_row;

   PROCEDURE update_row (
      p_task_sync_id IN NUMBER,
      p_task_id      IN NUMBER,
      p_resource_id  IN NUMBER
   )
   IS
      l_current_date DATE := SYSDATE;
      l_user_id NUMBER := fnd_global.user_id;
      l_login_id NUMBER := fnd_global.login_id;
   BEGIN
      UPDATE jta_sync_task_mapping
         SET resource_id       = p_resource_id,
             task_sync_id      = p_task_sync_id,
             task_id           = p_task_id,
             last_update_date  = l_current_date,
             last_updated_by   = l_user_id,
             last_update_login = l_login_id
       WHERE task_sync_id = p_task_sync_id;
   END update_row;

   PROCEDURE delete_row (
      p_task_sync_id IN NUMBER
   )
   IS
   BEGIN
      DELETE
        FROM jta_sync_task_mapping
       WHERE task_sync_id = p_task_sync_id;
   END delete_row;
END jta_sync_task_map_pkg;

/
