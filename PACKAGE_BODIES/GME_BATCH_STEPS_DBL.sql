--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEPS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEPS_DBL" AS
/*  $Header: GMEVGBSB.pls 120.3 2006/06/14 14:43:18 svgonugu noship $    */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_BATCH_STEPS';
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'gme_batch_step_dbl';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGBSB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package gme_batch_steps_dbl                                |
 |                                                                         |
 |  NOTES                                                                  |
 |  HISTORY                                                                |
 |                                                                         |
 |  13-Feb-01 Created                                                      |
 |                                                                         |
 |             - create_row                                                |
 |             - fetch_row                                                 |
 |             - update_row                                                |
 |             - delete_row                                                |
 |             - lock_row                                                  |
 |  07-Sep-01 Thomas Daniel                                                |
 |            Added plan_mass_qty and plan_volume_qty in the procedures.   |
 |  30-AUG-02 Chandrashekar Tiruvidula Bug 2526710                         |
 |            Added quality_status in insert/update/fetch                  |
 |  07-Mar-03 Bharati Satpute  Bug2804440  Added WHEN OTHERS exception     |
 |       which were not defined
 | Oct 2003    A. Newbury                                                  |
 |             - B3184949 Added terminate_ind for terminate batch enh.     |
 |     09-JUN-2006 SivakumarG    Now fetch_row will fetch max_step_capacity |
 |                               uom also.Bug#5231180                       |
 ===========================================================================
*/

   /*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    insert_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   insert_Row will insert a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   insert_Row will insert a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step IN gme_batch_step%ROWTYPE                                |
 |    x_batch_steps IN OUT NOCOPY gme_batch_step%ROWTYPE                    |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     15-FEB-2001  fabdi        Created                                    |
 |     02-APR-03  Bharati Satpute Bug2848936  Added minimum_transfer_qty to |
 |                complete MTQ functionality in APS                         |
 |     Oct 2003     A. Newbury   Added terminated_ind for terminate batch   |
 |                               enh B3184949.                              |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step   IN              gme_batch_steps%ROWTYPE
     ,x_batch_step   IN OUT NOCOPY   gme_batch_steps%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'INSERT_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_batch_step := p_batch_step;

      INSERT INTO gme_batch_steps
                  (batch_id, batchstep_id
                  ,routingstep_id, batchstep_no
                  ,oprn_id, plan_step_qty
                  ,actual_step_qty
                                  --, STEP_QTY_UOM
      ,            backflush_qty
                  ,plan_start_date
                  ,actual_start_date, due_date
                  ,plan_cmplt_date
                  ,actual_cmplt_date
                  ,step_close_date, step_status
                  ,priority_code, priority_value
                  ,delete_mark, steprelease_type
                  ,max_step_capacity
                                    --, MAX_STEP_CAPACITY_UOM
      ,            plan_charges
                  ,actual_charges, text_code
                  ,last_update_date, creation_date
                  ,created_by, last_updated_by
                  ,last_update_login
                  ,attribute_category, attribute1
                  ,attribute2, attribute3
                  ,attribute4, attribute5
                  ,attribute6, attribute7
                  ,attribute8, attribute9
                  ,attribute10, attribute11
                  ,attribute12, attribute13
                  ,attribute14, attribute15
                  ,attribute16, attribute17
                  ,attribute18, attribute19
                  ,attribute20, attribute21
                  ,attribute22, attribute23
                  ,attribute24, attribute25
                  ,attribute26, attribute27
                  ,attribute28, attribute29
                  ,attribute30
                              --, MASS_REF_UOM
                              --, VOLUME_REF_UOM
      ,            plan_mass_qty
                  ,plan_volume_qty
                  ,actual_mass_qty
                  ,actual_volume_qty
                  ,quality_status
                  ,minimum_transfer_qty, terminated_ind
                  ,step_qty_um
                  ,mass_ref_um
                  ,max_step_capacity_um
                  ,volume_ref_um)
           VALUES (x_batch_step.batch_id, gme_batch_step_s.NEXTVAL
                  ,x_batch_step.routingstep_id, x_batch_step.batchstep_no
                  ,x_batch_step.oprn_id, x_batch_step.plan_step_qty
                  ,x_batch_step.actual_step_qty
                                               --, x_batch_step.STEP_QTY_UOM
      ,            x_batch_step.backflush_qty
                  ,x_batch_step.plan_start_date
                  ,x_batch_step.actual_start_date, x_batch_step.due_date
                  ,x_batch_step.plan_cmplt_date
                  ,x_batch_step.actual_cmplt_date
                  ,x_batch_step.step_close_date, x_batch_step.step_status
                  ,x_batch_step.priority_code, x_batch_step.priority_value
                  ,x_batch_step.delete_mark, x_batch_step.steprelease_type
                  ,x_batch_step.max_step_capacity
                                                 --, x_batch_step.MAX_STEP_CAPACITY_UOM
      ,            x_batch_step.plan_charges
                  ,x_batch_step.actual_charges, x_batch_step.text_code
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id
                  ,x_batch_step.attribute_category, x_batch_step.attribute1
                  ,x_batch_step.attribute2, x_batch_step.attribute3
                  ,x_batch_step.attribute4, x_batch_step.attribute5
                  ,x_batch_step.attribute6, x_batch_step.attribute7
                  ,x_batch_step.attribute8, x_batch_step.attribute9
                  ,x_batch_step.attribute10, x_batch_step.attribute11
                  ,x_batch_step.attribute12, x_batch_step.attribute13
                  ,x_batch_step.attribute14, x_batch_step.attribute15
                  ,x_batch_step.attribute16, x_batch_step.attribute17
                  ,x_batch_step.attribute18, x_batch_step.attribute19
                  ,x_batch_step.attribute20, x_batch_step.attribute21
                  ,x_batch_step.attribute22, x_batch_step.attribute23
                  ,x_batch_step.attribute24, x_batch_step.attribute25
                  ,x_batch_step.attribute26, x_batch_step.attribute27
                  ,x_batch_step.attribute28, x_batch_step.attribute29
                  ,x_batch_step.attribute30
                                           --, x_batch_step.MASS_REF_UOM
                                           --, x_batch_step.VOLUME_REF_UOM
      ,            x_batch_step.plan_mass_qty
                  ,x_batch_step.plan_volume_qty
                  ,x_batch_step.actual_mass_qty
                  ,x_batch_step.actual_volume_qty
                  ,x_batch_step.quality_status
                  ,x_batch_step.minimum_transfer_qty, 0
                  ,x_batch_step.step_qty_um
                  ,x_batch_step.mass_ref_um
                  ,x_batch_step.max_step_capacity_um
                  ,x_batch_step.volume_ref_um)
        RETURNING batchstep_id
             INTO x_batch_step.batchstep_id;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_batch_step.batchstep_id := NULL;
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR'
                                    ,SQLERRM);
         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END insert_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    fetch_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   fetch_Row will fetch a row in  gme_batch_steps                        |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_row will fetch a row in  gme_batch_steps                        |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step IN gme_batch_steps%ROWTYPE                            |
 |    x_batch_steps IN OUT NOCOPY gme_batch_steps%ROWTYPE                           |
 | RETURNS                                                                  |
 |    BOOLEAN                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |     Oct 2003     A. Newbury   Added terminated_ind for terminate batch   |
 |                               enh B3184949.                              |
 |     09-JUN-2006 SivakumarG    Now fetch_row will fetch max_step_capacity |
 |                               uom also.Bug#5231180                       |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_step   IN              gme_batch_steps%ROWTYPE
     ,x_batch_step   IN OUT NOCOPY   gme_batch_steps%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'FETCH_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step.batchstep_id IS NOT NULL THEN
         SELECT batch_id, batchstep_id
               ,routingstep_id, batchstep_no
               ,oprn_id, plan_step_qty
               ,actual_step_qty
                               --, STEP_QTY_UOM
         ,      backflush_qty
               ,plan_start_date
               ,actual_start_date, due_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,step_close_date, step_status
               ,priority_code, priority_value
               ,delete_mark, steprelease_type
               ,max_step_capacity
                                 --, MAX_STEP_CAPACITY_UOM
         ,      plan_charges
               ,actual_charges, text_code
               ,last_update_date, creation_date
               ,created_by, last_updated_by
               ,last_update_login
               ,attribute_category, attribute1
               ,attribute2, attribute3
               ,attribute4, attribute5
               ,attribute6, attribute7
               ,attribute8, attribute9
               ,attribute10, attribute11
               ,attribute12, attribute13
               ,attribute14, attribute15
               ,attribute16, attribute17
               ,attribute18, attribute19
               ,attribute20, attribute21
               ,attribute22, attribute23
               ,attribute24, attribute25
               ,attribute26, attribute27
               ,attribute28, attribute29
               ,attribute30
                           --, MASS_REF_UOM
                           --, VOLUME_REF_UOM
         ,      plan_mass_qty
               ,plan_volume_qty, actual_mass_qty
               ,actual_volume_qty, quality_status
               ,minimum_transfer_qty
               ,terminated_ind, step_qty_um
               ,mass_ref_um, volume_ref_um
	       ,max_step_capacity_um  --Bug#5231180
           INTO x_batch_step.batch_id, x_batch_step.batchstep_id
               ,x_batch_step.routingstep_id, x_batch_step.batchstep_no
               ,x_batch_step.oprn_id, x_batch_step.plan_step_qty
               ,x_batch_step.actual_step_qty
                                            --, x_batch_step.STEP_QTY_UOM
         ,      x_batch_step.backflush_qty
               ,x_batch_step.plan_start_date
               ,x_batch_step.actual_start_date, x_batch_step.due_date
               ,x_batch_step.plan_cmplt_date
               ,x_batch_step.actual_cmplt_date
               ,x_batch_step.step_close_date, x_batch_step.step_status
               ,x_batch_step.priority_code, x_batch_step.priority_value
               ,x_batch_step.delete_mark, x_batch_step.steprelease_type
               ,x_batch_step.max_step_capacity
                                              --, x_batch_step.MAX_STEP_CAPACITY_UOM
         ,      x_batch_step.plan_charges
               ,x_batch_step.actual_charges, x_batch_step.text_code
               ,x_batch_step.last_update_date, x_batch_step.creation_date
               ,x_batch_step.created_by, x_batch_step.last_updated_by
               ,x_batch_step.last_update_login
               ,x_batch_step.attribute_category, x_batch_step.attribute1
               ,x_batch_step.attribute2, x_batch_step.attribute3
               ,x_batch_step.attribute4, x_batch_step.attribute5
               ,x_batch_step.attribute6, x_batch_step.attribute7
               ,x_batch_step.attribute8, x_batch_step.attribute9
               ,x_batch_step.attribute10, x_batch_step.attribute11
               ,x_batch_step.attribute12, x_batch_step.attribute13
               ,x_batch_step.attribute14, x_batch_step.attribute15
               ,x_batch_step.attribute16, x_batch_step.attribute17
               ,x_batch_step.attribute18, x_batch_step.attribute19
               ,x_batch_step.attribute20, x_batch_step.attribute21
               ,x_batch_step.attribute22, x_batch_step.attribute23
               ,x_batch_step.attribute24, x_batch_step.attribute25
               ,x_batch_step.attribute26, x_batch_step.attribute27
               ,x_batch_step.attribute28, x_batch_step.attribute29
               ,x_batch_step.attribute30
                                        --, x_batch_step.MASS_REF_UOM
                                        --, x_batch_step.VOLUME_REF_UOM
         ,      x_batch_step.plan_mass_qty
               ,x_batch_step.plan_volume_qty, x_batch_step.actual_mass_qty
               ,x_batch_step.actual_volume_qty, x_batch_step.quality_status
               ,x_batch_step.minimum_transfer_qty
               ,x_batch_step.terminated_ind, x_batch_step.step_qty_um
               ,x_batch_step.mass_ref_um, x_batch_step.volume_ref_um
	       ,x_batch_step.max_step_capacity_um   --Bug#5231180
           FROM gme_batch_steps
          WHERE batchstep_id = p_batch_step.batchstep_id;
      ELSIF     p_batch_step.batch_id IS NOT NULL
            AND p_batch_step.batchstep_no IS NOT NULL THEN
         SELECT batch_id, batchstep_id
               ,routingstep_id, batchstep_no
               ,oprn_id, plan_step_qty
               ,actual_step_qty
                               --, STEP_QTY_UOM
         ,      backflush_qty
               ,plan_start_date
               ,actual_start_date, due_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,step_close_date, step_status
               ,priority_code, priority_value
               ,delete_mark, steprelease_type
               ,max_step_capacity
                                 --, MAX_STEP_CAPACITY_UOM
         ,      plan_charges
               ,actual_charges, text_code
               ,last_update_date, creation_date
               ,created_by, last_updated_by
               ,last_update_login
               ,attribute_category, attribute1
               ,attribute2, attribute3
               ,attribute4, attribute5
               ,attribute6, attribute7
               ,attribute8, attribute9
               ,attribute10, attribute11
               ,attribute12, attribute13
               ,attribute14, attribute15
               ,attribute16, attribute17
               ,attribute18, attribute19
               ,attribute20, attribute21
               ,attribute22, attribute23
               ,attribute24, attribute25
               ,attribute26, attribute27
               ,attribute28, attribute29
               ,attribute30
                           --, MASS_REF_UOM
                           --, VOLUME_REF_UOM
         ,      plan_mass_qty
               ,plan_volume_qty, actual_mass_qty
               ,actual_volume_qty, quality_status
               ,minimum_transfer_qty
               ,terminated_ind, step_qty_um
               ,mass_ref_um, volume_ref_um
	       ,max_step_capacity_um --Bug#5231180
           INTO x_batch_step.batch_id, x_batch_step.batchstep_id
               ,x_batch_step.routingstep_id, x_batch_step.batchstep_no
               ,x_batch_step.oprn_id, x_batch_step.plan_step_qty
               ,x_batch_step.actual_step_qty
                                            --, x_batch_step.STEP_QTY_UOM
         ,      x_batch_step.backflush_qty
               ,x_batch_step.plan_start_date
               ,x_batch_step.actual_start_date, x_batch_step.due_date
               ,x_batch_step.plan_cmplt_date
               ,x_batch_step.actual_cmplt_date
               ,x_batch_step.step_close_date, x_batch_step.step_status
               ,x_batch_step.priority_code, x_batch_step.priority_value
               ,x_batch_step.delete_mark, x_batch_step.steprelease_type
               ,x_batch_step.max_step_capacity
                                              --, x_batch_step.MAX_STEP_CAPACITY_UOM
         ,      x_batch_step.plan_charges
               ,x_batch_step.actual_charges, x_batch_step.text_code
               ,x_batch_step.last_update_date, x_batch_step.creation_date
               ,x_batch_step.created_by, x_batch_step.last_updated_by
               ,x_batch_step.last_update_login
               ,x_batch_step.attribute_category, x_batch_step.attribute1
               ,x_batch_step.attribute2, x_batch_step.attribute3
               ,x_batch_step.attribute4, x_batch_step.attribute5
               ,x_batch_step.attribute6, x_batch_step.attribute7
               ,x_batch_step.attribute8, x_batch_step.attribute9
               ,x_batch_step.attribute10, x_batch_step.attribute11
               ,x_batch_step.attribute12, x_batch_step.attribute13
               ,x_batch_step.attribute14, x_batch_step.attribute15
               ,x_batch_step.attribute16, x_batch_step.attribute17
               ,x_batch_step.attribute18, x_batch_step.attribute19
               ,x_batch_step.attribute20, x_batch_step.attribute21
               ,x_batch_step.attribute22, x_batch_step.attribute23
               ,x_batch_step.attribute24, x_batch_step.attribute25
               ,x_batch_step.attribute26, x_batch_step.attribute27
               ,x_batch_step.attribute28, x_batch_step.attribute29
               ,x_batch_step.attribute30
                                        --, x_batch_step.MASS_REF_UOM
                                        --, x_batch_step.VOLUME_REF_UOM
         ,      x_batch_step.plan_mass_qty
               ,x_batch_step.plan_volume_qty, x_batch_step.actual_mass_qty
               ,x_batch_step.actual_volume_qty, x_batch_step.quality_status
               ,x_batch_step.minimum_transfer_qty
               ,x_batch_step.terminated_ind, x_batch_step.step_qty_um
               ,x_batch_step.mass_ref_um, x_batch_step.volume_ref_um
	       ,x_batch_step.max_step_capacity_um   --Bug#5231180
           FROM gme_batch_steps
          WHERE batch_id = p_batch_step.batch_id
            AND batchstep_no = p_batch_step.batchstep_no;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
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
         --bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END fetch_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    delete_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   delete_Row will delete a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   delete_row will delete a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step IN gme_batch_steps%ROWTYPE                               |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |     23-AUG-2002  Bharati Satpute  Bug 2404126                            |
 |     Added message GME_RECORD_CHANGED                                     |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION delete_row (p_batch_step IN gme_batch_steps%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER (5)    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'DELETE_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step.batchstep_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_steps
              WHERE batchstep_id = p_batch_step.batchstep_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_steps
               WHERE batchstep_id = p_batch_step.batchstep_id;
      ELSIF     p_batch_step.batch_id IS NOT NULL
            AND p_batch_step.batchstep_no IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_steps
              WHERE batch_id = p_batch_step.batch_id
                AND batchstep_no = p_batch_step.batchstep_no
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_steps
               WHERE batch_id = p_batch_step.batch_id
                 AND batchstep_no = p_batch_step.batchstep_no;
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
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batchstep'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_step.batchstep_no) );
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
         --bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END delete_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    update_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   update_row will update a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   update_row will update a row in  gme_batch_steps                       |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_step IN gme_batch_steps%ROWTYPE                               |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |     23-AUG-2002  Bharati Satpute  Bug 2404126                            |
 |     Added message GME_RECORD_CHANGED                                     |
 |     Oct 2003     A. Newbury   Added terminated_ind for terminate batch   |
 |                               enh B3184949.                              |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION update_row (p_batch_step IN gme_batch_steps%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'UPDATE_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step.batchstep_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_steps
              WHERE batchstep_id = p_batch_step.batchstep_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_steps
            SET routingstep_id = p_batch_step.routingstep_id
               ,batchstep_no = p_batch_step.batchstep_no
               ,oprn_id = p_batch_step.oprn_id
               ,plan_step_qty = p_batch_step.plan_step_qty
               ,actual_step_qty = p_batch_step.actual_step_qty
               --,STEP_QTY_UOM=p_batch_step.step_qty_uom
         ,      backflush_qty = p_batch_step.backflush_qty
               ,plan_start_date = p_batch_step.plan_start_date
               ,actual_start_date = p_batch_step.actual_start_date
               ,due_date = p_batch_step.due_date
               ,plan_cmplt_date = p_batch_step.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step.actual_cmplt_date
               ,step_close_date = p_batch_step.step_close_date
               ,step_status = p_batch_step.step_status
               ,priority_code = p_batch_step.priority_code
               ,priority_value = p_batch_step.priority_value
               ,delete_mark = p_batch_step.delete_mark
               ,steprelease_type = p_batch_step.steprelease_type
               ,max_step_capacity = p_batch_step.max_step_capacity
               --,MAX_STEP_CAPACITY_UOM=p_batch_step.max_step_capacity_uom
         ,      plan_charges = p_batch_step.plan_charges
               ,actual_charges = p_batch_step.actual_charges
               ,text_code = p_batch_step.text_code
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,attribute_category = p_batch_step.attribute_category
               ,attribute1 = p_batch_step.attribute1
               ,attribute2 = p_batch_step.attribute2
               ,attribute3 = p_batch_step.attribute3
               ,attribute4 = p_batch_step.attribute4
               ,attribute5 = p_batch_step.attribute5
               ,attribute6 = p_batch_step.attribute6
               ,attribute7 = p_batch_step.attribute7
               ,attribute8 = p_batch_step.attribute8
               ,attribute9 = p_batch_step.attribute9
               ,attribute10 = p_batch_step.attribute10
               ,attribute11 = p_batch_step.attribute11
               ,attribute12 = p_batch_step.attribute12
               ,attribute13 = p_batch_step.attribute13
               ,attribute14 = p_batch_step.attribute14
               ,attribute15 = p_batch_step.attribute15
               ,attribute16 = p_batch_step.attribute16
               ,attribute17 = p_batch_step.attribute17
               ,attribute18 = p_batch_step.attribute18
               ,attribute19 = p_batch_step.attribute19
               ,attribute20 = p_batch_step.attribute20
               ,attribute21 = p_batch_step.attribute21
               ,attribute22 = p_batch_step.attribute22
               ,attribute23 = p_batch_step.attribute23
               ,attribute24 = p_batch_step.attribute24
               ,attribute25 = p_batch_step.attribute25
               ,attribute26 = p_batch_step.attribute26
               ,attribute27 = p_batch_step.attribute27
               ,attribute28 = p_batch_step.attribute28
               ,attribute29 = p_batch_step.attribute29
               ,attribute30 = p_batch_step.attribute30
               --,MASS_REF_UOM=p_batch_step.mass_ref_uom
               --,VOLUME_REF_UOM=p_batch_step.volume_ref_uom
         ,      plan_mass_qty = p_batch_step.plan_mass_qty
               ,plan_volume_qty = p_batch_step.plan_volume_qty
               ,actual_mass_qty = p_batch_step.actual_mass_qty
               ,actual_volume_qty = p_batch_step.actual_volume_qty
               ,quality_status = p_batch_step.quality_status
               ,minimum_transfer_qty = p_batch_step.minimum_transfer_qty
               ,terminated_ind = p_batch_step.terminated_ind
               ,step_qty_um = p_batch_step.step_qty_um
               ,mass_ref_um = p_batch_step.mass_ref_um
               ,volume_ref_um = p_batch_step.volume_ref_um
          WHERE batchstep_id = p_batch_step.batchstep_id
            AND last_update_date = p_batch_step.last_update_date;
      ELSIF     p_batch_step.batch_id IS NOT NULL
            AND p_batch_step.batchstep_no IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_steps
              WHERE batch_id = p_batch_step.batch_id
                AND batchstep_no = p_batch_step.batchstep_no
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_steps
            SET routingstep_id = p_batch_step.routingstep_id
               ,batchstep_no = p_batch_step.batchstep_no
               ,oprn_id = p_batch_step.oprn_id
               ,plan_step_qty = p_batch_step.plan_step_qty
               ,actual_step_qty = p_batch_step.actual_step_qty
               --,STEP_QTY_UOM=p_batch_step.step_qty_uom
         ,      backflush_qty = p_batch_step.backflush_qty
               ,plan_start_date = p_batch_step.plan_start_date
               ,actual_start_date = p_batch_step.actual_start_date
               ,due_date = p_batch_step.due_date
               ,plan_cmplt_date = p_batch_step.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step.actual_cmplt_date
               ,step_close_date = p_batch_step.step_close_date
               ,step_status = p_batch_step.step_status
               ,priority_code = p_batch_step.priority_code
               ,priority_value = p_batch_step.priority_value
               ,delete_mark = p_batch_step.delete_mark
               ,steprelease_type = p_batch_step.steprelease_type
               ,max_step_capacity = p_batch_step.max_step_capacity
               --,MAX_STEP_CAPACITY_UOM=p_batch_step.max_step_capacity_uom
         ,      plan_charges = p_batch_step.plan_charges
               ,actual_charges = p_batch_step.actual_charges
               ,text_code = p_batch_step.text_code
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,attribute_category = p_batch_step.attribute_category
               ,attribute1 = p_batch_step.attribute1
               ,attribute2 = p_batch_step.attribute2
               ,attribute3 = p_batch_step.attribute3
               ,attribute4 = p_batch_step.attribute4
               ,attribute5 = p_batch_step.attribute5
               ,attribute6 = p_batch_step.attribute6
               ,attribute7 = p_batch_step.attribute7
               ,attribute8 = p_batch_step.attribute8
               ,attribute9 = p_batch_step.attribute9
               ,attribute10 = p_batch_step.attribute10
               ,attribute11 = p_batch_step.attribute11
               ,attribute12 = p_batch_step.attribute12
               ,attribute13 = p_batch_step.attribute13
               ,attribute14 = p_batch_step.attribute14
               ,attribute15 = p_batch_step.attribute15
               ,attribute16 = p_batch_step.attribute16
               ,attribute17 = p_batch_step.attribute17
               ,attribute18 = p_batch_step.attribute18
               ,attribute19 = p_batch_step.attribute19
               ,attribute20 = p_batch_step.attribute20
               ,attribute21 = p_batch_step.attribute21
               ,attribute22 = p_batch_step.attribute22
               ,attribute23 = p_batch_step.attribute23
               ,attribute24 = p_batch_step.attribute24
               ,attribute25 = p_batch_step.attribute25
               ,attribute26 = p_batch_step.attribute26
               ,attribute27 = p_batch_step.attribute27
               ,attribute28 = p_batch_step.attribute28
               ,attribute29 = p_batch_step.attribute29
               ,attribute30 = p_batch_step.attribute30
               --,MASS_REF_UOM=p_batch_step.mass_ref_uom
               --,VOLUME_REF_UOM=p_batch_step.volume_ref_uom
         ,      plan_mass_qty = p_batch_step.plan_mass_qty
               ,plan_volume_qty = p_batch_step.plan_volume_qty
               ,actual_mass_qty = p_batch_step.actual_mass_qty
               ,actual_volume_qty = p_batch_step.actual_volume_qty
               ,quality_status = p_batch_step.quality_status
               ,minimum_transfer_qty = p_batch_step.minimum_transfer_qty
               ,terminated_ind = p_batch_step.terminated_ind
               ,step_qty_um = p_batch_step.step_qty_um
               ,mass_ref_um = p_batch_step.mass_ref_um
               ,volume_ref_um = p_batch_step.volume_ref_um
          WHERE batch_id = p_batch_step.batch_id
            AND batchstep_no = p_batch_step.batchstep_no;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RAISE NO_DATA_FOUND;
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
                                    ,'Batchstep'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_step.batchstep_no) );
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
         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END update_row;

   FUNCTION lock_row (p_batch_step IN gme_batch_steps%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy               NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30) := 'lock_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step.batchstep_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_steps
              WHERE batchstep_id = p_batch_step.batchstep_id
         FOR UPDATE NOWAIT;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batchstep'
                                    ,'KEY'
                                    ,TO_CHAR (p_batch_step.batchstep_no) );
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

         --Bug2804440
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END;
END;

/
