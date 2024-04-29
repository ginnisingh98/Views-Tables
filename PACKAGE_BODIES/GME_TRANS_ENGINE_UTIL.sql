--------------------------------------------------------
--  DDL for Package Body GME_TRANS_ENGINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_TRANS_ENGINE_UTIL" AS
/*  $Header: GMEUTXNB.pls 120.6 2005/10/17 14:15:58 pxkumar noship $

 *****************************************************************
 *                                                               *
 * Package  GME_TRANS_ENGINE_UTIL                                *
 *                                                               *
 * Contents LOAD_MAT_AND_RSC_TRANS                               *
 * Contents BUILD_TRANS_REC                                      *
 *                                                               *
 * Use      This is the UTIL layer of the GME Inventory          *
 *          Transaction Loading                                  *
 *                                                               *
 * History                                                       *
 *****************************************************************
*/
/*  Global variables   */
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_TRANS_ENGINE_UTIL';
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

   PROCEDURE load_mat_and_rsc_trans (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_mat_row_count   OUT NOCOPY      NUMBER
     ,x_rsc_row_count   OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      CURSOR c_get_init_reversal (v_doc_id NUMBER)
      IS
         SELECT   *
             FROM gme_inventory_txns_gtmp
            -- WHERE  ACTION_CODE ='REVL'; -- Should this be indexed.
         WHERE    transaction_no = 2               -- Should this be indexed.
              AND trans_qty <>
                     0
                    -- these are already matched up... don't match them again.
              AND doc_id = v_doc_id
         ORDER BY line_type
                 ,item_id
                 ,material_detail_id
                 ,whse_code
                 ,lot_id
                 ,LOCATION
                 ,completed_ind
                 ,trans_id;

      --BUG#3528006 Added cursor c_get_match_reversal_date_cmp
      CURSOR c_get_match_reversal_date_cmp (
         v_doc_id          NUMBER
        ,v_detail_id       NUMBER
        ,v_line_type       NUMBER
        ,v_item_id         NUMBER
        ,v_whse_code       VARCHAR2
        ,v_lot_id          NUMBER
        ,v_location        VARCHAR2
        ,v_completed_ind   NUMBER
        ,v_qty             NUMBER
        ,v_trans_date      DATE)
      IS
         SELECT *
           FROM gme_inventory_txns_gtmp
          WHERE transaction_no <> 2                 -- Should this be indexed.
            AND doc_id = v_doc_id
            AND line_type = v_line_type
            AND item_id = v_item_id
            AND material_detail_id = v_detail_id
            AND whse_code = v_whse_code
            AND lot_id = v_lot_id
            AND LOCATION = v_location
            AND completed_ind = v_completed_ind
            AND trans_date = v_trans_date
            AND ABS (trans_qty) = v_qty;

      --BUG#3528006 Modified cursor c_get_match_reversal
      CURSOR c_get_match_reversal (
         v_doc_id          NUMBER
        ,v_detail_id       NUMBER
        ,v_line_type       NUMBER
        ,v_item_id         NUMBER
        ,v_whse_code       VARCHAR2
        ,v_lot_id          NUMBER
        ,v_location        VARCHAR2
        ,v_completed_ind   NUMBER
        ,v_qty             NUMBER)
      IS
         SELECT *
           FROM gme_inventory_txns_gtmp
          WHERE transaction_no <> 2                 -- Should this be indexed.
            AND doc_id = v_doc_id
            AND line_type = v_line_type
            AND item_id = v_item_id
            AND material_detail_id = v_detail_id
            AND whse_code = v_whse_code
            AND lot_id = v_lot_id
            AND LOCATION = v_location
            AND completed_ind = v_completed_ind
            AND ABS (trans_qty) = v_qty;

      CURSOR c_get_cmplt_zero_def_txns
      IS
         SELECT   *
             FROM gme_inventory_txns_gtmp
            WHERE completed_ind = 1 AND trans_qty = 0
         ORDER BY line_type
                 ,item_id
                 ,material_detail_id
                 ,whse_code
                 ,lot_id
                 ,LOCATION
                 ,completed_ind
                 ,trans_id;

      CURSOR c_check_mat_transactions (
         p_batch_id     IN   NUMBER
        ,p_batch_type   IN   VARCHAR2)
      IS
         SELECT COUNT (1)
           FROM gme_inventory_txns_gtmp
          WHERE doc_id = p_batch_id AND doc_type = p_batch_type;

      l_last_txn            c_get_cmplt_zero_def_txns%ROWTYPE;
      l_current_txn         c_get_cmplt_zero_def_txns%ROWTYPE;
      init_revs             c_get_init_reversal%ROWTYPE;
      match_revs            c_get_match_reversal%ROWTYPE;
      l_trans_no            gme_inventory_txns_gtmp.transaction_no%TYPE;
      l_api_name   CONSTANT VARCHAR2 (30)          := 'LOAD_MAT_AND_RSC_TRANS';
      l_mat_row_count       NUMBER                                        := 0;
      l_rsc_row_count       NUMBER                                        := 0;
      l_inv_exists          NUMBER                                        := 0;
      l_doc_type            VARCHAR2 (4);
      l_return_status       VARCHAR2 (1)          := fnd_api.g_ret_sts_success;
      l_match_rev_id        NUMBER;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      /* Check that we have at least a BATCH ID */
      IF (    (p_batch_row.batch_id IS NULL)
          OR (p_batch_row.batch_id = fnd_api.g_miss_num) ) THEN
         gme_common_pvt.log_message ('GME_NO_KEYS', 'TABLE_NAME', l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'BATCH ID NEEDED FOR RETRIEVAL');
         END IF;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Update Inventory Ind:'
                             || p_batch_row.update_inventory_ind
                             || ' Batch Id:'
                             || p_batch_row.batch_id);
      END IF;

      -- Check that the UPDATE_INVENTORY_IND Value
      IF (p_batch_row.update_inventory_ind <> 'Y') THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'No Transactions will be loaded');
         END IF;

         gme_common_pvt.log_message ('GME_BATCH_NON_INVENTORY'
                                    ,'BATCH_NO'
                                    ,p_batch_row.batch_no);
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Batch Type = > '
                             || p_batch_row.batch_type);
      END IF;

      -- Detemine Transactional Doc Type
      -- 0 - PROD 10 - FPO
      IF (p_batch_row.batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSIF (p_batch_row.batch_type = 10) THEN
         l_doc_type := 'FPO';
      ELSE
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'No BATCH TYPE loaded');
         END IF;

         gme_common_pvt.log_message ('INPUT_PARMS_MISS', 'PROC', l_api_name);
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Now Validate Transactions */
      /* Have Been Loaded */

      -- Check if values already exist in Table
      OPEN c_check_mat_transactions (p_batch_row.batch_id, l_doc_type);

      FETCH c_check_mat_transactions
       INTO l_inv_exists;

      CLOSE c_check_mat_transactions;

      IF (l_inv_exists > 0) THEN       -- We have Alreay Loaded INV Batch Data
         l_mat_row_count := l_inv_exists;
      ELSE           -- Now Populate The GME_INVENTORY_TXNS_GTMP table
                     -- Should this be in same file as other table routines */

         INSERT INTO gme_inventory_txns_gtmp
                     (trans_id,
                      item_id,
                      co_code,
                      orgn_code,
                      whse_code,
                      lot_id,
                      location,
                      doc_id,
                      doc_type,
                      doc_line,
                      line_type,
                      reason_code,
                      trans_date,
                      trans_qty,
                      trans_qty2,
                      qc_grade,
                      lot_status,
                      trans_stat,
                      trans_um,
                      trans_um2,
                      completed_ind,
                      staged_ind,
                      gl_posted_ind,
                      event_id,
                      delete_mark,
                      text_code,
                      action_code,
                      material_detail_id,
                      transaction_no,
            def_trans_ind,
                      organization_id,
                      locator_id,
                      subinventory,
                      alloc_um,
                      alloc_qty
                     )
            SELECT i.trans_id,
                   i.item_id,
                   i.co_code,
                   i.orgn_code,
                   i.whse_code,
                   i.lot_id,
                   i.location,
                   i.doc_id,
                   i.doc_type,
                   i.doc_line,
                   i.line_type,
                   i.reason_code,
                   i.trans_date,
                   i.trans_qty,
                   i.trans_qty2,
                   i.qc_grade,
                   i.lot_status,
                   i.trans_stat,
                   i.trans_um,
                   i.trans_um2,
                   i.completed_ind,
                   i.staged_ind,
                   i.gl_posted_ind,
                   i.event_id,
                   --Rishi Varma 25-05-2004 3476239 Serono enh.
                   --setting the delete_mark to 9 only if phantoms are involved
                   decode(g.phantom_id,NULL,i.delete_mark,9),
                   i.text_code,
                   'NONE',
                   i.line_id, -- I.TRANS_ID,-- Using TRANS ID for tranasction_no
                   1,    -- This means Display the Record Use For Forms,
         0,    -- def_trans_ind => default it to NO
                   0,    -- For Future Use
                   0,    -- For Future Use
                   --Swapna Kommineni bug#3897220 24-SEP-2004
                  -- subinvenoty is inserted with the trans_id which is used to check
                   -- before calling the delete_pending_trans procedure in GMEVTXNB.pls
                   trans_id, --NULL, -- For Future Use
                   g.item_um,
                   -- B2834826 prevent uom conv if not required
                   decode(g.item_um,i.trans_um2,
                          ABS(i.trans_qty2),
                          gmicuom.uom_conversion (
                             i.item_id,
                             i.lot_id,
                             ABS (i.trans_qty),
                             i.trans_um,
                             g.item_um,
                             0) )
             FROM ic_tran_pnd i, gme_material_details g
             WHERE doc_id = p_batch_row.batch_id AND
                   doc_type = l_doc_type AND
                   line_id = g.material_detail_id AND
                   -- Bug 3777331 commented next condition since not needed
                   --doc_id = batch_id AND
                   delete_mark <> 1 --3187467
                   -- Bug 3777331 added next AND condition and commented rest of the where clause
                   AND reverse_id IS NULL;
                   --BEGIN BUG#3528006
                   --END BUG#3528006
         l_mat_row_count := SQL%ROWCOUNT;


         /* Lets Now Mark all Transactions That are Reversals
            With the ACTION_CODE ='REVL' */

         /* Let's look at zero completed def transactions first    */
         OPEN c_get_cmplt_zero_def_txns;

         FETCH c_get_cmplt_zero_def_txns
          INTO l_last_txn;

         IF c_get_cmplt_zero_def_txns%FOUND THEN
            LOOP
               FETCH c_get_cmplt_zero_def_txns
                INTO l_current_txn;

               EXIT WHEN c_get_cmplt_zero_def_txns%NOTFOUND;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'l_last_txn id = '
                                      || l_last_txn.trans_id);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'l_current_txn id = '
                                      || l_current_txn.trans_id);
               END IF;

               IF     (l_last_txn.material_detail_id =
                                              l_current_txn.material_detail_id)
                  AND (l_last_txn.line_type = l_current_txn.line_type)
                  AND (l_last_txn.item_id = l_current_txn.item_id)
                  AND (l_last_txn.whse_code = l_current_txn.whse_code)
                  AND (l_last_txn.lot_id = l_current_txn.lot_id)
                  AND (l_last_txn.LOCATION = l_current_txn.LOCATION) THEN
                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'These txns match!');
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'Matching Reversal for '
                                         || l_last_txn.trans_id
                                         || ' Is => '
                                         || l_current_txn.trans_id);
                  END IF;

                  UPDATE gme_inventory_txns_gtmp
                     -- SET ACTION_CODE = 'REVS'
                  SET transaction_no = 2
                   WHERE trans_id IN
                                (l_last_txn.trans_id, l_current_txn.trans_id);

                  FETCH c_get_cmplt_zero_def_txns
                   INTO l_last_txn;
               ELSE
         /* _last_txn.material_detail_id = l_current_txn.material_detail_id */
                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'These txns do not match!');
                  END IF;

                  l_last_txn := l_current_txn;
               END IF;
         /* _last_txn.material_detail_id = l_current_txn.material_detail_id */
            END LOOP;
         END IF;                         /* c_get_cmplt_zero_def_txns%FOUND */

         CLOSE c_get_cmplt_zero_def_txns;

         /* Bug 2376240 - Thomas Daniel */
         /* Added the action_code = NONE and the batch_id condition as the following update  */
         /* was updating the rows of previous batches which have been modified */
         UPDATE gme_inventory_txns_gtmp
            SET transaction_no = 2
          WHERE action_code = 'NONE'
            AND doc_id = p_batch_row.batch_id
            AND (    (line_type = -1 AND trans_qty > 0)
                 OR (line_type <> -1 AND trans_qty < 0) );

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'No. Of reversals Found is = '
                                || SQL%ROWCOUNT);
         END IF;

         IF (SQL%ROWCOUNT > 0) THEN
            OPEN c_get_init_reversal (p_batch_row.batch_id);

            LOOP
               FETCH c_get_init_reversal
                INTO init_revs;

               EXIT WHEN c_get_init_reversal%NOTFOUND;

               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line ('Find matching Revserals');
                  gme_debug.put_line ('ORIG id is => ' || init_revs.trans_id);
               /* gme_debug.put_line('ORIG itemid is => ' || init_revs.item_id);
               gme_debug.put_line('ORIG lotid is => ' || init_revs.lot_id);
               gme_debug.put_line('ORIG location is => ' || init_revs.location);
               gme_debug.put_line('ORIG COM IND is => ' || init_revs.completed_ind);
               gme_debug.put_line('ORIG TRANS is => ' || ABS(init_revs.trans_qty));
               */
               END IF;     /*  NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT  */

               --BUG#3528006 OPEN c_get_match_reversal (p_batch_row.batch_id);
               --3187467 Shikha Nagar 05/12/03
               l_match_rev_id := NULL;

               --BEGIN BUG#3528006
               OPEN c_get_match_reversal_date_cmp
                                                (p_batch_row.batch_id
                                                ,init_revs.material_detail_id
                                                ,init_revs.line_type
                                                ,init_revs.item_id
                                                ,init_revs.whse_code
                                                ,init_revs.lot_id
                                                ,init_revs.LOCATION
                                                ,init_revs.completed_ind
                                                ,ABS (init_revs.trans_qty)
                                                ,init_revs.trans_date);

               FETCH c_get_match_reversal_date_cmp
                INTO match_revs;

               IF c_get_match_reversal_date_cmp%FOUND THEN
                  gme_debug.put_line ('NEW id is => ' || match_revs.trans_id);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'Matching Reversal for '
                                      || init_revs.trans_id
                                      || ' Is => '
                                      || match_revs.trans_id);
                  l_match_rev_id := match_revs.trans_id;
               ELSE           /* c_get_match_reversal_date_cmp is not found */
                  OPEN c_get_match_reversal (p_batch_row.batch_id
                                            ,init_revs.material_detail_id
                                            ,init_revs.line_type
                                            ,init_revs.item_id
                                            ,init_revs.whse_code
                                            ,init_revs.lot_id
                                            ,init_revs.LOCATION
                                            ,init_revs.completed_ind
                                            ,ABS (init_revs.trans_qty) );

                  --END BUG#3528006
                  --BUG#3528006 LOOP
                  FETCH c_get_match_reversal
                   INTO match_revs;

                  /* BEGIN BUG#3528006
                  EXIT WHEN c_get_match_reversal%NOTFOUND;
                  IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
                  END BUG#3528006 */
                  IF c_get_match_reversal%FOUND THEN             --BUG#3528006
                     gme_debug.put_line ('NEW id is => '
                                         || match_revs.trans_id);
                     --BEGIN BUG#3528006
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'Matching Reversal for '
                                         || init_revs.trans_id
                                         || ' Is => '
                                         || match_revs.trans_id);
                     l_match_rev_id := match_revs.trans_id;
                  --END BUG#3528006
                  END IF;

                  --BEGIN BUG#3528006
                  CLOSE c_get_match_reversal;
               END IF;    /* c_get_match_reversal_date_cmp if condition end */

               CLOSE c_get_match_reversal_date_cmp;

               --END BUG#3528006

               /* BEGIN BUG#3528006
                  IF ((init_revs.material_detail_id =
                                                   match_revs.material_detail_id) AND
                      (init_revs.line_type = match_revs.line_type) AND
                      (init_revs.item_id = match_revs.item_id) AND
                      (init_revs.whse_code = match_revs.whse_code) AND
                      (init_revs.lot_id = match_revs.lot_id) AND
                      (init_revs.location = match_revs.location) AND
                      (init_revs.completed_ind = match_revs.completed_ind) AND
                      (NVL(init_revs.reason_code,0) = NVL(match_revs.reason_code,0)) AND --3187467
                      (ABS (init_revs.trans_qty) = ABS (match_revs.trans_qty))
                     ) THEN
                    IF ( NVL(G_DEBUG,-1) = GME_DEBUG.G_LOG_STATEMENT ) THEN
                      gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Tentative Matching Reversal for '
                                          || init_revs.trans_id|| ' Is => '|| match_revs.trans_id);
                    END IF;
                    --3187467
                    IF l_match_rev_id IS NULL THEN
                      l_match_rev_id := match_revs.trans_id;
                    END IF;
                    IF (init_revs.trans_date = match_revs.trans_date) THEN
                      l_match_rev_id := match_revs.trans_id;
                      EXIT;
                    END IF;
               END BUG#3528006 */
               --BUG #3528006   END IF; /* init_revs.material_detail_id = match_revs.material_detail_id */
               --BUG #3528006 END LOOP; /* FETCH c_get_match_reversal */
               --BUG #3528006 CLOSE c_get_match_reversal;
               -- 3187467 mark the reversal if matching txn found
               IF l_match_rev_id IS NOT NULL THEN
                  UPDATE gme_inventory_txns_gtmp
                     SET transaction_no = 2
                   WHERE trans_id = l_match_rev_id;
               END IF;
            END LOOP;                 /* c_get_init_reversal INTO init_revs */

            CLOSE c_get_init_reversal;
         END IF;                                        /* SQL%ROWCOUNT > 0 */

         IF p_batch_row.migrated_batch_ind = 'Y' THEN            --BUG#3528006
            set_default_lot_for_batch (p_batch_row          => p_batch_row
                                      ,x_return_status      => l_return_status);
         --BEGIN BUG#3528006
         ELSE
            set_default_lot_for_new_batch (x_return_status      => l_return_status);
         END IF;

         --END BUG#3528006
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;                                           /* l_inv_exists > 0 */

      load_rsrc_trans (p_batch_row          => p_batch_row
                      ,x_rsc_row_count      => l_rsc_row_count
                      ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      /* Set Default Values for Return Parameters */
      x_return_status := l_return_status;
      x_mat_row_count := l_mat_row_count;
      x_rsc_row_count := l_rsc_row_count;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line ('sqlerrm=' || SQLERRM);
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END load_mat_and_rsc_trans;

   FUNCTION build_trans_rec (
      p_tran_row   IN              gme_inventory_txns_gtmp%ROWTYPE
     ,x_tran_rec   OUT NOCOPY      gmi_trans_engine_pub.ictran_rec)
      RETURN BOOLEAN
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'BUILD_TRANS_REC';
   BEGIN
      x_tran_rec.trans_id := p_tran_row.trans_id;
      x_tran_rec.item_id := p_tran_row.item_id;
      x_tran_rec.line_id := p_tran_row.material_detail_id;
      x_tran_rec.co_code := p_tran_row.co_code;
      x_tran_rec.orgn_code := p_tran_row.orgn_code;
      x_tran_rec.whse_code := p_tran_row.whse_code;
      x_tran_rec.lot_id := NVL (p_tran_row.lot_id, 0);
      x_tran_rec.LOCATION :=
                           NVL (p_tran_row.LOCATION, gmigutl.ic$default_loct);
      x_tran_rec.doc_type := p_tran_row.doc_type;
      x_tran_rec.doc_id := p_tran_row.doc_id;
      x_tran_rec.doc_line := NVL (p_tran_row.doc_line, 0);
      x_tran_rec.line_type := NVL (p_tran_row.line_type, 0);
      x_tran_rec.trans_date := NVL (p_tran_row.trans_date, SYSDATE);
      x_tran_rec.trans_qty := p_tran_row.trans_qty;
      x_tran_rec.trans_qty2 := p_tran_row.trans_qty2;
      x_tran_rec.qc_grade := p_tran_row.qc_grade;
      x_tran_rec.lot_status := p_tran_row.lot_status;
      x_tran_rec.trans_stat := p_tran_row.trans_stat;
      x_tran_rec.trans_um := p_tran_row.trans_um;
      x_tran_rec.trans_um2 := p_tran_row.trans_um2;
      x_tran_rec.staged_ind := p_tran_row.staged_ind;
      x_tran_rec.event_id := NVL (p_tran_row.event_id, 0);
      x_tran_rec.text_code := p_tran_row.text_code;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END build_trans_rec;

   /*===========================================================================================
   Procedure
     load_rsrc_trans
   Description
     This particular procedure loads the resource transactions.
   Parameters
     p_batch_row         The batch header row to identify the batch
     x_rsc_row_count     No of resource transaction rows loaded.
     x_return_status     outcome of the API call
             S - Success
             E - Error
             U - Unexpected error
    History
      Rishi Varma B3818266/3759970 10-08-2004
      Added the condition for elimination of reversed records
   =============================================================================================*/
   PROCEDURE load_rsrc_trans (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_rsc_row_count   OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      CURSOR c_get_reversal_resources
      IS
         SELECT *
           FROM gme_resource_txns_gtmp
          WHERE action_code = 'REVL';              -- Should this be indexed.

      CURSOR c_get_match_reversal_resources (v_line_id NUMBER)
      IS
         SELECT   *
             FROM gme_resource_txns_gtmp
            WHERE action_code NOT IN ('REVL', 'REVS')
              AND line_id = v_line_id
              AND completed_ind = 1
         ORDER BY trans_date DESC, poc_trans_id;

      CURSOR c_check_rsc_transactions (p_batch_id IN NUMBER)
      IS
         SELECT COUNT (1)
           FROM gme_resource_txns_gtmp
          WHERE doc_id = p_batch_id;

      l_api_name   CONSTANT VARCHAR2 (30)                 := 'LOAD_RSRC_TRANS';
      l_rsc_row_count       NUMBER                                   := 0;
      l_rsc_exists          NUMBER                                   := 0;
      l_doc_type            VARCHAR2 (10);
      resrc_revs            c_get_reversal_resources%ROWTYPE;
      mtch_resrc_revs       c_get_match_reversal_resources%ROWTYPE;
      l_return_status       VARCHAR2 (1);
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      -- Detemine Transactional Doc Type
      -- 0 - PROD 10 - FPO
      IF (p_batch_row.batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSIF (p_batch_row.batch_type = 10) THEN
         l_doc_type := 'FPO';
      ELSE
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'No BATCH TYPE loaded');
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'This should RETURN AN Expected Error');
         END IF;

         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN c_check_rsc_transactions (p_batch_row.batch_id);

      FETCH c_check_rsc_transactions
       INTO l_rsc_exists;

      CLOSE c_check_rsc_transactions;

      -- Validate That We have loaded RSC txns if POC_IND ='Y'
      IF (NVL (p_batch_row.poc_ind, 'N') = 'Y' AND l_rsc_exists = 0) THEN
         -- Now Populate The GME_RESOURCE_TXNS_GTMP table
         -- Should this be in same file as other table routines */
         INSERT INTO gme_resource_txns_gtmp
                     (poc_trans_id, orgn_code, doc_type, doc_id, line_type
                     ,line_id, resources, resource_usage, trans_um
                     ,trans_date, completed_ind, posted_ind, reason_code, reason_id
                     ,start_date, end_date, text_code, transaction_no
                     ,overrided_protected_ind, action_code, delete_mark
                     ,instance_id, sequence_dependent_ind,organization_id
                     ,attribute1, attribute2, attribute3, attribute4
                     ,attribute5, attribute6, attribute7, attribute8
                     ,attribute9, attribute10, attribute11, attribute12
                     ,attribute13, attribute14, attribute15, attribute16
                     ,attribute17, attribute18, attribute19, attribute20
                     ,attribute21, attribute22, attribute23, attribute24
                     ,attribute25, attribute26, attribute27, attribute28
                     ,attribute29, attribute30, attribute_category)
            SELECT poc_trans_id, orgn_code, doc_type, doc_id, line_type
                  ,line_id, resources, resource_usage, trans_qty_um
                  ,trans_date, completed_ind, posted_ind, reason_code, reason_id
                  ,start_date, end_date, text_code, poc_trans_id
                  ,overrided_protected_ind, 'NONE', delete_mark, instance_id
                  ,sequence_dependent_ind,organization_id
                  ,attribute1, attribute2, attribute3, attribute4
                  ,attribute5, attribute6, attribute7, attribute8
                  ,attribute9, attribute10, attribute11, attribute12
                  ,attribute13, attribute14, attribute15, attribute16
                  ,attribute17, attribute18, attribute19, attribute20
                  ,attribute21, attribute22, attribute23, attribute24
                  ,attribute25, attribute26, attribute27, attribute28
                  ,attribute29, attribute30, attribute_category
              FROM gme_resource_txns
             WHERE doc_id = p_batch_row.batch_id
               AND doc_type = l_doc_type
               AND delete_mark = 0
               --Rishi Varma B3818266/3759970 10-08-2004
               /*Added the condition for elimination of reversed records*/
               AND reverse_id IS NULL;

         x_rsc_row_count := SQL%ROWCOUNT;

         /* Lets Now Mark all Resource Transactions that are Reversals
            With the ACTION_CODE ='REVL' */
         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'Use SQL to Mark reversals');
         END IF;

         UPDATE gme_resource_txns_gtmp
            SET action_code = 'REVL'
          WHERE resource_usage < 0 AND completed_ind = 1;

         IF (SQL%ROWCOUNT > 0) THEN
            OPEN c_get_reversal_resources;

            LOOP
               FETCH c_get_reversal_resources
                INTO resrc_revs;

               EXIT WHEN c_get_reversal_resources%NOTFOUND;

               OPEN c_get_match_reversal_resources (resrc_revs.line_id);

               LOOP
                  FETCH c_get_match_reversal_resources
                   INTO mtch_resrc_revs;

                  EXIT WHEN c_get_match_reversal_resources%NOTFOUND;

                  IF (     (resrc_revs.trans_date = mtch_resrc_revs.trans_date)
                      AND (ABS (resrc_revs.resource_usage) =
                                          ABS (mtch_resrc_revs.resource_usage) ) ) THEN
                     UPDATE gme_resource_txns_gtmp
                        SET action_code = 'REVS'
                      WHERE poc_trans_id = mtch_resrc_revs.poc_trans_id;

                     EXIT;
                  END IF;
               END LOOP;

               CLOSE c_get_match_reversal_resources;
            END LOOP;

            CLOSE c_get_reversal_resources;
         END IF;
      ELSE
         x_rsc_row_count := l_rsc_exists;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END load_rsrc_trans;

   PROCEDURE set_default_lot_for_batch (
      p_batch_row       IN              gme_batch_header%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_matl (v_batch_id gme_batch_header.batch_id%TYPE)
      IS
         SELECT material_detail_id
           FROM gme_material_details
          WHERE batch_id = v_batch_id;

      get_matl_rec             cur_get_matl%ROWTYPE;
      l_def_trans_id           ic_tran_pnd.trans_id%TYPE;
      l_is_plain               BOOLEAN;
      l_return_status          VARCHAR2 (1);
      l_api_name      CONSTANT VARCHAR2 (30)   := 'SET_DEFAULT_LOT_FOR_BATCH';
      error_fetch_def_lot_id   EXCEPTION;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      FOR get_matl_rec IN cur_get_matl (p_batch_row.batch_id) LOOP
         get_default_lot (get_matl_rec.material_detail_id
                         ,l_def_trans_id
                         ,l_is_plain
                         ,l_return_status);

         IF l_return_status <> x_return_status OR l_def_trans_id IS NULL THEN
            RAISE error_fetch_def_lot_id;
         END IF;

         UPDATE gme_inventory_txns_gtmp
            SET def_trans_ind = 1
          WHERE trans_id = l_def_trans_id;
      END LOOP;
   EXCEPTION
      WHEN error_fetch_def_lot_id THEN
         x_return_status := l_return_status;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END set_default_lot_for_batch;

   PROCEDURE deduce_transaction_warehouse (
      p_transaction     IN              ic_tran_pnd%ROWTYPE
     ,p_item_master     IN              ic_item_mst%ROWTYPE
     ,x_whse_code       OUT NOCOPY      ps_whse_eff.whse_code%TYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_eff_whse (
         p_orgn_code   VARCHAR2
        ,p_item_id     NUMBER
        ,p_line_type   NUMBER)
      IS
         SELECT   whse_code
             FROM ps_whse_eff
            WHERE plant_code = p_orgn_code
              AND (whse_item_id IS NULL OR whse_item_id = p_item_id)
              AND (    (p_line_type > 0 AND replen_ind = 1)
                   OR (p_line_type < 0 AND consum_ind = 1) )
         ORDER BY whse_item_id, whse_code;

      l_api_name   CONSTANT VARCHAR2 (30) := 'DEDUCE_TRANSACTION_WAREHOUSE';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      OPEN cur_eff_whse (p_transaction.orgn_code
                        ,p_item_master.whse_item_id
                        ,p_transaction.line_type);

      FETCH cur_eff_whse
       INTO x_whse_code;

      IF cur_eff_whse%NOTFOUND THEN
         x_whse_code := NULL;
      END IF;

      CLOSE cur_eff_whse;
   EXCEPTION
      WHEN OTHERS THEN
         x_whse_code := NULL;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END deduce_transaction_warehouse;

   PROCEDURE get_default_lot (
      p_line_id         IN              gme_material_details.material_detail_id%TYPE
     ,x_def_trans_id    OUT NOCOPY      ic_tran_pnd.trans_id%TYPE
     ,x_is_plain        OUT NOCOPY      BOOLEAN
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_matl_dtl                gme_material_details%ROWTYPE;
      l_item_mst                ic_item_mst%ROWTYPE;
      l_ic_tran_pnd             ic_tran_pnd%ROWTYPE;
      l_whse_loct_ctl           ic_whse_mst.whse_code%TYPE;
      l_def_lot_found           BOOLEAN;

      CURSOR cur_get_def_trans (
         v_batch_id   gme_batch_header.batch_id%TYPE
        ,v_line_id    gme_material_details.material_detail_id%TYPE
        ,v_doc_type   gme_inventory_txns_gtmp.doc_type%TYPE)
      IS
         SELECT   trans_id, whse_code
             FROM gme_inventory_txns_gtmp
            WHERE doc_id = v_batch_id
              AND doc_type = v_doc_type
              AND material_detail_id = v_line_id
              AND lot_id = 0
              AND LOCATION = p_default_loct
              AND
                  --Rishi Varma B3476239 Serono enh.
                  --delete_mark = 0 AND
                  transaction_no <> 2
         ORDER BY line_type
                 ,item_id
                 ,material_detail_id
                 ,whse_code
                 ,lot_id
                 ,LOCATION
                 ,completed_ind
                 ,trans_id;

      CURSOR cur_get_whse_ctl (v_whse_code IN VARCHAR2)
      IS
         SELECT loct_ctl
           FROM ic_whse_mst
          WHERE whse_code = v_whse_code;

      get_trans_rec             cur_get_def_trans%ROWTYPE;
      l_tran_whse               ps_whse_eff.whse_code%TYPE;
      l_return_status           VARCHAR2 (1);
      l_api_name       CONSTANT VARCHAR2 (30)             := 'GET_DEFAULT_LOT';
      l_batch_type              gme_batch_header.batch_type%TYPE;
      l_doc_type                gme_inventory_txns_gtmp.doc_type%TYPE;
      l_cnt                     NUMBER;
      error_deduce_trans_whse   EXCEPTION;
   -- corrupt_batch           EXCEPTION;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      l_def_lot_found := FALSE;
      x_def_trans_id := NULL;

      SELECT *
        INTO l_matl_dtl
        FROM gme_material_details
       WHERE material_detail_id = p_line_id;

      SELECT *
        INTO l_item_mst
        FROM ic_item_mst
       WHERE item_id = l_matl_dtl.item_id;

      SELECT batch_type
        INTO l_batch_type
        FROM gme_batch_header
       WHERE batch_id = l_matl_dtl.batch_id;

      IF (l_batch_type = 0) THEN
         l_doc_type := 'PROD';
      ELSIF (l_batch_type = 10) THEN
         l_doc_type := 'FPO';
      END IF;

      SELECT COUNT (1)
        INTO l_cnt
        FROM gme_inventory_txns_gtmp
       WHERE doc_id = l_matl_dtl.batch_id
         AND doc_type = l_doc_type
         AND material_detail_id = p_line_id
         AND transaction_no <> 2
         AND trans_qty = 0;

      IF l_cnt = 1 THEN
         -- This is the default lot for sure, because there can only at most one zero qty txn, completed
         -- or pending.  No need for further processing.
         SELECT trans_id
           INTO x_def_trans_id
           FROM gme_inventory_txns_gtmp
          WHERE doc_id = l_matl_dtl.batch_id
            AND doc_type = l_doc_type
            AND material_detail_id = p_line_id
            AND transaction_no <> 2
            AND trans_qty = 0;

         l_def_lot_found := TRUE;
      --ELSIF l_cnt > 1 THEN
         -- OOPS! this is a corrupt batch.  If there is more than one zero qty txn after
         -- reversals have been figured out, then this is a corrupt batch...
         --RAISE corrupt_batch;
      ELSE
         FOR get_rec IN cur_get_def_trans (l_matl_dtl.batch_id
                                          ,p_line_id
                                          ,l_doc_type) LOOP
            OPEN cur_get_whse_ctl (get_rec.whse_code);

            FETCH cur_get_whse_ctl
             INTO l_whse_loct_ctl;

            CLOSE cur_get_whse_ctl;

            IF    l_item_mst.lot_ctl = 1
               OR (l_item_mst.loct_ctl > 0 AND l_whse_loct_ctl > 0) THEN
               -- This should be the only transaction that was returned for lot or loct ctrl
               x_def_trans_id := get_rec.trans_id;
               x_is_plain := FALSE;
               -- Shikha Nagar 03/20/02 B2273867
               -- Exit out of the loop as we have found default lot for sure
               -- no need to loop through other fetched transactions after this
               EXIT;
               l_def_lot_found := TRUE;
            ELSE
               IF l_def_lot_found = FALSE THEN
                  x_is_plain := TRUE;

                  SELECT *
                    INTO l_ic_tran_pnd
                    FROM ic_tran_pnd
                   WHERE trans_id = get_rec.trans_id;

                  deduce_transaction_warehouse
                                           (p_transaction        => l_ic_tran_pnd
                                           ,p_item_master        => l_item_mst
                                           ,x_whse_code          => l_tran_whse
                                           ,x_return_status      => l_return_status);

                  IF l_return_status <> x_return_status THEN
                     RAISE error_deduce_trans_whse;
                  END IF;

                  IF (l_tran_whse = l_ic_tran_pnd.whse_code) THEN
                     x_def_trans_id := get_rec.trans_id;

                     IF    l_ic_tran_pnd.completed_ind = 0
                        OR l_ic_tran_pnd.trans_qty = 0 THEN
                        l_def_lot_found := TRUE;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      IF x_def_trans_id IS NULL THEN
         OPEN cur_get_def_trans (l_matl_dtl.batch_id, p_line_id, l_doc_type);

         FETCH cur_get_def_trans
          INTO get_trans_rec;

         x_def_trans_id := get_trans_rec.trans_id;

         CLOSE cur_get_def_trans;

         x_is_plain := TRUE;
      END IF;
   EXCEPTION
      WHEN error_deduce_trans_whse THEN
         x_return_status := l_return_status;
      --WHEN corrupt_batch THEN
        --x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END get_default_lot;

   /*===========================================================================================
   Procedure
     set_default_lot_for_new_batch
   Description
     This procedure is to set the default lot for the batches which are created or not migrated.
   Parameters
     x_return_status     outcome of the API call
             S - Success
             E - Error
             U - Unexpected error
   History
     Vipul Vaish BUG#3528006 15-APR-2004 - PORT BUG#3470266
     Added this procedure to improve the performance.
   =============================================================================================*/
   PROCEDURE set_default_lot_for_new_batch (x_return_status OUT NOCOPY VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'SET_DEFAULT_LOT_FOR_NEW_BATCH';
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      UPDATE gme_inventory_txns_gtmp g
         SET def_trans_ind = 1
       WHERE trans_id = (SELECT MIN (trans_id)
                           FROM gme_inventory_txns_gtmp
                          WHERE material_detail_id = g.material_detail_id);
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END set_default_lot_for_new_batch;
END gme_trans_engine_util;

/
