--------------------------------------------------------
--  DDL for Package Body GME_BATCH_HISTORY_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_HISTORY_DBL" AS
/* $Header: GMEVGHSB.pls 120.1 2005/06/03 13:45:15 appldev  $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_BATCH_HISTORY';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGHSB.pls
 |
 |   DESCRIPTION
 |
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |      - Delete_row
 |
 |
 =============================================================================
*/

   /* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      insert_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Insert_Row will insert a row in gme_batch_history
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_history
 |
 |
 |
 |   PARAMETERS
 |     p_batch_history IN  gme_batch_history%ROWTYPE
 |     x_batch_history IN OUT NOCOPY gme_batch_history%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_batch_history   IN              gme_batch_history%ROWTYPE
     ,x_batch_history   IN OUT NOCOPY   gme_batch_history%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_batch_history := p_batch_history;

      INSERT INTO gme_batch_history
                  (event_id, batch_id
                  ,orig_status, new_status
                  ,orig_wip_whse
                  ,new_wip_whse
                  ,gl_posted_ind
                  ,last_updated_by, last_update_login
                  ,created_by, creation_date
                  ,last_update_date, program_id
                  ,request_id
                  ,program_update_date
                  ,program_application_id)
           VALUES (gem5_batch_event_id_s.NEXTVAL, x_batch_history.batch_id
                  ,x_batch_history.orig_status, x_batch_history.new_status
                  ,x_batch_history.orig_wip_whse
                  ,x_batch_history.new_wip_whse
                  ,x_batch_history.gl_posted_ind
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_login_id
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_timestamp, x_batch_history.program_id
                  ,x_batch_history.request_id
                  ,x_batch_history.program_update_date
                  ,x_batch_history.program_application_id)
        RETURNING event_id
             INTO x_batch_history.event_id;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END insert_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      fetch_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Fetch_Row will fetch a row in gme_batch_history
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_history
 |
 |
 |
 |   PARAMETERS
 |     p_batch_history IN  gme_batch_history%ROWTYPE
 |     x_batch_history IN OUT NOCOPY gme_batch_history%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_history   IN              gme_batch_history%ROWTYPE
     ,x_batch_history   IN OUT NOCOPY   gme_batch_history%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_batch_history.event_id IS NOT NULL THEN
         SELECT event_id, batch_id
               ,orig_status, new_status
               ,orig_wip_whse, new_wip_whse
               ,gl_posted_ind
               ,last_updated_by
               ,last_update_login
               ,created_by, creation_date
               ,last_update_date
               ,program_id, request_id
               ,program_update_date
               ,program_application_id
           INTO x_batch_history.event_id, x_batch_history.batch_id
               ,x_batch_history.orig_status, x_batch_history.new_status
               ,x_batch_history.orig_wip_whse, x_batch_history.new_wip_whse
               ,x_batch_history.gl_posted_ind
               ,x_batch_history.last_updated_by
               ,x_batch_history.last_update_login
               ,x_batch_history.created_by, x_batch_history.creation_date
               ,x_batch_history.last_update_date
               ,x_batch_history.program_id, x_batch_history.request_id
               ,x_batch_history.program_update_date
               ,x_batch_history.program_application_id
           FROM gme_batch_history
          WHERE event_id = p_batch_history.event_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END fetch_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Row will delete a row in gme_batch_history
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_history
 |
 |
 |
 |   PARAMETERS
 |     p_batch_history IN  gme_batch_history%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-01  Bharati Satpute  Bug 2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_batch_history.event_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_history
              WHERE event_id = p_batch_history.event_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_history
               WHERE event_id = p_batch_history.event_id;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         IF l_dummy = 0 THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_dummy = 0 THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batch'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_history.batch_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END delete_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      update_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Update_Row will update a row in gme_batch_history
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_history
 |
 |
 |
 |   PARAMETERS
 |     p_batch_history IN  gme_batch_history%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati Satpute Bug2404126
 |   Added Error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_batch_history.event_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_history
              WHERE event_id = p_batch_history.event_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_history
            SET batch_id = p_batch_history.batch_id
               ,orig_status = p_batch_history.orig_status
               ,new_status = p_batch_history.new_status
               ,orig_wip_whse = p_batch_history.orig_wip_whse
               ,new_wip_whse = p_batch_history.new_wip_whse
               ,gl_posted_ind = p_batch_history.gl_posted_ind
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,last_update_date = gme_common_pvt.g_timestamp
               ,program_id = p_batch_history.program_id
               ,request_id = p_batch_history.request_id
               ,program_update_date = p_batch_history.program_update_date
               ,program_application_id =
                                        p_batch_history.program_application_id
          WHERE event_id = p_batch_history.event_id
            AND last_update_date = p_batch_history.last_update_date;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         IF l_dummy = 0 THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         IF l_dummy = 0 THEN
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         ELSE
            gme_common_pvt.log_message ('GME_RECORD_CHANGED'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batch'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_history.batch_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         RETURN FALSE;
   END update_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      lock_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Lock_Row will lock a row in gme_batch_history
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_history
 |
 |
 |
 |   PARAMETERS
 |     p_batch_history IN  gme_batch_history%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION lock_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy   NUMBER;
   BEGIN
      IF p_batch_history.event_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_history
              WHERE event_id = p_batch_history.event_id
         FOR UPDATE NOWAIT;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batch'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_history.batch_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         RETURN FALSE;
   END lock_row;
END gme_batch_history_dbl;

/
