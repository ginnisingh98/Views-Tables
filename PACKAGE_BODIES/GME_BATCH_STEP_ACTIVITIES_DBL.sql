--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_ACTIVITIES_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_ACTIVITIES_DBL" AS
/* $Header: GMEVGSAB.pls 120.1 2005/06/03 10:59:59 appldev  $ */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_ACTIVITIES';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_BATCH_STEP_ACTIVITIES_DBL';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGSAB.pls
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
 |   06-FEB-04 Rishi Varma Bug 3372774
 |             Added the max_break and break_ind fields to the
 |             insert_row,update_row and fetch_row procedures.
 |
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
 |      Insert_Row will insert a row in gme_batch_step_activities
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_step_activities
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_activities IN            gme_batch_step_activities%ROWTYPE
 |     x_batch_step_activities IN OUT NOCOPY gme_batch_step_activities%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   02-APR-03  Bharati Satpute  Bug 2848936 Added material_ind to complete MTQ
 |              functionality in APS
 |   06-FEB-04  Rishi Varma  Bug 3372774 Added break_ind,max_break fields.
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step_activities   IN              gme_batch_step_activities%ROWTYPE
     ,x_batch_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'insert_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_batch_step_activities := p_batch_step_activities;

      INSERT INTO gme_batch_step_activities
                  (batch_id
                  ,activity
                  ,batchstep_id
                  ,batchstep_activity_id
                  ,oprn_line_id
                  ,offset_interval
                  ,plan_start_date
                  ,actual_start_date
                  ,plan_cmplt_date
                  ,actual_cmplt_date
                  ,plan_activity_factor
                  ,sequence_dependent_ind
                  ,delete_mark
                  ,attribute_category
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
                  ,creation_date, created_by
                  ,last_update_date, last_updated_by
                  ,last_update_login
                  ,text_code
                  ,actual_activity_factor
                  ,material_ind
                  -- rishi 3372774 06-FEB-04 start
      ,            break_ind
                  ,max_break
                            --rishi 3372774 06-FEB-04 end
                  )
           VALUES (x_batch_step_activities.batch_id
                  ,x_batch_step_activities.activity
                  ,x_batch_step_activities.batchstep_id
                  ,gme_batch_step_activity_s.NEXTVAL
                  ,x_batch_step_activities.oprn_line_id
                  ,x_batch_step_activities.offset_interval
                  ,x_batch_step_activities.plan_start_date
                  ,x_batch_step_activities.actual_start_date
                  ,x_batch_step_activities.plan_cmplt_date
                  ,x_batch_step_activities.actual_cmplt_date
                  ,x_batch_step_activities.plan_activity_factor
                  ,x_batch_step_activities.sequence_dependent_ind
                  ,x_batch_step_activities.delete_mark
                  ,x_batch_step_activities.attribute_category
                  ,x_batch_step_activities.attribute1
                  ,x_batch_step_activities.attribute2
                  ,x_batch_step_activities.attribute3
                  ,x_batch_step_activities.attribute4
                  ,x_batch_step_activities.attribute5
                  ,x_batch_step_activities.attribute6
                  ,x_batch_step_activities.attribute7
                  ,x_batch_step_activities.attribute8
                  ,x_batch_step_activities.attribute9
                  ,x_batch_step_activities.attribute10
                  ,x_batch_step_activities.attribute11
                  ,x_batch_step_activities.attribute12
                  ,x_batch_step_activities.attribute13
                  ,x_batch_step_activities.attribute14
                  ,x_batch_step_activities.attribute15
                  ,x_batch_step_activities.attribute16
                  ,x_batch_step_activities.attribute17
                  ,x_batch_step_activities.attribute18
                  ,x_batch_step_activities.attribute19
                  ,x_batch_step_activities.attribute20
                  ,x_batch_step_activities.attribute21
                  ,x_batch_step_activities.attribute22
                  ,x_batch_step_activities.attribute23
                  ,x_batch_step_activities.attribute24
                  ,x_batch_step_activities.attribute25
                  ,x_batch_step_activities.attribute26
                  ,x_batch_step_activities.attribute27
                  ,x_batch_step_activities.attribute28
                  ,x_batch_step_activities.attribute29
                  ,x_batch_step_activities.attribute30
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id
                  ,x_batch_step_activities.text_code
                  ,x_batch_step_activities.actual_activity_factor
                  ,x_batch_step_activities.material_ind
                  --rishi 3372774 06-FEB-2004 start
      ,            x_batch_step_activities.break_ind
                  ,x_batch_step_activities.max_break
                                                    --rishi 3372774 06-FEB-2004 end
                  )
        RETURNING batchstep_activity_id
             INTO x_batch_step_activities.batchstep_activity_id;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
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
 |      Fetch_Row will fetch a row in gme_batch_step_activities
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_step_activities
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_activities IN            gme_batch_step_activities%ROWTYPE
 |     x_batch_step_activities IN OUT NOCOPY gme_batch_step_activities%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   02-APR-03  Bharati Satpute  Added material_ind to complete MTQ
 |              functionality in APS
 |   06-FEB-2004 Rishi Varma  Bug#3372774 Added break_ind,max_break fields.
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_step_activities   IN              gme_batch_step_activities%ROWTYPE
     ,x_batch_step_activities   IN OUT NOCOPY   gme_batch_step_activities%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'fetch_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_activities.batchstep_activity_id IS NOT NULL THEN
         SELECT batch_id
               ,activity
               ,batchstep_id
               ,batchstep_activity_id
               ,oprn_line_id
               ,offset_interval
               ,plan_start_date
               ,actual_start_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,plan_activity_factor
               ,sequence_dependent_ind
               ,delete_mark
               ,attribute_category
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
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login
               ,text_code
               ,actual_activity_factor
               ,material_ind
               --rishi 3372774 06-FEB-2004 start
         ,      break_ind
               ,max_break
           --rishi 3372774 06-FEB-2004 end
         INTO   x_batch_step_activities.batch_id
               ,x_batch_step_activities.activity
               ,x_batch_step_activities.batchstep_id
               ,x_batch_step_activities.batchstep_activity_id
               ,x_batch_step_activities.oprn_line_id
               ,x_batch_step_activities.offset_interval
               ,x_batch_step_activities.plan_start_date
               ,x_batch_step_activities.actual_start_date
               ,x_batch_step_activities.plan_cmplt_date
               ,x_batch_step_activities.actual_cmplt_date
               ,x_batch_step_activities.plan_activity_factor
               ,x_batch_step_activities.sequence_dependent_ind
               ,x_batch_step_activities.delete_mark
               ,x_batch_step_activities.attribute_category
               ,x_batch_step_activities.attribute1
               ,x_batch_step_activities.attribute2
               ,x_batch_step_activities.attribute3
               ,x_batch_step_activities.attribute4
               ,x_batch_step_activities.attribute5
               ,x_batch_step_activities.attribute6
               ,x_batch_step_activities.attribute7
               ,x_batch_step_activities.attribute8
               ,x_batch_step_activities.attribute9
               ,x_batch_step_activities.attribute10
               ,x_batch_step_activities.attribute11
               ,x_batch_step_activities.attribute12
               ,x_batch_step_activities.attribute13
               ,x_batch_step_activities.attribute14
               ,x_batch_step_activities.attribute15
               ,x_batch_step_activities.attribute16
               ,x_batch_step_activities.attribute17
               ,x_batch_step_activities.attribute18
               ,x_batch_step_activities.attribute19
               ,x_batch_step_activities.attribute20
               ,x_batch_step_activities.attribute21
               ,x_batch_step_activities.attribute22
               ,x_batch_step_activities.attribute23
               ,x_batch_step_activities.attribute24
               ,x_batch_step_activities.attribute25
               ,x_batch_step_activities.attribute26
               ,x_batch_step_activities.attribute27
               ,x_batch_step_activities.attribute28
               ,x_batch_step_activities.attribute29
               ,x_batch_step_activities.attribute30
               ,x_batch_step_activities.creation_date
               ,x_batch_step_activities.created_by
               ,x_batch_step_activities.last_update_date
               ,x_batch_step_activities.last_updated_by
               ,x_batch_step_activities.last_update_login
               ,x_batch_step_activities.text_code
               ,x_batch_step_activities.actual_activity_factor
               ,x_batch_step_activities.material_ind
               --rishi 3372774 06-FEB-2004 start
         ,      x_batch_step_activities.break_ind
               ,x_batch_step_activities.max_break
           --rishi 3372774 06-FEB-2004 end
         FROM   gme_batch_step_activities
          WHERE batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id;
      ELSIF     p_batch_step_activities.batch_id IS NOT NULL
            AND p_batch_step_activities.batchstep_id IS NOT NULL
            AND p_batch_step_activities.activity IS NOT NULL THEN
         SELECT batch_id
               ,activity
               ,batchstep_id
               ,batchstep_activity_id
               ,oprn_line_id
               ,offset_interval
               ,plan_start_date
               ,actual_start_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,plan_activity_factor
               ,sequence_dependent_ind
               ,delete_mark
               ,attribute_category
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
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login
               ,text_code
               ,actual_activity_factor
               ,material_ind
               --rishi 3372774 06-FEB-04 start
         ,      break_ind
               ,max_break
           --rishi 3372774 06-FEB-04 end
         INTO   x_batch_step_activities.batch_id
               ,x_batch_step_activities.activity
               ,x_batch_step_activities.batchstep_id
               ,x_batch_step_activities.batchstep_activity_id
               ,x_batch_step_activities.oprn_line_id
               ,x_batch_step_activities.offset_interval
               ,x_batch_step_activities.plan_start_date
               ,x_batch_step_activities.actual_start_date
               ,x_batch_step_activities.plan_cmplt_date
               ,x_batch_step_activities.actual_cmplt_date
               ,x_batch_step_activities.plan_activity_factor
               ,x_batch_step_activities.sequence_dependent_ind
               ,x_batch_step_activities.delete_mark
               ,x_batch_step_activities.attribute_category
               ,x_batch_step_activities.attribute1
               ,x_batch_step_activities.attribute2
               ,x_batch_step_activities.attribute3
               ,x_batch_step_activities.attribute4
               ,x_batch_step_activities.attribute5
               ,x_batch_step_activities.attribute6
               ,x_batch_step_activities.attribute7
               ,x_batch_step_activities.attribute8
               ,x_batch_step_activities.attribute9
               ,x_batch_step_activities.attribute10
               ,x_batch_step_activities.attribute11
               ,x_batch_step_activities.attribute12
               ,x_batch_step_activities.attribute13
               ,x_batch_step_activities.attribute14
               ,x_batch_step_activities.attribute15
               ,x_batch_step_activities.attribute16
               ,x_batch_step_activities.attribute17
               ,x_batch_step_activities.attribute18
               ,x_batch_step_activities.attribute19
               ,x_batch_step_activities.attribute20
               ,x_batch_step_activities.attribute21
               ,x_batch_step_activities.attribute22
               ,x_batch_step_activities.attribute23
               ,x_batch_step_activities.attribute24
               ,x_batch_step_activities.attribute25
               ,x_batch_step_activities.attribute26
               ,x_batch_step_activities.attribute27
               ,x_batch_step_activities.attribute28
               ,x_batch_step_activities.attribute29
               ,x_batch_step_activities.attribute30
               ,x_batch_step_activities.creation_date
               ,x_batch_step_activities.created_by
               ,x_batch_step_activities.last_update_date
               ,x_batch_step_activities.last_updated_by
               ,x_batch_step_activities.last_update_login
               ,x_batch_step_activities.text_code
               ,x_batch_step_activities.actual_activity_factor
               ,x_batch_step_activities.material_ind
               --rishi 3372774 06-FEB-2004 start
         ,      x_batch_step_activities.break_ind
               ,x_batch_step_activities.max_break
           --rishi 3372774 06-FEB-2004 end
         FROM   gme_batch_step_activities
          WHERE batch_id = p_batch_step_activities.batch_id
            AND batchstep_id = p_batch_step_activities.batchstep_id
            AND activity = p_batch_step_activities.activity;
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
 |      Delete_Row will delete a row in gme_batch_step_activities
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_step_activities
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_activities IN  gme_batch_step_activities%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati satpute  Bug2404126
 |   Added Error message ' GME_RECORD_CHANGED' |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (
      p_batch_step_activities   IN   gme_batch_step_activities%ROWTYPE)
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

      IF p_batch_step_activities.batchstep_activity_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_activities
               WHERE batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id;
      ELSIF     p_batch_step_activities.batch_id IS NOT NULL
            AND p_batch_step_activities.batchstep_id IS NOT NULL
            AND p_batch_step_activities.activity IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batch_id = p_batch_step_activities.batch_id
                AND batchstep_id = p_batch_step_activities.batchstep_id
                AND activity = p_batch_step_activities.activity
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_activities
               WHERE batch_id = p_batch_step_activities.batch_id
                 AND batchstep_id = p_batch_step_activities.batchstep_id
                 AND activity = p_batch_step_activities.activity;
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
            gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                       ,'TABLE_NAME'
                                       ,g_table_name);
         END IF;

         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Activities'
                                    ,'KEY'
                                    ,p_batch_step_activities.activity);
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
 |      Update_Row will update a row in gme_batch_step_activities
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_step_activities
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_activities IN  gme_batch_step_activities%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   23-AUG-02  Bharati Satpute Added message GME_RECORD_CHANGED
 |   10-FEB-04  Rishi Varma Bug# 3372774 Added max_break,break_ind columns.
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (
      p_batch_step_activities   IN   gme_batch_step_activities%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'update_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_activities.batchstep_activity_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_activities
            SET batch_id = p_batch_step_activities.batch_id
               ,activity = p_batch_step_activities.activity
               ,batchstep_id = p_batch_step_activities.batchstep_id
               ,oprn_line_id = p_batch_step_activities.oprn_line_id
               ,offset_interval = p_batch_step_activities.offset_interval
               ,plan_start_date = p_batch_step_activities.plan_start_date
               ,actual_start_date = p_batch_step_activities.actual_start_date
               ,plan_cmplt_date = p_batch_step_activities.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step_activities.actual_cmplt_date
               ,plan_activity_factor =
                                  p_batch_step_activities.plan_activity_factor
               ,sequence_dependent_ind =
                                p_batch_step_activities.sequence_dependent_ind
               ,delete_mark = p_batch_step_activities.delete_mark
               ,attribute_category =
                                    p_batch_step_activities.attribute_category
               ,attribute1 = p_batch_step_activities.attribute1
               ,attribute2 = p_batch_step_activities.attribute2
               ,attribute3 = p_batch_step_activities.attribute3
               ,attribute4 = p_batch_step_activities.attribute4
               ,attribute5 = p_batch_step_activities.attribute5
               ,attribute6 = p_batch_step_activities.attribute6
               ,attribute7 = p_batch_step_activities.attribute7
               ,attribute8 = p_batch_step_activities.attribute8
               ,attribute9 = p_batch_step_activities.attribute9
               ,attribute10 = p_batch_step_activities.attribute10
               ,attribute11 = p_batch_step_activities.attribute11
               ,attribute12 = p_batch_step_activities.attribute12
               ,attribute13 = p_batch_step_activities.attribute13
               ,attribute14 = p_batch_step_activities.attribute14
               ,attribute15 = p_batch_step_activities.attribute15
               ,attribute16 = p_batch_step_activities.attribute16
               ,attribute17 = p_batch_step_activities.attribute17
               ,attribute18 = p_batch_step_activities.attribute18
               ,attribute19 = p_batch_step_activities.attribute19
               ,attribute20 = p_batch_step_activities.attribute20
               ,attribute21 = p_batch_step_activities.attribute21
               ,attribute22 = p_batch_step_activities.attribute22
               ,attribute23 = p_batch_step_activities.attribute23
               ,attribute24 = p_batch_step_activities.attribute24
               ,attribute25 = p_batch_step_activities.attribute25
               ,attribute26 = p_batch_step_activities.attribute26
               ,attribute27 = p_batch_step_activities.attribute27
               ,attribute28 = p_batch_step_activities.attribute28
               ,attribute29 = p_batch_step_activities.attribute29
               ,attribute30 = p_batch_step_activities.attribute30
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,text_code = p_batch_step_activities.text_code
               ,actual_activity_factor =
                                p_batch_step_activities.actual_activity_factor
               ,material_ind = p_batch_step_activities.material_ind
               --rishi 3372774 10-FEB-2004 start
         ,      break_ind = p_batch_step_activities.break_ind
               ,max_break = p_batch_step_activities.max_break
          --rishi 3372774 10-FEB-2004 end
         WHERE  batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id
            AND last_update_date = p_batch_step_activities.last_update_date;
      ELSIF     p_batch_step_activities.batch_id IS NOT NULL
            AND p_batch_step_activities.batchstep_id IS NOT NULL
            AND p_batch_step_activities.activity IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batch_id = p_batch_step_activities.batch_id
                AND batchstep_id = p_batch_step_activities.batchstep_id
                AND activity = p_batch_step_activities.activity
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_activities
            SET batch_id = p_batch_step_activities.batch_id
               ,activity = p_batch_step_activities.activity
               ,batchstep_id = p_batch_step_activities.batchstep_id
               ,oprn_line_id = p_batch_step_activities.oprn_line_id
               ,offset_interval = p_batch_step_activities.offset_interval
               ,plan_start_date = p_batch_step_activities.plan_start_date
               ,actual_start_date = p_batch_step_activities.actual_start_date
               ,plan_cmplt_date = p_batch_step_activities.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step_activities.actual_cmplt_date
               ,plan_activity_factor =
                                  p_batch_step_activities.plan_activity_factor
               ,sequence_dependent_ind =
                                p_batch_step_activities.sequence_dependent_ind
               ,delete_mark = p_batch_step_activities.delete_mark
               ,attribute_category =
                                    p_batch_step_activities.attribute_category
               ,attribute1 = p_batch_step_activities.attribute1
               ,attribute2 = p_batch_step_activities.attribute2
               ,attribute3 = p_batch_step_activities.attribute3
               ,attribute4 = p_batch_step_activities.attribute4
               ,attribute5 = p_batch_step_activities.attribute5
               ,attribute6 = p_batch_step_activities.attribute6
               ,attribute7 = p_batch_step_activities.attribute7
               ,attribute8 = p_batch_step_activities.attribute8
               ,attribute9 = p_batch_step_activities.attribute9
               ,attribute10 = p_batch_step_activities.attribute10
               ,attribute11 = p_batch_step_activities.attribute11
               ,attribute12 = p_batch_step_activities.attribute12
               ,attribute13 = p_batch_step_activities.attribute13
               ,attribute14 = p_batch_step_activities.attribute14
               ,attribute15 = p_batch_step_activities.attribute15
               ,attribute16 = p_batch_step_activities.attribute16
               ,attribute17 = p_batch_step_activities.attribute17
               ,attribute18 = p_batch_step_activities.attribute18
               ,attribute19 = p_batch_step_activities.attribute19
               ,attribute20 = p_batch_step_activities.attribute20
               ,attribute21 = p_batch_step_activities.attribute21
               ,attribute22 = p_batch_step_activities.attribute22
               ,attribute23 = p_batch_step_activities.attribute23
               ,attribute24 = p_batch_step_activities.attribute24
               ,attribute25 = p_batch_step_activities.attribute25
               ,attribute26 = p_batch_step_activities.attribute26
               ,attribute27 = p_batch_step_activities.attribute27
               ,attribute28 = p_batch_step_activities.attribute28
               ,attribute29 = p_batch_step_activities.attribute29
               ,attribute30 = p_batch_step_activities.attribute30
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,text_code = p_batch_step_activities.text_code
               ,actual_activity_factor =
                                p_batch_step_activities.actual_activity_factor
               ,material_ind = p_batch_step_activities.material_ind
               --rishi 3372774 10-FEB-2004 start
         ,      break_ind = p_batch_step_activities.break_ind
               ,max_break = p_batch_step_activities.max_break
          --rishi 3372774 10-FEB-2004 end
         WHERE  batch_id = p_batch_step_activities.batch_id
            AND batchstep_id = p_batch_step_activities.batchstep_id
            AND activity = p_batch_step_activities.activity
            AND last_update_date = p_batch_step_activities.last_update_date;
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
                                    ,'Activities'
                                    ,'KEY'
                                    ,p_batch_step_activities.activity);
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
 |      Lock_Row will lock a row in gme_batch_step_activities
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_step_activities
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_activities IN  gme_batch_step_activities%ROWTYPE
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
      p_batch_step_activities   IN   gme_batch_step_activities%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy               NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30) := 'lock_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_activities.batchstep_activity_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batchstep_activity_id =
                                 p_batch_step_activities.batchstep_activity_id
         FOR UPDATE NOWAIT;
      ELSIF     p_batch_step_activities.batch_id IS NOT NULL
            AND p_batch_step_activities.batchstep_id IS NOT NULL
            AND p_batch_step_activities.activity IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_activities
              WHERE batch_id = p_batch_step_activities.batch_id
                AND batchstep_id = p_batch_step_activities.batchstep_id
                AND activity = p_batch_step_activities.activity
         FOR UPDATE NOWAIT;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Activities'
                                    ,'KEY'
                                    ,p_batch_step_activities.activity);
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
END gme_batch_step_activities_dbl;

/
