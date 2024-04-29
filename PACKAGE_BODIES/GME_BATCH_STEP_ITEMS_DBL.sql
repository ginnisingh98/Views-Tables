--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_ITEMS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_ITEMS_DBL" AS
/* $Header: GMEVGSIB.pls 120.2.12010000.1 2008/07/25 10:30:53 appldev ship $ */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_ITEMS';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_BATCH_STEP_ITEMS_DBL';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |
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
 |      Insert_Row will insert a row in gme_batch_step_items
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_step_items
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_items IN            gme_batch_step_items%ROWTYPE
 |     x_batch_step_items IN OUT NOCOPY gme_batch_step_items%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   29-APR-04  Rishi Varma 3307549
 |              Added the fields minimum_transfer_qty,maximum_delay
 |       and minimum_delay.
 |   Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step_items   IN              gme_batch_step_items%ROWTYPE
     ,x_batch_step_items   IN OUT NOCOPY   gme_batch_step_items%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'insert_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_batch_step_items := p_batch_step_items;

      INSERT INTO gme_batch_step_items
                  (material_detail_id
                  ,batch_id
                  ,batchstep_id
                  ,text_code
                  ,minimum_transfer_qty
                  ,minimum_delay
                  ,maximum_delay
--Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
                  ,ATTRIBUTE_CATEGORY
	          ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
	          ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
	          ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15
                  ,ATTRIBUTE16
                  ,ATTRIBUTE17
                  ,ATTRIBUTE18
	          ,ATTRIBUTE19
                  ,ATTRIBUTE20
                  ,ATTRIBUTE21
                  ,ATTRIBUTE22
                  ,ATTRIBUTE23
                  ,ATTRIBUTE24
	          ,ATTRIBUTE25
                  ,ATTRIBUTE26
                  ,ATTRIBUTE27
                  ,ATTRIBUTE28
                  ,ATTRIBUTE29
                  ,ATTRIBUTE30
                  ,last_update_login, last_update_date
                  ,last_updated_by, creation_date
                  ,created_by)
           VALUES (x_batch_step_items.material_detail_id
                  ,x_batch_step_items.batch_id
                  ,x_batch_step_items.batchstep_id
                  ,x_batch_step_items.text_code
                  ,x_batch_step_items.minimum_transfer_qty
                  ,x_batch_step_items.minimum_delay
                  ,x_batch_step_items.maximum_delay
--Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
                  ,x_batch_step_items.ATTRIBUTE_CATEGORY
                  ,x_batch_step_items.ATTRIBUTE1
                  ,x_batch_step_items.ATTRIBUTE2
                  ,x_batch_step_items.ATTRIBUTE3
                  ,x_batch_step_items.ATTRIBUTE4
                  ,x_batch_step_items.ATTRIBUTE5
                  ,x_batch_step_items.ATTRIBUTE6
	          ,x_batch_step_items.ATTRIBUTE7
                  ,x_batch_step_items.ATTRIBUTE8
                  ,x_batch_step_items.ATTRIBUTE9
                  ,x_batch_step_items.ATTRIBUTE10
                  ,x_batch_step_items.ATTRIBUTE11
                  ,x_batch_step_items.ATTRIBUTE12
	          ,x_batch_step_items.ATTRIBUTE13
                  ,x_batch_step_items.ATTRIBUTE14
                  ,x_batch_step_items.ATTRIBUTE15
                  ,x_batch_step_items.ATTRIBUTE16
                  ,x_batch_step_items.ATTRIBUTE17
                  ,x_batch_step_items.ATTRIBUTE18
	          ,x_batch_step_items.ATTRIBUTE19
                  ,x_batch_step_items.ATTRIBUTE20
                  ,x_batch_step_items.ATTRIBUTE21
                  ,x_batch_step_items.ATTRIBUTE22
                  ,x_batch_step_items.ATTRIBUTE23
                  ,x_batch_step_items.ATTRIBUTE24
	          ,x_batch_step_items.ATTRIBUTE25
                  ,x_batch_step_items.ATTRIBUTE26
                  ,x_batch_step_items.ATTRIBUTE27
                  ,x_batch_step_items.ATTRIBUTE28
                  ,x_batch_step_items.ATTRIBUTE29
                  ,x_batch_step_items.ATTRIBUTE30
                  ,gme_common_pvt.g_login_id, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident);

      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
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
 |      Fetch_Row will fetch a row in gme_batch_step_items
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_step_items
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_items IN            gme_batch_step_items%ROWTYPE
 |     x_batch_step_items IN OUT NOCOPY gme_batch_step_items%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   29-APR-04  Rishi Varma 3307549
 |              Added the fields minimum_transfer_qty,maximum_delay
 |       and minimum_delay.
 |   Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_step_items   IN              gme_batch_step_items%ROWTYPE
     ,x_batch_step_items   IN OUT NOCOPY   gme_batch_step_items%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'fetch_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_items.material_detail_id IS NOT NULL THEN
         SELECT material_detail_id
               ,batch_id
               ,batchstep_id
               ,text_code
               ,minimum_transfer_qty
               ,minimum_delay
               ,maximum_delay
--Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
               ,ATTRIBUTE_CATEGORY
	       ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
	       ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
	       ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,ATTRIBUTE16
               ,ATTRIBUTE17
               ,ATTRIBUTE18
	       ,ATTRIBUTE19
               ,ATTRIBUTE20
               ,ATTRIBUTE21
               ,ATTRIBUTE22
               ,ATTRIBUTE23
               ,ATTRIBUTE24
	       ,ATTRIBUTE25
               ,ATTRIBUTE26
               ,ATTRIBUTE27
               ,ATTRIBUTE28
               ,ATTRIBUTE29
               ,ATTRIBUTE30
               ,last_update_login
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
           INTO x_batch_step_items.material_detail_id
               ,x_batch_step_items.batch_id
               ,x_batch_step_items.batchstep_id
               ,x_batch_step_items.text_code
               ,x_batch_step_items.minimum_transfer_qty
               ,x_batch_step_items.minimum_delay
               ,x_batch_step_items.maximum_delay
--Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
               ,x_batch_step_items.ATTRIBUTE_CATEGORY
               ,x_batch_step_items.ATTRIBUTE1
               ,x_batch_step_items.ATTRIBUTE2
               ,x_batch_step_items.ATTRIBUTE3
               ,x_batch_step_items.ATTRIBUTE4
               ,x_batch_step_items.ATTRIBUTE5
               ,x_batch_step_items.ATTRIBUTE6
	       ,x_batch_step_items.ATTRIBUTE7
               ,x_batch_step_items.ATTRIBUTE8
               ,x_batch_step_items.ATTRIBUTE9
               ,x_batch_step_items.ATTRIBUTE10
               ,x_batch_step_items.ATTRIBUTE11
               ,x_batch_step_items.ATTRIBUTE12
	       ,x_batch_step_items.ATTRIBUTE13
               ,x_batch_step_items.ATTRIBUTE14
               ,x_batch_step_items.ATTRIBUTE15
               ,x_batch_step_items.ATTRIBUTE16
               ,x_batch_step_items.ATTRIBUTE17
               ,x_batch_step_items.ATTRIBUTE18
	       ,x_batch_step_items.ATTRIBUTE19
               ,x_batch_step_items.ATTRIBUTE20
               ,x_batch_step_items.ATTRIBUTE21
               ,x_batch_step_items.ATTRIBUTE22
               ,x_batch_step_items.ATTRIBUTE23
               ,x_batch_step_items.ATTRIBUTE24
	       ,x_batch_step_items.ATTRIBUTE25
               ,x_batch_step_items.ATTRIBUTE26
               ,x_batch_step_items.ATTRIBUTE27
               ,x_batch_step_items.ATTRIBUTE28
               ,x_batch_step_items.ATTRIBUTE29
               ,x_batch_step_items.ATTRIBUTE30
               ,x_batch_step_items.last_update_login
               ,x_batch_step_items.last_update_date
               ,x_batch_step_items.last_updated_by
               ,x_batch_step_items.creation_date
               ,x_batch_step_items.created_by
           FROM gme_batch_step_items
          WHERE material_detail_id = p_batch_step_items.material_detail_id;
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
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
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
 |      Delete_Row will delete a row in gme_batch_step_items
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_step_items
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_items IN  gme_batch_step_items%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati Satpute  Bug2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (p_batch_step_items IN gme_batch_step_items%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'delete_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_items.material_detail_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_items
              WHERE material_detail_id = p_batch_step_items.material_detail_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_items
               WHERE material_detail_id =
                                         p_batch_step_items.material_detail_id;
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
         gme_common_pvt.log_message
                             ('GME_RECORD_LOCKED'
                             ,'TABLE_NAME'
                             ,g_table_name
                             ,'RECORD'
                             ,'Material detail id'
                             ,'KEY'
                             ,TO_CHAR (p_batch_step_items.material_detail_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
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
 |      Update_Row will update a row in gme_batch_step_items
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_step_items
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_items IN  gme_batch_step_items%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati Satpute  Bug2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |   13-MAY-04  Rishi Varma 3307549
 |              Added the fields minimum_transfer_qty,maximum_delay
 |       and minimum_delay.
 |   Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (p_batch_step_items IN gme_batch_step_items%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER (5)    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'update_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_items.material_detail_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_items
              WHERE material_detail_id = p_batch_step_items.material_detail_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_items
            SET batch_id = p_batch_step_items.batch_id
               ,batchstep_id = p_batch_step_items.batchstep_id
               ,text_code = p_batch_step_items.text_code
               ,minimum_transfer_qty = p_batch_step_items.minimum_transfer_qty
               ,minimum_delay = p_batch_step_items.minimum_delay
               ,maximum_delay = p_batch_step_items.maximum_delay
--Rajesh Patangya DFF Enhancement 03Jan2008 Bug# 6195829
               ,ATTRIBUTE_CATEGORY = p_batch_step_items.ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1 =  p_batch_step_items.ATTRIBUTE1
               ,ATTRIBUTE2 =  p_batch_step_items.ATTRIBUTE2
               ,ATTRIBUTE3 =  p_batch_step_items.ATTRIBUTE3
               ,ATTRIBUTE4 =  p_batch_step_items.ATTRIBUTE4
               ,ATTRIBUTE5 =  p_batch_step_items.ATTRIBUTE5
               ,ATTRIBUTE6  = p_batch_step_items.ATTRIBUTE6
               ,ATTRIBUTE7  = p_batch_step_items.ATTRIBUTE7
               ,ATTRIBUTE8  = p_batch_step_items.ATTRIBUTE8
               ,ATTRIBUTE9  = p_batch_step_items.ATTRIBUTE9
               ,ATTRIBUTE10 = p_batch_step_items.ATTRIBUTE10
               ,ATTRIBUTE11  =p_batch_step_items.ATTRIBUTE11
               ,ATTRIBUTE12  =p_batch_step_items.ATTRIBUTE12
               ,ATTRIBUTE13  =p_batch_step_items.ATTRIBUTE13
               ,ATTRIBUTE14  =p_batch_step_items.ATTRIBUTE14
               ,ATTRIBUTE15  =p_batch_step_items.ATTRIBUTE15
               ,ATTRIBUTE16 = p_batch_step_items.ATTRIBUTE16
               ,ATTRIBUTE17 = p_batch_step_items.ATTRIBUTE17
               ,ATTRIBUTE18 = p_batch_step_items.ATTRIBUTE18
               ,ATTRIBUTE19 = p_batch_step_items.ATTRIBUTE19
               ,ATTRIBUTE20 = p_batch_step_items.ATTRIBUTE20
               ,ATTRIBUTE21 = p_batch_step_items.ATTRIBUTE21
               ,ATTRIBUTE22 = p_batch_step_items.ATTRIBUTE22
               ,ATTRIBUTE23 = p_batch_step_items.ATTRIBUTE23
               ,ATTRIBUTE24 = p_batch_step_items.ATTRIBUTE24
               ,ATTRIBUTE25 = p_batch_step_items.ATTRIBUTE25
               ,ATTRIBUTE26 = p_batch_step_items.ATTRIBUTE26
               ,ATTRIBUTE27 = p_batch_step_items.ATTRIBUTE27
               ,ATTRIBUTE28 = p_batch_step_items.ATTRIBUTE28
               ,ATTRIBUTE29 = p_batch_step_items.ATTRIBUTE29
               ,ATTRIBUTE30 = p_batch_step_items.ATTRIBUTE30
               ,last_update_login = gme_common_pvt.g_login_id
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
          WHERE material_detail_id = p_batch_step_items.material_detail_id
            AND last_update_date = p_batch_step_items.last_update_date;
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
         gme_common_pvt.log_message
                             ('GME_RECORD_LOCKED'
                             ,'TABLE_NAME'
                             ,g_table_name
                             ,'RECORD'
                             ,'Material detail id'
                             ,'KEY'
                             ,TO_CHAR (p_batch_step_items.material_detail_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
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
 |      Lock_Row will lock a row in gme_batch_step_items
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_step_items
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_items IN  gme_batch_step_items%ROWTYPE
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
   FUNCTION lock_row (p_batch_step_items IN gme_batch_step_items%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy               NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30) := 'lock_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_items.material_detail_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_items
              WHERE material_detail_id = p_batch_step_items.material_detail_id
         FOR UPDATE NOWAIT;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message
                             ('GME_RECORD_LOCKED'
                             ,'TABLE_NAME'
                             ,g_table_name
                             ,'RECORD'
                             ,'Material detail id'
                             ,'KEY'
                             ,TO_CHAR (p_batch_step_items.material_detail_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         RETURN FALSE;
   END lock_row;
END gme_batch_step_items_dbl;

/
