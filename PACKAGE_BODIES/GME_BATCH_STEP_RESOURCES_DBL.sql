--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_RESOURCES_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_RESOURCES_DBL" AS
/* $Header: GMEVGSRB.pls 120.1 2005/06/03 11:00:34 appldev  $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_RESOURCES';
   g_debug        VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name     VARCHAR2 (30) := 'GME_BATCH_STEP_RESOURCES_DBL';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGSRB.pls
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
 |   24-OCT-01  Pawan Kumar  Added sequence_dependent_id and sequence_dependent_usage
 |   16-JAN-02  Sanrda Dulyk Added capacity_tolerance
     11-MAY-04  Rishi Varma  3307549
                Added firm_type,group_sequence_id and group_sequence_number
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
 |      Insert_Row will insert a row in gme_batch_step_resources
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_step_resources
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_resources IN            gme_batch_step_resources%ROWTYPE
 |     x_batch_step_resources IN OUT NOCOPY gme_batch_step_resources%ROWTYPE
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
      p_batch_step_resources   IN              gme_batch_step_resources%ROWTYPE
     ,x_batch_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'insert_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_batch_step_resources := p_batch_step_resources;

      INSERT INTO gme_batch_step_resources
                  (batchstep_resource_id
                  ,batchstep_activity_id
                  ,resources
                  ,cost_analysis_code
                  ,cost_cmpntcls_id
                  ,prim_rsrc_ind
                  ,scale_type
                  ,plan_rsrc_count
                  ,actual_rsrc_count
                  --,RESOURCE_QTY_UOM
      ,            plan_rsrc_usage
                  ,actual_rsrc_usage
                  --,USAGE_UOM
      ,            plan_start_date
                  ,actual_start_date
                  ,plan_cmplt_date
                  ,actual_cmplt_date
                  ,offset_interval
                  ,min_capacity
                  ,max_capacity
                  ,process_parameter_1
                  ,process_parameter_2
                  ,process_parameter_3
                  ,process_parameter_4
                  ,process_parameter_5
                  ,sequence_dependent_id
                  ,sequence_dependent_usage
                  ,capacity_tolerance
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
                  ,last_update_date, last_updated_by
                  ,created_by, creation_date
                  ,text_code
                  ,batch_id
                  ,batchstep_id
                  --,CAPACITY_UOM
      ,            actual_rsrc_qty
                  ,plan_rsrc_qty
                  ,last_update_login
                  ,calculate_charges
                  ,original_rsrc_qty
                  ,original_rsrc_usage
                  ,firm_type
                  ,group_sequence_id
                  ,group_sequence_number
                  ,capacity_um
                  ,usage_um
                  ,resource_qty_um
                  ,organization_id)
           VALUES (gem5_batchstepline_id_s.NEXTVAL
                  ,x_batch_step_resources.batchstep_activity_id
                  ,x_batch_step_resources.resources
                  ,x_batch_step_resources.cost_analysis_code
                  ,x_batch_step_resources.cost_cmpntcls_id
                  ,x_batch_step_resources.prim_rsrc_ind
                  ,x_batch_step_resources.scale_type
                  ,x_batch_step_resources.plan_rsrc_count
                  ,x_batch_step_resources.actual_rsrc_count
                  --,x_batch_step_resources.RESOURCE_QTY_UOM
      ,            x_batch_step_resources.plan_rsrc_usage
                  ,x_batch_step_resources.actual_rsrc_usage
                  --,x_batch_step_resources.USAGE_UOM
      ,            x_batch_step_resources.plan_start_date
                  ,x_batch_step_resources.actual_start_date
                  ,x_batch_step_resources.plan_cmplt_date
                  ,x_batch_step_resources.actual_cmplt_date
                  ,x_batch_step_resources.offset_interval
                  ,x_batch_step_resources.min_capacity
                  ,x_batch_step_resources.max_capacity
                  ,x_batch_step_resources.process_parameter_1
                  ,x_batch_step_resources.process_parameter_2
                  ,x_batch_step_resources.process_parameter_3
                  ,x_batch_step_resources.process_parameter_4
                  ,x_batch_step_resources.process_parameter_5
                  ,x_batch_step_resources.sequence_dependent_id
                  ,x_batch_step_resources.sequence_dependent_usage
                  ,x_batch_step_resources.capacity_tolerance
                  ,x_batch_step_resources.attribute_category
                  ,x_batch_step_resources.attribute1
                  ,x_batch_step_resources.attribute2
                  ,x_batch_step_resources.attribute3
                  ,x_batch_step_resources.attribute4
                  ,x_batch_step_resources.attribute5
                  ,x_batch_step_resources.attribute6
                  ,x_batch_step_resources.attribute7
                  ,x_batch_step_resources.attribute8
                  ,x_batch_step_resources.attribute9
                  ,x_batch_step_resources.attribute10
                  ,x_batch_step_resources.attribute11
                  ,x_batch_step_resources.attribute12
                  ,x_batch_step_resources.attribute13
                  ,x_batch_step_resources.attribute14
                  ,x_batch_step_resources.attribute15
                  ,x_batch_step_resources.attribute16
                  ,x_batch_step_resources.attribute17
                  ,x_batch_step_resources.attribute18
                  ,x_batch_step_resources.attribute19
                  ,x_batch_step_resources.attribute20
                  ,x_batch_step_resources.attribute21
                  ,x_batch_step_resources.attribute22
                  ,x_batch_step_resources.attribute23
                  ,x_batch_step_resources.attribute24
                  ,x_batch_step_resources.attribute25
                  ,x_batch_step_resources.attribute26
                  ,x_batch_step_resources.attribute27
                  ,x_batch_step_resources.attribute28
                  ,x_batch_step_resources.attribute29
                  ,x_batch_step_resources.attribute30
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,x_batch_step_resources.text_code
                  ,x_batch_step_resources.batch_id
                  ,x_batch_step_resources.batchstep_id
                  --,x_batch_step_resources.CAPACITY_UOM
      ,            x_batch_step_resources.actual_rsrc_qty
                  ,x_batch_step_resources.plan_rsrc_qty
                  ,gme_common_pvt.g_login_id
                  ,x_batch_step_resources.calculate_charges
                  ,x_batch_step_resources.original_rsrc_qty
                  ,x_batch_step_resources.original_rsrc_usage
                  ,x_batch_step_resources.firm_type
                  ,x_batch_step_resources.group_sequence_id
                  ,x_batch_step_resources.group_sequence_number
                  ,x_batch_step_resources.capacity_um
                  ,x_batch_step_resources.usage_um
                  ,x_batch_step_resources.resource_qty_um
                  ,x_batch_step_resources.organization_id)
        RETURNING batchstep_resource_id
             INTO x_batch_step_resources.batchstep_resource_id;

      IF SQL%FOUND THEN
         x_batch_step_resources.created_by := gme_common_pvt.g_user_ident;
         x_batch_step_resources.creation_date := gme_common_pvt.g_timestamp;
         x_batch_step_resources.last_updated_by :=
                                                  gme_common_pvt.g_user_ident;
         x_batch_step_resources.last_update_date :=
                                                   gme_common_pvt.g_timestamp;
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
 |      Fetch_Row will fetch a row in gme_batch_step_resources
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_step_resources
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_resources IN             gme_batch_step_resources%ROWTYPE
 |     x_batch_step_resources IN OUT NOCOPY  gme_batch_step_resources%ROWTYPE
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
      p_batch_step_resources   IN              gme_batch_step_resources%ROWTYPE
     ,x_batch_step_resources   IN OUT NOCOPY   gme_batch_step_resources%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'fetch_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_resources.batchstep_resource_id IS NOT NULL THEN
         SELECT batchstep_resource_id
               ,batchstep_activity_id
               ,resources
               ,cost_analysis_code
               ,cost_cmpntcls_id
               ,prim_rsrc_ind
               ,scale_type
               ,plan_rsrc_count
               ,actual_rsrc_count
               --,RESOURCE_QTY_UOM
         ,      plan_rsrc_usage
               ,actual_rsrc_usage
               --,USAGE_UOM
         ,      plan_start_date
               ,actual_start_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,offset_interval
               ,min_capacity
               ,max_capacity
               ,process_parameter_1
               ,process_parameter_2
               ,process_parameter_3
               ,process_parameter_4
               ,process_parameter_5
               ,sequence_dependent_id
               ,sequence_dependent_usage
               ,capacity_tolerance
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
               ,last_update_date
               ,last_updated_by
               ,created_by
               ,creation_date
               ,text_code
               ,batch_id
               ,batchstep_id
               --,CAPACITY_UOM
         ,      actual_rsrc_qty
               ,plan_rsrc_qty
               ,last_update_login
               ,calculate_charges
               ,original_rsrc_qty
               ,original_rsrc_usage
               ,firm_type
               ,group_sequence_id
               ,group_sequence_number
               ,capacity_um
               ,usage_um
               ,resource_qty_um
               ,organization_id
           INTO x_batch_step_resources.batchstep_resource_id
               ,x_batch_step_resources.batchstep_activity_id
               ,x_batch_step_resources.resources
               ,x_batch_step_resources.cost_analysis_code
               ,x_batch_step_resources.cost_cmpntcls_id
               ,x_batch_step_resources.prim_rsrc_ind
               ,x_batch_step_resources.scale_type
               ,x_batch_step_resources.plan_rsrc_count
               ,x_batch_step_resources.actual_rsrc_count
               --,x_batch_step_resources.RESOURCE_QTY_UOM
         ,      x_batch_step_resources.plan_rsrc_usage
               ,x_batch_step_resources.actual_rsrc_usage
               --,x_batch_step_resources.USAGE_UOM
         ,      x_batch_step_resources.plan_start_date
               ,x_batch_step_resources.actual_start_date
               ,x_batch_step_resources.plan_cmplt_date
               ,x_batch_step_resources.actual_cmplt_date
               ,x_batch_step_resources.offset_interval
               ,x_batch_step_resources.min_capacity
               ,x_batch_step_resources.max_capacity
               ,x_batch_step_resources.process_parameter_1
               ,x_batch_step_resources.process_parameter_2
               ,x_batch_step_resources.process_parameter_3
               ,x_batch_step_resources.process_parameter_4
               ,x_batch_step_resources.process_parameter_5
               ,x_batch_step_resources.sequence_dependent_id
               ,x_batch_step_resources.sequence_dependent_usage
               ,x_batch_step_resources.capacity_tolerance
               ,x_batch_step_resources.attribute_category
               ,x_batch_step_resources.attribute1
               ,x_batch_step_resources.attribute2
               ,x_batch_step_resources.attribute3
               ,x_batch_step_resources.attribute4
               ,x_batch_step_resources.attribute5
               ,x_batch_step_resources.attribute6
               ,x_batch_step_resources.attribute7
               ,x_batch_step_resources.attribute8
               ,x_batch_step_resources.attribute9
               ,x_batch_step_resources.attribute10
               ,x_batch_step_resources.attribute11
               ,x_batch_step_resources.attribute12
               ,x_batch_step_resources.attribute13
               ,x_batch_step_resources.attribute14
               ,x_batch_step_resources.attribute15
               ,x_batch_step_resources.attribute16
               ,x_batch_step_resources.attribute17
               ,x_batch_step_resources.attribute18
               ,x_batch_step_resources.attribute19
               ,x_batch_step_resources.attribute20
               ,x_batch_step_resources.attribute21
               ,x_batch_step_resources.attribute22
               ,x_batch_step_resources.attribute23
               ,x_batch_step_resources.attribute24
               ,x_batch_step_resources.attribute25
               ,x_batch_step_resources.attribute26
               ,x_batch_step_resources.attribute27
               ,x_batch_step_resources.attribute28
               ,x_batch_step_resources.attribute29
               ,x_batch_step_resources.attribute30
               ,x_batch_step_resources.last_update_date
               ,x_batch_step_resources.last_updated_by
               ,x_batch_step_resources.created_by
               ,x_batch_step_resources.creation_date
               ,x_batch_step_resources.text_code
               ,x_batch_step_resources.batch_id
               ,x_batch_step_resources.batchstep_id
               --,x_batch_step_resources.CAPACITY_UOM
         ,      x_batch_step_resources.actual_rsrc_qty
               ,x_batch_step_resources.plan_rsrc_qty
               ,x_batch_step_resources.last_update_login
               ,x_batch_step_resources.calculate_charges
               ,x_batch_step_resources.original_rsrc_qty
               ,x_batch_step_resources.original_rsrc_usage
               ,x_batch_step_resources.firm_type
               ,x_batch_step_resources.group_sequence_id
               ,x_batch_step_resources.group_sequence_number
               ,x_batch_step_resources.capacity_um
               ,x_batch_step_resources.usage_um
               ,x_batch_step_resources.resource_qty_um
               ,x_batch_step_resources.organization_id
           FROM gme_batch_step_resources
          WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id;
      ELSIF     p_batch_step_resources.batchstep_activity_id IS NOT NULL
            AND p_batch_step_resources.resources IS NOT NULL THEN
         SELECT batchstep_resource_id
               ,batchstep_activity_id
               ,resources
               ,cost_analysis_code
               ,cost_cmpntcls_id
               ,prim_rsrc_ind
               ,scale_type
               ,plan_rsrc_count
               ,actual_rsrc_count
               --,RESOURCE_QTY_UOM
         ,      plan_rsrc_usage
               ,actual_rsrc_usage
               --,USAGE_UOM
         ,      plan_start_date
               ,actual_start_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,offset_interval
               ,min_capacity
               ,max_capacity
               ,process_parameter_1
               ,process_parameter_2
               ,process_parameter_3
               ,process_parameter_4
               ,process_parameter_5
               ,sequence_dependent_id
               ,sequence_dependent_usage
               ,capacity_tolerance
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
               ,last_update_date
               ,last_updated_by
               ,created_by
               ,creation_date
               ,text_code
               ,batch_id
               ,batchstep_id
               --,CAPACITY_UOM
         ,      actual_rsrc_qty
               ,plan_rsrc_qty
               ,last_update_login
               ,calculate_charges
               ,original_rsrc_qty
               ,original_rsrc_usage
               ,firm_type
               ,group_sequence_id
               ,group_sequence_number
               ,capacity_um
               ,usage_um
               ,resource_qty_um
               ,organization_id
           INTO x_batch_step_resources.batchstep_resource_id
               ,x_batch_step_resources.batchstep_activity_id
               ,x_batch_step_resources.resources
               ,x_batch_step_resources.cost_analysis_code
               ,x_batch_step_resources.cost_cmpntcls_id
               ,x_batch_step_resources.prim_rsrc_ind
               ,x_batch_step_resources.scale_type
               ,x_batch_step_resources.plan_rsrc_count
               ,x_batch_step_resources.actual_rsrc_count
               --,x_batch_step_resources.RESOURCE_QTY_UOM
         ,      x_batch_step_resources.plan_rsrc_usage
               ,x_batch_step_resources.actual_rsrc_usage
               --,x_batch_step_resources.USAGE_UOM
         ,      x_batch_step_resources.plan_start_date
               ,x_batch_step_resources.actual_start_date
               ,x_batch_step_resources.plan_cmplt_date
               ,x_batch_step_resources.actual_cmplt_date
               ,x_batch_step_resources.offset_interval
               ,x_batch_step_resources.min_capacity
               ,x_batch_step_resources.max_capacity
               ,x_batch_step_resources.process_parameter_1
               ,x_batch_step_resources.process_parameter_2
               ,x_batch_step_resources.process_parameter_3
               ,x_batch_step_resources.process_parameter_4
               ,x_batch_step_resources.process_parameter_5
               ,x_batch_step_resources.sequence_dependent_id
               ,x_batch_step_resources.sequence_dependent_usage
               ,x_batch_step_resources.capacity_tolerance
               ,x_batch_step_resources.attribute_category
               ,x_batch_step_resources.attribute1
               ,x_batch_step_resources.attribute2
               ,x_batch_step_resources.attribute3
               ,x_batch_step_resources.attribute4
               ,x_batch_step_resources.attribute5
               ,x_batch_step_resources.attribute6
               ,x_batch_step_resources.attribute7
               ,x_batch_step_resources.attribute8
               ,x_batch_step_resources.attribute9
               ,x_batch_step_resources.attribute10
               ,x_batch_step_resources.attribute11
               ,x_batch_step_resources.attribute12
               ,x_batch_step_resources.attribute13
               ,x_batch_step_resources.attribute14
               ,x_batch_step_resources.attribute15
               ,x_batch_step_resources.attribute16
               ,x_batch_step_resources.attribute17
               ,x_batch_step_resources.attribute18
               ,x_batch_step_resources.attribute19
               ,x_batch_step_resources.attribute20
               ,x_batch_step_resources.attribute21
               ,x_batch_step_resources.attribute22
               ,x_batch_step_resources.attribute23
               ,x_batch_step_resources.attribute24
               ,x_batch_step_resources.attribute25
               ,x_batch_step_resources.attribute26
               ,x_batch_step_resources.attribute27
               ,x_batch_step_resources.attribute28
               ,x_batch_step_resources.attribute29
               ,x_batch_step_resources.attribute30
               ,x_batch_step_resources.last_update_date
               ,x_batch_step_resources.last_updated_by
               ,x_batch_step_resources.created_by
               ,x_batch_step_resources.creation_date
               ,x_batch_step_resources.text_code
               ,x_batch_step_resources.batch_id
               ,x_batch_step_resources.batchstep_id
               --,x_batch_step_resources.CAPACITY_UOM
         ,      x_batch_step_resources.actual_rsrc_qty
               ,x_batch_step_resources.plan_rsrc_qty
               ,x_batch_step_resources.last_update_login
               ,x_batch_step_resources.calculate_charges
               ,x_batch_step_resources.original_rsrc_qty
               ,x_batch_step_resources.original_rsrc_usage
               ,x_batch_step_resources.firm_type
               ,x_batch_step_resources.group_sequence_id
               ,x_batch_step_resources.group_sequence_number
               ,x_batch_step_resources.capacity_um
               ,x_batch_step_resources.usage_um
               ,x_batch_step_resources.resource_qty_um
               ,x_batch_step_resources.organization_id
           FROM gme_batch_step_resources
          WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
            AND resources = p_batch_step_resources.resources;
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
 |      Delete_Row will delete a row in gme_batch_step_resources
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_step_resources
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_resources IN  gme_batch_step_resources%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati Satpute  Bug 2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (
      p_batch_step_resources   IN   gme_batch_step_resources%ROWTYPE)
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

      IF p_batch_step_resources.batchstep_resource_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_resources
               WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id;
      ELSIF     p_batch_step_resources.batchstep_activity_id IS NOT NULL
            AND p_batch_step_resources.resources IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
                AND resources = p_batch_step_resources.resources
         FOR UPDATE NOWAIT;

         DELETE FROM gme_batch_step_resources
               WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
                 AND resources = p_batch_step_resources.resources;
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
         gme_common_pvt.log_message
                      ('GME_RECORD_LOCKED'
                      ,'TABLE_NAME'
                      ,g_table_name
                      ,'RECORD'
                      ,'Resource'
                      ,'KEY'
                      ,TO_CHAR (p_batch_step_resources.batchstep_resource_id) );
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
 |      Update_Row will update a row in gme_batch_step_resources
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_step_resources
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_resources IN  gme_batch_step_resources%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   26-AUG-02  Bharati Satpute  Bug 2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (
      p_batch_step_resources   IN   gme_batch_step_resources%ROWTYPE)
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

      IF p_batch_step_resources.batchstep_resource_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_resources
            SET batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
               ,resources = p_batch_step_resources.resources
               ,cost_analysis_code = p_batch_step_resources.cost_analysis_code
               ,cost_cmpntcls_id = p_batch_step_resources.cost_cmpntcls_id
               ,prim_rsrc_ind = p_batch_step_resources.prim_rsrc_ind
               ,scale_type = p_batch_step_resources.scale_type
               ,plan_rsrc_count = p_batch_step_resources.plan_rsrc_count
               ,actual_rsrc_count = p_batch_step_resources.actual_rsrc_count
               --,RESOURCE_QTY_UOM    = p_batch_step_resources.RESOURCE_QTY_UOM
         ,      plan_rsrc_usage = p_batch_step_resources.plan_rsrc_usage
               ,actual_rsrc_usage = p_batch_step_resources.actual_rsrc_usage
               --,USAGE_UOM              = p_batch_step_resources.USAGE_UOM
         ,      plan_start_date = p_batch_step_resources.plan_start_date
               ,actual_start_date = p_batch_step_resources.actual_start_date
               ,plan_cmplt_date = p_batch_step_resources.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step_resources.actual_cmplt_date
               ,offset_interval = p_batch_step_resources.offset_interval
               ,min_capacity = p_batch_step_resources.min_capacity
               ,max_capacity = p_batch_step_resources.max_capacity
               ,process_parameter_1 =
                                    p_batch_step_resources.process_parameter_1
               ,process_parameter_2 =
                                    p_batch_step_resources.process_parameter_2
               ,process_parameter_3 =
                                    p_batch_step_resources.process_parameter_3
               ,process_parameter_4 =
                                    p_batch_step_resources.process_parameter_4
               ,process_parameter_5 =
                                    p_batch_step_resources.process_parameter_5
               ,sequence_dependent_id =
                                  p_batch_step_resources.sequence_dependent_id
               ,sequence_dependent_usage =
                               p_batch_step_resources.sequence_dependent_usage
               ,capacity_tolerance = p_batch_step_resources.capacity_tolerance
               ,attribute_category = p_batch_step_resources.attribute_category
               ,attribute1 = p_batch_step_resources.attribute1
               ,attribute2 = p_batch_step_resources.attribute2
               ,attribute3 = p_batch_step_resources.attribute3
               ,attribute4 = p_batch_step_resources.attribute4
               ,attribute5 = p_batch_step_resources.attribute5
               ,attribute6 = p_batch_step_resources.attribute6
               ,attribute7 = p_batch_step_resources.attribute7
               ,attribute8 = p_batch_step_resources.attribute8
               ,attribute9 = p_batch_step_resources.attribute9
               ,attribute10 = p_batch_step_resources.attribute10
               ,attribute11 = p_batch_step_resources.attribute11
               ,attribute12 = p_batch_step_resources.attribute12
               ,attribute13 = p_batch_step_resources.attribute13
               ,attribute14 = p_batch_step_resources.attribute14
               ,attribute15 = p_batch_step_resources.attribute15
               ,attribute16 = p_batch_step_resources.attribute16
               ,attribute17 = p_batch_step_resources.attribute17
               ,attribute18 = p_batch_step_resources.attribute18
               ,attribute19 = p_batch_step_resources.attribute19
               ,attribute20 = p_batch_step_resources.attribute20
               ,attribute21 = p_batch_step_resources.attribute21
               ,attribute22 = p_batch_step_resources.attribute22
               ,attribute23 = p_batch_step_resources.attribute23
               ,attribute24 = p_batch_step_resources.attribute24
               ,attribute25 = p_batch_step_resources.attribute25
               ,attribute26 = p_batch_step_resources.attribute26
               ,attribute27 = p_batch_step_resources.attribute27
               ,attribute28 = p_batch_step_resources.attribute28
               ,attribute29 = p_batch_step_resources.attribute29
               ,attribute30 = p_batch_step_resources.attribute30
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,text_code = p_batch_step_resources.text_code
               ,batch_id = p_batch_step_resources.batch_id
               ,batchstep_id = p_batch_step_resources.batchstep_id
               --,CAPACITY_UOM             = p_batch_step_resources.CAPACITY_UOM
         ,      actual_rsrc_qty = p_batch_step_resources.actual_rsrc_qty
               ,plan_rsrc_qty = p_batch_step_resources.plan_rsrc_qty
               ,last_update_login = gme_common_pvt.g_login_id
               ,calculate_charges = p_batch_step_resources.calculate_charges
               ,original_rsrc_qty = p_batch_step_resources.original_rsrc_qty
               ,original_rsrc_usage =
                                    p_batch_step_resources.original_rsrc_usage
               ,firm_type = p_batch_step_resources.firm_type
               ,group_sequence_id = p_batch_step_resources.group_sequence_id
               ,group_sequence_number =
                                  p_batch_step_resources.group_sequence_number
               ,capacity_um = p_batch_step_resources.capacity_um
               ,usage_um = p_batch_step_resources.usage_um
               ,resource_qty_um = p_batch_step_resources.resource_qty_um
          WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id
            AND last_update_date = p_batch_step_resources.last_update_date;
      ELSIF     p_batch_step_resources.batchstep_activity_id IS NOT NULL
            AND p_batch_step_resources.resources IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
                AND resources = p_batch_step_resources.resources
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_resources
            SET batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
               ,resources = p_batch_step_resources.resources
               ,cost_analysis_code = p_batch_step_resources.cost_analysis_code
               ,cost_cmpntcls_id = p_batch_step_resources.cost_cmpntcls_id
               ,prim_rsrc_ind = p_batch_step_resources.prim_rsrc_ind
               ,scale_type = p_batch_step_resources.scale_type
               ,plan_rsrc_count = p_batch_step_resources.plan_rsrc_count
               ,actual_rsrc_count = p_batch_step_resources.actual_rsrc_count
               --,RESOURCE_QTY_UOM = p_batch_step_resources.RESOURCE_QTY_UOM
         ,      plan_rsrc_usage = p_batch_step_resources.plan_rsrc_usage
               ,actual_rsrc_usage = p_batch_step_resources.actual_rsrc_usage
               --,USAGE_UOM     = p_batch_step_resources.USAGE_UOM
         ,      plan_start_date = p_batch_step_resources.plan_start_date
               ,actual_start_date = p_batch_step_resources.actual_start_date
               ,plan_cmplt_date = p_batch_step_resources.plan_cmplt_date
               ,actual_cmplt_date = p_batch_step_resources.actual_cmplt_date
               ,offset_interval = p_batch_step_resources.offset_interval
               ,min_capacity = p_batch_step_resources.min_capacity
               ,max_capacity = p_batch_step_resources.max_capacity
               ,process_parameter_1 =
                                    p_batch_step_resources.process_parameter_1
               ,process_parameter_2 =
                                    p_batch_step_resources.process_parameter_2
               ,process_parameter_3 =
                                    p_batch_step_resources.process_parameter_3
               ,process_parameter_4 =
                                    p_batch_step_resources.process_parameter_4
               ,process_parameter_5 =
                                    p_batch_step_resources.process_parameter_5
               ,sequence_dependent_id =
                                  p_batch_step_resources.sequence_dependent_id
               ,sequence_dependent_usage =
                               p_batch_step_resources.sequence_dependent_usage
               ,capacity_tolerance = p_batch_step_resources.capacity_tolerance
               ,attribute_category = p_batch_step_resources.attribute_category
               ,attribute1 = p_batch_step_resources.attribute1
               ,attribute2 = p_batch_step_resources.attribute2
               ,attribute3 = p_batch_step_resources.attribute3
               ,attribute4 = p_batch_step_resources.attribute4
               ,attribute5 = p_batch_step_resources.attribute5
               ,attribute6 = p_batch_step_resources.attribute6
               ,attribute7 = p_batch_step_resources.attribute7
               ,attribute8 = p_batch_step_resources.attribute8
               ,attribute9 = p_batch_step_resources.attribute9
               ,attribute10 = p_batch_step_resources.attribute10
               ,attribute11 = p_batch_step_resources.attribute11
               ,attribute12 = p_batch_step_resources.attribute12
               ,attribute13 = p_batch_step_resources.attribute13
               ,attribute14 = p_batch_step_resources.attribute14
               ,attribute15 = p_batch_step_resources.attribute15
               ,attribute16 = p_batch_step_resources.attribute16
               ,attribute17 = p_batch_step_resources.attribute17
               ,attribute18 = p_batch_step_resources.attribute18
               ,attribute19 = p_batch_step_resources.attribute19
               ,attribute20 = p_batch_step_resources.attribute20
               ,attribute21 = p_batch_step_resources.attribute21
               ,attribute22 = p_batch_step_resources.attribute22
               ,attribute23 = p_batch_step_resources.attribute23
               ,attribute24 = p_batch_step_resources.attribute24
               ,attribute25 = p_batch_step_resources.attribute25
               ,attribute26 = p_batch_step_resources.attribute26
               ,attribute27 = p_batch_step_resources.attribute27
               ,attribute28 = p_batch_step_resources.attribute28
               ,attribute29 = p_batch_step_resources.attribute29
               ,attribute30 = p_batch_step_resources.attribute30
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,text_code = p_batch_step_resources.text_code
               ,batch_id = p_batch_step_resources.batch_id
               ,batchstep_id = p_batch_step_resources.batchstep_id
               --,CAPACITY_UOM     = p_batch_step_resources.CAPACITY_UOM
         ,      actual_rsrc_qty = p_batch_step_resources.actual_rsrc_qty
               ,plan_rsrc_qty = p_batch_step_resources.plan_rsrc_qty
               ,last_update_login = gme_common_pvt.g_login_id
               ,calculate_charges = p_batch_step_resources.calculate_charges
               ,original_rsrc_qty = p_batch_step_resources.original_rsrc_qty
               ,original_rsrc_usage =
                                    p_batch_step_resources.original_rsrc_usage
               ,firm_type = p_batch_step_resources.firm_type
               ,group_sequence_id = p_batch_step_resources.group_sequence_id
               ,group_sequence_number =
                                  p_batch_step_resources.group_sequence_number
               ,capacity_um = p_batch_step_resources.capacity_um
               ,usage_um = p_batch_step_resources.usage_um
               ,resource_qty_um = p_batch_step_resources.resource_qty_um
          WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
            AND resources = p_batch_step_resources.resources
            AND last_update_date = p_batch_step_resources.last_update_date;
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
                      ,'Resource'
                      ,'KEY'
                      ,TO_CHAR (p_batch_step_resources.batchstep_resource_id) );
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
 |      Lock_Row will lock a row in gme_batch_step_resources
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_step_resources
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_resources IN  gme_batch_step_resources%ROWTYPE
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
      p_batch_step_resources   IN   gme_batch_step_resources%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy               NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30) := 'lock_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_step_resources.batchstep_resource_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_resource_id =
                                  p_batch_step_resources.batchstep_resource_id
         FOR UPDATE NOWAIT;
      ELSIF     p_batch_step_resources.batchstep_activity_id IS NOT NULL
            AND p_batch_step_resources.resources IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_resources
              WHERE batchstep_activity_id =
                                  p_batch_step_resources.batchstep_activity_id
                AND resources = p_batch_step_resources.resources
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
                      ,'Resource'
                      ,'KEY'
                      ,TO_CHAR (p_batch_step_resources.batchstep_resource_id) );
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
END gme_batch_step_resources_dbl;

/
