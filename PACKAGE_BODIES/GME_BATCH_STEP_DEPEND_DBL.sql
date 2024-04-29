--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_DEPEND_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_DEPEND_DBL" AS
/* $Header: GMEVGSDB.pls 120.1 2005/06/03 13:46:57 appldev  $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_DEPENDENCIES';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |       GMEVGSDB.pls
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
 |      Insert_Row will insert a row in gme_batch_step_dependencies
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_step_dependencies
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_dependencies IN            gme_batch_step_dependencies%ROWTYPE
 |     x_batch_step_dependencies IN OUT NOCOPY gme_batch_step_dependencies%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   29-APR-04  Rishi Varma bug 3307549
 |    Added the chargeable_ind column.
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step_dependencies   IN              gme_batch_step_dependencies%ROWTYPE
     ,x_batch_step_dependencies   IN OUT NOCOPY   gme_batch_step_dependencies%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_batch_step_dependencies := p_batch_step_dependencies;

      INSERT INTO gme_batch_step_dependencies
                  (batch_id
                  ,batchstep_id
                  ,dep_type
                  ,dep_step_id
                  ,rework_code
                  ,standard_delay
                  ,min_delay
                  ,max_delay
                  ,transfer_qty
                  ,transfer_um
                  ,text_code
                  ,last_update_login, last_updated_by
                  ,created_by, creation_date
                  ,last_update_date
                  ,transfer_percent
                  ,attribute1
                  ,attribute2
                  ,attribute3
                  ,attribute4
                  ,attribute5
                  ,attribute6
                  ,attribute7
                  ,attribute8
                  ,attribute9
                  ,attribute10
                  ,attribute11
                  ,attribute12
                  ,attribute13
                  ,attribute14
                  ,attribute15
                  ,attribute16
                  ,attribute17
                  ,attribute18
                  ,attribute19
                  ,attribute20
                  ,attribute21
                  ,attribute22
                  ,attribute23
                  ,attribute24
                  ,attribute25
                  ,attribute26
                  ,attribute27
                  ,attribute28
                  ,attribute29
                  ,attribute30
                  ,attribute_category
                  ,chargeable_ind)
           VALUES (x_batch_step_dependencies.batch_id
                  ,x_batch_step_dependencies.batchstep_id
                  ,x_batch_step_dependencies.dep_type
                  ,x_batch_step_dependencies.dep_step_id
                  ,x_batch_step_dependencies.rework_code
                  ,x_batch_step_dependencies.standard_delay
                  ,x_batch_step_dependencies.min_delay
                  ,x_batch_step_dependencies.max_delay
                  ,x_batch_step_dependencies.transfer_qty
                  ,x_batch_step_dependencies.transfer_um
                  ,x_batch_step_dependencies.text_code
                  ,gme_common_pvt.g_login_id, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_timestamp
                  ,x_batch_step_dependencies.transfer_percent
                  ,x_batch_step_dependencies.attribute1
                  ,x_batch_step_dependencies.attribute2
                  ,x_batch_step_dependencies.attribute3
                  ,x_batch_step_dependencies.attribute4
                  ,x_batch_step_dependencies.attribute5
                  ,x_batch_step_dependencies.attribute6
                  ,x_batch_step_dependencies.attribute7
                  ,x_batch_step_dependencies.attribute8
                  ,x_batch_step_dependencies.attribute9
                  ,x_batch_step_dependencies.attribute10
                  ,x_batch_step_dependencies.attribute11
                  ,x_batch_step_dependencies.attribute12
                  ,x_batch_step_dependencies.attribute13
                  ,x_batch_step_dependencies.attribute14
                  ,x_batch_step_dependencies.attribute15
                  ,x_batch_step_dependencies.attribute16
                  ,x_batch_step_dependencies.attribute17
                  ,x_batch_step_dependencies.attribute18
                  ,x_batch_step_dependencies.attribute19
                  ,x_batch_step_dependencies.attribute20
                  ,x_batch_step_dependencies.attribute21
                  ,x_batch_step_dependencies.attribute22
                  ,x_batch_step_dependencies.attribute23
                  ,x_batch_step_dependencies.attribute24
                  ,x_batch_step_dependencies.attribute25
                  ,x_batch_step_dependencies.attribute26
                  ,x_batch_step_dependencies.attribute27
                  ,x_batch_step_dependencies.attribute28
                  ,x_batch_step_dependencies.attribute29
                  ,x_batch_step_dependencies.attribute30
                  ,x_batch_step_dependencies.attribute_category
                  ,x_batch_step_dependencies.chargeable_ind);

      RETURN TRUE;
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
 |      Fetch_Row will fetch a row in gme_batch_step_dependencies
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_step_dependencies
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_dependencies IN            gme_batch_step_dependencies%ROWTYPE
 |     x_batch_step_dependencies IN OUT NOCOPY gme_batch_step_dependencies%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   29-APR-04  Rishi Varma bug 3307549
 |    Added the chargeable_ind column.
 | | |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_step_dependencies   IN              gme_batch_step_dependencies%ROWTYPE
     ,x_batch_step_dependencies   IN OUT NOCOPY   gme_batch_step_dependencies%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF     p_batch_step_dependencies.batch_id IS NOT NULL
         AND p_batch_step_dependencies.batchstep_id IS NOT NULL
         AND p_batch_step_dependencies.dep_step_id IS NOT NULL THEN
         SELECT batch_id
               ,batchstep_id
               ,dep_type
               ,dep_step_id
               ,rework_code
               ,standard_delay
               ,min_delay
               ,max_delay
               ,transfer_qty
               ,transfer_um
               ,text_code
               ,last_update_login
               ,last_updated_by
               ,created_by
               ,creation_date
               ,last_update_date
               ,transfer_percent
               ,attribute1
               ,attribute2
               ,attribute3
               ,attribute4
               ,attribute5
               ,attribute6
               ,attribute7
               ,attribute8
               ,attribute9
               ,attribute10
               ,attribute11
               ,attribute12
               ,attribute13
               ,attribute14
               ,attribute15
               ,attribute16
               ,attribute17
               ,attribute18
               ,attribute19
               ,attribute20
               ,attribute21
               ,attribute22
               ,attribute23
               ,attribute24
               ,attribute25
               ,attribute26
               ,attribute27
               ,attribute28
               ,attribute29
               ,attribute30
               ,attribute_category
               ,chargeable_ind
           INTO x_batch_step_dependencies.batch_id
               ,x_batch_step_dependencies.batchstep_id
               ,x_batch_step_dependencies.dep_type
               ,x_batch_step_dependencies.dep_step_id
               ,x_batch_step_dependencies.rework_code
               ,x_batch_step_dependencies.standard_delay
               ,x_batch_step_dependencies.min_delay
               ,x_batch_step_dependencies.max_delay
               ,x_batch_step_dependencies.transfer_qty
               ,x_batch_step_dependencies.transfer_um
               ,x_batch_step_dependencies.text_code
               ,x_batch_step_dependencies.last_update_login
               ,x_batch_step_dependencies.last_updated_by
               ,x_batch_step_dependencies.created_by
               ,x_batch_step_dependencies.creation_date
               ,x_batch_step_dependencies.last_update_date
               ,x_batch_step_dependencies.transfer_percent
               ,x_batch_step_dependencies.attribute1
               ,x_batch_step_dependencies.attribute2
               ,x_batch_step_dependencies.attribute3
               ,x_batch_step_dependencies.attribute4
               ,x_batch_step_dependencies.attribute5
               ,x_batch_step_dependencies.attribute6
               ,x_batch_step_dependencies.attribute7
               ,x_batch_step_dependencies.attribute8
               ,x_batch_step_dependencies.attribute9
               ,x_batch_step_dependencies.attribute10
               ,x_batch_step_dependencies.attribute11
               ,x_batch_step_dependencies.attribute12
               ,x_batch_step_dependencies.attribute13
               ,x_batch_step_dependencies.attribute14
               ,x_batch_step_dependencies.attribute15
               ,x_batch_step_dependencies.attribute16
               ,x_batch_step_dependencies.attribute17
               ,x_batch_step_dependencies.attribute18
               ,x_batch_step_dependencies.attribute19
               ,x_batch_step_dependencies.attribute20
               ,x_batch_step_dependencies.attribute21
               ,x_batch_step_dependencies.attribute22
               ,x_batch_step_dependencies.attribute23
               ,x_batch_step_dependencies.attribute24
               ,x_batch_step_dependencies.attribute25
               ,x_batch_step_dependencies.attribute26
               ,x_batch_step_dependencies.attribute27
               ,x_batch_step_dependencies.attribute28
               ,x_batch_step_dependencies.attribute29
               ,x_batch_step_dependencies.attribute30
               ,x_batch_step_dependencies.attribute_category
               ,x_batch_step_dependencies.chargeable_ind
           FROM gme_batch_step_dependencies
          WHERE batch_id = p_batch_step_dependencies.batch_id
            AND batchstep_id = p_batch_step_dependencies.batchstep_id
            AND dep_step_id = p_batch_step_dependencies.dep_step_id;
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
 |      Delete_Row will delete a row in gme_batch_step_dependencies
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_step_dependencies
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_dependencies IN  gme_batch_step_dependencies%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-01  Bharati Satpute  bug2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (
      p_batch_step_dependencies   IN   gme_batch_step_dependencies%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER (5) := 0;
      x_batchstep_no         NUMBER;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF     p_batch_step_dependencies.batch_id IS NOT NULL
         AND p_batch_step_dependencies.batchstep_id IS NOT NULL
         AND p_batch_step_dependencies.dep_step_id IS NOT NULL THEN
         -- Bharati Satpute Selecting batchstep_no for message.
         SELECT batchstep_no
           INTO x_batchstep_no
           FROM gme_batch_steps
          WHERE batchstep_id = p_batch_step_dependencies.batchstep_id
            AND batch_id = p_batch_step_dependencies.batch_id;

         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_dependencies
              WHERE batch_id = p_batch_step_dependencies.batch_id
                AND batchstep_id = p_batch_step_dependencies.batchstep_id
                AND dep_step_id = p_batch_step_dependencies.dep_step_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_dependencies
               WHERE batch_id = p_batch_step_dependencies.batch_id
                 AND batchstep_id = p_batch_step_dependencies.batchstep_id
                 AND dep_step_id = p_batch_step_dependencies.dep_step_id;
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
                                    ,'Record'
                                    ,'Step No'
                                    ,'KEY'
                                    ,TO_CHAR (x_batchstep_no) );
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
 |      Update_Row will update a row in gme_batch_step_dependencies
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_step_dependencies
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_dependencies IN  gme_batch_step_dependencies%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-01  Bharati Satpute  bug2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |   13-MAY-04  Rishi Varma bug 3307549
 |    Added the chargeable_ind column.
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (
      p_batch_step_dependencies   IN   gme_batch_step_dependencies%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER    := 0;
      x_batchstep_no         NUMBER;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF     p_batch_step_dependencies.batch_id IS NOT NULL
         AND p_batch_step_dependencies.batchstep_id IS NOT NULL
         AND p_batch_step_dependencies.dep_step_id IS NOT NULL THEN
         -- Bharati Satpute Selecting batchstep_no for message.
         SELECT batchstep_no
           INTO x_batchstep_no
           FROM gme_batch_steps
          WHERE batchstep_id = p_batch_step_dependencies.batchstep_id
            AND batch_id = p_batch_step_dependencies.batch_id;

         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_dependencies
              WHERE batch_id = p_batch_step_dependencies.batch_id
                AND batchstep_id = p_batch_step_dependencies.batchstep_id
                AND dep_step_id = p_batch_step_dependencies.dep_step_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_dependencies
            SET dep_type = p_batch_step_dependencies.dep_type
               ,rework_code = p_batch_step_dependencies.rework_code
               ,standard_delay = p_batch_step_dependencies.standard_delay
               ,min_delay = p_batch_step_dependencies.min_delay
               ,max_delay = p_batch_step_dependencies.max_delay
               ,transfer_qty = p_batch_step_dependencies.transfer_qty
               ,transfer_um = p_batch_step_dependencies.transfer_um
               ,text_code = p_batch_step_dependencies.text_code
               ,last_update_login = gme_common_pvt.g_login_id
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,transfer_percent = p_batch_step_dependencies.transfer_percent
               ,attribute1 = p_batch_step_dependencies.attribute1
               ,attribute2 = p_batch_step_dependencies.attribute2
               ,attribute3 = p_batch_step_dependencies.attribute3
               ,attribute4 = p_batch_step_dependencies.attribute4
               ,attribute5 = p_batch_step_dependencies.attribute5
               ,attribute6 = p_batch_step_dependencies.attribute6
               ,attribute7 = p_batch_step_dependencies.attribute7
               ,attribute8 = p_batch_step_dependencies.attribute8
               ,attribute9 = p_batch_step_dependencies.attribute9
               ,attribute10 = p_batch_step_dependencies.attribute10
               ,attribute11 = p_batch_step_dependencies.attribute11
               ,attribute12 = p_batch_step_dependencies.attribute12
               ,attribute13 = p_batch_step_dependencies.attribute13
               ,attribute14 = p_batch_step_dependencies.attribute14
               ,attribute15 = p_batch_step_dependencies.attribute15
               ,attribute16 = p_batch_step_dependencies.attribute16
               ,attribute17 = p_batch_step_dependencies.attribute17
               ,attribute18 = p_batch_step_dependencies.attribute18
               ,attribute19 = p_batch_step_dependencies.attribute19
               ,attribute20 = p_batch_step_dependencies.attribute20
               ,attribute21 = p_batch_step_dependencies.attribute21
               ,attribute22 = p_batch_step_dependencies.attribute22
               ,attribute23 = p_batch_step_dependencies.attribute23
               ,attribute24 = p_batch_step_dependencies.attribute24
               ,attribute25 = p_batch_step_dependencies.attribute25
               ,attribute26 = p_batch_step_dependencies.attribute26
               ,attribute27 = p_batch_step_dependencies.attribute27
               ,attribute28 = p_batch_step_dependencies.attribute28
               ,attribute29 = p_batch_step_dependencies.attribute29
               ,attribute30 = p_batch_step_dependencies.attribute30
               ,attribute_category =
                                  p_batch_step_dependencies.attribute_category
               ,chargeable_ind = p_batch_step_dependencies.chargeable_ind
          WHERE batch_id = p_batch_step_dependencies.batch_id
            AND batchstep_id = p_batch_step_dependencies.batchstep_id
            AND dep_step_id = p_batch_step_dependencies.dep_step_id
            AND last_update_date = p_batch_step_dependencies.last_update_date;
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
                                    ,'Step No'
                                    ,'KEY'
                                    ,TO_CHAR (x_batchstep_no) );
         RETURN FALSE;
      WHEN OTHERS THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Step No'
                                    ,'KEY'
                                    ,TO_CHAR (x_batchstep_no) );
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
 |      Lock_Row will lock a row in gme_batch_step_dependencies
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_step_dependencies
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_dependencies IN  gme_batch_step_dependencies%ROWTYPE
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
   FUNCTION lock_row (
      p_batch_step_dependencies   IN   gme_batch_step_dependencies%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy          NUMBER;
      x_batchstep_no   NUMBER;
   BEGIN
      IF     p_batch_step_dependencies.batch_id IS NOT NULL
         AND p_batch_step_dependencies.batchstep_id IS NOT NULL
         AND p_batch_step_dependencies.dep_step_id IS NOT NULL THEN
         -- Bharati Satpute Selecting batchstep_no for message.
         SELECT batchstep_no
           INTO x_batchstep_no
           FROM gme_batch_steps
          WHERE batchstep_id = p_batch_step_dependencies.batchstep_id
            AND batch_id = p_batch_step_dependencies.batch_id;

         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_dependencies
              WHERE batch_id = p_batch_step_dependencies.batch_id
                AND batchstep_id = p_batch_step_dependencies.batchstep_id
                AND dep_step_id = p_batch_step_dependencies.dep_step_id
         FOR UPDATE NOWAIT;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Step No'
                                    ,'KEY'
                                    ,TO_CHAR (x_batchstep_no) );
         RETURN FALSE;
      WHEN OTHERS THEN
         RETURN FALSE;
   END lock_row;
END gme_batch_step_depend_dbl;

/
