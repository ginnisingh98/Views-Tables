--------------------------------------------------------
--  DDL for Package Body GME_MATERIAL_DETAILS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_MATERIAL_DETAILS_DBL" AS
/*  $Header: GMEVGMDB.pls 120.3.12010000.2 2009/02/27 20:19:17 gmurator ship $    */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_MATERIAL_DETAILS';
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_MATERIAL_DETAILS_DBL';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGMDB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package gme_material_details_dbl                           |
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
 |             - fetch_tab                                                 |
 |                                                                         |
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
 |   insert_Row will insert a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   insert_Row will insert a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_material_detail IN gme_material_details%ROWTYPE                     |
 |    x_material_detail IN OUT NOCOPY gme_material_details%ROWTYPE                    |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |     15-OCT-2001  Thomas Daniel                                           |
 |                  Added who columns to be passed back.                    |
 |     30-AUG-02    Chandrashekar Tiruvidula Bug 2526710                    |
 |                  Added byproduct_type in insert/update/fetch             |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION insert_row (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'INSERT_ROW';
   BEGIN
      x_material_detail := p_material_detail;

      INSERT INTO gme_material_details
                  (material_detail_id, batch_id
                  ,formulaline_id
                  ,line_no,
                           --item_id,
                           line_type
                  ,plan_qty,
                            --item_um,
                            item_um2
                  ,actual_qty
                  ,release_type
                  ,scrap_factor
                  ,scale_type
                  ,phantom_type
                  ,cost_alloc
                  ,alloc_ind, COST
                  ,text_code
                  ,phantom_id
                  ,created_by, creation_date
                  ,last_updated_by, last_update_date
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
                  ,last_update_login
                  ,scale_rounding_variance
                  ,scale_multiple
                  ,rounding_direction
                  ,contribute_yield_ind
                  ,contribute_step_qty_ind
                  ,wip_plan_qty
                  ,original_qty
                  ,by_product_type
                  ,organization_id
                  ,inventory_item_id
                  ,subinventory
                  ,locator_id, revision
                  ,backordered_qty
                  ,original_primary_qty
                  ,material_requirement_date
                  ,phantom_line_id
                  ,move_order_line_id
                  ,dtl_um
                  ,dispense_ind)
           VALUES (gem5_line_id_s.NEXTVAL, x_material_detail.batch_id
                  ,x_material_detail.formulaline_id
                  ,x_material_detail.line_no,
                                             --x_material_detail.item_id,
                                             x_material_detail.line_type
                  ,x_material_detail.plan_qty,
                                              --x_material_detail.item_um,
                                              x_material_detail.item_um2
                  ,x_material_detail.actual_qty
                  ,x_material_detail.release_type
                  ,x_material_detail.scrap_factor
                  ,x_material_detail.scale_type
                  ,x_material_detail.phantom_type
                  ,x_material_detail.cost_alloc
                  ,x_material_detail.alloc_ind, x_material_detail.COST
                  ,x_material_detail.text_code
                  ,x_material_detail.phantom_id
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,x_material_detail.attribute1
                  ,x_material_detail.attribute2
                  ,x_material_detail.attribute3
                  ,x_material_detail.attribute4
                  ,x_material_detail.attribute5
                  ,x_material_detail.attribute6
                  ,x_material_detail.attribute7
                  ,x_material_detail.attribute8
                  ,x_material_detail.attribute9
                  ,x_material_detail.attribute10
                  ,x_material_detail.attribute11
                  ,x_material_detail.attribute12
                  ,x_material_detail.attribute13
                  ,x_material_detail.attribute14
                  ,x_material_detail.attribute15
                  ,x_material_detail.attribute16
                  ,x_material_detail.attribute17
                  ,x_material_detail.attribute18
                  ,x_material_detail.attribute19
                  ,x_material_detail.attribute20
                  ,x_material_detail.attribute21
                  ,x_material_detail.attribute22
                  ,x_material_detail.attribute23
                  ,x_material_detail.attribute24
                  ,x_material_detail.attribute25
                  ,x_material_detail.attribute26
                  ,x_material_detail.attribute27
                  ,x_material_detail.attribute28
                  ,x_material_detail.attribute29
                  ,x_material_detail.attribute30
                  ,x_material_detail.attribute_category
                  ,x_material_detail.last_update_login
                  ,x_material_detail.scale_rounding_variance
                  ,x_material_detail.scale_multiple
                  ,x_material_detail.rounding_direction
                  ,x_material_detail.contribute_yield_ind
                  ,x_material_detail.contribute_step_qty_ind
                  ,x_material_detail.wip_plan_qty
                  ,x_material_detail.original_qty
                  ,x_material_detail.by_product_type
                  ,x_material_detail.organization_id
                  ,x_material_detail.inventory_item_id
                  ,x_material_detail.subinventory
                  ,x_material_detail.locator_id, x_material_detail.revision
                  ,x_material_detail.backordered_qty
                  ,x_material_detail.original_primary_qty
                  ,x_material_detail.material_requirement_date
                  ,x_material_detail.phantom_line_id
                  ,x_material_detail.move_order_line_id
                  ,x_material_detail.dtl_um
                  ,x_material_detail.dispense_ind)
        RETURNING material_detail_id
             INTO x_material_detail.material_detail_id;

      IF SQL%ROWCOUNT = 1 THEN
         x_material_detail.created_by := gme_common_pvt.g_user_ident;
         x_material_detail.creation_date := gme_common_pvt.g_timestamp;
         x_material_detail.last_updated_by := gme_common_pvt.g_user_ident;
         x_material_detail.last_update_date := gme_common_pvt.g_timestamp;
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

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

         x_material_detail.material_detail_id := NULL;
         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
         RETURN FALSE;
   END insert_row;

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    fetch_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   fetch_Row will fetch a row in  gme_material_details                    |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_row will fetch a row in  gme_material_details                    |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_material_detail IN            gme_material_details%ROWTYPE          |
 |    x_material_detail IN OUT NOCOPY gme_material_details%ROWTYPE          |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |                                                                          |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION fetch_row (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_api_name      CONSTANT VARCHAR2 (30)                  := 'FETCH_ROW';
      l_gme_material_details   gme_material_details%ROWTYPE;
      l_material_detail_id     NUMBER;
      l_batch_id               NUMBER;
      l_line_no                NUMBER;
      l_line_type              NUMBER;
   BEGIN
      l_material_detail_id := p_material_detail.material_detail_id;
      l_batch_id := p_material_detail.batch_id;
      l_line_no := p_material_detail.line_no;
      l_line_type := p_material_detail.line_type;

      IF (l_material_detail_id IS NOT NULL) THEN
         SELECT batch_id
               ,material_detail_id
               ,formulaline_id
               ,line_no
               ,
                --item_id,
                line_type
               ,plan_qty
               ,
                --item_um,
                item_um2
               ,actual_qty
               ,release_type
               ,scrap_factor
               ,scale_type
               ,phantom_type
               ,cost_alloc
               ,alloc_ind
               ,COST
               ,text_code
               ,phantom_id
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
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
               ,last_update_login
               ,scale_rounding_variance
               ,scale_multiple
               ,rounding_direction
               ,contribute_yield_ind
               ,contribute_step_qty_ind
               ,wip_plan_qty
               ,original_qty
               ,by_product_type
               ,organization_id
               ,inventory_item_id
               ,subinventory
               ,locator_id
               ,revision
               ,backordered_qty
               ,original_primary_qty
               ,material_requirement_date
               ,phantom_line_id
               ,move_order_line_id
               ,dtl_um
               ,dispense_ind
           INTO l_gme_material_details.batch_id
               ,l_gme_material_details.material_detail_id
               ,l_gme_material_details.formulaline_id
               ,l_gme_material_details.line_no
               ,
                --l_gme_material_details.item_id,
                l_gme_material_details.line_type
               ,l_gme_material_details.plan_qty
               ,
                --l_gme_material_details.item_um,
                l_gme_material_details.item_um2
               ,l_gme_material_details.actual_qty
               ,l_gme_material_details.release_type
               ,l_gme_material_details.scrap_factor
               ,l_gme_material_details.scale_type
               ,l_gme_material_details.phantom_type
               ,l_gme_material_details.cost_alloc
               ,l_gme_material_details.alloc_ind
               ,l_gme_material_details.COST
               ,l_gme_material_details.text_code
               ,l_gme_material_details.phantom_id
               ,l_gme_material_details.created_by
               ,l_gme_material_details.creation_date
               ,l_gme_material_details.last_updated_by
               ,l_gme_material_details.last_update_date
               ,l_gme_material_details.attribute1
               ,l_gme_material_details.attribute2
               ,l_gme_material_details.attribute3
               ,l_gme_material_details.attribute4
               ,l_gme_material_details.attribute5
               ,l_gme_material_details.attribute6
               ,l_gme_material_details.attribute7
               ,l_gme_material_details.attribute8
               ,l_gme_material_details.attribute9
               ,l_gme_material_details.attribute10
               ,l_gme_material_details.attribute11
               ,l_gme_material_details.attribute12
               ,l_gme_material_details.attribute13
               ,l_gme_material_details.attribute14
               ,l_gme_material_details.attribute15
               ,l_gme_material_details.attribute16
               ,l_gme_material_details.attribute17
               ,l_gme_material_details.attribute18
               ,l_gme_material_details.attribute19
               ,l_gme_material_details.attribute20
               ,l_gme_material_details.attribute21
               ,l_gme_material_details.attribute22
               ,l_gme_material_details.attribute23
               ,l_gme_material_details.attribute24
               ,l_gme_material_details.attribute25
               ,l_gme_material_details.attribute26
               ,l_gme_material_details.attribute27
               ,l_gme_material_details.attribute28
               ,l_gme_material_details.attribute29
               ,l_gme_material_details.attribute30
               ,l_gme_material_details.attribute_category
               ,l_gme_material_details.last_update_login
               ,l_gme_material_details.scale_rounding_variance
               ,l_gme_material_details.scale_multiple
               ,l_gme_material_details.rounding_direction
               ,l_gme_material_details.contribute_yield_ind
               ,l_gme_material_details.contribute_step_qty_ind
               ,l_gme_material_details.wip_plan_qty
               ,l_gme_material_details.original_qty
               ,l_gme_material_details.by_product_type
               ,l_gme_material_details.organization_id
               ,l_gme_material_details.inventory_item_id
               ,l_gme_material_details.subinventory
               ,l_gme_material_details.locator_id
               ,l_gme_material_details.revision
               ,l_gme_material_details.backordered_qty
               ,l_gme_material_details.original_primary_qty
               ,l_gme_material_details.material_requirement_date
               ,l_gme_material_details.phantom_line_id
               ,l_gme_material_details.move_order_line_id
               ,l_gme_material_details.dtl_um
               ,l_gme_material_details.dispense_ind
           FROM gme_material_details
          WHERE material_detail_id = l_material_detail_id;
      ELSIF     (l_batch_id IS NOT NULL)
            AND (l_line_no IS NOT NULL)
            AND (l_line_type IS NOT NULL) THEN
         SELECT batch_id
               ,material_detail_id
               ,formulaline_id
               ,line_no
               ,
                --item_id,
                line_type
               ,plan_qty
               ,
                --item_um,
                item_um2
               ,actual_qty
               ,release_type
               ,scrap_factor
               ,scale_type
               ,phantom_type
               ,cost_alloc
               ,alloc_ind
               ,COST
               ,text_code
               ,phantom_id
               ,created_by
               ,creation_date
               ,last_updated_by
               ,last_update_date
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
               ,last_update_login
               ,scale_rounding_variance
               ,scale_multiple
               ,rounding_direction
               ,contribute_yield_ind
               ,contribute_step_qty_ind
               ,wip_plan_qty
               ,original_qty
               ,by_product_type
               ,organization_id
               ,inventory_item_id
               ,subinventory
               ,locator_id
               ,revision
               ,backordered_qty
               ,original_primary_qty
               ,material_requirement_date
               ,phantom_line_id
               ,move_order_line_id
               ,dtl_um
               ,dispense_ind
           INTO l_gme_material_details.batch_id
               ,l_gme_material_details.material_detail_id
               ,l_gme_material_details.formulaline_id
               ,l_gme_material_details.line_no
               ,
                --l_gme_material_details.item_id,
                l_gme_material_details.line_type
               ,l_gme_material_details.plan_qty
               ,
                --l_gme_material_details.item_um,
                l_gme_material_details.item_um2
               ,l_gme_material_details.actual_qty
               ,l_gme_material_details.release_type
               ,l_gme_material_details.scrap_factor
               ,l_gme_material_details.scale_type
               ,l_gme_material_details.phantom_type
               ,l_gme_material_details.cost_alloc
               ,l_gme_material_details.alloc_ind
               ,l_gme_material_details.COST
               ,l_gme_material_details.text_code
               ,l_gme_material_details.phantom_id
               ,l_gme_material_details.created_by
               ,l_gme_material_details.creation_date
               ,l_gme_material_details.last_updated_by
               ,l_gme_material_details.last_update_date
               ,l_gme_material_details.attribute1
               ,l_gme_material_details.attribute2
               ,l_gme_material_details.attribute3
               ,l_gme_material_details.attribute4
               ,l_gme_material_details.attribute5
               ,l_gme_material_details.attribute6
               ,l_gme_material_details.attribute7
               ,l_gme_material_details.attribute8
               ,l_gme_material_details.attribute9
               ,l_gme_material_details.attribute10
               ,l_gme_material_details.attribute11
               ,l_gme_material_details.attribute12
               ,l_gme_material_details.attribute13
               ,l_gme_material_details.attribute14
               ,l_gme_material_details.attribute15
               ,l_gme_material_details.attribute16
               ,l_gme_material_details.attribute17
               ,l_gme_material_details.attribute18
               ,l_gme_material_details.attribute19
               ,l_gme_material_details.attribute20
               ,l_gme_material_details.attribute21
               ,l_gme_material_details.attribute22
               ,l_gme_material_details.attribute23
               ,l_gme_material_details.attribute24
               ,l_gme_material_details.attribute25
               ,l_gme_material_details.attribute26
               ,l_gme_material_details.attribute27
               ,l_gme_material_details.attribute28
               ,l_gme_material_details.attribute29
               ,l_gme_material_details.attribute30
               ,l_gme_material_details.attribute_category
               ,l_gme_material_details.last_update_login
               ,l_gme_material_details.scale_rounding_variance
               ,l_gme_material_details.scale_multiple
               ,l_gme_material_details.rounding_direction
               ,l_gme_material_details.contribute_yield_ind
               ,l_gme_material_details.contribute_step_qty_ind
               ,l_gme_material_details.wip_plan_qty
               ,l_gme_material_details.original_qty
               ,l_gme_material_details.by_product_type
               ,l_gme_material_details.organization_id
               ,l_gme_material_details.inventory_item_id
               ,l_gme_material_details.subinventory
               ,l_gme_material_details.locator_id
               ,l_gme_material_details.revision
               ,l_gme_material_details.backordered_qty
               ,l_gme_material_details.original_primary_qty
               ,l_gme_material_details.material_requirement_date
               ,l_gme_material_details.phantom_line_id
               ,l_gme_material_details.move_order_line_id
               ,l_gme_material_details.dtl_um
               ,l_gme_material_details.dispense_ind

           FROM gme_material_details
          WHERE batch_id = l_batch_id
            AND line_no = l_line_no
            AND line_type = l_line_type;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF (SQL%FOUND) THEN
         x_material_detail := l_gme_material_details;
         RETURN TRUE;
      ELSE
         gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         x_material_detail := l_gme_material_details;
         RETURN FALSE;
      END IF;
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

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    delete_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   delete_Row will delete a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   delete_row will delete a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_material_detail IN gme_material_details%ROWTYPE                     |
 | RETURNS                                                                  |
 |    BOOLEAN                                                                  |
 |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created                                    |
 |     26-AUG-2002 Bharati Satpute  Bug2404126                              |
 |     Added Error message 'GME_RECORD_CHANGED'                                                                     |
 +==========================================================================+
  Api end of comments
*/
   FUNCTION delete_row (p_material_detail IN gme_material_details%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_material_detail_id   NUMBER;
      l_batch_id             NUMBER;
      l_line_no              NUMBER;
      l_line_type            NUMBER;
      l_dummy                NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'DELETE_ROW';
   BEGIN
      l_material_detail_id := p_material_detail.material_detail_id;
      l_batch_id := p_material_detail.batch_id;
      l_line_no := p_material_detail.line_no;
      l_line_type := p_material_detail.line_type;

      IF l_material_detail_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_material_details
              WHERE material_detail_id = l_material_detail_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_material_details
               WHERE material_detail_id = l_material_detail_id;
      ELSIF     (l_batch_id IS NOT NULL)
            AND (l_line_no IS NOT NULL)
            AND (l_line_type IS NOT NULL) THEN
         SELECT     1
               INTO l_dummy
               FROM gme_material_details
              WHERE batch_id = l_batch_id
                AND line_no = l_line_no
                AND line_type = l_line_type
         FOR UPDATE NOWAIT;

         DELETE FROM gme_material_details
               WHERE batch_id = l_batch_id
                 AND line_no = l_line_no
                 AND line_type = l_line_type;
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
         END IF;

         RETURN FALSE;
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
                                    ,'Line No'
                                    ,'KEY'
                                    ,TO_CHAR (p_material_detail.line_no) );
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

/*  Api start of comments
 +==========================================================================+
 | FUNCTION NAME                                                           |
 |    update_row                                                            |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   update_row will update a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   update_row will update a row in  gme_material_details                  |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_material_detail IN gme_material_details%ROWTYPE                     |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |                                                                          |
 | HISTORY                                                                  |
 |     12-FEB-2001  fabdi        Created
 |     29-MAR-2002  bsatpute     Added error message                        |
 |     26-AUG-2002 Bharati Satpute  Bug2404126                              |
 |     Added Error message 'GME_RECORD_CHANGED'
 |                                                                          |
    G. Muratore   26-Feb-2009  Bug 7710435
       Added Called by parameter to avoid timestamp failures during batch
       creation. Also, corrected checking of l_dummy by adding NVL and
       left additional debug messages in here for future use.
 +==========================================================================+
  Api end of comments
*/
   FUNCTION update_row (p_material_detail IN gme_material_details%ROWTYPE
                       ,p_called_by IN VARCHAR2 DEFAULT 'U')
      RETURN BOOLEAN
   IS
      l_material_detail_id   NUMBER;
      l_batch_id             NUMBER;
      l_line_no              NUMBER;
      l_line_type            NUMBER;
      l_upd                  DATE;
      l_dummy                NUMBER        := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
      l_api_name    CONSTANT VARCHAR2 (30) := 'UPDATE_ROW';
   BEGIN
      l_material_detail_id := p_material_detail.material_detail_id;
      l_batch_id := p_material_detail.batch_id;
      l_line_no := p_material_detail.line_no;
      l_line_type := p_material_detail.line_type;

      IF g_debug <= gme_debug.g_log_statement THEN
         gme_debug.put_line ('Entering '||l_api_name);
         gme_debug.put_line ('Lets see what is really happening in db layer upon update.');
         gme_debug.put_line ('material detail id is '||l_material_detail_id);
         gme_debug.put_line ('batch detail id is '||l_batch_id);
         gme_debug.put_line ('line no is '||l_line_no);
         gme_debug.put_line ('l_line_type is '||l_line_type);
         gme_debug.put_line ('last_update_date coming in is '||TO_CHAR(p_material_detail.last_update_date,'DD-MON-YYYY HH24:MI:SS'));
         gme_debug.put_line ('timestamp is '||TO_CHAR(gme_common_pvt.g_timestamp,'DD-MON-YYYY HH24:MI:SS'));
      END IF;

      IF l_material_detail_id IS NOT NULL THEN
         SELECT     1, last_update_date
               INTO l_dummy, l_upd
               FROM gme_material_details
              WHERE material_detail_id = l_material_detail_id
         FOR UPDATE NOWAIT;

         UPDATE gme_material_details
            SET formulaline_id = p_material_detail.formulaline_id
               ,line_no = p_material_detail.line_no
               ,
                --item_id = p_material_detail.item_id,
                line_type = p_material_detail.line_type
               ,plan_qty = p_material_detail.plan_qty
               ,
                --item_um = p_material_detail.item_um,
                item_um2 = p_material_detail.item_um2
               ,actual_qty = nvl(p_material_detail.actual_qty,0)
               ,release_type = p_material_detail.release_type
               ,scrap_factor = p_material_detail.scrap_factor
               ,scale_type = p_material_detail.scale_type
               ,phantom_type = p_material_detail.phantom_type
               ,cost_alloc = p_material_detail.cost_alloc
               ,alloc_ind = p_material_detail.alloc_ind
               ,COST = p_material_detail.COST
               ,text_code = p_material_detail.text_code
               ,phantom_id = p_material_detail.phantom_id
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,attribute1 = p_material_detail.attribute1
               ,attribute2 = p_material_detail.attribute2
               ,attribute3 = p_material_detail.attribute3
               ,attribute4 = p_material_detail.attribute4
               ,attribute5 = p_material_detail.attribute5
               ,attribute6 = p_material_detail.attribute6
               ,attribute7 = p_material_detail.attribute7
               ,attribute8 = p_material_detail.attribute8
               ,attribute9 = p_material_detail.attribute9
               ,attribute10 = p_material_detail.attribute10
               ,attribute11 = p_material_detail.attribute11
               ,attribute12 = p_material_detail.attribute12
               ,attribute13 = p_material_detail.attribute13
               ,attribute14 = p_material_detail.attribute14
               ,attribute15 = p_material_detail.attribute15
               ,attribute16 = p_material_detail.attribute16
               ,attribute17 = p_material_detail.attribute17
               ,attribute18 = p_material_detail.attribute18
               ,attribute19 = p_material_detail.attribute19
               ,attribute20 = p_material_detail.attribute20
               ,attribute21 = p_material_detail.attribute21
               ,attribute22 = p_material_detail.attribute22
               ,attribute23 = p_material_detail.attribute23
               ,attribute24 = p_material_detail.attribute24
               ,attribute25 = p_material_detail.attribute25
               ,attribute26 = p_material_detail.attribute26
               ,attribute27 = p_material_detail.attribute27
               ,attribute28 = p_material_detail.attribute28
               ,attribute29 = p_material_detail.attribute29
               ,attribute30 = p_material_detail.attribute30
               ,attribute_category = p_material_detail.attribute_category
               ,last_update_login = p_material_detail.last_update_login
               ,scale_rounding_variance =
                                     p_material_detail.scale_rounding_variance
               ,scale_multiple = p_material_detail.scale_multiple
               ,rounding_direction = p_material_detail.rounding_direction
               ,contribute_yield_ind = p_material_detail.contribute_yield_ind
               ,contribute_step_qty_ind =
                                     p_material_detail.contribute_step_qty_ind
               ,wip_plan_qty = p_material_detail.wip_plan_qty
               ,original_qty = p_material_detail.original_qty
               ,by_product_type = p_material_detail.by_product_type
               ,organization_id = p_material_detail.organization_id
               ,inventory_item_id = p_material_detail.inventory_item_id
               ,subinventory = p_material_detail.subinventory
               ,locator_id = p_material_detail.locator_id
               ,revision = p_material_detail.revision
               ,backordered_qty = p_material_detail.backordered_qty
               ,material_requirement_date =
                                   p_material_detail.material_requirement_date
               ,phantom_line_id = p_material_detail.phantom_line_id
               ,move_order_line_id = p_material_detail.move_order_line_id
               ,dtl_um = p_material_detail.dtl_um
               ,dispense_ind = p_material_detail.dispense_ind

          WHERE material_detail_id = p_material_detail.material_detail_id
            -- AND last_update_date = p_material_detail.last_update_date;
            -- Bug 7710435 Put decode in there to avoid timestamp failures during batch creation.
            AND last_update_date = DECODE(p_called_by, 'U', p_material_detail.last_update_date, last_update_date);
      ELSIF     (l_batch_id IS NOT NULL)
            AND (l_line_no IS NOT NULL)
            AND (l_line_type IS NOT NULL) THEN
         SELECT     1
               INTO l_dummy
               FROM gme_material_details
              WHERE batch_id = l_batch_id
                AND line_no = l_line_no
                AND line_type = l_line_type
         FOR UPDATE NOWAIT;

         UPDATE gme_material_details
            SET formulaline_id = p_material_detail.formulaline_id
               ,line_no = p_material_detail.line_no
               ,line_type = p_material_detail.line_type
               ,plan_qty = p_material_detail.plan_qty
               ,item_um2 = p_material_detail.item_um2
               ,actual_qty = p_material_detail.actual_qty
               ,release_type = p_material_detail.release_type
               ,scrap_factor = p_material_detail.scrap_factor
               ,scale_type = p_material_detail.scale_type
               ,phantom_type = p_material_detail.phantom_type
               ,cost_alloc = p_material_detail.cost_alloc
               ,alloc_ind = p_material_detail.alloc_ind
               ,COST = p_material_detail.COST
               ,text_code = p_material_detail.text_code
               ,phantom_id = p_material_detail.phantom_id
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,attribute1 = p_material_detail.attribute1
               ,attribute2 = p_material_detail.attribute2
               ,attribute3 = p_material_detail.attribute3
               ,attribute4 = p_material_detail.attribute4
               ,attribute5 = p_material_detail.attribute5
               ,attribute6 = p_material_detail.attribute6
               ,attribute7 = p_material_detail.attribute7
               ,attribute8 = p_material_detail.attribute8
               ,attribute9 = p_material_detail.attribute9
               ,attribute10 = p_material_detail.attribute10
               ,attribute11 = p_material_detail.attribute11
               ,attribute12 = p_material_detail.attribute12
               ,attribute13 = p_material_detail.attribute13
               ,attribute14 = p_material_detail.attribute14
               ,attribute15 = p_material_detail.attribute15
               ,attribute16 = p_material_detail.attribute16
               ,attribute17 = p_material_detail.attribute17
               ,attribute18 = p_material_detail.attribute18
               ,attribute19 = p_material_detail.attribute19
               ,attribute20 = p_material_detail.attribute20
               ,attribute21 = p_material_detail.attribute21
               ,attribute22 = p_material_detail.attribute22
               ,attribute23 = p_material_detail.attribute23
               ,attribute24 = p_material_detail.attribute24
               ,attribute25 = p_material_detail.attribute25
               ,attribute26 = p_material_detail.attribute26
               ,attribute27 = p_material_detail.attribute27
               ,attribute28 = p_material_detail.attribute28
               ,attribute29 = p_material_detail.attribute29
               ,attribute30 = p_material_detail.attribute30
               ,attribute_category = p_material_detail.attribute_category
               ,last_update_login = p_material_detail.last_update_login
               ,scale_rounding_variance =
                                     p_material_detail.scale_rounding_variance
               ,scale_multiple = p_material_detail.scale_multiple
               ,rounding_direction = p_material_detail.rounding_direction
               ,contribute_yield_ind = p_material_detail.contribute_yield_ind
               ,contribute_step_qty_ind =
                                     p_material_detail.contribute_step_qty_ind
               ,wip_plan_qty = p_material_detail.wip_plan_qty
               ,by_product_type = p_material_detail.by_product_type
               ,organization_id = p_material_detail.organization_id
               ,inventory_item_id = p_material_detail.inventory_item_id
               ,subinventory = p_material_detail.subinventory
               ,locator_id = p_material_detail.locator_id
               ,revision = p_material_detail.revision
               ,backordered_qty = p_material_detail.backordered_qty
               ,original_primary_qty = p_material_detail.original_primary_qty
               ,material_requirement_date =
                                   p_material_detail.material_requirement_date
               ,phantom_line_id = p_material_detail.phantom_line_id
               ,move_order_line_id = p_material_detail.move_order_line_id
               ,dtl_um = p_material_detail.dtl_um
               ,dispense_ind = p_material_detail.dispense_ind

          WHERE batch_id = l_batch_id
            AND line_no = l_line_no
            AND line_type = l_line_type
            -- AND last_update_date = p_material_detail.last_update_date;
            -- Bug 7710435 Put decode in there to avoid timestamp failures during batch creation.
            AND last_update_date = DECODE(p_called_by, 'U', p_material_detail.last_update_date, last_update_date);
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,g_table_name);
         RETURN FALSE;
      END IF;

      IF (SQL%FOUND) THEN
         RETURN TRUE;
      ELSE

         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line ('Lets see why update is failing. POINT 1');
            IF (l_dummy IS NULL) THEN
               gme_debug.put_line ('l_dummy is NULL');
            ELSE
               gme_debug.put_line ('l_dummy is '||l_dummy);
            END IF;
            gme_debug.put_line ('DB LUP date is '||TO_CHAR(l_upd,'DD-MON-YYYY HH24:MI:SS'));
         END IF;

         IF NVL(l_dummy,0) = 0 THEN
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
         IF g_debug <= gme_debug.g_log_statement THEN
            gme_debug.put_line ('Lets see why update is failing. POINT 2');
            IF (l_dummy IS NULL) THEN
               gme_debug.put_line ('l_dummy is NULL');
            ELSE
               gme_debug.put_line ('l_dummy is '||l_dummy);
            END IF;
         END IF;

         IF NVL(l_dummy,0) = 0 THEN
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
                                    ,'Line No'
                                    ,'KEY'
                                    ,TO_CHAR (p_material_detail.line_no) );
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

/*
 +==========================================================================+
 | FUNCTION NAME                                                            |
 |    fetch_tab                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |    Private                                                               |
 |                                                                          |
 | USAGE                                                                    |
 |   fetch_tab will fetch a tab in  gme_material_details                    |
 |                                                                          |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_tab will fetch a tab in  gme_material_details                    |
 |                                                                          |
 |                                                                          |
 | PARAMETERS                                                               |
 |    p_material_detail IN            gme_material_details%ROWTYPE          |
 |    x_material_detail IN OUT NOCOPY GME_API_GRP.material_details_tab      |
 |                                                                          |
 | RETURNS                                                                  |
 |    BOOLEAN                                                               |
 |                                                                          |
 | HISTORY                                                                  |
 |     08-May-2001  odaboval     Created                                    |
 |                                                                          |
 +==========================================================================+
*/
   FUNCTION fetch_tab (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_common_pvt.material_details_tab)
      RETURN BOOLEAN
   IS
      i                     NUMBER        := 0;
      l_api_name   CONSTANT VARCHAR2 (30) := 'FETCH_TAB';

      CURSOR c_material_dtl_0 (l_batch_id IN NUMBER)
      IS
         SELECT *
           FROM gme_material_details
          WHERE batch_id = l_batch_id;

      CURSOR c_material_dtl_1 (l_mat_dtl_id IN NUMBER)
      IS
         SELECT *
           FROM gme_material_details
          WHERE material_detail_id = l_mat_dtl_id;

      CURSOR c_material_dtl_2 (
         l_batch_id    IN   NUMBER
        ,l_line_no     IN   NUMBER
        ,l_line_type   IN   NUMBER)
      IS
         SELECT *
           FROM gme_material_details
          WHERE batch_id = l_batch_id
            AND line_no = l_line_no
            AND line_type = l_line_type;
   BEGIN
      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   l_api_name
                             || ' in fetch_tab. batch_id= '
                             || p_material_detail.batch_id);
      END IF;

      IF (p_material_detail.batch_id IS NOT NULL) THEN
         OPEN c_material_dtl_0 (p_material_detail.batch_id);

         LOOP
            i := i + 1;

            FETCH c_material_dtl_0
             INTO x_material_detail (i);

            EXIT WHEN c_material_dtl_0%NOTFOUND;
         END LOOP;

         IF (c_material_dtl_0%ROWCOUNT = 0) THEN
            CLOSE c_material_dtl_0;

            RAISE NO_DATA_FOUND;
         END IF;

         CLOSE c_material_dtl_0;
      ELSIF (p_material_detail.material_detail_id IS NOT NULL) THEN
         OPEN c_material_dtl_1 (p_material_detail.material_detail_id);

         LOOP
            i := i + 1;

            FETCH c_material_dtl_1
             INTO x_material_detail (i);

            EXIT WHEN c_material_dtl_0%NOTFOUND;
         END LOOP;

         IF (c_material_dtl_1%ROWCOUNT = 0) THEN
            CLOSE c_material_dtl_1;

            RAISE NO_DATA_FOUND;
         END IF;

         CLOSE c_material_dtl_1;
      ELSIF     (p_material_detail.batch_id IS NOT NULL)
            AND (p_material_detail.line_no IS NOT NULL)
            AND (p_material_detail.line_type IS NOT NULL) THEN
         OPEN c_material_dtl_2 (p_material_detail.batch_id
                               ,p_material_detail.line_no
                               ,p_material_detail.line_type);

         LOOP
            i := i + 1;

            FETCH c_material_dtl_2
             INTO x_material_detail (i);

            EXIT WHEN c_material_dtl_0%NOTFOUND;
         END LOOP;

         IF (c_material_dtl_2%NOTFOUND) THEN
            CLOSE c_material_dtl_2;

            RAISE NO_DATA_FOUND;
         END IF;

         CLOSE c_material_dtl_2;
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

         IF (c_material_dtl_0%ISOPEN) THEN
            CLOSE c_material_dtl_0;
         END IF;

         IF (c_material_dtl_1%ISOPEN) THEN
            CLOSE c_material_dtl_1;
         END IF;

         IF (c_material_dtl_2%ISOPEN) THEN
            CLOSE c_material_dtl_2;
         END IF;

         gme_common_pvt.log_message ('GME_UNEXPECTED_ERROR', 'ERROR', SQLERRM);
         RETURN FALSE;
   END fetch_tab;
END gme_material_details_dbl;

/
