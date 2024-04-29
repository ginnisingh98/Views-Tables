--------------------------------------------------------
--  DDL for Package Body GME_BATCH_HEADER_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_HEADER_DBL" AS
/*  $Header: GMEVGBHB.pls 120.4.12010000.4 2008/12/23 13:43:15 apmishra noship $    */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_BATCH_HEADER';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_BATCH_HEADER_DBL';

/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGBHB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package gme_batch_header_dbl                               |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  13-Feb-01 Created                                                      |
 |                                                                         |
 |             - create_row                                                |
 |             - fetch_row                                                 |
 |             - update_row                                                |
 |             - delete_row                                                |
 | 08-JUNE-2005 Pawan added enhanced_pi_ind for GMO.
 | 17 Dec 2008 Apeksha added JA_OSP_BATCH a new column.                    |
 |                                                                         |
 ===========================================================================
*/

   /*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    insert_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   insert_Row will insert a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   insert_Row will insert a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_header IN gme_batch_header%ROWTYPE                            |
 |    x_batch_header IN OUT NOCOPY gme_batch_header%ROWTYPE                 |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION insert_row (
      p_batch_header   IN              gme_batch_header%ROWTYPE
     ,x_batch_header   IN OUT NOCOPY   gme_batch_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'INSERT_ROW';
      l_wip_entity_id       NUMBER;
      l_prefix              VARCHAR2 (32);
      CURSOR cur_wip_entity
      IS
         SELECT wip_entities_s.NEXTVAL
           FROM DUAL;
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      x_batch_header := p_batch_header;

      OPEN cur_wip_entity;

      FETCH cur_wip_entity
       INTO l_wip_entity_id;

      CLOSE cur_wip_entity;
      IF (p_batch_header.batch_type = 0) THEN
       l_prefix := FND_PROFILE.VALUE('GME_BATCH_PREFIX');
      ELSE
       l_prefix := FND_PROFILE.VALUE('GME_FPO_PREFIX');
      END IF;
      INSERT INTO wip_entities
                  (wip_entity_id, organization_id
                  ,last_update_date, last_updated_by
                  ,creation_date, created_by
                  ,wip_entity_name
                  ,entity_type
                  ,gen_object_id)
           VALUES (l_wip_entity_id, x_batch_header.organization_id
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,l_prefix||x_batch_header.batch_no
                  ,DECODE (x_batch_header.batch_type
                          ,0, gme_common_pvt.g_wip_entity_type_batch
                          ,gme_common_pvt.g_wip_entity_type_fpo)
                  ,mtl_gen_object_id_s.NEXTVAL);

      INSERT INTO gme_batch_header
                  (batch_id, batch_no
                  ,batch_type, prod_id
                  ,prod_sequence
                  ,recipe_validity_rule_id
                  ,formula_id, routing_id
                  ,plan_start_date
                  ,actual_start_date, due_date
                  ,plan_cmplt_date
                  ,actual_cmplt_date
                  ,batch_status
                  ,priority_value
                  ,priority_code, print_count
                  ,fmcontrol_class
                  --,  WIP_WHSE_CODE
      ,            batch_close_date, poc_ind
                  ,actual_cost_ind
                  ,gl_posted_ind
                  ,update_inventory_ind
                  ,last_update_date, last_updated_by
                  ,creation_date, created_by
                  ,last_update_login, delete_mark, text_code
                  ,parentline_id, fpo_id
                  ,attribute1, attribute2
                  ,attribute3, attribute4
                  ,attribute5, attribute6
                  ,attribute7, attribute8
                  ,attribute9, attribute10
                  ,attribute11, attribute12
                  ,attribute13, attribute14
                  ,attribute15, attribute16
                  ,attribute17, attribute18
                  ,attribute19, attribute20
                  ,attribute21, attribute22
                  ,attribute23, attribute24
                  ,attribute25, attribute26
                  ,attribute27, attribute28
                  ,attribute29, attribute30
                  ,attribute31, attribute32
                  ,attribute33, attribute34
                  ,attribute35, attribute36
                  ,attribute37, attribute38
                  ,attribute39, attribute40
                  ,attribute_category
                  ,automatic_step_calculation
                  ,firmed_ind
                  ,finite_scheduled_ind
                  ,order_priority
                  ,migrated_batch_ind
                  ,enforce_step_dependency, terminated_ind
                  ,organization_id
                  ,laboratory_ind
                  ,enhanced_pi_ind
                  ,fixed_process_loss_applied
                  ,ja_osp_batch)
           VALUES (l_wip_entity_id, x_batch_header.batch_no
                  ,x_batch_header.batch_type, x_batch_header.prod_id
                  ,x_batch_header.prod_sequence
                  ,x_batch_header.recipe_validity_rule_id
                  ,x_batch_header.formula_id, x_batch_header.routing_id
                  ,x_batch_header.plan_start_date
                  ,x_batch_header.actual_start_date, x_batch_header.due_date
                  ,x_batch_header.plan_cmplt_date
                  ,x_batch_header.actual_cmplt_date
                  ,x_batch_header.batch_status
                  ,x_batch_header.priority_value
                  ,x_batch_header.priority_code, x_batch_header.print_count
                  ,x_batch_header.fmcontrol_class
                  --,  x_batch_header.WIP_WHSE_CODE
      ,            x_batch_header.batch_close_date, x_batch_header.poc_ind
                  ,x_batch_header.actual_cost_ind
                  ,x_batch_header.gl_posted_ind
                  ,x_batch_header.update_inventory_ind
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id, 0, x_batch_header.text_code
                  ,x_batch_header.parentline_id, x_batch_header.fpo_id
                  ,x_batch_header.attribute1, x_batch_header.attribute2
                  ,x_batch_header.attribute3, x_batch_header.attribute4
                  ,x_batch_header.attribute5, x_batch_header.attribute6
                  ,x_batch_header.attribute7, x_batch_header.attribute8
                  ,x_batch_header.attribute9, x_batch_header.attribute10
                  ,x_batch_header.attribute11, x_batch_header.attribute12
                  ,x_batch_header.attribute13, x_batch_header.attribute14
                  ,x_batch_header.attribute15, x_batch_header.attribute16
                  ,x_batch_header.attribute17, x_batch_header.attribute18
                  ,x_batch_header.attribute19, x_batch_header.attribute20
                  ,x_batch_header.attribute21, x_batch_header.attribute22
                  ,x_batch_header.attribute23, x_batch_header.attribute24
                  ,x_batch_header.attribute25, x_batch_header.attribute26
                  ,x_batch_header.attribute27, x_batch_header.attribute28
                  ,x_batch_header.attribute29, x_batch_header.attribute30
                  ,x_batch_header.attribute31, x_batch_header.attribute32
                  ,x_batch_header.attribute33, x_batch_header.attribute34
                  ,x_batch_header.attribute35, x_batch_header.attribute36
                  ,x_batch_header.attribute37, x_batch_header.attribute38
                  ,x_batch_header.attribute39, x_batch_header.attribute40
                  ,x_batch_header.attribute_category
                  ,x_batch_header.automatic_step_calculation
                  ,x_batch_header.firmed_ind
                  ,x_batch_header.finite_scheduled_ind
                  ,x_batch_header.order_priority
                  ,x_batch_header.migrated_batch_ind
                  ,x_batch_header.enforce_step_dependency, 0
                  ,x_batch_header.organization_id
                  ,x_batch_header.laboratory_ind
                  ,x_batch_header.enhanced_pi_ind
                  ,x_batch_header.fixed_process_loss_applied
                  ,x_batch_header.ja_osp_batch);  --Bug7616310

      x_batch_header.batch_id := l_wip_entity_id;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      IF SQL%FOUND THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      --Bug280440
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         x_batch_header.batch_id := NULL;
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
 |   fetch_Row will fetch a row in  gme_batch_header                        |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_row will fetch a row in  gme_batch_header                        |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_header IN gme_batch_header%ROWTYPE                            |
 |    x_batch_header IN OUT NOCOPY gme_batch_header%ROWTYPE                 |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 | 17 Dec 2008 Apeksha added JA_OSP_BATCH a new column.                                                                         |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION fetch_row (
      p_batch_header   IN              gme_batch_header%ROWTYPE
     ,x_batch_header   IN OUT NOCOPY   gme_batch_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_gme_batch_header    gme_batch_header%ROWTYPE;
      l_batch_id            NUMBER;
      l_organization_id     NUMBER;
      l_batch_no            VARCHAR2 (32);
      l_batch_type          NUMBER (5);
      l_api_name   CONSTANT VARCHAR2 (30)              := 'fetch_row';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Retrieving batch id: '
                             || TO_CHAR (p_batch_header.batch_id) );
      END IF;

      l_batch_id := p_batch_header.batch_id;
      l_organization_id := p_batch_header.organization_id;
      l_batch_no := p_batch_header.batch_no;
      l_batch_type := p_batch_header.batch_type;

      IF (l_batch_id IS NOT NULL) THEN
         SELECT batch_id
                        --,  PLANT_CODE
         ,      batch_no
               ,batch_type, prod_id
               ,prod_sequence
               ,recipe_validity_rule_id
               ,formula_id
               ,routing_id
               ,plan_start_date
               ,actual_start_date
               ,due_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,batch_status
               ,priority_value
               ,priority_code
               ,print_count
               ,fmcontrol_class
               --,  WIP_WHSE_CODE
         ,      batch_close_date
               ,poc_ind
               ,actual_cost_ind
               ,gl_posted_ind
               ,update_inventory_ind
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,delete_mark
               ,text_code
               ,parentline_id, fpo_id
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
               ,attribute31
               ,attribute32
               ,attribute33
               ,attribute34
               ,attribute35
               ,attribute36
               ,attribute37
               ,attribute38
               ,attribute39
               ,attribute40
               ,attribute_category
               ,automatic_step_calculation
               ,firmed_ind
               ,finite_scheduled_ind
               ,order_priority
               ,migrated_batch_ind
               ,enforce_step_dependency
               ,terminated_ind
               ,organization_id
               ,laboratory_ind
               ,enhanced_pi_ind
               ,move_order_header_id
               ,terminate_reason_id
               ,fixed_process_loss_applied
               ,ja_osp_batch --Bug7616310
           INTO l_gme_batch_header.batch_id
                                           --,  l_gme_batch_header.PLANT_CODE
         ,      l_gme_batch_header.batch_no
               ,l_gme_batch_header.batch_type, l_gme_batch_header.prod_id
               ,l_gme_batch_header.prod_sequence
               ,l_gme_batch_header.recipe_validity_rule_id
               ,l_gme_batch_header.formula_id
               ,l_gme_batch_header.routing_id
               ,l_gme_batch_header.plan_start_date
               ,l_gme_batch_header.actual_start_date
               ,l_gme_batch_header.due_date
               ,l_gme_batch_header.plan_cmplt_date
               ,l_gme_batch_header.actual_cmplt_date
               ,l_gme_batch_header.batch_status
               ,l_gme_batch_header.priority_value
               ,l_gme_batch_header.priority_code
               ,l_gme_batch_header.print_count
               ,l_gme_batch_header.fmcontrol_class
               --,  l_gme_batch_header.WIP_WHSE_CODE
         ,      l_gme_batch_header.batch_close_date
               ,l_gme_batch_header.poc_ind
               ,l_gme_batch_header.actual_cost_ind
               ,l_gme_batch_header.gl_posted_ind
               ,l_gme_batch_header.update_inventory_ind
               ,l_gme_batch_header.last_update_date
               ,l_gme_batch_header.last_updated_by
               ,l_gme_batch_header.creation_date
               ,l_gme_batch_header.created_by
               ,l_gme_batch_header.last_update_login
               ,l_gme_batch_header.delete_mark
               ,l_gme_batch_header.text_code
               ,l_gme_batch_header.parentline_id, l_gme_batch_header.fpo_id
               ,l_gme_batch_header.attribute1
               ,l_gme_batch_header.attribute2
               ,l_gme_batch_header.attribute3
               ,l_gme_batch_header.attribute4
               ,l_gme_batch_header.attribute5
               ,l_gme_batch_header.attribute6
               ,l_gme_batch_header.attribute7
               ,l_gme_batch_header.attribute8
               ,l_gme_batch_header.attribute9
               ,l_gme_batch_header.attribute10
               ,l_gme_batch_header.attribute11
               ,l_gme_batch_header.attribute12
               ,l_gme_batch_header.attribute13
               ,l_gme_batch_header.attribute14
               ,l_gme_batch_header.attribute15
               ,l_gme_batch_header.attribute16
               ,l_gme_batch_header.attribute17
               ,l_gme_batch_header.attribute18
               ,l_gme_batch_header.attribute19
               ,l_gme_batch_header.attribute20
               ,l_gme_batch_header.attribute21
               ,l_gme_batch_header.attribute22
               ,l_gme_batch_header.attribute23
               ,l_gme_batch_header.attribute24
               ,l_gme_batch_header.attribute25
               ,l_gme_batch_header.attribute26
               ,l_gme_batch_header.attribute27
               ,l_gme_batch_header.attribute28
               ,l_gme_batch_header.attribute29
               ,l_gme_batch_header.attribute30
               ,l_gme_batch_header.attribute31
               ,l_gme_batch_header.attribute32
               ,l_gme_batch_header.attribute33
               ,l_gme_batch_header.attribute34
               ,l_gme_batch_header.attribute35
               ,l_gme_batch_header.attribute36
               ,l_gme_batch_header.attribute37
               ,l_gme_batch_header.attribute38
               ,l_gme_batch_header.attribute39
               ,l_gme_batch_header.attribute40
               ,l_gme_batch_header.attribute_category
               ,l_gme_batch_header.automatic_step_calculation
               ,l_gme_batch_header.firmed_ind
               ,l_gme_batch_header.finite_scheduled_ind
               ,l_gme_batch_header.order_priority
               ,l_gme_batch_header.migrated_batch_ind
               ,l_gme_batch_header.enforce_step_dependency
               ,l_gme_batch_header.terminated_ind
               ,l_gme_batch_header.organization_id
               ,l_gme_batch_header.laboratory_ind
               ,l_gme_batch_header.enhanced_pi_ind
               ,l_gme_batch_header.move_order_header_id
               ,l_gme_batch_header.terminate_reason_id
               ,l_gme_batch_header.fixed_process_loss_applied
               ,l_gme_batch_header.ja_osp_batch --Bug7616310
           FROM gme_batch_header
          WHERE batch_id = p_batch_header.batch_id;
      ELSIF     (l_organization_id IS NOT NULL)
            AND (l_batch_no IS NOT NULL)
            AND (l_batch_type IS NOT NULL) THEN
         SELECT batch_id
                        --,  PLANT_CODE
         ,      batch_no
               ,batch_type, prod_id
               ,prod_sequence
               ,recipe_validity_rule_id
               ,formula_id
               ,routing_id
               ,plan_start_date
               ,actual_start_date
               ,due_date
               ,plan_cmplt_date
               ,actual_cmplt_date
               ,batch_status
               ,priority_value
               ,priority_code
               ,print_count
               ,fmcontrol_class
               --,  WIP_WHSE_CODE
         ,      batch_close_date
               ,poc_ind
               ,actual_cost_ind
               ,gl_posted_ind
               ,update_inventory_ind
               ,last_update_date
               ,last_updated_by
               ,creation_date
               ,created_by
               ,last_update_login
               ,delete_mark
               ,text_code
               ,parentline_id, fpo_id
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
               ,attribute31
               ,attribute32
               ,attribute33
               ,attribute34
               ,attribute35
               ,attribute36
               ,attribute37
               ,attribute38
               ,attribute39
               ,attribute40
               ,attribute_category
               ,automatic_step_calculation
               ,firmed_ind
               ,finite_scheduled_ind
               ,order_priority
               ,migrated_batch_ind
               ,enforce_step_dependency
               ,terminated_ind
               ,organization_id
               ,laboratory_ind
               ,enhanced_pi_ind
               ,move_order_header_id
               ,terminate_reason_id
               ,fixed_process_loss_applied
               ,ja_osp_batch --Bug7616310
           INTO l_gme_batch_header.batch_id
                                           --,  l_gme_batch_header.PLANT_CODE
         ,      l_gme_batch_header.batch_no
               ,l_gme_batch_header.batch_type, l_gme_batch_header.prod_id
               ,l_gme_batch_header.prod_sequence
               ,l_gme_batch_header.recipe_validity_rule_id
               ,l_gme_batch_header.formula_id
               ,l_gme_batch_header.routing_id
               ,l_gme_batch_header.plan_start_date
               ,l_gme_batch_header.actual_start_date
               ,l_gme_batch_header.due_date
               ,l_gme_batch_header.plan_cmplt_date
               ,l_gme_batch_header.actual_cmplt_date
               ,l_gme_batch_header.batch_status
               ,l_gme_batch_header.priority_value
               ,l_gme_batch_header.priority_code
               ,l_gme_batch_header.print_count
               ,l_gme_batch_header.fmcontrol_class
               --,  l_gme_batch_header.WIP_WHSE_CODE
         ,      l_gme_batch_header.batch_close_date
               ,l_gme_batch_header.poc_ind
               ,l_gme_batch_header.actual_cost_ind
               ,l_gme_batch_header.gl_posted_ind
               ,l_gme_batch_header.update_inventory_ind
               ,l_gme_batch_header.last_update_date
               ,l_gme_batch_header.last_updated_by
               ,l_gme_batch_header.creation_date
               ,l_gme_batch_header.created_by
               ,l_gme_batch_header.last_update_login
               ,l_gme_batch_header.delete_mark
               ,l_gme_batch_header.text_code
               ,l_gme_batch_header.parentline_id, l_gme_batch_header.fpo_id
               ,l_gme_batch_header.attribute1
               ,l_gme_batch_header.attribute2
               ,l_gme_batch_header.attribute3
               ,l_gme_batch_header.attribute4
               ,l_gme_batch_header.attribute5
               ,l_gme_batch_header.attribute6
               ,l_gme_batch_header.attribute7
               ,l_gme_batch_header.attribute8
               ,l_gme_batch_header.attribute9
               ,l_gme_batch_header.attribute10
               ,l_gme_batch_header.attribute11
               ,l_gme_batch_header.attribute12
               ,l_gme_batch_header.attribute13
               ,l_gme_batch_header.attribute14
               ,l_gme_batch_header.attribute15
               ,l_gme_batch_header.attribute16
               ,l_gme_batch_header.attribute17
               ,l_gme_batch_header.attribute18
               ,l_gme_batch_header.attribute19
               ,l_gme_batch_header.attribute20
               ,l_gme_batch_header.attribute21
               ,l_gme_batch_header.attribute22
               ,l_gme_batch_header.attribute23
               ,l_gme_batch_header.attribute24
               ,l_gme_batch_header.attribute25
               ,l_gme_batch_header.attribute26
               ,l_gme_batch_header.attribute27
               ,l_gme_batch_header.attribute28
               ,l_gme_batch_header.attribute29
               ,l_gme_batch_header.attribute30
               ,l_gme_batch_header.attribute31
               ,l_gme_batch_header.attribute32
               ,l_gme_batch_header.attribute33
               ,l_gme_batch_header.attribute34
               ,l_gme_batch_header.attribute35
               ,l_gme_batch_header.attribute36
               ,l_gme_batch_header.attribute37
               ,l_gme_batch_header.attribute38
               ,l_gme_batch_header.attribute39
               ,l_gme_batch_header.attribute40
               ,l_gme_batch_header.attribute_category
               ,l_gme_batch_header.automatic_step_calculation
               ,l_gme_batch_header.firmed_ind
               ,l_gme_batch_header.finite_scheduled_ind
               ,l_gme_batch_header.order_priority
               ,l_gme_batch_header.migrated_batch_ind
               ,l_gme_batch_header.enforce_step_dependency
               ,l_gme_batch_header.terminated_ind
               ,l_gme_batch_header.organization_id
               ,l_gme_batch_header.laboratory_ind
               ,l_gme_batch_header.enhanced_pi_ind
               ,l_gme_batch_header.move_order_header_id
               ,l_gme_batch_header.terminate_reason_id
               ,l_gme_batch_header.fixed_process_loss_applied
               ,l_gme_batch_header.ja_osp_batch --Bug7616310
           FROM gme_batch_header
          WHERE organization_id = p_batch_header.organization_id
            AND batch_no = p_batch_header.batch_no
            AND batch_type = p_batch_header.batch_type;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      x_batch_header := l_gme_batch_header;
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

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END fetch_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    delete_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   delete_Row will delete a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   delete_row will delete a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_header IN gme_batch_header%ROWTYPE                            |
 | RETURNS                                                                  |
 |    BOOLEAN                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION delete_row (p_batch_header IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_gme_batch_header     gme_batch_header%ROWTYPE;
      l_batch_id             NUMBER;
      l_organization_id      NUMBER;
      l_batch_no             VARCHAR2 (32);
      l_batch_type           NUMBER (5);
      l_dummy                NUMBER (5)                 := 0;
      l_api_name    CONSTANT VARCHAR2 (30)              := 'DELETE_ROW';
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      l_batch_id := p_batch_header.batch_id;
      l_organization_id := p_batch_header.organization_id;
      l_batch_no := p_batch_header.batch_no;
      l_batch_type := p_batch_header.batch_type;

      IF l_batch_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE batch_id = l_batch_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_header
            SET delete_mark = 1
          WHERE batch_id = p_batch_header.batch_id;
      ELSIF     (l_organization_id IS NOT NULL)
            AND (l_batch_no IS NOT NULL)
            AND (l_batch_type IS NOT NULL) THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE organization_id = p_batch_header.organization_id
                AND batch_no = p_batch_header.batch_no
                AND batch_type = p_batch_header.batch_type
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_header
            SET delete_mark = 1
          WHERE organization_id = p_batch_header.organization_id
            AND batch_no = p_batch_header.batch_no
            AND batch_type = p_batch_header.batch_type;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF (SQL%FOUND) THEN
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
            RETURN FALSE;
         END IF;
      END IF;

      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN locked_by_other_user THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batch'
                                    ,'KEY'
                                    ,p_batch_header.batch_no);
         RETURN FALSE;
      --Bug2804440
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END delete_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    update_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   update_row will update a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   update_row will update a row in  gme_batch_header                      |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_batch_header IN gme_batch_header%ROWTYPE                            |
 | RETURNS                                                                  |
 |    BOOLEAN                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |17 Dec 2008 Apeksha added JA_OSP_BATCH a new column.
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION update_row (p_batch_header IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER        := 0;
      l_batch_id             NUMBER;
      l_organization_id      NUMBER;
      l_batch_no             VARCHAR2 (32);
      l_batch_type           NUMBER (5);
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'UPDATE_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   'Inside update_row for batch_id: '
                             || TO_CHAR (p_batch_header.batch_id) );
      END IF;

      l_batch_id := p_batch_header.batch_id;
      l_organization_id := p_batch_header.organization_id;
      l_batch_no := p_batch_header.batch_no;
      l_batch_type := p_batch_header.batch_type;

      IF l_batch_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE batch_id = l_batch_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_header
            SET recipe_validity_rule_id =
                                        p_batch_header.recipe_validity_rule_id
               ,formula_id = p_batch_header.formula_id
               ,routing_id = p_batch_header.routing_id
               ,plan_start_date = p_batch_header.plan_start_date
               ,actual_start_date = p_batch_header.actual_start_date
               ,due_date = p_batch_header.due_date
               ,plan_cmplt_date = p_batch_header.plan_cmplt_date
               ,actual_cmplt_date = p_batch_header.actual_cmplt_date
               ,batch_status = p_batch_header.batch_status
               ,print_count = p_batch_header.print_count
               ,
                --WIP_WHSE_CODE = p_batch_header.WIP_WHSE_CODE,
                batch_close_date = p_batch_header.batch_close_date
               ,poc_ind = p_batch_header.poc_ind
               ,actual_cost_ind = p_batch_header.actual_cost_ind
               ,gl_posted_ind = p_batch_header.gl_posted_ind
               ,update_inventory_ind = p_batch_header.update_inventory_ind
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,delete_mark = p_batch_header.delete_mark
               ,text_code = p_batch_header.text_code
               ,parentline_id = p_batch_header.parentline_id
               ,fpo_id = p_batch_header.fpo_id
               ,attribute1 = p_batch_header.attribute1
               ,attribute2 = p_batch_header.attribute2
               ,attribute3 = p_batch_header.attribute3
               ,attribute4 = p_batch_header.attribute4
               ,attribute5 = p_batch_header.attribute5
               ,attribute6 = p_batch_header.attribute6
               ,attribute7 = p_batch_header.attribute7
               ,attribute8 = p_batch_header.attribute8
               ,attribute9 = p_batch_header.attribute9
               ,attribute10 = p_batch_header.attribute10
               ,attribute11 = p_batch_header.attribute11
               ,attribute12 = p_batch_header.attribute12
               ,attribute13 = p_batch_header.attribute13
               ,attribute14 = p_batch_header.attribute14
               ,attribute15 = p_batch_header.attribute15
               ,attribute16 = p_batch_header.attribute16
               ,attribute17 = p_batch_header.attribute17
               ,attribute18 = p_batch_header.attribute18
               ,attribute19 = p_batch_header.attribute19
               ,attribute20 = p_batch_header.attribute20
               ,attribute21 = p_batch_header.attribute21
               ,attribute22 = p_batch_header.attribute22
               ,attribute23 = p_batch_header.attribute23
               ,attribute24 = p_batch_header.attribute24
               ,attribute25 = p_batch_header.attribute25
               ,attribute26 = p_batch_header.attribute26
               ,attribute27 = p_batch_header.attribute27
               ,attribute28 = p_batch_header.attribute28
               ,attribute29 = p_batch_header.attribute29
               ,attribute30 = p_batch_header.attribute30
               ,attribute31 = p_batch_header.attribute31
               ,attribute32 = p_batch_header.attribute32
               ,attribute33 = p_batch_header.attribute33
               ,attribute34 = p_batch_header.attribute34
               ,attribute35 = p_batch_header.attribute35
               ,attribute36 = p_batch_header.attribute36
               ,attribute37 = p_batch_header.attribute37
               ,attribute38 = p_batch_header.attribute38
               ,attribute39 = p_batch_header.attribute39
               ,attribute40 = p_batch_header.attribute40
               ,attribute_category = p_batch_header.attribute_category
               ,automatic_step_calculation =
                                     p_batch_header.automatic_step_calculation
               ,firmed_ind = p_batch_header.firmed_ind
               ,finite_scheduled_ind = p_batch_header.finite_scheduled_ind
               ,order_priority = p_batch_header.order_priority
               ,migrated_batch_ind = p_batch_header.migrated_batch_ind
               ,enforce_step_dependency =
                                        p_batch_header.enforce_step_dependency
               ,terminated_ind = p_batch_header.terminated_ind
               ,enhanced_pi_ind = p_batch_header.enhanced_pi_ind
               ,move_order_header_id = p_batch_header.move_order_header_id
               ,terminate_reason_id = p_batch_header.terminate_reason_id
               ,fixed_process_loss_applied = p_batch_header.fixed_process_loss_applied
               ,ja_osp_batch = p_batch_header.ja_osp_batch --Bug7616310
          WHERE batch_id = p_batch_header.batch_id
            AND last_update_date = p_batch_header.last_update_date;
      ELSIF     (l_organization_id IS NOT NULL)
            AND (l_batch_no IS NOT NULL)
            AND (l_batch_type IS NOT NULL) THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE organization_id = p_batch_header.organization_id
                AND batch_no = p_batch_header.batch_no
                AND batch_type = p_batch_header.batch_type
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_header
            SET organization_id = p_batch_header.organization_id
               ,batch_no = p_batch_header.batch_no
               ,batch_type = p_batch_header.batch_type
               ,prod_id = p_batch_header.prod_id
               ,prod_sequence = p_batch_header.prod_sequence
               ,recipe_validity_rule_id =
                                        p_batch_header.recipe_validity_rule_id
               ,formula_id = p_batch_header.formula_id
               ,routing_id = p_batch_header.routing_id
               ,plan_start_date = p_batch_header.plan_start_date
               ,actual_start_date = p_batch_header.actual_start_date
               ,due_date = p_batch_header.due_date
               ,plan_cmplt_date = p_batch_header.plan_cmplt_date
               ,actual_cmplt_date = p_batch_header.actual_cmplt_date
               ,batch_status = p_batch_header.batch_status
               ,priority_value = p_batch_header.priority_value
               ,priority_code = p_batch_header.priority_code
               ,print_count = p_batch_header.print_count
               ,fmcontrol_class = p_batch_header.fmcontrol_class
               ,
                --WIP_WHSE_CODE = p_batch_header.WIP_WHSE_CODE,
                batch_close_date = p_batch_header.batch_close_date
               ,poc_ind = p_batch_header.poc_ind
               ,actual_cost_ind = p_batch_header.actual_cost_ind
               ,gl_posted_ind = p_batch_header.gl_posted_ind
               ,update_inventory_ind = p_batch_header.update_inventory_ind
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,delete_mark = p_batch_header.delete_mark
               ,text_code = p_batch_header.text_code
               ,parentline_id = p_batch_header.parentline_id
               ,fpo_id = p_batch_header.fpo_id
               ,attribute1 = p_batch_header.attribute1
               ,attribute2 = p_batch_header.attribute2
               ,attribute3 = p_batch_header.attribute3
               ,attribute4 = p_batch_header.attribute4
               ,attribute5 = p_batch_header.attribute5
               ,attribute6 = p_batch_header.attribute6
               ,attribute7 = p_batch_header.attribute7
               ,attribute8 = p_batch_header.attribute8
               ,attribute9 = p_batch_header.attribute9
               ,attribute10 = p_batch_header.attribute10
               ,attribute11 = p_batch_header.attribute11
               ,attribute12 = p_batch_header.attribute12
               ,attribute13 = p_batch_header.attribute13
               ,attribute14 = p_batch_header.attribute14
               ,attribute15 = p_batch_header.attribute15
               ,attribute16 = p_batch_header.attribute16
               ,attribute17 = p_batch_header.attribute17
               ,attribute18 = p_batch_header.attribute18
               ,attribute19 = p_batch_header.attribute19
               ,attribute20 = p_batch_header.attribute20
               ,attribute21 = p_batch_header.attribute21
               ,attribute22 = p_batch_header.attribute22
               ,attribute23 = p_batch_header.attribute23
               ,attribute24 = p_batch_header.attribute24
               ,attribute25 = p_batch_header.attribute25
               ,attribute26 = p_batch_header.attribute26
               ,attribute27 = p_batch_header.attribute27
               ,attribute28 = p_batch_header.attribute28
               ,attribute29 = p_batch_header.attribute29
               ,attribute30 = p_batch_header.attribute30
               ,attribute31 = p_batch_header.attribute31
               ,attribute32 = p_batch_header.attribute32
               ,attribute33 = p_batch_header.attribute33
               ,attribute34 = p_batch_header.attribute34
               ,attribute35 = p_batch_header.attribute35
               ,attribute36 = p_batch_header.attribute36
               ,attribute37 = p_batch_header.attribute37
               ,attribute38 = p_batch_header.attribute38
               ,attribute39 = p_batch_header.attribute39
               ,attribute40 = p_batch_header.attribute40
               ,attribute_category = p_batch_header.attribute_category
               ,automatic_step_calculation =
                                     p_batch_header.automatic_step_calculation
               ,firmed_ind = p_batch_header.firmed_ind
               ,finite_scheduled_ind = p_batch_header.finite_scheduled_ind
               ,order_priority = p_batch_header.order_priority
               ,migrated_batch_ind = p_batch_header.migrated_batch_ind
               ,enforce_step_dependency =
                                        p_batch_header.enforce_step_dependency
               ,terminated_ind = p_batch_header.terminated_ind
               ,enhanced_pi_ind = p_batch_header.enhanced_pi_ind
               ,move_order_header_id = p_batch_header.move_order_header_id
               ,terminate_reason_id = p_batch_header.terminate_reason_id
               ,fixed_process_loss_applied = p_batch_header.fixed_process_loss_applied
               ,ja_osp_batch = p_batch_header.ja_osp_batch --Bug7616310
          WHERE organization_id = p_batch_header.organization_id
            AND batch_no = p_batch_header.batch_no
            AND batch_type = p_batch_header.batch_type
            AND last_update_date = p_batch_header.last_update_date;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;
      IF SQL%ROWCOUNT <> 0 THEN
         IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
         END IF;
         RETURN TRUE;
      ELSE
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN TRUE;
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
                                    ,p_batch_header.batch_no);
         RETURN FALSE;
      --Bug2804440
      WHEN OTHERS THEN
         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN FALSE;
   END update_row;

/*
 +============================================================================
 |   FUNCTION NAME
 |      lock_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Lock_Row will lock a row in gme_batch_header
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_header
 |
 |
 |
 |   PARAMETERS
 |     p_batch_header         IN  gme_batch_header%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Olivier Daboval  Created
 |
 |
 |
 +=============================================================================
*/
   FUNCTION lock_row (p_batch_header IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy               NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30) := 'LOCK_ROW';
   BEGIN
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;

      IF p_batch_header.batch_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE batch_id = p_batch_header.batch_id
         FOR UPDATE NOWAIT;
      ELSIF (    p_batch_header.organization_id IS NOT NULL
             AND p_batch_header.batch_no IS NOT NULL
             AND p_batch_header.batch_type IS NOT NULL) THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_header
              WHERE organization_id = p_batch_header.organization_id
                AND batch_no = p_batch_header.batch_no
                AND batch_type = p_batch_header.batch_type
         FOR UPDATE NOWAIT;
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
      WHEN app_exception.record_lock_exception THEN
         gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                                    ,'TABLE_NAME'
                                    ,g_table_name
                                    ,'RECORD'
                                    ,'Batch'
                                    ,'KEY'
                                    ,p_batch_header.batch_no);
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
   END lock_row;
END gme_batch_header_dbl;

/
