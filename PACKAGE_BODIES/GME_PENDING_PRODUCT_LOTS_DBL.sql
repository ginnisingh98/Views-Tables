--------------------------------------------------------
--  DDL for Package Body GME_PENDING_PRODUCT_LOTS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_PENDING_PRODUCT_LOTS_DBL" AS
/*  $Header: GMEVGPLB.pls 120.1 2006/05/03 12:00:07 creddy noship $    */

   /* Global Variables */
   g_table_name          VARCHAR2 (80) DEFAULT 'GME_PENDING_PRODUCT_LOTS';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_PENDING_PRODUCT_LOTS_DBL';

 /*=========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGPLB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Body of package gme_pending_product_lots_dbl                       |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |    June 2005 Created                                                    |
 |                                                                         |
 |             - insert_row                                                |
 |             - fetch_row                                                 |
 |             - update_row                                                |
 |             - delete_row                                                |
 |             - lock_row                                                  |
 |                                                                         |
 =========================================================================*/

 /*==========================================================================
 | FUNCTION NAME                                                            |
 |   insert_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   insert_row will insert a row in gme_pending_product_lots               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   insert_row will insert a row in gme_pending_product_lots               |
 |                                                                          |
 | PARAMETERS                                                               |
 |   p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE         |
 |   x_pending_product_lots_rec IN OUT NOCOPY gme_pending_product_lots%ROWTYPE |
 |                                                                          |
 | RETURNS                                                                  |
 |   BOOLEAN                                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 ==========================================================================*/
  FUNCTION insert_row
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   IN OUT NOCOPY  gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN IS

    l_api_name   CONSTANT VARCHAR2 (30) := 'insert_row';

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    x_pending_product_lots_rec := p_pending_product_lots_rec;

    x_pending_product_lots_rec.last_update_date := gme_common_pvt.g_timestamp;
    x_pending_product_lots_rec.last_updated_by := gme_common_pvt.g_user_ident;
    x_pending_product_lots_rec.last_update_login := gme_common_pvt.g_login_id;

    x_pending_product_lots_rec.creation_date := gme_common_pvt.g_timestamp;
    x_pending_product_lots_rec.created_by := gme_common_pvt.g_user_ident;

    SELECT apps.gme_pending_product_lots_s.nextval
      INTO x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID
      FROM sys.dual;

    INSERT INTO gme_pending_product_lots
                (PENDING_PRODUCT_LOT_ID
                ,SEQUENCE
                ,BATCH_ID
                ,MATERIAL_DETAIL_ID
                ,REVISION
                ,LOT_NUMBER
                ,QUANTITY
                ,SECONDARY_QUANTITY
                ,REASON_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN)
         VALUES (x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID
                ,x_pending_product_lots_rec.SEQUENCE
                ,x_pending_product_lots_rec.BATCH_ID
                ,x_pending_product_lots_rec.MATERIAL_DETAIL_ID
                ,x_pending_product_lots_rec.REVISION
                ,x_pending_product_lots_rec.LOT_NUMBER
                ,x_pending_product_lots_rec.QUANTITY
                ,x_pending_product_lots_rec.SECONDARY_QUANTITY
                ,x_pending_product_lots_rec.REASON_ID
                ,x_pending_product_lots_rec.CREATION_DATE
                ,x_pending_product_lots_rec.CREATED_BY
                ,x_pending_product_lots_rec.LAST_UPDATE_DATE
                ,x_pending_product_lots_rec.LAST_UPDATED_BY
                ,x_pending_product_lots_rec.LAST_UPDATE_LOGIN);

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Exiting api '||g_pkg_name||'.'||l_api_name);
    END IF;

    IF SQL%FOUND THEN
      RETURN TRUE;
    ELSE
      x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID := NULL;
      RETURN FALSE;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;

    x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID := NULL;

    RETURN FALSE;
  END insert_row;

 /*==========================================================================
 | FUNCTION NAME                                                            |
 |   fetch_row                                                              |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   fetch_row will fetch a row in gme_pending_product_lots                 |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   fetch_row will fetch a row in gme_pending_product_lots                 |
 |                                                                          |
 | PARAMETERS                                                               |
 |   p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE         |
 |   x_pending_product_lots_rec IN OUT NOCOPY gme_pending_product_lots%ROWTYPE |
 |                                                                          |
 | RETURNS                                                                  |
 |   BOOLEAN                                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 ==========================================================================*/

  FUNCTION fetch_row
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   IN OUT NOCOPY  gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN IS

    l_pp_lot_id         NUMBER;
    l_matl_dtl_id       NUMBER;
    l_sequ              NUMBER;

    l_api_name   CONSTANT VARCHAR2 (30)              := 'fetch_row';
  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    l_pp_lot_id := p_pending_product_lots_rec.pending_product_lot_id;
    l_matl_dtl_id := p_pending_product_lots_rec.material_detail_id;
    l_sequ := p_pending_product_lots_rec.sequence;

    IF (l_pp_lot_id IS NOT NULL) THEN
      SELECT *
        INTO x_pending_product_lots_rec
        FROM gme_pending_product_lots
       WHERE pending_product_lot_id = l_pp_lot_id;
    ELSIF (l_matl_dtl_id IS NOT NULL) AND
          (l_sequ IS NOT NULL) THEN
      SELECT *
        INTO x_pending_product_lots_rec
        FROM gme_pending_product_lots
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ;
    ELSE
      gme_common_pvt.log_message ('GME_NO_KEYS'
                                 ,'TABLE_NAME'
                                 ,g_table_name);
      x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID := NULL;
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
    x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID := NULL;
    RETURN FALSE;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;

    x_pending_product_lots_rec.PENDING_PRODUCT_LOT_ID := NULL;

    RETURN FALSE;
  END fetch_row;

 /*==========================================================================
 | FUNCTION NAME                                                            |
 |   delete_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   delete_row will delete a row in gme_pending_product_lots               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   delete_row will delete a row in gme_pending_product_lots               |
 |                                                                          |
 | PARAMETERS                                                               |
 |   p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE         |
 |                                                                          |
 | RETURNS                                                                  |
 |   BOOLEAN                                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 ==========================================================================*/

  FUNCTION delete_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN IS

    l_api_name    CONSTANT VARCHAR2 (30)              := 'delete_row';

    locked_by_other_user   EXCEPTION;
    PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);

    l_dummy                NUMBER (5)                 := 0;
    l_pp_lot_id         NUMBER;
    l_matl_dtl_id       NUMBER;
    l_sequ              NUMBER;

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    l_pp_lot_id := p_pending_product_lots_rec.pending_product_lot_id;
    l_matl_dtl_id := p_pending_product_lots_rec.material_detail_id;
    l_sequ := p_pending_product_lots_rec.sequence;

    IF (l_pp_lot_id IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE pending_product_lot_id = l_pp_lot_id
         FOR UPDATE NOWAIT;

      DELETE
        FROM gme_pending_product_lots
       WHERE pending_product_lot_id = l_pp_lot_id;

    ELSIF (l_matl_dtl_id IS NOT NULL) AND
          (l_sequ IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ
         FOR UPDATE NOWAIT;

      DELETE
        FROM gme_pending_product_lots
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ;
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
  WHEN NO_DATA_FOUND THEN
    gme_common_pvt.log_message ('GME_NO_DATA_FOUND'
                               ,'TABLE_NAME'
                               ,g_table_name);
    RETURN FALSE;
  WHEN locked_by_other_user THEN
    gme_common_pvt.log_message ('GME_RECORD_LOCKED'
                               ,'TABLE_NAME'
                               ,g_table_name
                               ,'RECORD'
                               ,'PendingProductLots'
                               ,'KEY'
                               ,p_pending_product_lots_rec.pending_product_lot_id);
    RETURN FALSE;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;

    RETURN FALSE;
  END delete_row;

 /*==========================================================================
 | FUNCTION NAME                                                            |
 |   update_row                                                             |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   update_row will update a row in gme_pending_product_lots               |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   update_row will update a row in gme_pending_product_lots               |
 |                                                                          |
 | PARAMETERS                                                               |
 |   p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE         |
 |                                                                          |
 | RETURNS                                                                  |
 |   BOOLEAN                                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 ==========================================================================*/
  FUNCTION update_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN IS
    l_dummy                NUMBER        := 0;

    locked_by_other_user   EXCEPTION;
    PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
    l_api_name    CONSTANT VARCHAR2 (30) := 'update_row';

    l_pp_lot_id         NUMBER;
    l_matl_dtl_id       NUMBER;
    l_sequ              NUMBER;
    l_pp_lot_rec        gme_pending_product_lots%ROWTYPE;

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    l_pp_lot_id := p_pending_product_lots_rec.pending_product_lot_id;
    l_matl_dtl_id := p_pending_product_lots_rec.material_detail_id;
    l_sequ := p_pending_product_lots_rec.sequence;

    l_pp_lot_rec := p_pending_product_lots_rec;

    l_pp_lot_rec.last_update_date := gme_common_pvt.g_timestamp;
    l_pp_lot_rec.last_updated_by := gme_common_pvt.g_user_ident;
    l_pp_lot_rec.last_update_login := gme_common_pvt.g_login_id;

    IF (l_pp_lot_id IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE pending_product_lot_id = l_pp_lot_id
         FOR UPDATE NOWAIT;
      /* Bug 5193154 added lot number*/
      UPDATE gme_pending_product_lots
         SET SEQUENCE                  = l_pp_lot_rec.SEQUENCE
            ,LOT_NUMBER                = l_pp_lot_rec.LOT_NUMBER
            ,REVISION                  = l_pp_lot_rec.REVISION
            ,QUANTITY                  = l_pp_lot_rec.QUANTITY
            ,SECONDARY_QUANTITY        = l_pp_lot_rec.SECONDARY_QUANTITY
            ,REASON_ID                 = l_pp_lot_rec.REASON_ID
            ,LAST_UPDATE_DATE          = l_pp_lot_rec.LAST_UPDATE_DATE
            ,LAST_UPDATED_BY           = l_pp_lot_rec.LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN         = l_pp_lot_rec.LAST_UPDATE_LOGIN
       WHERE pending_product_lot_id = l_pp_lot_id
         AND last_update_date = p_pending_product_lots_rec.last_update_date;

    ELSIF (l_matl_dtl_id IS NOT NULL) AND
          (l_sequ IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ
         FOR UPDATE NOWAIT;

      UPDATE gme_pending_product_lots
         SET SEQUENCE                  = l_pp_lot_rec.SEQUENCE
            ,REVISION                  = l_pp_lot_rec.REVISION
            ,QUANTITY                  = l_pp_lot_rec.QUANTITY
            ,SECONDARY_QUANTITY        = l_pp_lot_rec.SECONDARY_QUANTITY
            ,REASON_ID                 = l_pp_lot_rec.REASON_ID
            ,LAST_UPDATE_DATE          = l_pp_lot_rec.LAST_UPDATE_DATE
            ,LAST_UPDATED_BY           = l_pp_lot_rec.LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN         = l_pp_lot_rec.LAST_UPDATE_LOGIN
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ
         AND last_update_date = p_pending_product_lots_rec.last_update_date;
    ELSE
      gme_common_pvt.log_message ('GME_NO_KEYS'
                                 ,'TABLE_NAME'
                                 ,g_table_name);
      RETURN FALSE;
    END IF;

    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
    END IF;

    IF SQL%ROWCOUNT <> 0 THEN
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
                               ,'PendingProductLots'
                               ,'KEY'
                               ,p_pending_product_lots_rec.pending_product_lot_id);
    RETURN FALSE;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;

    RETURN FALSE;
  END update_row;

 /*==========================================================================
 | FUNCTION NAME                                                            |
 |   lock_row                                                               |
 |                                                                          |
 | TYPE                                                                     |
 |   Private                                                                |
 |                                                                          |
 | USAGE                                                                    |
 |   lock_row will lock a row in gme_pending_product_lots                   |
 |                                                                          |
 | DESCRIPTION                                                              |
 |   lock_row will lock a row in gme_pending_product_lots                   |
 |                                                                          |
 | PARAMETERS                                                               |
 |   p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE         |
 |                                                                          |
 | RETURNS                                                                  |
 |   BOOLEAN                                                                |
 |                                                                          |
 | HISTORY                                                                  |
 |                                                                          |
 ==========================================================================*/
  FUNCTION lock_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN IS
    l_dummy                NUMBER        := 0;

    locked_by_other_user   EXCEPTION;
    PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);
    l_api_name    CONSTANT VARCHAR2 (30) := 'lock_row';

    l_pp_lot_id         NUMBER;
    l_matl_dtl_id       NUMBER;
    l_sequ              NUMBER;

  BEGIN

    IF nvl(g_debug, gme_debug.g_log_procedure + 1) <= gme_debug.g_log_procedure THEN
      gme_debug.put_line('Entering api '||g_pkg_name||'.'||l_api_name);
    END IF;

    l_pp_lot_id := p_pending_product_lots_rec.pending_product_lot_id;
    l_matl_dtl_id := p_pending_product_lots_rec.material_detail_id;
    l_sequ := p_pending_product_lots_rec.sequence;

    IF (l_pp_lot_id IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE pending_product_lot_id = l_pp_lot_id
         FOR UPDATE NOWAIT;

    ELSIF (l_matl_dtl_id IS NOT NULL) AND
          (l_sequ IS NOT NULL) THEN
      SELECT 1
        INTO l_dummy
        FROM gme_pending_product_lots
       WHERE material_detail_id = l_matl_dtl_id
         AND sequence = l_sequ
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
                               ,'PendingProductLots'
                               ,'KEY'
                               ,p_pending_product_lots_rec.pending_product_lot_id);
    RETURN FALSE;
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
    IF g_debug <= gme_debug.g_log_procedure THEN
      gme_debug.put_line ('Unexpected error: '||g_pkg_name||'.'||l_api_name||': '||SQLERRM);
    END IF;

    RETURN FALSE;
  END lock_row;
END gme_pending_product_lots_dbl;

/
