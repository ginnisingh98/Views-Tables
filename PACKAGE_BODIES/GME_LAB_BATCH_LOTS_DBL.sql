--------------------------------------------------------
--  DDL for Package Body GME_LAB_BATCH_LOTS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_LAB_BATCH_LOTS_DBL" AS
/* $Header: GMEVGLBB.pls 120.2 2006/02/03 07:23:27 svgonugu noship $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_LAB_BATCH_LOTS_DBL';
   g_debug        VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGLBB.pls
 |
 |   DESCRIPTION
 |      This procedure is user to manipulate the GME_LAB_BATCH_LOTS table.
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |      - create_row
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
 |      Insert_Row will insert a row in gme_lab_batch_lots
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_lab_batch_lots
 |
 |
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
 |     x_lab_batch_lots IN OUT NOCOPY gme_lab_batch_lots%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01    Thomas Daniel  Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_lab_batch_lots   IN              gme_lab_batch_lots%ROWTYPE
     ,x_lab_batch_lots   IN OUT NOCOPY   gme_lab_batch_lots%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_lab_batch_lots := p_lab_batch_lots;

      INSERT INTO gme_lab_batch_lots
                  (batch_id
                  ,material_detail_id
                  ,item_id, lot_id
                  ,qty, qty2
                  ,uom, uom2
                  ,creation_date, created_by
                  ,last_update_date, last_updated_by
                  ,last_update_login, attribute1
                  ,attribute2, attribute3
                  ,attribute4, attribute5
                  ,attribute6, attribute7
                  ,attribute8, attribute9
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
                  ,attribute_category)
           VALUES (x_lab_batch_lots.batch_id
                  ,x_lab_batch_lots.material_detail_id
                  ,x_lab_batch_lots.item_id, x_lab_batch_lots.lot_id
                  ,x_lab_batch_lots.qty, x_lab_batch_lots.qty2
                  ,x_lab_batch_lots.uom, x_lab_batch_lots.uom2
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_timestamp, gme_common_pvt.g_user_ident
                  ,gme_common_pvt.g_login_id, x_lab_batch_lots.attribute1
                  ,x_lab_batch_lots.attribute2, x_lab_batch_lots.attribute3
                  ,x_lab_batch_lots.attribute4, x_lab_batch_lots.attribute5
                  ,x_lab_batch_lots.attribute6, x_lab_batch_lots.attribute7
                  ,x_lab_batch_lots.attribute8, x_lab_batch_lots.attribute9
                  ,x_lab_batch_lots.attribute10
                  ,x_lab_batch_lots.attribute11
                  ,x_lab_batch_lots.attribute12
                  ,x_lab_batch_lots.attribute13
                  ,x_lab_batch_lots.attribute14
                  ,x_lab_batch_lots.attribute15
                  ,x_lab_batch_lots.attribute16
                  ,x_lab_batch_lots.attribute17
                  ,x_lab_batch_lots.attribute18
                  ,x_lab_batch_lots.attribute19
                  ,x_lab_batch_lots.attribute20
                  ,x_lab_batch_lots.attribute21
                  ,x_lab_batch_lots.attribute22
                  ,x_lab_batch_lots.attribute23
                  ,x_lab_batch_lots.attribute24
                  ,x_lab_batch_lots.attribute25
                  ,x_lab_batch_lots.attribute26
                  ,x_lab_batch_lots.attribute27
                  ,x_lab_batch_lots.attribute28
                  ,x_lab_batch_lots.attribute29
                  ,x_lab_batch_lots.attribute30
                  ,x_lab_batch_lots.attribute_category);

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
 |      Fetch_Row will fetch a row in gme_lab_batch_lots
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_lab_batch_lots
 |
 |
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
 |     x_lab_batch_lots IN OUT NOCOPY gme_lab_batch_lots%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION fetch_row (
      p_lab_batch_lots   IN              gme_lab_batch_lots%ROWTYPE
     ,x_lab_batch_lots   IN OUT NOCOPY   gme_lab_batch_lots%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF     p_lab_batch_lots.batch_id IS NOT NULL
         AND p_lab_batch_lots.material_detail_id IS NOT NULL
         AND p_lab_batch_lots.item_id IS NOT NULL
         AND p_lab_batch_lots.lot_id IS NOT NULL THEN
         SELECT batch_id
               ,material_detail_id
               ,item_id, lot_id
               ,qty, qty2
               ,uom, uom2
               ,creation_date, created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login
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
               ,attribute_category
           INTO x_lab_batch_lots.batch_id
               ,x_lab_batch_lots.material_detail_id
               ,x_lab_batch_lots.item_id, x_lab_batch_lots.lot_id
               ,x_lab_batch_lots.qty, x_lab_batch_lots.qty2
               ,x_lab_batch_lots.uom, x_lab_batch_lots.uom2
               ,x_lab_batch_lots.creation_date, x_lab_batch_lots.created_by
               ,x_lab_batch_lots.last_update_date
               ,x_lab_batch_lots.last_updated_by
               ,x_lab_batch_lots.last_update_login
               ,x_lab_batch_lots.attribute1, x_lab_batch_lots.attribute2
               ,x_lab_batch_lots.attribute3, x_lab_batch_lots.attribute4
               ,x_lab_batch_lots.attribute5, x_lab_batch_lots.attribute6
               ,x_lab_batch_lots.attribute7, x_lab_batch_lots.attribute8
               ,x_lab_batch_lots.attribute9, x_lab_batch_lots.attribute10
               ,x_lab_batch_lots.attribute11, x_lab_batch_lots.attribute12
               ,x_lab_batch_lots.attribute13, x_lab_batch_lots.attribute14
               ,x_lab_batch_lots.attribute15, x_lab_batch_lots.attribute16
               ,x_lab_batch_lots.attribute17, x_lab_batch_lots.attribute18
               ,x_lab_batch_lots.attribute19, x_lab_batch_lots.attribute20
               ,x_lab_batch_lots.attribute21, x_lab_batch_lots.attribute22
               ,x_lab_batch_lots.attribute23, x_lab_batch_lots.attribute24
               ,x_lab_batch_lots.attribute25, x_lab_batch_lots.attribute26
               ,x_lab_batch_lots.attribute27, x_lab_batch_lots.attribute28
               ,x_lab_batch_lots.attribute29, x_lab_batch_lots.attribute30
               ,x_lab_batch_lots.attribute_category
           FROM gme_lab_batch_lots
          WHERE batch_id = p_lab_batch_lots.batch_id
            AND material_detail_id = p_lab_batch_lots.material_detail_id
            AND item_id = p_lab_batch_lots.item_id
            AND lot_id = p_lab_batch_lots.lot_id;
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
 |      Delete_Row will delete a row in gme_lab_batch_lots
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_lab_batch_lots
 |
 |
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel  Created
 |   26-AUG-02  Bharati Satpute 2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (p_lab_batch_lots IN gme_lab_batch_lots%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER (5) := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF     p_lab_batch_lots.batch_id IS NOT NULL
         AND p_lab_batch_lots.material_detail_id IS NOT NULL
         AND p_lab_batch_lots.item_id IS NOT NULL
         AND p_lab_batch_lots.lot_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_lab_batch_lots
              WHERE batch_id = p_lab_batch_lots.batch_id
                AND material_detail_id = p_lab_batch_lots.material_detail_id
                AND item_id = p_lab_batch_lots.item_id
                AND lot_id = p_lab_batch_lots.lot_id
         FOR UPDATE NOWAIT;

         DELETE FROM gme_lab_batch_lots
               WHERE batch_id = p_lab_batch_lots.batch_id
                 AND material_detail_id = p_lab_batch_lots.material_detail_id
                 AND item_id = p_lab_batch_lots.item_id
                 AND lot_id = p_lab_batch_lots.lot_id;
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
                                    ,TO_CHAR (p_lab_batch_lots.batch_id) );
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
 |      Update_Row will update a row in gme_lab_batch_lots
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_lab_batch_lots
 |
 |
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01    Thomas Daniel  Created
 |   26-AUG-02  Bharati Satpute 2404126
 |   Added error message 'GME_RECORD_CHANGED'
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (p_lab_batch_lots IN gme_lab_batch_lots%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF     p_lab_batch_lots.batch_id IS NOT NULL
         AND p_lab_batch_lots.material_detail_id IS NOT NULL
         AND p_lab_batch_lots.item_id IS NOT NULL
         AND p_lab_batch_lots.lot_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_lab_batch_lots
              WHERE batch_id = p_lab_batch_lots.batch_id
                AND material_detail_id = p_lab_batch_lots.material_detail_id
                AND item_id = p_lab_batch_lots.item_id
                AND lot_id = p_lab_batch_lots.lot_id
         FOR UPDATE NOWAIT;

         UPDATE gme_lab_batch_lots
            SET qty = p_lab_batch_lots.qty
               ,qty2 = p_lab_batch_lots.qty2
               ,uom = p_lab_batch_lots.uom
               ,uom2 = p_lab_batch_lots.uom2
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_login = gme_common_pvt.g_login_id
               ,attribute1 = p_lab_batch_lots.attribute1
               ,attribute2 = p_lab_batch_lots.attribute2
               ,attribute3 = p_lab_batch_lots.attribute3
               ,attribute4 = p_lab_batch_lots.attribute4
               ,attribute5 = p_lab_batch_lots.attribute5
               ,attribute6 = p_lab_batch_lots.attribute6
               ,attribute7 = p_lab_batch_lots.attribute7
               ,attribute8 = p_lab_batch_lots.attribute8
               ,attribute9 = p_lab_batch_lots.attribute9
               ,attribute10 = p_lab_batch_lots.attribute10
               ,attribute11 = p_lab_batch_lots.attribute11
               ,attribute12 = p_lab_batch_lots.attribute12
               ,attribute13 = p_lab_batch_lots.attribute13
               ,attribute14 = p_lab_batch_lots.attribute14
               ,attribute15 = p_lab_batch_lots.attribute15
               ,attribute16 = p_lab_batch_lots.attribute16
               ,attribute17 = p_lab_batch_lots.attribute17
               ,attribute18 = p_lab_batch_lots.attribute18
               ,attribute19 = p_lab_batch_lots.attribute19
               ,attribute20 = p_lab_batch_lots.attribute20
               ,attribute21 = p_lab_batch_lots.attribute21
               ,attribute22 = p_lab_batch_lots.attribute22
               ,attribute23 = p_lab_batch_lots.attribute23
               ,attribute24 = p_lab_batch_lots.attribute24
               ,attribute25 = p_lab_batch_lots.attribute25
               ,attribute26 = p_lab_batch_lots.attribute26
               ,attribute27 = p_lab_batch_lots.attribute27
               ,attribute28 = p_lab_batch_lots.attribute28
               ,attribute29 = p_lab_batch_lots.attribute29
               ,attribute30 = p_lab_batch_lots.attribute30
               ,attribute_category = p_lab_batch_lots.attribute_category
          WHERE batch_id = p_lab_batch_lots.batch_id
            AND material_detail_id = p_lab_batch_lots.material_detail_id
            AND item_id = p_lab_batch_lots.item_id
            AND lot_id = p_lab_batch_lots.lot_id
            AND last_update_date = p_lab_batch_lots.last_update_date;
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
                                    ,TO_CHAR (p_lab_batch_lots.batch_id) );
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
 |      Lock_Row will lock a row in gme_lab_batch_lots
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_lab_batch_lots
 |
 |
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
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
   FUNCTION lock_row (p_lab_batch_lots IN gme_lab_batch_lots%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy   NUMBER;
   BEGIN
      IF     p_lab_batch_lots.batch_id IS NOT NULL
         AND p_lab_batch_lots.material_detail_id IS NOT NULL
         AND p_lab_batch_lots.item_id IS NOT NULL
         AND p_lab_batch_lots.lot_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_lab_batch_lots
              WHERE batch_id = p_lab_batch_lots.batch_id
                AND material_detail_id = p_lab_batch_lots.material_detail_id
                AND item_id = p_lab_batch_lots.item_id
                AND lot_id = p_lab_batch_lots.lot_id
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
                                    ,TO_CHAR (p_lab_batch_lots.batch_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         RETURN FALSE;
   END lock_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_lab_lots
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Lab_Lots will delete all the lot allocations.
 |
 |
 |   DESCRIPTION
 |      Delete_Lab_Lots will delete all the lot allocations either for a
 |      batch or for a material detail or for a combination of material
 |      detail and lot id.
 |
 |   PARAMETERS
 |     p_lab_batch_lots IN  gme_lab_batch_lots%ROWTYPE
 |     x_return_status  IN OUT NOCOPY VARCHAR2
 |
 |   HISTORY
 |   13-NOV-01 Thomas Daniel   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   PROCEDURE delete_lab_lots (
      p_lab_batch_lots   IN              gme_lab_batch_lots%ROWTYPE
     ,x_return_status    IN OUT NOCOPY   VARCHAR2)
   IS
      TYPE query_ref IS REF CURSOR;

      get_lots     query_ref;
      l_where      VARCHAR2 (2000);
      l_cursor     NUMBER (5);
      l_lab_lots   gme_lab_batch_lots%ROWTYPE;
   BEGIN
      /*  Initialize API return status to sucess  */
      x_return_status := fnd_api.g_ret_sts_success;

      -- Determine if any of the key values are present
      IF (     (p_lab_batch_lots.lot_id IS NOT NULL)
          AND (p_lab_batch_lots.material_detail_id IS NOT NULL) ) THEN
         /*l_where :=
               'material_detail_ID =:material_detail_id AND '
            || 'lot_id = :lot_id'; */
         l_cursor := 1;
      ELSIF (p_lab_batch_lots.material_detail_id IS NOT NULL) THEN
         --l_where := 'material_detail_id =:material_detail_id';
         l_cursor := 2;
      ELSIF (p_lab_batch_lots.batch_id IS NOT NULL) THEN
         --l_where := 'BATCH_ID =:batch_id';
         l_cursor := 3;
      ELSE
         gme_common_pvt.log_message ('GME_NO_KEYS'
                                    ,'TABLE_NAME'
                                    ,'GME_LAB_BATCH_LOTS');
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line ('Where Clause = ' || l_where);
      END IF;

      --FPBug#4998874 directly put the l_where value in the OPEN FOR statement.
      IF l_cursor = 1 THEN
         OPEN get_lots
          FOR  ' SELECT * FROM GME_LAB_BATCH_LOTS
                   WHERE material_detail_ID =:material_detail_id AND lot_id = :lot_id'
                USING p_lab_batch_lots.material_detail_id, p_lab_batch_lots.lot_id;
      ELSIF l_cursor = 2 THEN
         OPEN get_lots
          FOR  ' SELECT * FROM GME_LAB_BATCH_LOTS
	           WHERE material_detail_id =:material_detail_id'
               USING p_lab_batch_lots.material_detail_id;
      ELSIF l_cursor = 3 THEN
         OPEN get_lots
          FOR    ' SELECT * FROM GME_LAB_BATCH_LOTS
                     WHERE batch_id =:batch_id'
                   USING p_lab_batch_lots.batch_id;
      END IF;

      LOOP
         FETCH get_lots
          INTO l_lab_lots;

         EXIT WHEN get_lots%NOTFOUND;

         IF NOT gme_lab_batch_lots_dbl.delete_row
                                              (p_lab_batch_lots      => l_lab_lots) THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

      CLOSE get_lots;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ('GME_LAB_BATCH_LOTS_DBL'
                                 ,'DELETE_LAB_LOTS');

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('IN OTHERS ' || SQLERRM);
         END IF;
   END delete_lab_lots;
END gme_lab_batch_lots_dbl;

/
