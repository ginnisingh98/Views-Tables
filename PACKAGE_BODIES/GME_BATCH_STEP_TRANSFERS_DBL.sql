--------------------------------------------------------
--  DDL for Package Body GME_BATCH_STEP_TRANSFERS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_STEP_TRANSFERS_DBL" AS
/* $Header: GMEVGSTB.pls 120.1 2005/06/03 13:47:29 appldev  $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'GME_BATCH_STEP_TRANSFERS';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGSTB.pls
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
 |      Insert_Row will insert a row in gme_batch_step_transfers
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gme_batch_step_transfers
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_transfers IN             gme_batch_step_transfers%ROWTYPE
 |     x_batch_step_transfers IN OUT NOCOPY  gme_batch_step_transfers%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION insert_row (
      p_batch_step_transfers   IN              gme_batch_step_transfers%ROWTYPE
     ,x_batch_step_transfers   IN OUT NOCOPY   gme_batch_step_transfers%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      x_batch_step_transfers := p_batch_step_transfers;

      INSERT INTO gme_batch_step_transfers
                  (wip_trans_id
                  ,batch_id
                  ,batchstep_no
                  ,transfer_step_no
                  ,line_type
                  ,trans_qty
                  ,trans_um
                  ,trans_date
                  ,last_updated_by, last_update_date
                  ,last_update_login, creation_date
                  ,created_by
                  ,delete_mark
                  ,text_code
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
                  ,attribute_category)
           VALUES (gem5_wip_trans_id_s.NEXTVAL
                  ,x_batch_step_transfers.batch_id
                  ,x_batch_step_transfers.batchstep_no
                  ,x_batch_step_transfers.transfer_step_no
                  ,x_batch_step_transfers.line_type
                  ,x_batch_step_transfers.trans_qty
                  ,x_batch_step_transfers.trans_um
                  ,x_batch_step_transfers.trans_date
                  ,gme_common_pvt.g_user_ident, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_login_id, gme_common_pvt.g_timestamp
                  ,gme_common_pvt.g_user_ident
                  ,x_batch_step_transfers.delete_mark
                  ,x_batch_step_transfers.text_code
                  ,x_batch_step_transfers.attribute1
                  ,x_batch_step_transfers.attribute2
                  ,x_batch_step_transfers.attribute3
                  ,x_batch_step_transfers.attribute4
                  ,x_batch_step_transfers.attribute5
                  ,x_batch_step_transfers.attribute6
                  ,x_batch_step_transfers.attribute7
                  ,x_batch_step_transfers.attribute8
                  ,x_batch_step_transfers.attribute9
                  ,x_batch_step_transfers.attribute10
                  ,x_batch_step_transfers.attribute11
                  ,x_batch_step_transfers.attribute12
                  ,x_batch_step_transfers.attribute13
                  ,x_batch_step_transfers.attribute14
                  ,x_batch_step_transfers.attribute15
                  ,x_batch_step_transfers.attribute16
                  ,x_batch_step_transfers.attribute17
                  ,x_batch_step_transfers.attribute18
                  ,x_batch_step_transfers.attribute19
                  ,x_batch_step_transfers.attribute20
                  ,x_batch_step_transfers.attribute21
                  ,x_batch_step_transfers.attribute22
                  ,x_batch_step_transfers.attribute23
                  ,x_batch_step_transfers.attribute24
                  ,x_batch_step_transfers.attribute25
                  ,x_batch_step_transfers.attribute26
                  ,x_batch_step_transfers.attribute27
                  ,x_batch_step_transfers.attribute28
                  ,x_batch_step_transfers.attribute29
                  ,x_batch_step_transfers.attribute30
                  ,x_batch_step_transfers.attribute_category)
        RETURNING wip_trans_id
             INTO x_batch_step_transfers.wip_trans_id;

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
 |      Fetch_Row will fetch a row in gme_batch_step_transfers
 |
 |
 |   DESCRIPTION
 |      Fetch_Row will fetch a row in gme_batch_step_transfers
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_transfers IN             gme_batch_step_transfers%ROWTYPE
 |     x_batch_step_transfers IN OUT NOCOPY  gme_batch_step_transfers%ROWTYPE
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
      p_batch_step_transfers   IN              gme_batch_step_transfers%ROWTYPE
     ,x_batch_step_transfers   IN OUT NOCOPY   gme_batch_step_transfers%ROWTYPE)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_batch_step_transfers.wip_trans_id IS NOT NULL THEN
         SELECT wip_trans_id
               ,batch_id
               ,batchstep_no
               ,transfer_step_no
               ,line_type
               ,trans_qty
               ,trans_um
               ,trans_date
               ,last_updated_by
               ,last_update_date
               ,last_update_login
               ,creation_date
               ,created_by
               ,delete_mark
               ,text_code
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
           INTO x_batch_step_transfers.wip_trans_id
               ,x_batch_step_transfers.batch_id
               ,x_batch_step_transfers.batchstep_no
               ,x_batch_step_transfers.transfer_step_no
               ,x_batch_step_transfers.line_type
               ,x_batch_step_transfers.trans_qty
               ,x_batch_step_transfers.trans_um
               ,x_batch_step_transfers.trans_date
               ,x_batch_step_transfers.last_updated_by
               ,x_batch_step_transfers.last_update_date
               ,x_batch_step_transfers.last_update_login
               ,x_batch_step_transfers.creation_date
               ,x_batch_step_transfers.created_by
               ,x_batch_step_transfers.delete_mark
               ,x_batch_step_transfers.text_code
               ,x_batch_step_transfers.attribute1
               ,x_batch_step_transfers.attribute2
               ,x_batch_step_transfers.attribute3
               ,x_batch_step_transfers.attribute4
               ,x_batch_step_transfers.attribute5
               ,x_batch_step_transfers.attribute6
               ,x_batch_step_transfers.attribute7
               ,x_batch_step_transfers.attribute8
               ,x_batch_step_transfers.attribute9
               ,x_batch_step_transfers.attribute10
               ,x_batch_step_transfers.attribute11
               ,x_batch_step_transfers.attribute12
               ,x_batch_step_transfers.attribute13
               ,x_batch_step_transfers.attribute14
               ,x_batch_step_transfers.attribute15
               ,x_batch_step_transfers.attribute16
               ,x_batch_step_transfers.attribute17
               ,x_batch_step_transfers.attribute18
               ,x_batch_step_transfers.attribute19
               ,x_batch_step_transfers.attribute20
               ,x_batch_step_transfers.attribute21
               ,x_batch_step_transfers.attribute22
               ,x_batch_step_transfers.attribute23
               ,x_batch_step_transfers.attribute24
               ,x_batch_step_transfers.attribute25
               ,x_batch_step_transfers.attribute26
               ,x_batch_step_transfers.attribute27
               ,x_batch_step_transfers.attribute28
               ,x_batch_step_transfers.attribute29
               ,x_batch_step_transfers.attribute30
               ,x_batch_step_transfers.attribute_category
           FROM gme_batch_step_transfers
          WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id;
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
 |      Delete_Row will delete a row in gme_batch_step_transfers
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gme_batch_step_transfers
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_transfers IN  gme_batch_step_transfers%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   23-AUG-02  Bharati Satpute  Bug2404126
 |   Added error message GME_RECORD_CHANGED
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION delete_row (
      p_batch_step_transfers   IN   gme_batch_step_transfers%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER (5) := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_batch_step_transfers.wip_trans_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_transfers
              WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_transfers
            SET delete_mark = 1
          WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id;
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
                               ,'WIP_TRANS_ID'
                               ,'KEY'
                               ,TO_CHAR (p_batch_step_transfers.wip_trans_id) );
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
 |      Update_Row will update a row in gme_batch_step_transfers
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gme_batch_step_transfers
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_transfers IN  gme_batch_step_transfers%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-01 Thomas Daniel   Created
 |   23-AUG-02  Bharati Satpute  Bug2404126
 |   Added error message GME_RECORD_CHANGED
 |
 |
 +=============================================================================
 Api end of comments
*/
   FUNCTION update_row (
      p_batch_step_transfers   IN   gme_batch_step_transfers%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy                NUMBER;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
   BEGIN
      IF p_batch_step_transfers.wip_trans_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_transfers
              WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id
         FOR UPDATE NOWAIT;

         UPDATE gme_batch_step_transfers
            SET batch_id = p_batch_step_transfers.batch_id
               ,batchstep_no = p_batch_step_transfers.batchstep_no
               ,transfer_step_no = p_batch_step_transfers.transfer_step_no
               ,line_type = p_batch_step_transfers.line_type
               ,trans_qty = p_batch_step_transfers.trans_qty
               ,trans_um = p_batch_step_transfers.trans_um
               ,trans_date = p_batch_step_transfers.trans_date
               ,last_updated_by = gme_common_pvt.g_user_ident
               ,last_update_date = gme_common_pvt.g_timestamp
               ,last_update_login = gme_common_pvt.g_login_id
               ,delete_mark = p_batch_step_transfers.delete_mark
               ,text_code = p_batch_step_transfers.text_code
               ,attribute1 = p_batch_step_transfers.attribute1
               ,attribute2 = p_batch_step_transfers.attribute2
               ,attribute3 = p_batch_step_transfers.attribute3
               ,attribute4 = p_batch_step_transfers.attribute4
               ,attribute5 = p_batch_step_transfers.attribute5
               ,attribute6 = p_batch_step_transfers.attribute6
               ,attribute7 = p_batch_step_transfers.attribute7
               ,attribute8 = p_batch_step_transfers.attribute8
               ,attribute9 = p_batch_step_transfers.attribute9
               ,attribute10 = p_batch_step_transfers.attribute10
               ,attribute11 = p_batch_step_transfers.attribute11
               ,attribute12 = p_batch_step_transfers.attribute12
               ,attribute13 = p_batch_step_transfers.attribute13
               ,attribute14 = p_batch_step_transfers.attribute14
               ,attribute15 = p_batch_step_transfers.attribute15
               ,attribute16 = p_batch_step_transfers.attribute16
               ,attribute17 = p_batch_step_transfers.attribute17
               ,attribute18 = p_batch_step_transfers.attribute18
               ,attribute19 = p_batch_step_transfers.attribute19
               ,attribute20 = p_batch_step_transfers.attribute20
               ,attribute21 = p_batch_step_transfers.attribute21
               ,attribute22 = p_batch_step_transfers.attribute22
               ,attribute23 = p_batch_step_transfers.attribute23
               ,attribute24 = p_batch_step_transfers.attribute24
               ,attribute25 = p_batch_step_transfers.attribute25
               ,attribute26 = p_batch_step_transfers.attribute26
               ,attribute27 = p_batch_step_transfers.attribute27
               ,attribute28 = p_batch_step_transfers.attribute28
               ,attribute29 = p_batch_step_transfers.attribute29
               ,attribute30 = p_batch_step_transfers.attribute30
               ,attribute_category = p_batch_step_transfers.attribute_category
          WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id
            AND last_update_date = p_batch_step_transfers.last_update_date;
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
                               ,'WIP_TRANS_ID'
                               ,'KEY'
                               ,TO_CHAR (p_batch_step_transfers.wip_trans_id) );
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
 |      Lock_Row will lock a row in gme_batch_step_transfers
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gme_batch_step_transfers
 |
 |
 |
 |   PARAMETERS
 |     p_batch_step_transfers IN  gme_batch_step_transfers%ROWTYPE
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
      p_batch_step_transfers   IN   gme_batch_step_transfers%ROWTYPE)
      RETURN BOOLEAN
   IS
      l_dummy   NUMBER;
   BEGIN
      IF p_batch_step_transfers.wip_trans_id IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gme_batch_step_transfers
              WHERE wip_trans_id = p_batch_step_transfers.wip_trans_id
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
                               ,'wip_trans_id'
                               ,'KEY'
                               ,TO_CHAR (p_batch_step_transfers.wip_trans_id) );
         RETURN FALSE;
      WHEN OTHERS THEN
         RETURN FALSE;
   END lock_row;
END gme_batch_step_transfers_dbl;

/
