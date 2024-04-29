--------------------------------------------------------
--  DDL for Package Body GME_TRANSACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_TRANSACTIONS_PVT" AS
/*  $Header: GMEVPTXB.pls 120.47.12010000.10 2010/03/22 15:13:09 gmurator ship $    */
   g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_transactions_PVT';
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVPTXB.pls
REM * PURPOSE: Package Body for the GME batch transactions api
REM * AUTHOR:  Pawan Kumar
REM * DATE:    2 May 2005
REM * HISTORY:
REM * ========
REM *
REM *
REM * Archana Mundhe Bug 6437252 - LPN support
REM *   Modified insert_txn_inter_hdr to insert lpn_id , transfer_lpn_id into
REM *   mtl_transactions_interface table
REM *   Modiied delete_material_txn to populate lpn_id or transfer_lpn_id
REM *   into mtl_transactions_interface based on the transaction type
REM * Swapna K Bug 7226474
REM *   Modified build_txn_inter_lot to insert attribute columns into
REM *   mtl_transactions_interface table
REM * Archana Mundhe Bug 7385309
REM *   Modified procedure update_material_txn to create the transaction
REM *   first and then delete.

REM * G. Muratore    24-Dec-2008  Bug 7626742/7423041
REM *   Backout one piece of fix from 7385309 - Do not clear the cache.
REM *   Procedure:  query_quantities

REM * G. Muratore    29-Dec-2008  Bug 7623144
REM *   Add 'C_', 'D_' and 'N_' lot attribute columns plus lot_attribute_category.
REM *   Procedure:  build_txn_inter_lot
REM *  Kbanddyo     21-Jan-2009 Bug 7720970
REM *  Procedure : process_transactions
REM *  Swapna k 18-MAR-09 Bug 8300015
REM *    Added p_phantom_line_id parameter to the get_mat_txns procedure.

REM * G. Muratore    26-MAY-2009  Bug 8453485
REM *   Added dynamically derived column rev_order_column to help us in order by clause.
REM *   This will aid in handling Product Yield reversals first for layer sequencing for GMF.
REM *   Procedure:  process_transactions

REM * Apeksha Mishra 21-Sep-2009  Bug 8605909
REM *   Added the call to function  gme_common_pvt.check_close_period to check whether
REM *   the period is closed or not.
REM *   Procedure:  delete_material_txn

REM *  G. Muratore   05-AUG-2009  Bug 8639523 (rework of 7385309 for ingreds)
REM *     Resequence calls for transaction reversals depending on line_type.
REM *     PROCEDURE: update_material_txn

REM *  G. Muratore   01-Dec-2009  Bug 9170460
REM *     Pass in subinventory and locator id to applicable function.
REM *     PROCEDURE: build_txn_inter_lot

REM *  G. Muratore   15-FEB-2010  Bug 9301755 (extension of 8639523/7385309)
rem *     update_material_txn is an overloaded function so we need to make same fix again.
REM *     Resequence calls for transaction reversals depending on line_type.
REM *     PROCEDURE: update_material_txn

REM *  G. Muratore   19-MAR-2010  Bug 8751983
REM *     Added p_order_by parameter to allow fetching of transactions in reverse trans order.
REM *     PROCEDURE: get_mat_trans
REM **********************************************************************
*/

   /* +==========================================================================+
   | PROCEDURE NAME
   |   create_material_txn
   |
   | USAGE
   |    Inserts the transaction to interface table
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_mmli_tbl -- table of mtl_trans_lots_inter_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE create_material_txn (
      p_mmti_rec        IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl        IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_phantom_trans   IN              NUMBER DEFAULT 0
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)            := 'CREATE_MATERIAL_TXN';
      l_return_status       VARCHAR2 (1)         := fnd_api.g_ret_sts_success;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      m_mmti_rec            mtl_transactions_interface%ROWTYPE;
      m_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      x_mmti_rec            mtl_transactions_interface%ROWTYPE;
      x_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      m_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_ret                 NUMBER;
      l_api_version         NUMBER;
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2 (2000);
      l_msg_index           NUMBER (5);
      l_txn_count           NUMBER;
      l_assign_phantom      NUMBER;
      l_cnt_int             NUMBER;
      l_cnt_temp            NUMBER;
      build_txn_inter_err   EXCEPTION;
   BEGIN
      /* Initially let us assign the return status to success */
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmti_rec := p_mmti_rec;
      l_mmli_tbl := p_mmli_tbl;
      l_mat_dtl_rec.material_detail_id := l_mmti_rec.trx_source_line_id;

      -- Now fetch the material details for the material
      IF NOT gme_material_details_dbl.fetch_row
             (p_material_detail      => l_mat_dtl_rec
             ,x_material_detail      => l_mat_dtl_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'material det_id'
                             || l_mat_dtl_rec.material_detail_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'batch_id'
                             || l_mat_dtl_rec.batch_id);
      END IF;

       IF p_phantom_trans <> 2 THEN
         IF     l_mat_dtl_rec.phantom_line_id IS NOT NULL
            AND (p_phantom_trans = 0) THEN
            l_assign_phantom := 1;
         END IF;

         -- call for build procedure
         build_txn_inter (p_mmti_rec            => l_mmti_rec
                         ,p_mmli_tbl            => l_mmli_tbl
                         ,p_assign_phantom      => l_assign_phantom
                         ,x_mmti_rec            => x_mmti_rec
                         ,x_mmli_tbl            => x_mmli_tbl
                         ,x_return_status       => l_return_status);
            IF l_return_status <> fnd_api.g_ret_sts_success  THEN
               RAISE build_txn_inter_err;
            END IF;
            l_assign_phantom := 0;

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'status after build : '
                                || l_return_status);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'x_mmti_rec.transaction_interface_id : '
                                || x_mmti_rec.transaction_interface_id);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'x_mmti_rec.transaction_reference : '
                                || x_mmti_rec.transaction_reference);
         END IF;
      END IF;                                           --p_phantom_trans <> 2

-- For phantom
      IF p_phantom_trans <> 1 THEN
         IF l_mat_dtl_rec.phantom_line_id IS NOT NULL THEN
            m_mmti_rec := p_mmti_rec;
            m_mmli_tbl := p_mmli_tbl;
            m_mmti_rec.trx_source_line_id := l_mat_dtl_rec.phantom_line_id;
            m_mat_dtl_rec.material_detail_id := m_mmti_rec.trx_source_line_id;

            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'for phantom line id:'
                                   || l_mat_dtl_rec.phantom_line_id);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || ' original transaction_type_id :'
                                   || l_mmti_rec.transaction_type_id);
            END IF;

            -- Now fetch the material details for the phantom line
            IF NOT gme_material_details_dbl.fetch_row
               (p_material_detail      => m_mat_dtl_rec
               ,x_material_detail      => m_mat_dtl_rec) THEN
              RAISE fnd_api.g_exc_error;
            END IF;

            m_mmti_rec.transaction_source_id := m_mat_dtl_rec.batch_id;

            IF l_mmti_rec.transaction_type_id = gme_common_pvt.g_ing_issue THEN
                                                                        --(35)
               m_mmti_rec.transaction_type_id :=
                                             gme_common_pvt.g_prod_completion;
                                                                      -- (44)
               m_mmti_rec.transaction_action_id :=
                                        gme_common_pvt.g_prod_comp_txn_action;
                                                                       --(31)
            ELSIF l_mmti_rec.transaction_type_id = gme_common_pvt.g_ing_return THEN
                                                                        --(43)
               m_mmti_rec.transaction_type_id := gme_common_pvt.g_prod_return;
                                                                      -- (17)
               m_mmti_rec.transaction_action_id :=
                                         gme_common_pvt.g_prod_ret_txn_action;
                                                                       --(27)
            ELSIF l_mmti_rec.transaction_type_id =
                                              gme_common_pvt.g_prod_completion THEN
                                                                       -- (44)
               m_mmti_rec.transaction_type_id := gme_common_pvt.g_ing_issue;
                                                                      -- (35)
               m_mmti_rec.transaction_action_id :=
                                        gme_common_pvt.g_ing_issue_txn_action;
                                                                        --(1)
            ELSIF l_mmti_rec.transaction_type_id =
                                                  gme_common_pvt.g_prod_return THEN
               m_mmti_rec.transaction_type_id := gme_common_pvt.g_ing_return;
                                                                      -- (17)
               m_mmti_rec.transaction_action_id :=
                                          gme_common_pvt.g_ing_ret_txn_action;
                                                                       --(27)
            ELSIF l_mmti_rec.transaction_type_id =
                                            gme_common_pvt.g_byprod_completion THEN
               -- add for byprod type_id
               m_mmti_rec.transaction_action_id :=
                                       gme_common_pvt.g_byprod_ret_txn_action;
                                                                       --(32)
            ELSE
        --l_mmti_rec.transaction_type_id = gme_common_pvt.g_byprod_return THEN
               -- add for byprod type_id
               m_mmti_rec.transaction_action_id :=
                                      gme_common_pvt.g_byprod_comp_txn_action;
                                                                       --(31)
            END IF;

            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'calling build for phantom');
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'transaction_type_id for phantom :'
                                   || m_mmti_rec.transaction_type_id);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'transaction_action_id  for phantom :'
                                   || m_mmti_rec.transaction_action_id);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'm_mat_dtl_rec.phantom_line_id :'
                                   || m_mat_dtl_rec.phantom_line_id);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'x_mmti_rec.transaction_interface_id :'
                                   || x_mmti_rec.transaction_interface_id);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'x_mmti_rec.transaction_reference :'
                                   || x_mmti_rec.transaction_reference);
            END IF;

            IF (p_phantom_trans = 0) THEN
               m_mmti_rec.transaction_reference :=
                                          x_mmti_rec.transaction_interface_id;
               l_assign_phantom := 0;
            ELSE
               l_assign_phantom := 0;
            END IF;

            -- calling build for phantom
            build_txn_inter (p_mmti_rec            => m_mmti_rec
                            ,p_mmli_tbl            => m_mmli_tbl
                            ,p_assign_phantom      => l_assign_phantom
                            ,x_mmti_rec            => x_mmti_rec
                            ,x_mmli_tbl            => x_mmli_tbl
                            ,x_return_status       => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success  THEN
               RAISE build_txn_inter_err;
            END IF;

            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'status from build for phantom '
                                   || l_return_status);
            END IF;
         END IF;                                                -- for phantom
      END IF;                                      --p_phantom_trans <> 1 THEN

      -- code for moving the data to temp
      IF gme_common_pvt.g_move_to_temp = fnd_api.g_true THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'calling validate transactions:'
                                || gme_common_pvt.g_transaction_header_id);


             select count(*)
             into l_cnt_int
             from mtl_transactions_interface
             where transaction_header_id= gme_common_pvt.g_transaction_header_id;
             gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'count from interface table:'
                                || l_cnt_int);

         END IF;

         /* Jalaj Srivastava Bug 5109154
            pass additional parameter p_free_tree as false.
            we wil free the tree while calling process transactions */

         l_ret := inv_txn_manager_grp.validate_transactions
                       (p_api_version           => l_api_version
                       ,p_init_msg_list         => fnd_api.g_true
                       ,p_validation_level      => fnd_api.g_valid_level_full
                       ,p_header_id             => gme_common_pvt.g_transaction_header_id
                       ,x_return_status         => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data
                       ,x_trans_count           => l_txn_count
                       ,p_free_tree             => fnd_api.g_false);
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'after validate transactions:'|| l_ret);
            gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'x_trans_count:'|| l_txn_count);
            select count(*) into l_cnt_temp
            from mtl_material_transactions_temp
            where transaction_header_id= gme_common_pvt.g_transaction_header_id;
            gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'count from temp table:'|| l_cnt_temp);
         END IF;
         IF l_ret < 0 THEN
           IF (g_debug <= gme_debug.g_log_statement) THEN
             gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from validate transactions');
           END IF;
           /* Jalaj Srivastava Bug 5001915 add msg returned to stack */
           IF (l_msg_data IS NOT NULL) THEN
             IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'l_msg_data is: '||l_msg_data);
             END IF;
             gme_common_pvt.log_message(p_message_code => 'FND_GENERIC_MESSAGE'
                                       ,p_product_code => 'FND'
                                       ,p_token1_name  => 'MESSAGE'
                                       ,p_token1_value => l_msg_data);
           ELSE
             /* Bug 5256543 Get messages from interface table and put on stack */
             FOR get_msgs IN (SELECT error_explanation FROM mtl_transactions_interface
                              WHERE transaction_header_id = gme_common_pvt.g_transaction_header_id
                              AND error_explanation IS NOT NULL) LOOP
               IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'error_explanation is: '||get_msgs.error_explanation);
               END IF;
               gme_common_pvt.log_message(p_message_code => 'FND_GENERIC_MESSAGE'
                                         ,p_product_code => 'FND'
                                         ,p_token1_name  => 'MESSAGE'
                                         ,p_token1_value => get_msgs.error_explanation);
             END LOOP;
           END IF;
           RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN build_txn_inter_err THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'
           ||' error from build_txn_inter');
         x_return_status := l_return_status;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END create_material_txn;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   update_material_txn
   |
   | USAGE
   |    update the transaction in interface table - it deletes all transactions
   |    of transaction_id passed. Creates new transactions as passed.
   |
   | ARGUMENTS
   |   p_transaction_id - transaction_id from mmt for deletion
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_mmli_tbl -- table of mtl_transaction_lots_inumber_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |   Bug 7385309 Archana Mundhe
   |   Create a new transaction before deleting existing one.
   |
   |   G. Muratore   15-FEB-2010  Bug 9301755
   |      Resequence calls for reversals depending on line_type. This is an
   |      extension of 8639523/7385309 which dealt with product yields only.
   |      update_material_txn is an overloaded function so we need to make same fix here.
   +==========================================================================+ */
   PROCEDURE update_material_txn (
      p_transaction_id   IN              NUMBER
     ,p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl         IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)            := 'UPDATE_MATERIAL_TXN';
      l_mmt_rec             mtl_material_transactions%ROWTYPE;
      l_mmln_tbl            gme_common_pvt.mtl_trans_lots_num_tbl;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_return_status       VARCHAR2 (1)         := fnd_api.g_ret_sts_success;

      create_material_txn_err  EXCEPTION;
      delete_material_txn_err  EXCEPTION;

    -- Bug 9301755 - Introduce cursor to get line_type and variables.
    CURSOR Cur_get_material_line_type (v_transaction_id NUMBER) IS
      SELECT d.line_type
      FROM   mtl_material_transactions t, gme_material_details d
      WHERE  t.transaction_source_type_id = 5
             AND t.transaction_id = v_transaction_id
             AND d.batch_id = t.transaction_source_id
             AND d.material_detail_id = t.trx_source_line_id;

      l_line_type        gme_material_details.line_type%TYPE;
      invalid_line_type  EXCEPTION;
   BEGIN
      --Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmti_rec := p_mmti_rec;
      l_mmli_tbl := p_mmli_tbl;

      -- Bug 9301755 - Fetch the line_type so we can decide whether to call delete first or create.
      OPEN Cur_get_material_line_type (p_transaction_id);
      FETCH Cur_get_material_line_type INTO l_line_type;
      IF (Cur_get_material_line_type%NOTFOUND) THEN
         CLOSE Cur_get_material_line_type;
         RAISE invalid_line_type;
      END IF;
      CLOSE Cur_get_material_line_type;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'line type is '||l_line_type);
      END IF;

      -- Bug 9301755 - Call delete first only for ingredient lines since we want
      -- the inventory put back before we call create txn again. This ensures all
      -- the inventory is available as we do not get erroneous shortage messages.
      IF l_line_type = gme_common_pvt.g_line_type_ing THEN
         -- call to delete all the transactions for this transaction_id
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || 'calling delete transaction for transaction id'
                              || p_transaction_id);
         END IF;

         delete_material_txn (p_transaction_id      => p_transaction_id
                              -- 8605909 updated the delete material transaction with the trans date parameter
                             ,p_trans_date          => l_mmti_rec.transaction_date
                             ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
            END IF;
            RAISE delete_material_txn_err;
         END IF;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling create in update with :'
                             || l_mmti_rec.transaction_interface_id);
      END IF;

      -- Now send the new transaction and lot tbl for create a new transactions
      create_material_txn (p_mmti_rec           => l_mmti_rec
                          ,p_mmli_tbl           => l_mmli_tbl
                          ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE create_material_txn_err;
      END IF;

      -- Bug 9301755 - Call delete for non ingredient lines.
      IF l_line_type <> gme_common_pvt.g_line_type_ing THEN
         -- call to delete all the transactions for this transaction_id
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || 'calling delete transaction for transaction id'
                              || p_transaction_id);
         END IF;

         delete_material_txn (p_transaction_id      => p_transaction_id
                              -- 8605909 updated the delete material transaction with the trans date parameter
                             ,p_trans_date          => l_mmti_rec.transaction_date
                             ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
            END IF;
            RAISE delete_material_txn_err;
         END IF;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
     WHEN invalid_line_type  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error fetching line_type.');
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

      WHEN delete_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
       x_return_status := l_return_status ;

      WHEN create_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create material txn');
       x_return_status := l_return_status ;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END update_material_txn;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   update_material_txn
   |
   | USAGE
   |    update the transaction in interface table - it deletes all transactions
   |    by getting transaction_id from the mmt record passed. Creates new transactions
   |    in interface by converting the mmt to mmti.
   |
   | ARGUMENTS
   |   p_mmt_rec -- mtl_material_transaction rowtype
   |   p_mmln_tbl -- table of mtl_transaction_lots_inumber_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   |   Bug 7385309 Archana Mundhe
   |   Create a new transaction before deleting existing one.
   |
   |   G. Muratore   05-AUG-2009  Bug 8639523
   |      Resequence calls for reversals depending on line_type. This is a rework
   |      of 7385309 which dealt with product yields only. This keeps that fix
   |      in place for products and byproducts.
   +==========================================================================+ */
   PROCEDURE update_material_txn (
      p_mmt_rec         IN              mtl_material_transactions%ROWTYPE
     ,p_mmln_tbl        IN              gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_api_name   CONSTANT VARCHAR2 (30)          := 'UPDATE_MATERIAL_TXN-2';
      l_transaction_id      NUMBER;
      l_mmt_rec             mtl_material_transactions%ROWTYPE;
      l_mmln_tbl            gme_common_pvt.mtl_trans_lots_num_tbl;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_return_status       VARCHAR2 (1)         := fnd_api.g_ret_sts_success;
      create_material_txn_err  EXCEPTION;
      delete_material_txn_err  EXCEPTION;

    -- Bug 8639523 - Introduce cursor to get line_type and variables.
    CURSOR Cur_get_material_line_type (v_transaction_id NUMBER) IS
      SELECT d.line_type
      FROM   mtl_material_transactions t, gme_material_details d
      WHERE  t.transaction_source_type_id = 5
             AND t.transaction_id = v_transaction_id
             AND d.batch_id = t.transaction_source_id
             AND d.material_detail_id = t.trx_source_line_id;

      l_line_type        gme_material_details.line_type%TYPE;
      invalid_line_type  EXCEPTION;


   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmt_rec := p_mmt_rec;
      l_mmln_tbl := p_mmln_tbl;
      -- get the transaction_id from the mmt record for deleting it.
      l_transaction_id := l_mmt_rec.transaction_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling construct from mmt to mmti :'
                             || l_mmt_rec.transaction_id);
      END IF;

      -- Now call the construct procedure to populate the interface for inserting new txns
      construct_mmti (p_mmt_rec            => l_mmt_rec
                     ,p_mmln_tbl           => l_mmln_tbl
                     ,x_mmti_rec           => l_mmti_rec
                     ,x_mmli_tbl           => l_mmli_tbl
                     ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from construct mmti');
        END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Bug 8639523 - Fetch the line_type so we can decide whether to call delete first or create.
      OPEN Cur_get_material_line_type (l_transaction_id);
      FETCH Cur_get_material_line_type INTO l_line_type;
      IF (Cur_get_material_line_type%NOTFOUND) THEN
         CLOSE Cur_get_material_line_type;
         RAISE invalid_line_type;
      END IF;
      CLOSE Cur_get_material_line_type;

     IF (g_debug <= gme_debug.g_log_statement) THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'line type is '||l_line_type);
     END IF;

      -- Bug 8639523 - Call delete first only for ingredient lines since we want
      -- the inventory put back before we call create txn again. This ensures all
      -- the inventory is available as we do not get erroneous shortage messages.
      IF l_line_type = gme_common_pvt.g_line_type_ing THEN
         -- call to delete all the transactions for this transaction_id
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || 'calling delete transaction for transaction id'
                              || l_transaction_id);
         END IF;

         delete_material_txn (p_transaction_id      => l_transaction_id
                            --8605909 updated the delete material transaction with the trans date parameter
                            ,p_trans_date          => l_mmt_rec.transaction_date
                             ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
           END IF;
            RAISE delete_material_txn_err;
         END IF;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling create trans with ='
                             || l_mmt_rec.transaction_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling create trans with ='
                             || l_mmt_rec.source_line_id);
      END IF;

      -- Now send the new transaction and lot tbl for create a new transactions
      create_material_txn (p_mmti_rec           => l_mmti_rec
                          ,p_mmli_tbl           => l_mmli_tbl
                          ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create material txn');
        END IF;
         RAISE create_material_txn_err;
      END IF;

      -- Bug 8639523 - Call delete for non ingredient lines.
      IF l_line_type <> gme_common_pvt.g_line_type_ing THEN
         -- call to delete all the transactions for this transaction_id
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
                             (   g_pkg_name
                              || '.'
                              || l_api_name
                              || ':'
                              || 'calling delete transaction for transaction id'
                              || l_transaction_id);
         END IF;

         -- call to delete all the transactions for this transaction_id
         delete_material_txn (p_transaction_id      => l_transaction_id
               --8605909 updated the delete material transaction with the trans date parameter
               ,p_trans_date          => l_mmt_rec.transaction_date
                             ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
           IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
           END IF;
            RAISE delete_material_txn_err;
         END IF;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;

   EXCEPTION
     WHEN invalid_line_type  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error fetching line_type.');
       x_return_status := fnd_api.g_ret_sts_unexp_error ;
     WHEN delete_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
       x_return_status := l_return_status ;
      WHEN create_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create material txn');
       x_return_status := l_return_status ;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END update_material_txn;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   delete_material_txn
   |
   | USAGE
   |    delete all transactions of transaction_id passed by creating reverse transaction.
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for deletion
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   |   A. Mishra       03-Sep-2009   Bug 8605909
   |      Added p_trans_date parameter to be potentially be used on reversals
   |      where original transaction is now in a closed period.
   +==========================================================================+ */
   PROCEDURE delete_material_txn (
      p_transaction_id   IN              NUMBER
     ,p_txns_pair        IN              NUMBER DEFAULT NULL
     ,p_trans_date       IN              DATE DEFAULT NULL
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_ph_txns (v_transaction_id NUMBER)
      IS
         SELECT transaction_id2
           FROM gme_transaction_pairs
          WHERE transaction_id1 = v_transaction_id
            AND pair_type = gme_common_pvt.g_pairs_phantom_type;

      l_api_name   CONSTANT VARCHAR2 (30)             := 'DELETE_MATERIAL_TXN';
      l_transaction_id      NUMBER;
      m_transaction_id      NUMBER;
      l_mmt_rec             mtl_material_transactions%ROWTYPE;
      l_mmln_tbl            gme_common_pvt.mtl_trans_lots_num_tbl;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec         gme_material_details%ROWTYPE;
      l_return_status       VARCHAR2 (1)          := fnd_api.g_ret_sts_success;
      create_material_txn_err  EXCEPTION;
      delete_material_txn_err  EXCEPTION;
      get_trans_err  EXCEPTION;
      l_trans_date          DATE;
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_transaction_id := p_transaction_id;
      l_trans_date := p_trans_date;

      IF l_transaction_id IS NOT NULL THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
               (   g_pkg_name
                || '.'
                || l_api_name
                || ':'
                || 'getting all transaction for deletion with transaction id  '
                || l_transaction_id);
         END IF;

         get_transactions (p_transaction_id      => l_transaction_id
                          ,x_mmt_rec             => l_mmt_rec
                          ,x_mmln_tbl            => l_mmln_tbl
                          ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from get transactions');
            END IF;
            RAISE get_trans_err;
         END IF;

         -- Bug 8605909 Check to see if original transaction date is in a closed period
         IF NOT gme_common_pvt.check_close_period(p_org_id     => l_mmt_rec.organization_id
                                                 ,p_trans_date => l_mmt_rec.transaction_date) THEN

            -- Let's default to timestamp and overwrite if the user entered a different date.
            l_mmt_rec.transaction_date := gme_common_pvt.g_timestamp;
            IF l_trans_date IS NOT NULL AND l_trans_date <> l_mmt_rec.transaction_date THEN
               l_mmt_rec.transaction_date := l_trans_date;
            END IF;
         END IF;
         -- Bug 8605909 Ends
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'calling construct from mmt to mmti :'
                             || l_mmt_rec.transaction_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'the mmt record source line id(null) ='
                             || l_mmt_rec.source_line_id);
      END IF;

      construct_mmti (p_mmt_rec            => l_mmt_rec
                     ,p_mmln_tbl           => l_mmln_tbl
                     ,x_mmti_rec           => l_mmti_rec
                     ,x_mmli_tbl           => l_mmli_tbl
                     ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from construct mmti');
        END IF;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'getting material for '
                             || l_mmt_rec.trx_source_line_id);
      END IF;

      -- get the material details of the transaction
      l_mat_dtl_rec.material_detail_id := l_mmt_rec.trx_source_line_id;

      -- Now fetch the material details for the material
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'getting material for '
                             || l_mat_dtl_rec.material_detail_id);
      END IF;

      IF NOT gme_material_details_dbl.fetch_row
             (p_material_detail      => l_mat_dtl_rec
              ,x_material_detail      => l_mat_dtl_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Bug 6437252 LPN Support
      IF l_mmti_rec.transaction_type_id = gme_common_pvt.g_ing_issue THEN
                                                                        --(35)
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_ing_return;
                                                                       --(43)
         l_mmti_rec.transaction_action_id :=
                                          gme_common_pvt.g_ing_ret_txn_action;
                                                                       --(27)
         l_mmti_rec.transfer_lpn_id := l_mmt_rec.lpn_id;
      ELSIF l_mmti_rec.transaction_type_id = gme_common_pvt.g_ing_return THEN
                                                                        --(43)
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_ing_issue;
                                                                      -- (35)
         l_mmti_rec.transaction_action_id :=
                                        gme_common_pvt.g_ing_issue_txn_action;
                                                                        --(1)
         l_mmti_rec.lpn_id := l_mmt_rec.transfer_lpn_id;
      ELSIF l_mmti_rec.transaction_type_id = gme_common_pvt.g_prod_completion THEN
                                                                       -- (44)
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_prod_return;
                                                                       --(17)
         l_mmti_rec.transaction_action_id :=
                                         gme_common_pvt.g_prod_ret_txn_action;
                                                                       --(27)
         l_mmti_rec.lpn_id := l_mmt_rec.transfer_lpn_id;
      ELSIF l_mmti_rec.transaction_type_id = gme_common_pvt.g_prod_return THEN
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_prod_completion;
         l_mmti_rec.transaction_action_id :=
                                        gme_common_pvt.g_prod_comp_txn_action;
                                                                       --(31)
         l_mmti_rec.transfer_lpn_id := l_mmt_rec.lpn_id;
      ELSIF l_mmti_rec.transaction_type_id =
                                            gme_common_pvt.g_byprod_completion THEN
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_byprod_return;
         l_mmti_rec.transaction_action_id :=
                                       gme_common_pvt.g_byprod_ret_txn_action;
                                                                       --(32)
         l_mmti_rec.lpn_id := l_mmt_rec.transfer_lpn_id;
      ELSE
        --l_mmti_rec.transaction_type_id = gme_common_pvt.g_byprod_return THEN
         l_mmti_rec.transaction_type_id := gme_common_pvt.g_prod_completion;
         l_mmti_rec.transaction_action_id :=
                                      gme_common_pvt.g_byprod_comp_txn_action;
                                                                       --(31)
         l_mmti_rec.transfer_lpn_id := l_mmt_rec.lpn_id;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'sending transaction_type_id:'
                             || l_mmti_rec.transaction_type_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'sending transaction_action_id:'
                             || l_mmti_rec.transaction_action_id);
      END IF;

      -- set for delete transaction
      l_mmti_rec.source_line_id := l_mmt_rec.transaction_id;
      gme_debug.put_line (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ':'
                          || 'calling create trans with ='
                          || l_mmti_rec.source_line_id);

            -- changes for phantom
     --Bug#8453427 Start
       /*Bug#8453427 Added the delete call for the phantom transactions for the product return transactions, as the
      corresponsing phantom transctions would be of the production completion types and always +ve sign transactions should be
      created first */
      IF (l_mmti_rec.transaction_type_id = gme_common_pvt.g_prod_return OR
          l_mmti_rec.transaction_type_id = gme_common_pvt.g_byprod_return ) THEN
        IF l_mat_dtl_rec.phantom_line_id IS NOT NULL AND p_txns_pair IS NULL THEN
             IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || ':'
                                  || 'deleting for phantom:'
                                         || l_mat_dtl_rec.phantom_line_id);
           END IF;

           OPEN cur_get_ph_txns (p_transaction_id);

           FETCH cur_get_ph_txns
            INTO m_transaction_id;

           CLOSE cur_get_ph_txns;

           IF m_transaction_id IS NOT NULL THEN
              IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (   g_pkg_name
                                     || '.'
                                     || l_api_name
                                     || ':'
                                     || 'calling delete txns for phantom:'
                                     || m_transaction_id);
              END IF;

              delete_material_txn (p_transaction_id      => m_transaction_id
                                  ,p_txns_pair           => 1
                                  ,p_trans_date          => l_trans_date
                                  ,x_return_status       => l_return_status);
               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  IF (g_debug <= gme_debug.g_log_statement) THEN
                    gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create mat txn');
                  END IF;
                  RAISE delete_material_txn_err;
              END IF; -- ret status
           ELSE
              IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (   g_pkg_name
                                     || '.'
                                     || l_api_name
                                     || ':'
                                     || 'no phantom txns found for '
                                     || l_transaction_id);
              END IF;
           END IF; -- m_transaction_id is not null
        END IF;
      END IF;
          --Bug#8453427 End
      -- with the new rec- call the create txn
      create_material_txn (p_mmti_rec           => l_mmti_rec
                          ,p_mmli_tbl           => l_mmli_tbl
                          ,p_phantom_trans      => 1
                          ,x_return_status      => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create mat txn');
        END IF;
         RAISE create_material_txn_err;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'status from create :'
                             || l_return_status);
      END IF;

      -- Insert into gme_transactions_pairs table
      -- code need to added  for  INSERT INTO GME_TRANSACTION_PAIRS tables
      -- which column will carry the material detail ld
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'inserting into pairs table transaction_id:'
                             || l_transaction_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'inserting into pairs table batch_id:'
                             || l_mat_dtl_rec.batch_id);
         gme_debug.put_line
                          (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ':'
                           || 'inserting into pairs table material_detail_id:'
                           || l_mat_dtl_rec.material_detail_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'inserting into pairs table pair_type:'
                             || gme_common_pvt.g_pairs_reversal_type);
      END IF;

      INSERT INTO gme_transaction_pairs
                  (batch_id, material_detail_id
                  ,transaction_id1, transaction_id2
                  ,pair_type)
           VALUES (l_mat_dtl_rec.batch_id, l_mat_dtl_rec.material_detail_id
                  ,l_mmt_rec.transaction_id, NULL
                  ,gme_common_pvt.g_pairs_reversal_type);

         /*Bug#8453427 Added the below if condition as the phantom transactions already created
	               above for the product and by product return transaction types. */
      IF (l_mmti_rec.transaction_type_id <> gme_common_pvt.g_prod_return AND
            l_mmti_rec.transaction_type_id <> gme_common_pvt.g_byprod_return ) THEN
      -- changes for phantom
        IF l_mat_dtl_rec.phantom_line_id IS NOT NULL AND p_txns_pair IS NULL THEN
           IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || ':'
                                  || 'deleting for phantom:'
                                  || l_mat_dtl_rec.phantom_line_id);
           END IF;

           OPEN cur_get_ph_txns (p_transaction_id);

           FETCH cur_get_ph_txns
            INTO m_transaction_id;

           CLOSE cur_get_ph_txns;

           IF m_transaction_id IS NOT NULL THEN
              IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (   g_pkg_name
                                     || '.'
                                     || l_api_name
                                     || ':'
                                     || 'calling delete txns for phantom:'
                                     || m_transaction_id);
              END IF;

              delete_material_txn (p_transaction_id      => m_transaction_id
                                  ,p_txns_pair           => 1
                                  ,p_trans_date          => l_trans_date
                                  ,x_return_status       => l_return_status);
               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  IF (g_debug <= gme_debug.g_log_statement) THEN
                    gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create mat txn');
                  END IF;
                  RAISE delete_material_txn_err;
              END IF; -- ret status
           ELSE
              IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (   g_pkg_name
                                     || '.'
                                     || l_api_name
                                     || ':'
                                     || 'no phantom txns found for '
                                     || l_transaction_id);
              END IF;
           END IF; -- m_transaction_id is not null
        END IF;
      END IF;
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN delete_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from delete material txn');
       x_return_status := l_return_status ;
      WHEN get_trans_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from get_transactions');
       x_return_status := l_return_status ;
      WHEN create_material_txn_err  THEN
        gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from create material txn');
       x_return_status := l_return_status ;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'Unexpected');
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END delete_material_txn;

/* +==========================================================================+
| PROCEDURE NAME
|   build_txn_inter
|
| USAGE
|    Inserts the transaction to interface table
|
| ARGUMENTS
|   p_mmti_rec -- mtl_transaction_interface rowtype
|   p_mmli_tbl -- table of mtl_trans_lots_inter_tbl as input
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|
+==========================================================================+ */
   PROCEDURE build_txn_inter (
      p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_mmli_tbl         IN              gme_common_pvt.mtl_trans_lots_inter_tbl
     ,p_assign_phantom   IN              NUMBER DEFAULT 0
     ,x_mmti_rec         OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_mmli_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      l_mmti_rec                mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl                gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_api_name   CONSTANT     VARCHAR2 (30)                := 'BUILD_TXN_INTER';
      x_header_id               NUMBER;
      l_return_status           VARCHAR2 (1)         := fnd_api.g_ret_sts_success;
      l_insert_hdr              BOOLEAN;
      build_txn_inter_err       EXCEPTION;
      build_txn_inter_lot_err   EXCEPTION;
      lot_expired_err           EXCEPTION;
      insert_hdr_err            EXCEPTION ;
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmti_rec := p_mmti_rec;
      l_mmli_tbl := p_mmli_tbl;
      /* Bug 4929610 Added code to pass parameter */
      IF (l_mmli_tbl.COUNT > 0) THEN
        l_insert_hdr := FALSE;
      ELSE
        l_insert_hdr := TRUE;
      END IF;
      build_txn_inter_hdr (p_mmti_rec            => p_mmti_rec
                          ,p_assign_phantom      => p_assign_phantom
                          ,x_mmti_rec            => x_mmti_rec
                          ,x_return_status       => l_return_status
                          ,p_insert_hdr          => l_insert_hdr);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from build inter hdr');
        END IF;
         RAISE  build_txn_inter_err;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'after header- inserting lot');
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'after header- inter_id:'
                             || x_mmti_rec.transaction_interface_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'after header- header_id:'
                             || x_mmti_rec.transaction_header_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'after header- trasn_type:'
                             || x_mmti_rec.transaction_type_id);
      END IF;

      IF (l_mmli_tbl.COUNT > 0) THEN
         FOR i IN 1 .. l_mmli_tbl.COUNT LOOP
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'lot_number '
                                   || l_mmli_tbl (i).lot_number);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'transaction_quantity '
                                   || l_mmli_tbl (i).transaction_quantity);
            END IF;
            /* Bug 4929610 added lot expiry check */
            IF (x_mmti_rec.transaction_type_id = gme_common_pvt.g_ing_issue) THEN
              IF (gme_transactions_pvt.is_lot_expired (p_organization_id   => x_mmti_rec.organization_id,
                                                       p_inventory_item_id => x_mmti_rec.inventory_item_id,
                                                       p_lot_number        => l_mmli_tbl(i).lot_number,
                                                       p_date              => x_mmti_rec.transaction_date)) THEN
                RAISE lot_expired_err;
              END IF;
            END IF;
            build_txn_inter_lot
                     (p_trans_inter_id           => x_mmti_rec.transaction_interface_id
                     ,p_transaction_type_id      => x_mmti_rec.transaction_type_id
                     ,p_inventory_item_id        => x_mmti_rec.inventory_item_id
                     ,p_subinventory_code        => x_mmti_rec.subinventory_code
                     ,p_locator_id               => x_mmti_rec.locator_id
                     ,p_mmli_rec                 => l_mmli_tbl (i)
                     ,x_mmli_rec                 => x_mmli_tbl (i)
                     ,x_return_status            => l_return_status);

            IF l_return_status <> fnd_api.g_ret_sts_success THEN
               IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'Error from build lot inter');
                END IF;
                RAISE  build_txn_inter_lot_err;
            END IF;
         END LOOP;
      END IF;                                               --l_mmli_tbl.count
      /* Bug 4929610 Added code to insert if not inserted originally */
      IF NOT(l_insert_hdr) THEN
        insert_txn_inter_hdr(p_mmti_rec      => x_mmti_rec,
                             x_return_status => l_return_status);
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          RAISE insert_hdr_err;
        END IF;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
     WHEN insert_hdr_err THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'insert_hdr_err');
        x_return_status := l_return_status;
      WHEN lot_expired_err THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'lot_expired_err');
        x_return_status := 'T';
      WHEN build_txn_inter_lot_err THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'build_txn_inter_lot_err');
         x_return_status := l_return_status;
      WHEN build_txn_inter_err THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'build_txn_inter_err');
         x_return_status := l_return_status;
      WHEN fnd_api.g_exc_error THEN
         gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||'user defined error');
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'unexp'
                             || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END build_txn_inter;

/* +==========================================================================+
| PROCEDURE NAME
|   build_txn_inter_hdr
|
| USAGE
|    Inserts the transaction to interface table
|
| ARGUMENTS
|   p_mmti_rec -- mtl_transaction_interface rowtype
|
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|            13-Sep-05 Namit Singhi - Modified to include insert into transfer_lpn_id.
|
+==========================================================================+ */
   PROCEDURE build_txn_inter_hdr (
      p_mmti_rec         IN              mtl_transactions_interface%ROWTYPE
     ,p_assign_phantom   IN              NUMBER DEFAULT 0
     ,x_mmti_rec         OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,p_insert_hdr       IN              BOOLEAN DEFAULT TRUE)
   IS
     CURSOR get_location (v_org_id IN NUMBER
                         ,v_sub_inv IN VARCHAR2
                         ,v_loc_id IN NUMBER) IS
         SELECT substr(concatenated_segments,1,100)
         FROM wms_item_locations_kfv
         WHERE organization_id = v_org_id
           AND subinventory_code = v_sub_inv
           AND inventory_location_id (+) = v_loc_id;
      l_mmti_rec                mtl_transactions_interface%ROWTYPE;
      l_api_name   CONSTANT     VARCHAR2 (30)                   := 'BUILD_TXN_INTER_hdr';
      x_header_id               NUMBER;
      l_return_status           VARCHAR2 (1)                    := fnd_api.g_ret_sts_success;
      l_item                    VARCHAR2(100);
      l_type                    VARCHAR2(100);
      l_locator                 VARCHAR2(100);
      material_status_err       EXCEPTION ;
      insert_hdr_err            EXCEPTION ;
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmti_rec := p_mmti_rec;

      IF gme_common_pvt.g_transaction_header_id IS NULL THEN
         SELECT mtl_material_transactions_s.NEXTVAL
           INTO gme_common_pvt.g_transaction_header_id
           FROM DUAL;

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'GME_COMMON_PVT.g_transaction_header_id '
                                || gme_common_pvt.g_transaction_header_id);
         END IF;
      END IF;

      l_mmti_rec.transaction_header_id :=
                                        gme_common_pvt.g_transaction_header_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'l_mmti_rec.transaction_header_id '
                             || l_mmti_rec.transaction_header_id);
      END IF;

      SELECT mtl_material_transactions_s.NEXTVAL
        INTO l_mmti_rec.transaction_interface_id
        FROM DUAL;

      IF l_mmti_rec.transaction_type_id IN
            (gme_common_pvt.g_ing_return
            ,gme_common_pvt.g_prod_completion
            ,gme_common_pvt.g_byprod_completion) THEN
         l_mmti_rec.transaction_batch_seq := 1;
         l_mmti_rec.transaction_batch_id := l_mmti_rec.transaction_header_id ;
         l_mmti_rec.transaction_quantity :=
                                        ABS(l_mmti_rec.transaction_quantity);
         l_mmti_rec.secondary_transaction_quantity :=
                             ABS(l_mmti_rec.secondary_transaction_quantity);
      ELSE
         l_mmti_rec.transaction_batch_seq := 100;
         l_mmti_rec.transaction_batch_id := l_mmti_rec.transaction_header_id ;
         l_mmti_rec.transaction_quantity :=
                                       (-1) * ABS(l_mmti_rec.transaction_quantity);
         l_mmti_rec.secondary_transaction_quantity :=
                             (-1) * ABS(l_mmti_rec.secondary_transaction_quantity);
      END IF;
       -- Code for checking mateial status
      IF (inv_material_status_grp.is_status_applicable
                        (p_wms_installed         => NULL
                        ,p_trx_status_enabled    => NULL
                        ,p_trx_type_id           => l_mmti_rec.transaction_type_id
                        ,p_lot_status_enabled    => NULL
                        ,p_serial_status_enabled => NULL
                        ,p_organization_id       => l_mmti_rec.organization_id
                        ,p_inventory_item_id     => l_mmti_rec.inventory_item_id
                        ,p_sub_code              => l_mmti_rec.subinventory_code
                        ,p_locator_id            => l_mmti_rec.locator_id
                        ,p_lot_number            => NULL
                        ,p_serial_number         => NULL
                        ,p_object_type           => 'A') = 'N') THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                         || '.'
                         || l_api_name
                         || ':'
                         || 'material status check not valid  for item '
                         || l_mmti_rec.inventory_item_id);
         END IF;
         RAISE material_status_err;
      END IF; /* inv_material_status_grp.is_status_applicable */
      -- for a phantom transaction- asssign value to transaction_refernece
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'Material Status is VALID');
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || 'p_assign_phantom: '
                             || p_assign_phantom);
      END IF;

      IF p_assign_phantom = 1 THEN
         l_mmti_rec.transaction_reference :=
                                       (l_mmti_rec.transaction_interface_id);
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_interface_id: '
                             || l_mmti_rec.transaction_interface_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_source_id: '
                             || l_mmti_rec.transaction_source_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_type_id: '
                             || l_mmti_rec.transaction_type_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_source_type_id: '
                             || l_mmti_rec.transaction_source_type_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_quantity: '
                             || l_mmti_rec.transaction_quantity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_uom: '
                             || l_mmti_rec.transaction_uom);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'secondary_transaction_quantity: '
                             || l_mmti_rec.secondary_transaction_quantity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'secondary_uom_code: '
                             || l_mmti_rec.secondary_uom_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'primary_quantity: '
                             || l_mmti_rec.primary_quantity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'process_flag: '
                             || l_mmti_rec.process_flag);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'inventory_item_id: '
                             || l_mmti_rec.inventory_item_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'revision: '
                             || l_mmti_rec.revision);
          gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transfer_lpn_id: '
                             || l_mmti_rec.transfer_lpn_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'organization_id: '
                             || l_mmti_rec.organization_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'subinventory_code: '
                             || TO_CHAR (l_mmti_rec.subinventory_code) );
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'locator_id:'
                             || l_mmti_rec.locator_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'source_line_id: '
                             || l_mmti_rec.source_line_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'trx_source_line_id: '
                             || l_mmti_rec.trx_source_line_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'source_header_id: '
                             || l_mmti_rec.source_header_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_source_name: '
                             || l_mmti_rec.transaction_source_name);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_mode: '
                             || l_mmti_rec.transaction_mode);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'last_updated_by: '
                             || gme_common_pvt.g_user_ident);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_reference: '
                             || l_mmti_rec.transaction_reference);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_batch_id: '
                             || l_mmti_rec.transaction_batch_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_batch_seq: '
                             || l_mmti_rec.transaction_batch_seq);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'reservation_quantity: '
                             || l_mmti_rec.reservation_quantity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_sequence_id: '
                             || l_mmti_rec.transaction_sequence_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'reason_id: '
                             || l_mmti_rec.reason_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transfer_lpn_id: '
                             || l_mmti_rec.transfer_lpn_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_date: '
                             || to_char(l_mmti_rec.transaction_date,'YYYY-MON-DD HH24:MI:SS'));
      END IF;
      /* Bug 4929610 fixed */
      IF (p_insert_hdr) THEN
        insert_txn_inter_hdr(p_mmti_rec      => l_mmti_rec,
                             x_return_status => l_return_status);
        IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
          RAISE insert_hdr_err;
        END IF;
      END IF;
      x_mmti_rec := l_mmti_rec;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'after inserting header with status:'||x_return_status);

      END IF;
   EXCEPTION
     WHEN insert_hdr_err THEN
        x_return_status := l_return_status;
     WHEN material_status_err THEN
         SELECT substr(concatenated_segments,1,100)
         INTO l_item
         FROM mtl_system_items_kfv
         WHERE organization_id = l_mmti_rec.organization_id
           AND inventory_item_id = l_mmti_rec.inventory_item_id;
         OPEN get_location(l_mmti_rec.organization_id, l_mmti_rec.subinventory_code, l_mmti_rec.locator_id);
         FETCH get_location INTO l_locator;
         CLOSE get_location;
         SELECT transaction_type_name
         INTO   l_type
         FROM   mtl_transaction_types
         WHERE  transaction_type_id = l_mmti_rec.transaction_type_id;
         IF l_locator IS NOT NULL THEN
            gme_common_pvt.log_message ('GME_MATERIAL_STS_INV_SUB_LOC'
                                        ,'TRANSTYPE',l_type,'ITEM',l_item
                                        ,'SUBINV',l_mmti_rec.subinventory_code
                                        ,'LOCN',l_locator);
         ELSE
            gme_common_pvt.log_message ('GME_MATERIAL_STS_INV_SUB'
                                        ,'TRANSTYPE',l_type,'ITEM',l_item
                                        ,'SUBINV',l_mmti_rec.subinventory_code);
         END IF;
              gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'material status invalid for item, subinventory, locator etc'
                             );
         x_return_status := 'T';
      WHEN fnd_api.g_exc_unexpected_error THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'unexp'
                             || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END build_txn_inter_hdr;

/* +==========================================================================+
| PROCEDURE NAME
|   build_txn_inter_lot
|
| USAGE
|    Inserts the transaction to interface table
|
| ARGUMENTS
|
|   p_mmli_rec -- table of mtl_trans_lots_inter_tbl as input
|
| RETURNS
|   returns via x_status OUT parameters
|
| HISTORY
|   Created  02-Feb-05 Pawan Kumar
|
|   G. Muratore      29-Dec-08   Bug 7623144 - add all missing lot attribute columns
|      'C_', 'D_' and 'N_' attribute columns plus lot_attribute_category.
|
|   G. Muratore      01-Dec-09   Bug 9170460
|      Pass in subinventory and locator id to applicable function.
+==========================================================================+ */
   PROCEDURE build_txn_inter_lot (
      p_trans_inter_id        IN              NUMBER
     ,p_transaction_type_id   IN              NUMBER
     ,p_inventory_item_id     IN              NUMBER
     ,p_subinventory_code     IN              VARCHAR2
     ,p_locator_id            IN              NUMBER
     ,p_mmli_rec              IN              mtl_transaction_lots_interface%ROWTYPE
     ,x_mmli_rec              OUT NOCOPY      mtl_transaction_lots_interface%ROWTYPE
     ,x_return_status         OUT NOCOPY      VARCHAR2)
   IS
      l_api_name        CONSTANT        VARCHAR2 (30)          := 'BUILD_TXN_INTER_LOT';
      l_return_status                   VARCHAR2 (1)       := fnd_api.g_ret_sts_success;
      l_mmli_rec                        mtl_transaction_lots_interface%ROWTYPE;
      l_transaction_type_id             NUMBER;
      l_inventory_item_id               NUMBER;
      l_item                            VARCHAR2(100);
      l_type                            VARCHAR2(100);
      material_status_err               EXCEPTION;
   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmli_rec := p_mmli_rec;
      l_mmli_rec.transaction_interface_id := p_trans_inter_id;
      l_transaction_type_id := p_transaction_type_id;
      l_inventory_item_id   := p_inventory_item_id ;
      IF l_transaction_type_id IN
            (gme_common_pvt.g_ing_return
            ,gme_common_pvt.g_prod_completion
            ,gme_common_pvt.g_byprod_completion) THEN
         l_mmli_rec.transaction_quantity :=
                                       ABS(l_mmli_rec.transaction_quantity);
         l_mmli_rec.secondary_transaction_quantity :=
                                       ABS(l_mmli_rec.secondary_transaction_quantity);
      ELSE
        l_mmli_rec.transaction_quantity :=
                                       (-1) * ABS(l_mmli_rec.transaction_quantity);
         l_mmli_rec.secondary_transaction_quantity :=
                             (-1) * ABS(l_mmli_rec.secondary_transaction_quantity);
      END IF;

      -- Bug 9170460 - Pass in subinventory and locator id to applicable function.
      IF (inv_material_status_grp.is_status_applicable
                        (p_wms_installed         => NULL
                        ,p_trx_status_enabled    => NULL
                        ,p_trx_type_id           => l_transaction_type_id
                        ,p_lot_status_enabled    => NULL
                        ,p_serial_status_enabled => NULL
                        ,p_organization_id       => gme_common_pvt.g_organization_id
                        ,p_inventory_item_id     => l_inventory_item_id
                        ,p_sub_code              => p_subinventory_code
                        ,p_locator_id            => p_locator_id
                        ,p_lot_number            => l_mmli_rec.lot_number
                        ,p_serial_number         => NULL
                        ,p_object_type           => 'A') = 'N') THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (   g_pkg_name
                        || '.'
                        || l_api_name
                        || ':'
                        || 'material status check for lot NOT valid  for lot '
                        || l_mmli_rec.lot_number);
         END IF;
         RAISE material_status_err;
      END IF;  /* inv_material_status_grp.is_status_applicable */

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                        || '.'
                        || l_api_name
                        || ':'
                        || 'Material Status is VALID for lot '
                        || l_mmli_rec.lot_number);
         gme_debug.put_line (   g_pkg_name
                        || '.'
                        || l_api_name
                        || ':'
                        || 'lot_qty is '
                        || l_mmli_rec.transaction_quantity);
      END IF;
     /* Bug#7226474 Added attribute columns as the lot attribute information DFF
      * fields can be entered using api */
      INSERT INTO mtl_transaction_lots_interface
                  (transaction_interface_id, last_update_date
                  ,last_updated_by, last_update_login
                  ,creation_date, created_by,parent_lot_number
                  ,lot_number, transaction_quantity
                  ,primary_quantity
                  ,secondary_transaction_quantity
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
		  ,attribute_category    -- );   -- Bug 7623144 Added additional missing columns here for lot attributes.
                  ,lot_attribute_category
                  ,c_attribute1
                  ,c_attribute2
                  ,c_attribute3
                  ,c_attribute4
                  ,c_attribute5
                  ,c_attribute6
                  ,c_attribute7
                  ,c_attribute8
                  ,c_attribute9
                  ,c_attribute10
                  ,c_attribute11
                  ,c_attribute12
                  ,c_attribute13
                  ,c_attribute14
                  ,c_attribute15
                  ,c_attribute16
                  ,c_attribute17
                  ,c_attribute18
                  ,c_attribute19
                  ,c_attribute20
                  ,d_attribute1
                  ,d_attribute2
                  ,d_attribute3
                  ,d_attribute4
                  ,d_attribute5
                  ,d_attribute6
                  ,d_attribute7
                  ,d_attribute8
                  ,d_attribute9
                  ,d_attribute10
                  ,n_attribute1
                  ,n_attribute2
                  ,n_attribute3
                  ,n_attribute4
                  ,n_attribute5
                  ,n_attribute6
                  ,n_attribute7
                  ,n_attribute8
                  ,n_attribute9
                  ,n_attribute10)
           VALUES ( p_trans_inter_id  --transaction_interface_id
                   ,gme_common_pvt.g_timestamp --last_update_date
                   ,gme_common_pvt.g_user_ident --last_updated_by
                   ,gme_common_pvt.g_user_ident --last_update_login
                   ,gme_common_pvt.g_timestamp  --creation_date
                   ,gme_common_pvt.g_user_ident --created_by
                   ,l_mmli_rec.parent_lot_number --parent lot_number
/*Bug#7372673*/
                   ,l_mmli_rec.lot_number --lot_number
                   ,l_mmli_rec.transaction_quantity --lot_quantity
                   ,l_mmli_rec.primary_quantity
                   ,l_mmli_rec.secondary_transaction_quantity
                   ,l_mmli_rec.attribute1
                   ,l_mmli_rec.attribute2
                   ,l_mmli_rec.attribute3
                   ,l_mmli_rec.attribute4
                   ,l_mmli_rec.attribute5
                   ,l_mmli_rec.attribute6
                   ,l_mmli_rec.attribute7
                   ,l_mmli_rec.attribute8
                   ,l_mmli_rec.attribute9
                   ,l_mmli_rec.attribute10
                   ,l_mmli_rec.attribute11
                   ,l_mmli_rec.attribute12
                   ,l_mmli_rec.attribute13
                   ,l_mmli_rec.attribute14
                   ,l_mmli_rec.attribute15
                   ,l_mmli_rec.attribute_category    --  );  -- Bug 7623144 Added aditional missing columns here for lot attributes.
                   ,l_mmli_rec.lot_attribute_category
                   ,l_mmli_rec.c_attribute1
                   ,l_mmli_rec.c_attribute2
                   ,l_mmli_rec.c_attribute3
                   ,l_mmli_rec.c_attribute4
                   ,l_mmli_rec.c_attribute5
                   ,l_mmli_rec.c_attribute6
                   ,l_mmli_rec.c_attribute7
                   ,l_mmli_rec.c_attribute8
                   ,l_mmli_rec.c_attribute9
                   ,l_mmli_rec.c_attribute10
                   ,l_mmli_rec.c_attribute11
                   ,l_mmli_rec.c_attribute12
                   ,l_mmli_rec.c_attribute13
                   ,l_mmli_rec.c_attribute14
                   ,l_mmli_rec.c_attribute15
                   ,l_mmli_rec.c_attribute16
                   ,l_mmli_rec.c_attribute17
                   ,l_mmli_rec.c_attribute18
                   ,l_mmli_rec.c_attribute19
                   ,l_mmli_rec.c_attribute20
                   ,l_mmli_rec.d_attribute1
                   ,l_mmli_rec.d_attribute2
                   ,l_mmli_rec.d_attribute3
                   ,l_mmli_rec.d_attribute4
                   ,l_mmli_rec.d_attribute5
                   ,l_mmli_rec.d_attribute6
                   ,l_mmli_rec.d_attribute7
                   ,l_mmli_rec.d_attribute8
                   ,l_mmli_rec.d_attribute9
                   ,l_mmli_rec.d_attribute10
                   ,l_mmli_rec.n_attribute1
                   ,l_mmli_rec.n_attribute2
                   ,l_mmli_rec.n_attribute3
                   ,l_mmli_rec.n_attribute4
                   ,l_mmli_rec.n_attribute5
                   ,l_mmli_rec.n_attribute6
                   ,l_mmli_rec.n_attribute7
                   ,l_mmli_rec.n_attribute8
                   ,l_mmli_rec.n_attribute9
                   ,l_mmli_rec.n_attribute10);

      x_mmli_rec := l_mmli_rec;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN material_status_err THEN
         SELECT substr(concatenated_segments,1,100)
         INTO l_item
         FROM mtl_system_items_kfv
         WHERE organization_id = gme_common_pvt.g_organization_id
           AND inventory_item_id = l_inventory_item_id;
         SELECT transaction_type_name
         INTO   l_type
         FROM   mtl_transaction_types
         WHERE  transaction_type_id = p_transaction_type_id;
         gme_common_pvt.log_message ('GME_MATERIAL_STS_INV_LOT'
                                     ,'TRANSTYPE',l_type,'ITEM',l_item
                                     ,'LOT',l_mmli_rec.lot_number);
              gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'material status invalid for item, subinventory, locator etc');
         x_return_status := 'T';
      WHEN fnd_api.g_exc_error THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'WHEN exe'
                             || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'unexp'
                             || SQLERRM);
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END BUILD_TXN_INTER_LOT;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_transactions
   |
   | USAGE
   |    Gets all transactions from mmt based on transaction_id passed.
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for fetch
   |
   | RETURNS
   |
   |   returns via x_status OUT parameters
   |   x_mmt_rec -- mtl_transaction_interface rowtype
   |   x_mmln_tbl -- table of mtl_trans_lots_number_tbl
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |            09-Feb-06 Namit S. Bug4917213 Changed query for perf reasons.
   |
   +==========================================================================+ */
   PROCEDURE get_transactions (
      p_transaction_id   IN              NUMBER
     ,x_mmt_rec          OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS

-- Namit S. Bug4917213. Changed query to add hint to improve sharable memory.
-- Hint was provided by the apps perf team.
-- Pawan Kumar bug 5483071 added order by clause
-- donot change the order by clause it is done so that we reverse the outbound transaction first

      CURSOR cur_get_transaction (v_transaction_id NUMBER, v_reversal_type NUMBER)
      IS
         SELECT *
           FROM mtl_material_transactions mmt
          WHERE transaction_id = v_transaction_id
            AND NOT EXISTS ( SELECT  /*+ no_unnest */
                        transaction_id1
                     FROM gme_transaction_pairs
                    WHERE transaction_id1 = mmt.transaction_id
                      AND pair_type = v_reversal_type)
           ORDER BY mmt.transaction_quantity;

      CURSOR cur_get_lot_transaction (v_transaction_id NUMBER)
      IS
         SELECT *
           FROM mtl_transaction_lot_numbers
          WHERE transaction_id = v_transaction_id;

      l_api_name    CONSTANT VARCHAR2 (30) := 'GET_TRANSACTIONS';
      l_return_status        VARCHAR2 (1)  := fnd_api.g_ret_sts_success;
      l_transaction_id       NUMBER;
      no_transaction_found   EXCEPTION;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with transaction '||p_transaction_id);
      END IF;

      IF p_transaction_id IS NULL THEN
         gme_common_pvt.log_message ('GME_NO_KEYS', 'TABLE_NAME', l_api_name);

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'TRANSACTION ID NEEDED FOR RETRIEVAL');
         END IF;
      END IF;

      l_transaction_id := p_transaction_id;
-- Namit S. Bug4917213.
      OPEN cur_get_transaction (l_transaction_id, gme_common_pvt.g_pairs_reversal_type);
      FETCH cur_get_transaction
       INTO x_mmt_rec;
      IF cur_get_transaction%FOUND THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'TRANSACTIONS found for '
                                || l_transaction_id);
         END IF;
         get_lot_trans (p_transaction_id      => l_transaction_id
                       ,x_mmln_tbl            => x_mmln_tbl
                       ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'error from get lot trans');
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE /* IF cur_get_transaction%FOUND THEN */
         CLOSE cur_get_transaction;
         gme_common_pvt.log_message ('GME_NO_TRANS_FOUND');
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_get_transaction;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'TRANSACTION '
                             || x_mmt_rec.transaction_id);
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END get_transactions;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   construct_mmti
   |
   | USAGE
   |    Construct interface table record based on mmt passed to it.
   |
   | ARGUMENTS
   |   p_mmt_rec -- mtl_material_transaction rowtype
   |   p_mmln_tbl -- table of mtl_trans_lots_num_tbl as input
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |               x_mmti_rec mtl_transactions_interface rowtype
   |               x_mmli_tbl table of mtl_trans_lots_inter_tbl
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE construct_mmti (
      p_mmt_rec         IN              mtl_material_transactions%ROWTYPE
     ,p_mmln_tbl        IN              gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_mmti_rec        OUT NOCOPY      mtl_transactions_interface%ROWTYPE
     ,x_mmli_tbl        OUT NOCOPY      gme_common_pvt.mtl_trans_lots_inter_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS
      l_mmt_rec             mtl_material_transactions%ROWTYPE;
      l_mmln_tbl            gme_common_pvt.mtl_trans_lots_num_tbl;
      l_mmti_rec            mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl            gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_api_name   CONSTANT VARCHAR2 (30)                 := 'CONSTRUCT_MMTI';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      l_mmt_rec := p_mmt_rec;
      l_mmln_tbl := p_mmln_tbl;
      -- x_mmti_rec.transaction_mode := l_mmt_rec.transaction_mode;
      x_mmti_rec.source_code                    := l_mmt_rec.source_code;
      -- x_mmti_rec.source_header_id            :=  l_mmt_rec.source_header_id            ;
      x_mmti_rec.source_line_id                 := NVL (l_mmt_rec.source_line_id, -99);
      x_mmti_rec.transaction_source_id          := l_mmt_rec.transaction_source_id;
      x_mmti_rec.trx_source_line_id             := l_mmt_rec.trx_source_line_id;
      x_mmti_rec.last_updated_by                := l_mmt_rec.last_updated_by;
      x_mmti_rec.last_update_login              := l_mmt_rec.last_update_login;
      x_mmti_rec.last_update_date               := l_mmt_rec.last_update_date;
      x_mmti_rec.creation_date                  := l_mmt_rec.creation_date;
      x_mmti_rec.created_by                     := l_mmt_rec.created_by;
      x_mmti_rec.inventory_item_id              := l_mmt_rec.inventory_item_id;
      x_mmti_rec.revision                       := l_mmt_rec.revision;
      x_mmti_rec.organization_id                := l_mmt_rec.organization_id;
      x_mmti_rec.acct_period_id                 := l_mmt_rec.acct_period_id;
      x_mmti_rec.transaction_date               := l_mmt_rec.transaction_date;
      x_mmti_rec.transaction_type_id            := l_mmt_rec.transaction_type_id;
      x_mmti_rec.transaction_action_id          := l_mmt_rec.transaction_action_id;
      x_mmti_rec.transaction_quantity           := l_mmt_rec.transaction_quantity;
      x_mmti_rec.primary_quantity               := l_mmt_rec.primary_quantity;
      x_mmti_rec.secondary_transaction_quantity := l_mmt_rec.secondary_transaction_quantity;
      x_mmti_rec.secondary_uom_code             := l_mmt_rec.secondary_uom_code ;
      x_mmti_rec.distribution_account_id        := l_mmt_rec.distribution_account_id;
      x_mmti_rec.transaction_uom                := l_mmt_rec.transaction_uom;
      x_mmti_rec.subinventory_code              := l_mmt_rec.subinventory_code;
      x_mmti_rec.locator_id                     := l_mmt_rec.locator_id;

      x_mmti_rec.transaction_source_type_id     := l_mmt_rec.transaction_source_type_id;
      x_mmti_rec.transaction_source_name        := l_mmt_rec.transaction_source_name;
      x_mmti_rec.transaction_reference          := l_mmt_rec.transaction_reference;
      x_mmti_rec.reason_id                      := l_mmt_rec.reason_id;
       --x_mmti_rec.reservation_quantity    := l_mmt_rec.reservation_quantity;
      -- x_mmti_rec.transaction_sequence_id := l_mmt_rec.transaction_sequence_id;
      --x_mmti_rec.transaction_reference := l_mmt_rec.transaction_reference;

      -- construct mtl_transaction_lots_interface
      IF (l_mmln_tbl.COUNT > 0) THEN
         FOR i IN 1 .. l_mmln_tbl.COUNT LOOP
            x_mmli_tbl (i).last_update_date :=
                                              l_mmln_tbl (i).last_update_date;
            x_mmli_tbl (i).last_updated_by := l_mmln_tbl (i).last_updated_by;
            x_mmli_tbl (i).creation_date := l_mmln_tbl (i).creation_date;
            x_mmli_tbl (i).created_by := l_mmln_tbl (i).created_by;
            x_mmli_tbl (i).lot_number := l_mmln_tbl (i).lot_number;
            x_mmli_tbl (i).transaction_quantity :=
                                          l_mmln_tbl (i).transaction_quantity;
            x_mmli_tbl (i).primary_quantity :=
                                              l_mmln_tbl (i).primary_quantity;
            x_mmli_tbl (i).secondary_transaction_quantity :=
                                l_mmln_tbl (i).secondary_transaction_quantity;
         END LOOP;
      END IF;                                               --l_mmln_tbl.count

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END construct_mmti;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_mat_trans
   |
   | USAGE
   |    Gets all transactions from mmt based on material_detail_id and batch_id passed.
   |
   | ARGUMENTS
   |   p_mat_det_id -- material_detail_id passed of material
   |   p_batch_id -- batch_id to which the material belongs.
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |               x_mmt_tbl- gives back all transactions of the material
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |            09-Feb-06 Namit S. Bug4917213 Changed query for perf reasons.
   |  Swapna K Bug#8300015 Added p_phantom_line_id parameter and loaded the the
   |            phantom transactions also if the parameter is not null.
   |
   |  G. Muratore     19-MAR-2010   Bug 8751983
   |     Added p_order_by parameter to allow fetching of transactions in reverse trans order.
   +==========================================================================+ */
   PROCEDURE get_mat_trans (
      p_mat_det_id      IN              NUMBER
     ,p_batch_id        IN              NUMBER
     ,p_phantom_line_id IN              NUMBER DEFAULT NULL
     ,p_order_by        IN              NUMBER DEFAULT 1
     ,x_mmt_tbl         OUT NOCOPY      gme_common_pvt.mtl_mat_tran_tbl
     ,x_return_status   OUT NOCOPY      VARCHAR2)
   IS

-- Namit S. Bug4917213. Changed query to add hint to improve sharable memory.
-- Hint was provided by the apps perf team.
-- Pawan Kumar bug 5483071 added order by clause
-- do not change the order by clause it is done so that we reverse the outbound transaction first

      -- Bug 8751983 - Let's fetch the transactions in reverse order based on parameter value.
      CURSOR cur_get_trans (v_mat_det_id NUMBER, v_batch_id NUMBER,
                            v_txn_source_type NUMBER, v_pairs_reversal_type NUMBER)
      IS
        SELECT *
           FROM mtl_material_transactions mmt
          WHERE trx_source_line_id = v_mat_det_id
            AND transaction_source_id = v_batch_id
            AND transaction_source_type_id = v_txn_source_type
            AND NOT EXISTS ( SELECT /*+ no_unnest */
                        transaction_id1
                     FROM gme_transaction_pairs
                    WHERE transaction_id1 = mmt.transaction_id
                      AND pair_type = v_pairs_reversal_type)
            ORDER BY CASE p_order_by
                       when 1 then Row_Number() over(order by transaction_quantity)
                       when 2 then Row_Number() over(order by transaction_id DESC)
                     END;


      -- Bug 8751983 - Let's fetch the resource transaction in reverse order based on parameter value.
      CURSOR cur_get_all_trans (v_mat_det_id NUMBER,  v_batch_id NUMBER, v_phantom_line_id NUMBER,v_phantom_batch_id NUMBER,
                            v_txn_source_type NUMBER, v_pairs_reversal_type NUMBER)
      IS

        SELECT *  FROM
        ( SELECT *
           FROM mtl_material_transactions mmt
          WHERE trx_source_line_id = v_mat_det_id
            AND transaction_source_id = v_batch_id
            AND transaction_source_type_id = v_txn_source_type
            AND NOT EXISTS ( SELECT /*+ no_unnest */
                        transaction_id1
                     FROM gme_transaction_pairs
                    WHERE transaction_id1 = mmt.transaction_id
                      AND pair_type = v_pairs_reversal_type)

         UNION ALL

         SELECT *
           FROM mtl_material_transactions mmt
          WHERE trx_source_line_id = v_phantom_line_id
            AND transaction_source_id = v_phantom_batch_id
            AND transaction_source_type_id = v_txn_source_type
            AND NOT EXISTS ( SELECT /*+ no_unnest */
                        transaction_id1
                     FROM gme_transaction_pairs
                    WHERE transaction_id1 = mmt.transaction_id
                      AND pair_type = v_pairs_reversal_type))
            ORDER BY CASE p_order_by
                       when 1 then Row_Number() over(order by transaction_quantity)
                       when 2 then Row_Number() over(order by transaction_id DESC)
                     END;

      l_api_name    CONSTANT VARCHAR2 (30) := 'GET_MAT_TRANS';
      p_phantom_batch_id NUMBER;
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with mat/batch '||p_mat_det_id||'/'||p_batch_id);
      END IF;

      IF p_mat_det_id IS NOT NULL AND p_batch_id IS NOT NULL THEN
      /*Bug#8300015 Fetching the transactions along with the associated phantom material */
         IF p_phantom_line_id IS NOT NULL THEN
            SELECT batch_id INTO p_phantom_batch_id
            FROM gme_material_details
            WHERE material_detail_id = p_phantom_line_id;
           OPEN cur_get_all_trans (p_mat_det_id, p_batch_id,p_phantom_line_id,p_phantom_batch_id,
               gme_common_pvt.g_txn_source_type, gme_common_pvt.g_pairs_reversal_type);
           FETCH cur_get_all_trans
           BULK COLLECT INTO x_mmt_tbl;
           CLOSE cur_get_all_trans;
         ELSE
-- Namit S. Bug4917213.
           OPEN cur_get_trans (p_mat_det_id, p_batch_id,
               gme_common_pvt.g_txn_source_type, gme_common_pvt.g_pairs_reversal_type);
           FETCH cur_get_trans
           BULK COLLECT INTO x_mmt_tbl;
           CLOSE cur_get_trans;
         END IF;
      END IF;
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error  THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END get_mat_trans;


   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_lot_trans
   |
   | USAGE
   |    Gets all lot transactions from mmln for a given transaction_id.
   |
   | ARGUMENTS
   |   p_transaction_id --  transaction_id for which all lot info is required.
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |                x_mmln_tbl- all lot info for a given transaction_id.
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE get_lot_trans (
      p_transaction_id   IN              NUMBER
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_lot_trans (v_transaction_id NUMBER)
      IS
         SELECT *
           FROM mtl_transaction_lot_numbers
          WHERE transaction_id = v_transaction_id;

      l_api_name    CONSTANT VARCHAR2 (30) := 'GET_LOT_TRANS';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with transaction id '||p_transaction_id);

      END IF;

      IF p_transaction_id IS NOT NULL THEN
         OPEN cur_get_lot_trans (p_transaction_id);
         FETCH cur_get_lot_trans
         BULK COLLECT INTO x_mmln_tbl;
         CLOSE cur_get_lot_trans;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'lot count '
                             || x_mmln_tbl.COUNT);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error  THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END get_lot_trans;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   GME_PRE_PROCESS
   |
   | USAGE
   |    Gets all pre-process validations based on header_id
   |
   | ARGUMENTS
   |   p_transaction_hdr_id
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE gme_pre_process (
      p_transaction_hdr_id   IN              NUMBER
     ,x_return_status        OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_trans (v_hdr_id NUMBER)
      IS
         SELECT transaction_interface_id
           FROM mtl_transactions_interface
          WHERE transaction_header_id = v_hdr_id
            AND transaction_source_type_id = gme_common_pvt.g_txn_source_type
            AND wip_entity_type = gme_common_pvt.g_wip_entity_type_batch;

      l_return_status        VARCHAR2 (1)  := fnd_api.g_ret_sts_success;
      l_number_tab           gme_common_pvt.number_tab;
      no_transaction_found   EXCEPTION;
      l_api_name    CONSTANT VARCHAR2 (30)             := 'GME_PRE_PROCESS';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with p_transaction_hdr_id '||p_transaction_hdr_id);
      END IF;

      IF p_transaction_hdr_id IS NOT NULL THEN
         OPEN cur_get_trans (p_transaction_hdr_id);
         IF cur_get_trans%NOTFOUND THEN
            CLOSE cur_get_trans;
            gme_common_pvt.log_message ('GME_NO_TRANS_FOUND');
            RAISE fnd_api.g_exc_error;
         END IF;
         FETCH cur_get_trans
         BULK COLLECT INTO l_number_tab;
         CLOSE cur_get_trans;
      END IF;

      FOR i IN 1 .. l_number_tab.COUNT LOOP
        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'calling pre_process_val with transaction_id '||l_number_tab (i));
        END IF;
         pre_process_val (p_transaction_interface_id      => l_number_tab (i)
                         ,x_return_status                 => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      /* update mtl_transactions_interface
            set error_code = 'wip_mtlInterfaceProc_pub.processInterface()',
                error_explanation = l_errMessage,
                process_flag = wip_constants.mti_error
          where transaction_header_id = p_txnHdrID; */
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END gme_pre_process;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_returnable_qty
   |
   | USAGE
   |    Gets net quantity that can be returned from mmt based on the details passed
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |   p_lot_number - Lot number
   |   p_lot_control - 1 for plain 2 for lot control
   | RETURNS
   |   x_return_status S for success, U for unexpected
   |   x_available_qty  Quantity that can be returned.
   | HISTORY
   |   Created  20-Sep-05 Shrikant Nene
   |
   +==========================================================================+ */

   PROCEDURE get_returnable_qty (
      p_mmti_rec                IN          mtl_transactions_interface%ROWTYPE,
      p_lot_number              IN          VARCHAR2,
      p_lot_control             IN          NUMBER,
      x_available_qty           OUT NOCOPY  NUMBER,
      x_return_status           OUT NOCOPY  VARCHAR2
      ) IS

      CURSOR cur_plain_item (
         v_item_id           IN   NUMBER,
         v_organization_id   IN   NUMBER,
         v_revision          IN   VARCHAR2,
         v_batch_id          IN   NUMBER,
         v_mat_det_id        IN   NUMBER,
         v_trans_uom         IN   VARCHAR2
      ) IS
         SELECT   SUM (DECODE (v_trans_uom,
                            t.transaction_uom, transaction_quantity,
                            inv_convert.inv_um_convert (d.inventory_item_id,
                                                        gme_common_pvt.g_precision,
                                                        t.transaction_quantity,
                                                        t.transaction_uom,
                                                        v_trans_uom,
                                                        NULL,
                                                        NULL
                                                       )
                           )
                   )
          FROM mtl_material_transactions t, gme_material_details d
         WHERE t.organization_id = v_organization_id
           AND t.inventory_item_id = v_item_id
           AND t.transaction_source_id = v_batch_id
           AND t.trx_source_line_id = v_mat_det_id
           AND t.transaction_source_type_id = gme_common_pvt.g_txn_source_type
           AND t.trx_source_line_id = d.material_detail_id
           AND (t.revision IS NULL OR t.revision = v_revision)
      GROUP BY t.revision, t.inventory_item_id;

      CURSOR cur_lot_qty (
         v_lot_number        IN   VARCHAR2,
         v_item_id           IN   NUMBER,
         v_organization_id   IN   NUMBER,
         v_revision          IN   VARCHAR2,
         v_batch_id          IN   NUMBER,
         v_mat_det_id        IN   NUMBER,
         v_trans_uom         IN   VARCHAR2
      ) IS
         SELECT   lot_number,
                  SUM (DECODE (v_trans_uom,
                               m.transaction_uom, m.transaction_quantity,
                               inv_convert.inv_um_convert (d.inventory_item_id,
                                                           gme_common_pvt.g_precision,
                                                           m.transaction_quantity,
                                                           m.transaction_uom,
                                                           v_trans_uom,
                                                           NULL,
                                                           NULL
                                                          )
                              )
                      )
          FROM mtl_material_transactions m, mtl_transaction_lot_numbers l, gme_material_details d
         WHERE l.transaction_id = m.transaction_id
           AND m.trx_source_line_id = d.material_detail_id
           AND l.lot_number = v_lot_number
           AND l.inventory_item_id = v_item_id
           AND l.organization_id = v_organization_id
           AND l.transaction_source_id = v_batch_id
           AND m.trx_source_line_id = v_mat_det_id
           AND m.transaction_source_type_id = gme_common_pvt.g_txn_source_type
           -- Pawan Kumar added for checking of revision  bug 5451006- 5493370
           AND (m.revision IS NULL OR m.revision = v_revision)
      GROUP BY l.lot_number, l.inventory_item_id;

      l_lot_no                     VARCHAR2 (80);
      l_api_name          CONSTANT VARCHAR2 (30)          := 'GET_RETURNABLE_QTY';

    BEGIN
        -- Initially let us assign the return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':' || 'Entering');
        END IF;
        IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || 'p_lot_number: '
                               || p_lot_number
                               || ' p_lot_control code: '
                               || p_lot_control);
        END IF;
        IF p_lot_control = 1 THEN
           /* Plain Item */
           OPEN cur_plain_item (p_mmti_rec.inventory_item_id
                               ,p_mmti_rec.organization_id
                               ,p_mmti_rec.revision
                               ,p_mmti_rec.transaction_source_id
                               ,p_mmti_rec.trx_source_line_id
                               ,p_mmti_rec.transaction_uom);

           FETCH cur_plain_item
            INTO x_available_qty;

           IF cur_plain_item%NOTFOUND THEN
              x_available_qty := 0;
           END IF;

           CLOSE cur_plain_item;
        ELSE /* Lot control Item */
           OPEN cur_lot_qty (p_lot_number
                            ,p_mmti_rec.inventory_item_id
                            ,p_mmti_rec.organization_id
                            ,p_mmti_rec.revision
                            ,p_mmti_rec.transaction_source_id
                            ,p_mmti_rec.trx_source_line_id
                            ,p_mmti_rec.transaction_uom);

           FETCH cur_lot_qty
            INTO l_lot_no, x_available_qty;

           IF cur_lot_qty%NOTFOUND THEN
              x_available_qty := 0;
           END IF;

           CLOSE cur_lot_qty;
        END IF;
        IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                               || '.'
                               || l_api_name
                               || ':'
                               || 'Exiting with return status '
                               || x_return_status
                               || ' Available Qty '
                               || x_available_qty);
         END IF;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
    END get_returnable_qty;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   PRE_PROCESS_VAL
   |
   | USAGE
   |    Gets all transactions from mmt based on material_detail_id and batch_id passed.
   |
   | ARGUMENTS
   |   p_mmti_rec -- mtl_transaction_interface rowtype
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
    PROCEDURE pre_process_val (
      p_transaction_interface_id   IN              NUMBER
     ,x_return_status              OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_trans_detail (v_trans_inter_id NUMBER)
      IS
         SELECT *
           FROM mtl_transactions_interface
          WHERE transaction_interface_id = v_trans_inter_id;


      CURSOR cur_get_item_rec (v_item_id NUMBER, v_org_id NUMBER)
      IS
         SELECT *
           FROM mtl_system_items_b
          WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;
       CURSOR Cur_associated_step(v_matl_dtl_id NUMBER)
      IS
        SELECT step_status
        FROM gme_batch_steps s, gme_batch_step_items i
        WHERE s.batchstep_id = i.batchstep_id
        AND i.material_detail_id = v_matl_dtl_id;

      CURSOR cur_lot_input (v_trans_inter_id NUMBER)
      IS
         SELECT   lot_number, SUM (transaction_quantity) l_mtli_lot_qty
             FROM mtl_transaction_lots_interface
            WHERE transaction_interface_id = v_trans_inter_id
         GROUP BY lot_number;

      l_mmti_rec                   mtl_transactions_interface%ROWTYPE;
      l_mmli_tbl                   gme_common_pvt.mtl_trans_lots_inter_tbl;
      l_mat_dtl_rec                gme_material_details%ROWTYPE;
      l_batch_hdr_rec              gme_batch_header%ROWTYPE;
      l_item_rec                   mtl_system_items_b%ROWTYPE;
      l_available_qty              NUMBER;
      l_step_status                NUMBER;
      l_rel_type                   NUMBER;
      l_return_status              VARCHAR2(1);
      item_not_found               EXCEPTION;
      not_valid_trans              EXCEPTION;
      lot_val_err                  EXCEPTION;
      l_api_name          CONSTANT VARCHAR2 (30)          := 'PRE_PROCESS_VAL';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      OPEN cur_trans_detail (p_transaction_interface_id);

      FETCH cur_trans_detail
       INTO l_mmti_rec;

      CLOSE cur_trans_detail;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.transaction_header_id: '||l_mmti_rec.transaction_header_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.subinventory_code: '||l_mmti_rec.subinventory_code);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.transaction_uom: '||l_mmti_rec.transaction_uom);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.inventory_item_id: '||l_mmti_rec.inventory_item_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.trx_source_line_id: '||l_mmti_rec.trx_source_line_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.revision: '||l_mmti_rec.revision);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.transaction_source_id: '||l_mmti_rec.transaction_source_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.locator_id: '||l_mmti_rec.locator_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'l_mmti_rec.transaction_type_id: '||l_mmti_rec.transaction_type_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_transaction_interface_id: '||p_transaction_interface_id);
      END IF;

      IF l_mmti_rec.transaction_source_id IS NOT NULL THEN
         l_batch_hdr_rec.batch_id := l_mmti_rec.transaction_source_id;

         IF NOT gme_batch_header_dbl.fetch_row
                                          (p_batch_header      => l_batch_hdr_rec
                                          ,x_batch_header      => l_batch_hdr_rec) THEN
            RAISE fnd_api.g_exc_error;
         END IF;-- batch fetch
       ELSE
         RAISE fnd_api.g_exc_error;
       END IF;  -- transaction_source_id IS NOT NULL

      IF l_batch_hdr_rec.update_inventory_ind = 'Y' THEN
         IF l_mmti_rec.trx_source_line_id IS NOT NULL THEN
            l_mat_dtl_rec.material_detail_id := l_mmti_rec.trx_source_line_id;

            IF NOT gme_material_details_dbl.fetch_row
                                         (p_material_detail      => l_mat_dtl_rec
                                         ,x_material_detail      => l_mat_dtl_rec) THEN
               RAISE fnd_api.g_exc_error;
            END IF; -- material fetch

        ELSE
            RAISE fnd_api.g_exc_error;
        END IF;       -- trx_source_line_id IS NOT NULL
        IF gme_common_pvt.g_batch_status_check = fnd_api.g_true THEN
           IF l_batch_hdr_rec.batch_status NOT IN (2, 3) THEN
              gme_common_pvt.log_message ('GME_INVALID_BATCH_STATUS');
              RAISE fnd_api.g_exc_error;
           END IF;
           -- Check for step status in case the item is associated to a step.
           l_rel_type :=
                 gme_common_pvt.is_material_auto_release
                                                  (l_mat_dtl_rec.material_detail_id);
           IF (   l_rel_type = gme_common_pvt.g_mtl_autobystep_release ) THEN            -- /*3*/
             OPEN Cur_associated_step(l_mat_dtl_rec.material_detail_id);
             FETCH Cur_associated_step INTO l_step_status;
             CLOSE Cur_associated_step;
             IF l_step_status NOT IN (2,3) THEN
                gme_common_pvt.log_message ('GME_API_INVALID_STEP_STATUS');
              RAISE fnd_api.g_exc_error;
             END IF;
           END IF; -- IF (   l_rel_type = gme_common_pvt.g_mtl_autobystep_release ) THEN
           -- check for item release type for products
           IF (l_rel_type = gme_common_pvt.g_mtl_auto_release )
            AND l_mat_dtl_rec.line_type IN (1,2)
            AND l_mat_dtl_rec.phantom_line_id IS NULL   THEN
                IF l_batch_hdr_rec.batch_status <> 3 THEN
                   gme_common_pvt.log_message('GME_INVALID_BATCH_STATUS');
                   RAISE fnd_api.g_exc_error;
                END IF;
           END IF;
         END IF;  -- gme_common_pvt.g_batch_status_check
         IF l_mmti_rec.transaction_type_id IN
                    (gme_common_pvt.g_ing_issue, gme_common_pvt.g_ing_return) THEN
            IF l_mat_dtl_rec.line_type <> -1 THEN
               /* Bug 5141394 Changed message */
               gme_common_pvt.log_message ('GME_LINE_TYPE_TXN_TYPE_DIFF');
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF l_mmti_rec.transaction_type_id IN
                 (gme_common_pvt.g_prod_completion
                 ,gme_common_pvt.g_prod_return) THEN
            IF l_mat_dtl_rec.line_type <> 1 THEN
            	/* Bug 5141394 Changed message */
                 gme_common_pvt.log_message ('GME_LINE_TYPE_TXN_TYPE_DIFF');
               RAISE fnd_api.g_exc_error;
            END IF;
         ELSIF l_mmti_rec.transaction_type_id IN
                 (gme_common_pvt.g_byprod_completion
                 ,gme_common_pvt.g_byprod_return) THEN
            IF l_mat_dtl_rec.line_type <> 2 THEN
	       /* Bug 5141394 Changed message */
	       --RLNAGARA Bug6873185 Moved below line which was setting message name inside the IF condition.
               gme_common_pvt.log_message ('GME_LINE_TYPE_TXN_TYPE_DIFF');
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- check for phantom
         IF l_mat_dtl_rec.phantom_line_id IS NOT NULL THEN
            IF l_mmti_rec.transaction_header_id <>
                                       gme_common_pvt.g_transaction_header_id THEN
               gme_common_pvt.log_message ('GME_PHANTOM_NO_RETURN');
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- get the item propertites
         OPEN cur_get_item_rec (l_mmti_rec.inventory_item_id, l_mmti_rec.organization_id);
         FETCH cur_get_item_rec INTO l_item_rec;
         IF cur_get_item_rec%NOTFOUND THEN
           CLOSE cur_get_item_rec;
           gme_common_pvt.log_message ('PM_INVALID_ITEM');
           IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
             gme_debug.put_line('Item cursor fetch no record in mtl_system_items_b: ');
             gme_debug.put_line('inventory_item_id = '|| TO_CHAR (l_mmti_rec.inventory_item_id));
             gme_debug.put_line('organization_id = '|| TO_CHAR (l_mmti_rec.organization_id));
           END IF;
           RAISE item_not_found;
         END IF;
         CLOSE cur_get_item_rec;
         IF (g_debug <= gme_debug.g_log_statement) THEN
           gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item lot_control Code: '|| l_item_rec.lot_control_code);
           gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item loct_control Code: '|| l_item_rec.location_control_code);
         END IF;

         /* Bug 5358129 for ingredients lots should exist */
         IF (l_mat_dtl_rec.line_type = gme_common_pvt.g_line_type_ing AND l_mat_dtl_rec.phantom_type = 0 AND l_item_rec.lot_control_code = 2) THEN
           FOR get_lots IN (SELECT DISTINCT lot_number FROM mtl_transaction_lots_interface WHERE transaction_interface_id = p_transaction_interface_id) LOOP
      	     gme_transactions_pvt.validate_lot_for_ing(p_organization_id   => l_mmti_rec.organization_id,
                                                       p_inventory_item_id => l_mmti_rec.inventory_item_id,
                                                       p_lot_number        => get_lots.lot_number,
                                                       x_return_status     => l_return_status);
             IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE lot_val_err;
             END IF;
           END LOOP;
         END IF;

         -- if return transaction then check qty was issued and return not more than issued qty
         IF l_mmti_rec.transaction_type_id IN
               (gme_common_pvt.g_byprod_return
               ,gme_common_pvt.g_prod_return
               ,gme_common_pvt.g_ing_return) THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||
                  'Return transaction for : '||l_mmti_rec.transaction_type_id);

            END IF;
            IF l_item_rec.lot_control_code = 1 THEN
              IF (g_debug <= gme_debug.g_log_statement) THEN
                 gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || ':'
                                   || 'Item is  NOT lot_control: '
                                   || l_item_rec.lot_control_code);
               END IF;
               get_returnable_qty(
                   p_mmti_rec      => l_mmti_rec
                  ,p_lot_number    => NULL
                  ,p_lot_control   => l_item_rec.lot_control_code
                  ,x_available_qty => l_available_qty
                  ,x_return_status => x_return_status);

               IF x_return_Status <> fnd_api.g_ret_sts_success THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
               IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'Returning Qty '
                                      || l_mmti_rec.transaction_quantity);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'Available to Return '
                                      || l_available_qty);
               END IF;

               IF ABS (l_available_qty) < ABS (l_mmti_rec.transaction_quantity) THEN
                  gme_common_pvt.log_message ('GME_QTY_LESS_THEN_ISSUED');
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE /* Lot Control */
               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || ':'
                                      || 'Item is lot control: '
                                      || l_item_rec.lot_control_code);
               END IF;

               FOR get_rec IN cur_lot_input (p_transaction_interface_id) LOOP
                  -- first get the qty from the mtln table
                  get_returnable_qty(
                      p_mmti_rec      => l_mmti_rec
                     ,p_lot_number    => get_rec.lot_number
                     ,p_lot_control   => l_item_rec.lot_control_code
                     ,x_available_qty => l_available_qty
                     ,x_return_status => x_return_status);

                  IF x_return_Status <> fnd_api.g_ret_sts_success THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
                  IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'Returning qty: '|| get_rec.l_mtli_lot_qty);
                     gme_debug.put_line (   g_pkg_name
                                         || '.'
                                         || l_api_name
                                         || ':'
                                         || 'Available to Return '
                                         || l_available_qty);
                  END IF;

                  IF ABS (l_available_qty) < ABS (get_rec.l_mtli_lot_qty) THEN
                     gme_common_pvt.log_message ('GME_QTY_LESS_THEN_ISSUED');
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END LOOP;
            END IF; /* IF l_item_rec.lot_control_code = 1 THEN */
         END IF; /* IF transaction_type_id in RETURNS */
      END IF;  /* update_inventory_ind = 'Y' */

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN lot_val_err THEN
      	x_return_status := l_return_status;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         gme_transactions_pvt.gme_txn_message
                   (p_api_name                      => l_api_name
                   ,p_transaction_interface_id      => p_transaction_interface_id
                   );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;

         gme_transactions_pvt.gme_txn_message
                    (p_api_name                      => l_api_name
                    ,p_transaction_interface_id      => p_transaction_interface_id
                   );

   END pre_process_val;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   gme_txn_message
   |
   | USAGE
   |
   |
   | ARGUMENTS
   |
   |
   | RETURNS
   |
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE gme_txn_message (
      p_api_name                   IN              VARCHAR2
     ,p_transaction_interface_id   IN              VARCHAR2
     )
   IS
      l_transaction_interface_id   NUMBER;
      x_message_count              NUMBER;
      x_message_list               VARCHAR2 (2000);
      l_errm                       VARCHAR2 (2000) := SQLERRM;
      l_api_name          CONSTANT VARCHAR2 (30)   := 'gme_txn_message';
   BEGIN
      -- Initially let us assign the return status to success

      l_transaction_interface_id := p_transaction_interface_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      -- based on message  call count and get
      gme_common_pvt.count_and_get (x_count        => x_message_count
                                   ,p_encoded      => fnd_api.g_false
                                   ,x_data         => x_message_list);

      UPDATE mtl_transactions_interface
         SET ERROR_CODE = g_pkg_name || '.' || p_api_name
            ,error_explanation = NVL (x_message_list, l_errm)
            ,process_flag = 3       -- we can make it a constant in gme common
       WHERE transaction_interface_id = l_transaction_interface_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting'
                             );
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;
   END gme_txn_message;

    /* +==========================================================================+
   | PROCEDURE NAME
   |   gme_post_process
   |
   | USAGE
   |
   |
   | ARGUMENTS
   |   p_transaction_id
   |
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |   5176319  20-Jun-06 Namit S. Added call to gme_unrelease_batch_pvt.create_matl_resv_pplot
   |      and gme_common_pvt.reset_txn_hdr_tbl.
   |   Bug 5763818   28-Feb-2007 Archana Mundhe Do not update actual qty if
   |       the material detail line has been deleted.
   |   Bug 8300015 Changed the logic of updating the phantom transactions.
   |   Bug back port 6997483   Srinivasulu Puri Added parameter transaction_id
   |       to gme_unrelease_batch_pvt.create_matl_resv_pplot.
   +==========================================================================+ */
   PROCEDURE gme_post_process (
      p_transaction_id   IN              NUMBER
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS
      CURSOR cur_get_trans (v_transaction_id NUMBER)
      IS
         SELECT t.transaction_id, t.transaction_source_id, l.lot_number
               ,t.trx_source_line_id, t.source_line_id, t.transaction_type_id,
               t.transaction_reference, t.inventory_item_id
               , t.organization_id ,t.transaction_quantity
           FROM mtl_material_transactions t, mtl_transaction_lot_numbers l
          WHERE t.transaction_id = l.transaction_id(+)
                AND t.transaction_id = v_transaction_id;
     /* Bug 5903208 Modified cursor so it gets 1 lot at a time for GMF needs */
     CURSOR cur_mat_sum(v_organization_id   IN   NUMBER
                       ,v_batch_id          IN   NUMBER
                       ,v_mat_det_id        IN   NUMBER) IS
       SELECT a.transaction_id, a.lot_number, a.doc_qty, SUM(a.doc_qty) over() mtl_qty
       FROM   (SELECT t.transaction_id, tl.lot_number,
               DECODE(d.dtl_um,t.transaction_uom, NVL(tl.transaction_quantity,t.transaction_quantity),
               Inv_Convert.inv_um_convert(d.inventory_item_id,tl.lot_number,t.organization_id, 5
                                         ,NVL(tl.transaction_quantity,t.transaction_quantity), t.transaction_uom
                                         ,d.dtl_um, NULL, NULL)) doc_qty
               FROM  mtl_material_transactions t , gme_material_details d, mtl_transaction_lot_numbers tl
               WHERE t.organization_id = v_organization_id
                     AND t.transaction_source_id = v_batch_id
                     AND t.trx_source_line_id = v_mat_det_id
                     AND t.transaction_source_type_id = gme_common_pvt.g_txn_source_type
                     AND t.trx_source_line_id = d.material_detail_id
         AND tl.transaction_id(+) = t.transaction_id) a;

      CURSOR cur_lot_qty (
         v_lot_number        IN   VARCHAR2
        ,v_item_id           IN   NUMBER
        ,v_organization_id   IN   NUMBER
        ,v_batch_id          IN   NUMBER
        ,v_mat_det_id        IN   NUMBER)
      IS
         SELECT   lot_number, SUM (l.transaction_quantity)
             FROM mtl_material_transactions m, mtl_transaction_lot_numbers l
            WHERE l.transaction_id = m.transaction_id
              AND l.lot_number = v_lot_number
              AND l.inventory_item_id = v_item_id
              AND l.organization_id = v_organization_id
              AND l.transaction_source_id = v_batch_id
              AND m.trx_source_line_id = v_mat_det_id
              AND m.transaction_source_type_id =
                                              gme_common_pvt.g_txn_source_type
         GROUP BY l.lot_number, l.inventory_item_id;

      -- Bug 5763818
      CURSOR check_event_batchmtl_removed (
            v_transaction_source_id IN NUMBER
                ,v_trx_source_line_id IN NUMBER)
      IS
      select count(1)
      from GME_ERES_GTMP
      where event_name = 'oracle.apps.gme.batchmtl.removed'
      and event_key  = v_transaction_source_id||'-'||v_trx_source_line_id;

      x_msg_count               NUMBER;
      x_msg_data                VARCHAR2(2000);
      l_return_status           VARCHAR2(1) ;
      l_transaction_id          NUMBER;
      l_dispense_id             NUMBER;
      l_transaction_source_id   NUMBER;
      l_transaction_type_id     NUMBER;
      l_lot_number              VARCHAR2 (80);
      l_transaction_reference   VARCHAR2 (80);
      l_trx_source_line_id      NUMBER;
      l_source_line_id          NUMBER;
      l_inventory_item_id       NUMBER;
      l_organization_id         NUMBER;
      l_actual_qty              NUMBER;
      l_gme_pairs_rec           gme_transaction_pairs%ROWTYPE;
      l_mat_dtl_rec             gme_material_details%ROWTYPE;
      l_api_name       CONSTANT VARCHAR2 (30)            := 'gme_post_process';
      l_exists                   NUMBER; -- Bug 5763818
      transfer_error            EXCEPTION;   -- B4944024
      dispense_error            EXCEPTION;

      l_gme_pairs_rec_upd           gme_transaction_pairs%ROWTYPE;
      l_transaction_quantity       NUMBER;
      l_transaction_quantity_upd   NUMBER;


   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with trans id: '||p_transaction_id);

      END IF;

      l_transaction_id := p_transaction_id;
      -- based on this transaction_id get all transactions details
      OPEN cur_get_trans (l_transaction_id);

      FETCH cur_get_trans
       INTO l_transaction_id, l_transaction_source_id, l_lot_number
           ,l_trx_source_line_id, l_source_line_id,l_transaction_type_id,
            l_transaction_reference ,l_inventory_item_id, l_organization_id,l_transaction_quantity;

      CLOSE cur_get_trans;

      -- nsinghi bug#5176319
      /* Re-Create Material Reservation during un-release batch/step. */
      gme_unrelease_batch_pvt.create_matl_resv_pplot (
    p_material_dtl_id  => l_trx_source_line_id,
    p_transaction_id   => l_transaction_id,
    x_return_status    => x_return_status);

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_id: '
                             || l_transaction_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction_source_id: '
                             || l_transaction_source_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'trx_source_line_id: '
                             || l_trx_source_line_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'source_line_id: '
                             || l_source_line_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'inventory_item_id: '
                             || l_inventory_item_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'transaction refernce: '
                             || l_transaction_reference);
      END IF;

      IF l_source_line_id <> -99 THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'for inserting reverse transaction_id: '
                                || l_transaction_id);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'for inserting reverse source_line_id: '
                                || l_source_line_id);
         END IF;

         -- UPDATE transactions pair table for the reversal transaction
         UPDATE gme_transaction_pairs
            SET transaction_id2 = l_transaction_id
          WHERE batch_id = l_transaction_source_id
            AND material_detail_id = l_trx_source_line_id
            AND transaction_id1 = l_source_line_id
            AND pair_type = gme_common_pvt.g_pairs_reversal_type;
         -- Now insert a reverse record
         INSERT INTO gme_transaction_pairs
                     (batch_id, material_detail_id
                     ,transaction_id1, transaction_id2
                     ,pair_type)
              VALUES (l_transaction_source_id, l_trx_source_line_id
                     ,l_transaction_id, l_source_line_id
                     ,gme_common_pvt.g_pairs_reversal_type);

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'after inserting reverse transaction_id: '
                                || l_transaction_id);
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'after inserting reverse source_line_id: '
                                || l_source_line_id);
         END IF;
      END IF;  -- l_source_line_id

      -- for transaction pairs
      IF l_transaction_reference IS NOT NULL THEN
          l_mat_dtl_rec.material_detail_id := l_trx_source_line_id ;
         IF NOT gme_material_details_dbl.fetch_row
                                         (p_material_detail      => l_mat_dtl_rec
                                         ,x_material_detail      => l_mat_dtl_rec) THEN
               RAISE fnd_api.g_exc_error;
         END IF;
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line
                         (   g_pkg_name
                          || '.'
                          || l_api_name
                          || ':'
                          || 'for inserting phantom l_transaction_reference: '
                          || l_transaction_reference);
         END IF;


        IF l_mat_dtl_rec.phantom_line_id IS NOT NULL THEN
             IF (g_debug <= gme_debug.g_log_statement) THEN
                gme_debug.put_line
                       (   g_pkg_name
                        || '.'
                        || l_api_name
                        || '.'
                        || 'update row -phantom in pairs having l_trans_ref: '
                        || l_transaction_reference);
                gme_debug.put_line
                            (   g_pkg_name
                             || '.'
                             || l_api_name
                             || '.'
                             || 'update row-phantom in pairs with l_trans_ID: '
                             || l_transaction_id);
                END IF;
           /* Added the below loop to update the transaction only if it matches with the existing transactions
                and with the qty and opposite sign */
          FOR l_gme_pairs_rec_upd in (select * from gme_transaction_pairs where transaction_id2 =  l_transaction_reference)
          LOOP
            SELECT transaction_quantity INTO l_transaction_quantity_upd
            FROM mtl_material_transactions t
            WHERE t.transaction_id = l_gme_pairs_rec_upd.transaction_id1;

            IF (l_transaction_quantity_upd = (-1) *l_transaction_quantity )AND
               (l_mat_dtl_rec.phantom_line_id = l_gme_pairs_rec_upd.material_detail_id) THEN
              UPDATE gme_transaction_pairs
              SET transaction_id2 = l_transaction_id
              WHERE transaction_id1 = l_gme_pairs_rec_upd.transaction_id1
              AND pair_type = gme_common_pvt.g_pairs_phantom_type;
            END IF;
          END LOOP;
          BEGIN
            SELECT *
              INTO l_gme_pairs_rec
              FROM gme_transaction_pairs
             WHERE transaction_id2 = l_transaction_id
             AND pair_type = gme_common_pvt.g_pairs_phantom_type;

             IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line
                                 (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || '.'
                                  || 'after update row -phantom l_trans_id1: '
                                  || l_gme_pairs_rec.transaction_id1);
               gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || '.'
                                   || 'after update row-phantom l_trans_ID2: '
                                   || l_gme_pairs_rec.transaction_id1);
                 gme_debug.put_line
                                (   g_pkg_name
                                 || '.'
                                 || l_api_name
                                 || '.'
                                 || 'insert row- after update -transaction_id1: '
                                 || l_gme_pairs_rec.transaction_id1);
                  gme_debug.put_line
                                 (   g_pkg_name
                                  || '.'
                                  || l_api_name
                                  || '.'
                                  || 'insert row- after update -transaction_id2: '
                                  || l_gme_pairs_rec.transaction_id2);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'insert row- after update -batch_id:'
                                      || l_transaction_source_id);
                  gme_debug.put_line (   g_pkg_name
                                   || '.'
                                   || l_api_name
                                   || '.'
                                   || 'insert row- after update -mat_det_id: '
                                   || l_trx_source_line_id);
              END IF; -- for debug

            INSERT INTO gme_transaction_pairs
                        (batch_id, material_detail_id
                        ,transaction_id1, transaction_id2
                        ,pair_type)
                 VALUES (l_transaction_source_id, l_trx_source_line_id
                        ,l_transaction_id, l_gme_pairs_rec.transaction_id1
                        ,gme_common_pvt.g_pairs_phantom_type);


            EXCEPTION
               WHEN NO_DATA_FOUND THEN
               IF (g_debug <= gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'No_data_found');
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'insert row-transaction_id1: '
                                      || l_transaction_id);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'insert row-transaction_id2: '
                                      || l_transaction_reference);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'insert row-batch_id: '
                                      || l_transaction_source_id);
                  gme_debug.put_line (   g_pkg_name
                                      || '.'
                                      || l_api_name
                                      || '.'
                                      || 'insert row-material_detail_id: '
                                      || l_trx_source_line_id);
               END IF;

               --INSERT a new row
               INSERT INTO gme_transaction_pairs
                           (batch_id, material_detail_id
                           ,transaction_id1, transaction_id2
                           ,pair_type)
                    VALUES (l_transaction_source_id, l_trx_source_line_id
                           ,l_transaction_id, l_transaction_reference
                           ,gme_common_pvt.g_pairs_phantom_type);
               END;
           ELSE
            l_dispense_id := l_transaction_reference ;
            -- make a call to GMO for informing about dispense_id
                IF  l_mat_dtl_rec.dispense_ind = 'Y' THEN
                   IF l_transaction_type_id = gme_common_pvt.g_ing_issue THEN
                        -- For consume
                    GMO_DISPENSE_GRP.CHANGE_DISPENSE_STATUS
                   (p_api_version       => 1.0,
                    p_init_msg_list     => 'F',
                    p_commit            => 'F',
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_dispense_id       => l_dispense_id,
                    p_status_code       => 'CNSUMED',
                    p_transaction_id    => l_transaction_id
                    ) ;
                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       RAISE dispense_error;
                    END IF;
                  ELSE
                        -- unconsume

                        GMO_DISPENSE_GRP.CHANGE_DISPENSE_STATUS
                   (p_api_version       => 1.0,
                    p_init_msg_list     => 'F',
                    p_commit            => 'F',
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data ,
                    p_dispense_id       => l_dispense_id,
                    p_status_code       => 'REVRDISP' ,
                    p_transaction_id    => l_transaction_id
                    ) ;
                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       RAISE dispense_error;
                    END IF;
                  END IF;
                END IF ; -- dispense_ind
            END IF; -- if phantom_line_id is not null
          END IF; -- transaction_refernce is not null

    -- Bug 5763818
    -- Open cursor to fetch event name and event key from gme_eres_gmtp
    -- IF event name is oracle.apps.gme.batchmtl.removed then do not process
    OPEN check_event_batchmtl_removed (l_transaction_source_id,
                                       l_trx_source_line_id);
    FETCH check_event_batchmtl_removed INTO l_exists;
    CLOSE check_event_batchmtl_removed;

    IF (g_debug <= gme_debug.g_log_statement) THEN
       gme_debug.put_line (g_pkg_name||'.'||l_api_name||': '||'l_exists =  '||
                           TO_CHAR (l_exists));
    END IF;

    -- Bug 5763818
    -- Do not update the actual qty if the line has been deleted.
    IF (l_exists = 0) THEN

      -- get the total quantity for actaul qty update of material detail line
      l_mat_dtl_rec.material_detail_id := l_trx_source_line_id;

      IF NOT gme_material_details_dbl.fetch_row
                                          (p_material_detail      => l_mat_dtl_rec
                                          ,x_material_detail      => l_mat_dtl_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

     IF (g_debug <= gme_debug.g_log_statement) THEN
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||' mat_id '|| l_mat_dtl_rec.material_detail_id );
      gme_debug.put_line (g_pkg_name||'.'||l_api_name||':'||' DTL_UM '|| l_mat_dtl_rec.dtl_um );

     END IF;
      --sum for material_detail line
     /* Bug 5903208 Instead of directly getting sum now we get 1 lot at a time and also the sum */
     FOR get_rec IN cur_mat_sum(l_organization_id, l_transaction_source_id, l_trx_source_line_id) LOOP
       l_actual_qty := get_rec.mtl_qty;
       p_qty_tbl(get_rec.transaction_id||'@'||get_rec.lot_number).doc_qty := get_rec.doc_qty;
     END LOOP;

      -- Now update the qty to material_detail
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':Actual Quantity '
                             || l_actual_qty);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ': TRX_SOURCE_LINE_ID '
                             || l_trx_source_line_id);
      END IF;

      l_mat_dtl_rec.actual_qty := ABS (l_actual_qty);

      IF NOT gme_material_details_dbl.update_row
                                           (p_material_detail      => l_mat_dtl_rec) THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      -- B4944024 BEGIN
      -- At yield, any reservations against PROD must transfer to a supply source of Inventory
      -- In this way, the newly generated inventory is re-secured to the demand source
      -- ======================================================================================
      -- Pawan Kumar bug 5483071 added check for transaction refernce and source_line_id
     -- THis done so that we donot try to invoke this for reversal of wip return
     -- dispense is not a issue as it is only for ingredients
      IF l_mat_dtl_rec.line_type <> -1 AND
         l_transaction_type_id = gme_common_pvt.g_prod_completion
         AND l_transaction_reference IS NULL
         --  Pawan Kumar add bug 5709186
         -- in case transaction added from transaction form, l_source_line_id is null.
         AND nvl(l_source_line_id, -99) < 0 THEN

          IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' Invoke transfer_reservation_to_inv ');
          END IF;
        GME_SUPPLY_RES_PVT.transfer_reservation_to_inv (
           p_matl_dtl_rec   =>  l_mat_dtl_rec
          ,p_transaction_id =>  p_transaction_id
          ,x_message_count  =>  x_msg_count
          ,x_message_list   =>  x_msg_data
          ,x_return_status  =>  x_return_status);

        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ' transfer_reservation_to_inv returns '
                             || x_return_status);
        END IF;
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE transfer_error; -- B4944024
        END IF;
      END IF;
      -- B4944024 END

      -- Now check for negative qty
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   END IF; -- l_exists = 0
   EXCEPTION
       WHEN dispense_error THEN

         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;
   END gme_post_process;


/* +==========================================================================+
   | PROCEDURE NAME
   |    purge_trans_pairs
   |
   | USAGE
   |
   |
   | ARGUMENTS
   |   p_batch_id
   |   p_material_detail_id
   |
   | RETURNS
   |   returns via x_status OUT parameters
   |
   | HISTORY
   |   Created  02-Feb-05 Pawan Kumar
   |
   +==========================================================================+ */
   PROCEDURE purge_trans_pairs (
      p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2)
   IS
      l_batch_id             NUMBER;
      l_material_detail_id   NUMBER;
      l_api_name    CONSTANT VARCHAR2 (30) := 'purge_trans_pairs';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF p_batch_id IS NULL AND p_material_detail_id IS NULL THEN
         gme_common_pvt.log_message ('GME_INVALID_FIELD'
                                    ,'FIELD'
                                    ,'p_batch_id');
         RAISE fnd_api.g_exc_error;
      END IF;

      l_batch_id := p_batch_id;
      l_material_detail_id := p_material_detail_id;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'batch_id:'
                             || l_batch_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'material_detail_id:'
                             || l_material_detail_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         DELETE FROM gme_transaction_pairs
               WHERE batch_id = l_batch_id;
      ELSIF l_material_detail_id IS NOT NULL THEN
         DELETE FROM gme_transaction_pairs
               WHERE material_detail_id = l_material_detail_id;
      ELSE
         DELETE FROM gme_transaction_pairs
               WHERE batch_id = l_batch_id
                 AND material_detail_id = l_material_detail_id;
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF g_debug <= gme_debug.g_log_unexpected THEN
            gme_debug.put_line (   'When others exception in '
                                || g_pkg_name
                                || '.'
                                || l_api_name
                                || ' Error is '
                                || SQLERRM);
         END IF;
   END purge_trans_pairs;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   Process_transactions
   |
   | USAGE
   |   This is the interface procedure to the Inventory Transaction
   |   Manager to validate and process a batch of material transaction
   |   interface records
   |
   | ARGUMENTS
   |   p_api_version API Version of this procedure. Current version is 1.0
   |
   |   p_commit Indicates whether to commit the changes after successful processing
   |   p_validation_level Indicates whether or not to perform a full validation
   |   x_return_status Returns the status to indicate success or failure of execution
   |   x_msg_count Returns number of error message in the error message stack in case of failure
   |   x_msg_data Returns the error message in case of failure
   |   x_trans_count The count of material transaction interface records processed.
   |   p_table Source of transaction records with value 1 of material transaction interface table and value 2 of material transaction temp table
   |   p_header_id Transaction header id DEFAULT gme_common_pvt.get_txn_header_id
   |
   | RETURNS
   |   returns via x_ OUT parameters
   |
   | HISTORY
   |   Created  07-Mar-05 Jalaj Srivastava
   |    26-JUL-2007 Swapna Bug#6266714
   |    Added condition to check the transaction source type in the for loop query.
   |    26-JUL-2007 Swapna Bug#6685680
   |    Added call to gme_common_pvt.log message to log the actual error message which we can
   |    retrieve using gme_common_pvt.count_and_get from the wraper apis.
   |
   |    10-MAR-2009 Hari Luthra BUG # 6335682
   |    Added condition gtp.pair_type(+) = 1 to avoid duplicate rows in the for loop while creation
   |    of layers so as to handle the transactions for phantom batches.
   |    18-MAR-2009 Parag Kanetkar Bug 8347011 base bug 8219507 Removed mtln join before calling
   |    layers API.
   |
   |    26-MAY-2009 G. Muratore   Bug 8453485
   |       Added dynamically derived column rev_order_column to help us in order by clause.
   |       This will aid in handling Product Yield reversals first for layer sequencing for GMF.
   +==========================================================================+ */
   /* Bug 5255959 added p_clear_qty_cache parameter */
   PROCEDURE process_transactions (
      p_api_version        IN              NUMBER := 1
     ,p_init_msg_list      IN              VARCHAR2 := fnd_api.g_false
     ,p_commit             IN              VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN              NUMBER
            := fnd_api.g_valid_level_full
     ,p_table              IN              NUMBER := 2
     ,p_header_id          IN              NUMBER
            := gme_common_pvt.get_txn_header_id
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_trans_count        OUT NOCOPY      NUMBER
     --Bug#5584699 Changed variable from boolean to varchar2
     ,p_clear_qty_cache    IN              VARCHAR2 := fnd_api.g_true)
     --,p_clear_qty_cache    IN              BOOLEAN DEFAULT TRUE)
   IS

   --bug 7720970 kbanddyo added join error_explanation IS NOT NULL for both the cursors below

      CURSOR get_error_int
      IS
         SELECT ERROR_CODE, error_explanation
           FROM mtl_transactions_interface
          WHERE transaction_header_id =gme_common_pvt.g_transaction_header_id
          AND error_explanation IS NOT NULL;

      CURSOR get_error_temp
      IS
         SELECT ERROR_CODE, error_explanation
           FROM mtl_material_transactions_temp
          WHERE transaction_header_id =gme_common_pvt.g_transaction_header_id
          AND error_explanation IS NOT NULL;

      l_api_name   CONSTANT VARCHAR2 (30) := 'PROCESS_TRANSACTIONS';
      l_return              NUMBER;
      l_trans_rec  GMF_LAYERS.TRANS_REC_TYPE;
   BEGIN
      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      /* Jalaj Srivastava Bug 5109154
         if p_table is MMTT then
         free the quantity tree */
      /* Bug 5255959 added p_clear_qty_cache condition */
      --Bug#5584699
      IF (p_table = 2 AND p_clear_qty_cache = fnd_api.g_true) THEN
        IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                          (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ':'
                           || 'Calling inv_quantity_tree_pub.clear_quantity_cache. p_table is MMTT');
        END IF;
        inv_quantity_tree_pub.clear_quantity_cache;
      END IF;

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                          (   g_pkg_name
                           || '.'
                           || l_api_name
                           || ':'
                           || 'Calling INV_TXN_MANAGER_PUB.process_transactions');
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Transaction Header ID = '
                             || p_header_id);
         gme_debug.put_line
                           (   g_pkg_name
                            || '.'
                            || l_api_name
                            || ':'
                            || 'Transaction Table passed in MTI->1 MMTT->2 = '
                            || p_table);
      END IF;

      l_return :=
         inv_txn_manager_pub.process_transactions
                                    (p_api_version           => p_api_version
                                    ,p_init_msg_list         => p_init_msg_list
                                    ,p_commit                => p_commit
                                    ,p_validation_level      => p_validation_level
                                    ,p_table                 => p_table
                                    ,p_header_id             => p_header_id
                                    ,x_return_status         => x_return_status
                                    ,x_msg_count             => x_msg_count
                                    ,x_msg_data              => x_msg_data
                                    ,x_trans_count           => x_trans_count);

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'After calling INV_TXN_MANAGER_PUB.process_transactions l_return= '
                            || l_return || ' x_return_status= '|| x_return_status
                            || ' x_msg_data = '|| x_msg_data);
      END IF;

      /* begin temporary */
      IF (l_return = 0) THEN
         x_return_status := 'S';
      END IF;
      IF (x_msg_data IS NOT NULL) THEN
      	gme_common_pvt.log_message(p_message_code => 'FND_GENERIC_MESSAGE'
                                  ,p_product_code => 'FND'
                                  ,p_token1_name  => 'MESSAGE'
                                  ,p_token1_value => x_msg_data);
      END IF;
      IF (l_return < 0) THEN
         --Pawan Added for messages display
         IF p_table = 1 THEN
            x_msg_count := 0;
            FOR rec IN get_error_int LOOP
             /*Bug#6685680 Add the below call to log the actual error message*/
            	gme_common_pvt.log_message(p_message_code => 'FND_GENERIC_MESSAGE'
                                  ,p_product_code => 'FND'
                                  ,p_token1_name  => 'MESSAGE'
                                  ,p_token1_value => rec.error_explanation);
               --fnd_message.set_encoded (rec.error_explanation);

               IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name|| '.'|| l_api_name|| ':'|| rec.error_explanation);
               END IF;
               x_msg_count := x_msg_count + 1;
               x_msg_data := rec.error_explanation;
            END LOOP;
         ELSE
            x_msg_count := 0;
            FOR rec IN get_error_temp LOOP
             /*Bug#6685680 Add the below call to log the actual error message*/
            	gme_common_pvt.log_message(p_message_code => 'FND_GENERIC_MESSAGE'
                                  ,p_product_code => 'FND'
                                  ,p_token1_name  => 'MESSAGE'
                                  ,p_token1_value => rec.error_explanation);
               --fnd_message.set_encoded (rec.error_explanation);

               IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
                  gme_debug.put_line (   g_pkg_name|| '.'|| l_api_name|| ':'|| rec.error_explanation);
               END IF;
               x_msg_count := x_msg_count + 1;
               x_msg_data := rec.error_explanation;
            END LOOP;
         END IF;                                                 -- IF p_table

         IF (x_return_status IS NULL OR x_return_status = 'S') THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;
      /* Bug 5903208 Start GMF code */
      /* BUG 6335682 HALUTHRA : Adding gtp.pair_type (+) = 1 to avoid duplicate generation of layers to handle phantom batches*/
      /* Bug 8347011 base bug 8219507 removed mtln join from the query */

      -- Bug 8453485 - Added dynamically derived column rev_order_column to help us in order
      -- by clause. This will aid in handling Product Yield reversals for layer sequencing.
      -- It will force a real reversing transaction to be processed first.
      IF x_return_status = 'S' THEN
        FOR trans_rec in
        (
	  SELECT
	         mmt.transaction_id
	       , mmt.transaction_source_type_id
	       , mmt.transaction_action_id
	       , mmt.transaction_type_id
	       , mmt.inventory_item_id
	       , mmt.organization_id
	       , NULL as lot_number
	       , mmt.transaction_date
	       , mmt.primary_quantity as primary_quantity  /* Changed for Bug 8347011 base bug 8219507 */
                --nvl(mtln.primary_quantity, mmt.primary_quantity) as primary_quantity
	       , msi.primary_uom_code
               ,mmt.transaction_quantity as transaction_quantity /* Changed for Bug 8347011 base bug 8219507 */
	       --, nvl(mtln.transaction_quantity, mmt.transaction_quantity) as transaction_quantity /* Doc Qty */
	       , md.dtl_um as doc_uom
	       , mmt.transaction_source_id -- batch_id
	       , mmt.trx_source_line_id    -- line_id
	       , gtp.transaction_id2 AS reverse_id
               , decode(NVL(gtp.transaction_id2, 0), 0, mmt.transaction_id + 999, mmt.transaction_id) as rev_order_column
	       , md.line_type
	       , mmt.last_updated_by
	       , mmt.created_by
	       , mmt.last_update_login
	    FROM
	       --mtl_material_transactions mmt,
	       --mtl_transaction_lot_numbers mtln,
               mtl_material_transactions mmt, /* Removed mtln for Bug 8347011 base bug 8219507 */
	       mtl_system_items_b msi,
	       gme_material_details md,
	       gme_transaction_pairs gtp
	   WHERE
	         mmt.transaction_set_id = gme_common_pvt.g_transaction_header_id
	     --AND mtln.transaction_id(+) = mmt.transaction_id /*Commented for Bug 8347011*/
	     AND msi.organization_id    = mmt.organization_id
	     AND msi.inventory_item_id  = mmt.inventory_item_id
	     AND md.material_detail_id  = mmt.trx_source_line_id
	     AND gtp.transaction_id1(+) = mmt.transaction_id
	     AND gtp.batch_id(+)        = mmt.transaction_source_id
	     AND gtp.material_detail_id(+) = mmt.trx_source_line_id
	     AND mmt.transaction_source_type_id = gme_common_pvt.g_txn_source_type /*Bug#6266714*/
	     AND gtp.pair_type (+) = 1  /*BUG 6335682 */
	   ORDER BY mmt.transaction_date,
	            case md.line_type
	             when -1 then 0
	             when 2  then 1
	             when 1  then 2
	  	 end,
                 md.material_detail_id,
	            case md.line_type
	             when -1  then mmt.transaction_id
	             when 2  then rev_order_column
	             when 1  then rev_order_column
	  	 --mmt.transaction_id, mtln.lot_number) LOOP
	  	 end) LOOP
--                 mmt.transaction_id, lot_number) LOOP
	  l_trans_rec.transaction_id              := trans_rec.transaction_id;
	  l_trans_rec.transaction_source_type_id  := trans_rec.transaction_source_type_id;
	  l_trans_rec.transaction_action_id       := trans_rec.transaction_action_id;
	  l_trans_rec.transaction_type_id         := trans_rec.transaction_type_id;
	  l_trans_rec.inventory_item_id           := trans_rec.inventory_item_id;
	  l_trans_rec.organization_id             := trans_rec.organization_id;
	  l_trans_rec.lot_number                  := trans_rec.lot_number;
	  l_trans_rec.transaction_date            := trans_rec.transaction_date;
	  l_trans_rec.primary_quantity            := trans_rec.primary_quantity;
	  l_trans_rec.primary_uom                 := trans_rec.primary_uom_code;
	  l_trans_rec.doc_qty                     := trans_rec.transaction_quantity; /* Bug 8347011 base bug 8219507 */
	  l_trans_rec.doc_uom                     := trans_rec.doc_uom;
	  l_trans_rec.transaction_source_id       := trans_rec.transaction_source_id;
	  l_trans_rec.trx_source_line_id          := trans_rec.trx_source_line_id;
	  l_trans_rec.reverse_id                  := trans_rec.reverse_id;
	  l_trans_rec.line_type                   := trans_rec.line_type;
	  l_trans_rec.last_updated_by             := trans_rec.last_updated_by;
	  l_trans_rec.created_by                  := trans_rec.created_by;
	  l_trans_rec.last_update_login           := trans_rec.last_update_login;

	  IF trans_rec.transaction_action_id in (1, 27) THEN
            IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
              gme_debug.put_line('in process_txns for (INGR) actionID: ' || trans_rec.transaction_action_id || '...calling GMF outgoing layers'); --xxxremove
              gme_debug.put_line('in process_txns for (INGR) actionID: ' || trans_rec.transaction_action_id || '...calling GMF outgoing layers');
            END IF;

	    l_trans_rec.doc_qty := -1 * l_trans_rec.doc_qty;

	    gmf_layers.Create_outgoing_Layers
	    ( p_api_version   => 1.0,
	      p_init_msg_list => FND_API.G_FALSE,
	      p_tran_rec      => l_trans_rec,
	      x_return_status => x_return_status,
	      x_msg_count     => x_msg_count,
	      x_msg_data      => x_msg_data);
         ELSIF trans_rec.transaction_action_id in (31, 32) THEN
            IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
	      gme_debug.put_line('in process_txns for (PROD) actionID: ' || trans_rec.transaction_action_id || '...calling GMF incoming layers');
            END IF;

            --Bug#6322202 Added the below condition for byproducts
            IF trans_rec.line_type <> 1 THEN
               gmf_layers.Create_outgoing_Layers
        	    ( p_api_version   => 1.0,
        	      p_init_msg_list => FND_API.G_FALSE,
         	      p_tran_rec      => l_trans_rec,
   	              x_return_status => x_return_status,
        	      x_msg_count     => x_msg_count,
        	      x_msg_data      => x_msg_data);
            ELSE
      	      gmf_layers.Create_Incoming_Layers
        	    ( p_api_version   => 1.0,
        	      p_init_msg_list => FND_API.G_FALSE,
        	      p_tran_rec      => l_trans_rec,
        	      x_return_status => x_return_status,
         	      x_msg_count     => x_msg_count,
        	      x_msg_data      => x_msg_data);
            END IF;
              IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
	        gme_debug.put_line('in process_txns for (PROD) actionID: ' || trans_rec.transaction_action_id || '...after calling GMF incoming layers...status: ' || x_return_status); --xxxremove
              END IF;
	  ELSIF trans_rec.transaction_action_id in (33, 34) THEN
	    NULL;
	  END IF;
	END LOOP;
      END IF;
      p_qty_tbl.delete();
      /* Bug 5903208 End GMF code */

      IF x_return_status = 'S' THEN
         gme_common_pvt.g_transaction_header_id := NULL;
         gme_common_pvt.g_batch_status_check := fnd_api.g_true;
      END IF;
      /* end temporary */

      IF (l_return = 0) AND (fnd_api.to_boolean (p_commit) ) THEN
         --empty the quantity tree cache
         IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
            gme_debug.put_line
                        (   g_pkg_name
                         || '.'
                         || l_api_name
                         || ':'
                         || 'Calling Inv_Quantity_Tree_Pub.clear_quantity_cache');
         END IF;

         inv_quantity_tree_pub.clear_quantity_cache;
      END IF;

      gme_common_pvt.reset_txn_hdr_tbl; -- nsinghi bug#5176319

      -- Bug 8751983 - Reset global IB timestamp to NULL.
      gme_common_pvt.g_ib_timestamp_set := 0;

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'UNEXPECTED:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'OTHERS:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
   END process_transactions;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   query_quantities
   |
   | USAGE
   |    Query quantities at a level specified by the input
   |
   | ARGUMENTS
   |   p_api_version API Version of this procedure. Current version is 1.0
   |   p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not                  |
   |   x_return_status Returns the status to indicate success or failure of execution
   |   x_msg_count Returns number of error message in the error message stack in case of failure
   |   x_msg_data Returns the error message in case of failure
   |
   | RETURNS
   |   returns via x_ OUT parameters
   |
   | HISTORY
   |   Created  07-Mar-05 Jalaj Srivastava
   |   Archana Mundhe 20-Oct-2008  Bug 7385309
   |   Added code to clear cache before querying quantity tree.
   |
   |   G. Muratore    24-Dec-2008  Bug 7626742/7423041
   |   Backout one piece of fix from 7385309 - Do not clear the cache.
   +==========================================================================+ */
   PROCEDURE query_quantities (
      p_api_version_number           IN              NUMBER := 1
     ,p_init_msg_lst                 IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,x_msg_count                    OUT NOCOPY      NUMBER
     ,x_msg_data                     OUT NOCOPY      VARCHAR2
     ,p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER
     ,p_tree_mode                    IN              INTEGER
     ,p_is_serial_control            IN              BOOLEAN DEFAULT FALSE
     ,p_grade_code                   IN              VARCHAR2
     ,p_demand_source_type_id        IN              NUMBER
            DEFAULT gme_common_pvt.g_txn_source_type
     ,p_demand_source_header_id      IN              NUMBER DEFAULT -9999
     ,p_demand_source_line_id        IN              NUMBER DEFAULT -9999
     ,p_demand_source_name           IN              VARCHAR2 DEFAULT NULL
     ,p_lot_expiration_date          IN              DATE DEFAULT NULL
     ,p_revision                     IN              VARCHAR2
     ,p_lot_number                   IN              VARCHAR2
     ,p_subinventory_code            IN              VARCHAR2
     ,p_locator_id                   IN              NUMBER
     ,p_onhand_source                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_all_subs
     ,x_qoh                          OUT NOCOPY      NUMBER
     ,x_rqoh                         OUT NOCOPY      NUMBER
     ,x_qr                           OUT NOCOPY      NUMBER
     ,x_qs                           OUT NOCOPY      NUMBER
     ,x_att                          OUT NOCOPY      NUMBER
     ,x_atr                          OUT NOCOPY      NUMBER
     ,x_sqoh                         OUT NOCOPY      NUMBER
     ,x_srqoh                        OUT NOCOPY      NUMBER
     ,x_sqr                          OUT NOCOPY      NUMBER
     ,x_sqs                          OUT NOCOPY      NUMBER
     ,x_satt                         OUT NOCOPY      NUMBER
     ,x_satr                         OUT NOCOPY      NUMBER
     ,p_transfer_subinventory_code   IN              VARCHAR2 DEFAULT NULL
     ,p_cost_group_id                IN              NUMBER DEFAULT NULL
     ,p_lpn_id                       IN              NUMBER DEFAULT NULL
     ,p_transfer_locator_id          IN              NUMBER DEFAULT NULL)
   IS
      l_api_name     CONSTANT VARCHAR2 (30) := 'QUERY_QUANTITIES';
      l_is_revision_control   BOOLEAN       := FALSE;
      l_is_lot_control        BOOLEAN       := FALSE;
   BEGIN
      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF (p_revision IS NOT NULL) THEN
         l_is_revision_control := TRUE;
      END IF;

      IF (p_lot_number IS NOT NULL) THEN
         l_is_lot_control := TRUE;
      END IF;

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Calling Inv_Quantity_Tree_Pub.Query_Quantities');
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Organization ID = '
                             || p_organization_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Inventory Item ID = '
                             || p_inventory_item_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Subinventory = '
                             || p_subinventory_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Lot Number = '
                             || p_lot_number);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Locator ID = '
                             || p_locator_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Item Revision = '
                             || p_revision);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Tree Mode = '
                             || p_tree_mode);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Grade = '
                             || p_grade_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Lot Expiration Date = '
                             || TO_CHAR (p_lot_expiration_date
                                        ,'MM/DD/YYYY HH24:MI:SS') );
      END IF;


      -- Bug 7385309
      -- Clear cache before querying quantity tree.
      -- Bug 7626742 - Backout fix from 7385309 - Do not clear the cache.
      -- inv_quantity_tree_pub.clear_quantity_cache;
      inv_quantity_tree_pub.query_quantities
                (p_api_version_number              => p_api_version_number
                ,p_init_msg_lst                    => p_init_msg_lst
                ,x_return_status                   => x_return_status
                ,x_msg_count                       => x_msg_count
                ,x_msg_data                        => x_msg_data
                ,p_organization_id                 => p_organization_id
                ,p_inventory_item_id               => p_inventory_item_id
                ,p_tree_mode                       => p_tree_mode
                ,p_is_revision_control             => l_is_revision_control
                ,p_is_lot_control                  => l_is_lot_control
                ,p_is_serial_control               => p_is_serial_control
                ,p_grade_code                      => p_grade_code
                ,p_demand_source_type_id           => p_demand_source_type_id
                ,p_demand_source_header_id         => p_demand_source_header_id
                ,p_demand_source_line_id           => p_demand_source_line_id
                ,p_demand_source_name              => p_demand_source_name
                ,p_lot_expiration_date             => p_lot_expiration_date
                ,p_revision                        => p_revision
                ,p_lot_number                      => p_lot_number
                ,p_subinventory_code               => p_subinventory_code
                ,p_locator_id                      => p_locator_id
                ,p_onhand_source                   => p_onhand_source
                ,x_qoh                             => x_qoh
                ,x_rqoh                            => x_rqoh
                ,x_qr                              => x_qr
                ,x_qs                              => x_qs
                ,x_att                             => x_att
                ,x_atr                             => x_atr
                ,x_sqoh                            => x_sqoh
                ,x_srqoh                           => x_srqoh
                ,x_sqr                             => x_sqr
                ,x_sqs                             => x_sqs
                ,x_satt                            => x_satt
                ,x_satr                            => x_satr
                ,p_transfer_subinventory_code      => p_transfer_subinventory_code
                ,p_cost_group_id                   => p_cost_group_id
                ,p_lpn_id                          => p_lpn_id
                ,p_transfer_locator_id             => p_transfer_locator_id);

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'UNEXPECTED:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'OTHERS:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
   END query_quantities;

   /* +==========================================================================+
   | PROCEDURE NAME
   |   update_quantities
   |
   | USAGE
   |    Update quantity at the level specified by the input and
   |    return the quantities at the level after the update
   |
   | ARGUMENTS
   |   p_api_version API Version of this procedure. Current version is 1.0
   |   p_init_msg_list fnd_api.g_false or fnd_api.g_true is passed as input to determine whether to Initialize message list or not                  |
   |   x_return_status Returns the status to indicate success or failure of execution
   |   x_msg_count Returns number of error message in the error message stack in case of failure
   |   x_msg_data Returns the error message in case of failure
   |
   | RETURNS
   |   returns via x_ OUT parameters
   |
   | HISTORY
   |   Created  07-Mar-05 Jalaj Srivastava
   |
   +==========================================================================+ */
   PROCEDURE update_quantities (
      p_api_version_number           IN              NUMBER := 1
     ,p_init_msg_lst                 IN              VARCHAR2
            DEFAULT fnd_api.g_false
     ,x_return_status                OUT NOCOPY      VARCHAR2
     ,x_msg_count                    OUT NOCOPY      NUMBER
     ,x_msg_data                     OUT NOCOPY      VARCHAR2
     ,p_organization_id              IN              NUMBER
     ,p_inventory_item_id            IN              NUMBER
     ,p_tree_mode                    IN              INTEGER
     ,p_is_serial_control            IN              BOOLEAN := FALSE
     ,p_demand_source_type_id        IN              NUMBER
            DEFAULT gme_common_pvt.g_txn_source_type
     ,p_demand_source_header_id      IN              NUMBER DEFAULT -9999
     ,p_demand_source_line_id        IN              NUMBER DEFAULT -9999
     ,p_demand_source_name           IN              VARCHAR2 DEFAULT NULL
     ,p_lot_expiration_date          IN              DATE DEFAULT NULL
     ,p_revision                     IN              VARCHAR2 DEFAULT NULL
     ,p_lot_number                   IN              VARCHAR2 DEFAULT NULL
     ,p_subinventory_code            IN              VARCHAR2 DEFAULT NULL
     ,p_locator_id                   IN              NUMBER DEFAULT NULL
     ,p_grade_code                   IN              VARCHAR2 DEFAULT NULL
     ,p_primary_quantity             IN              NUMBER
     ,p_quantity_type                IN              INTEGER
     ,p_secondary_quantity           IN              NUMBER
     ,p_onhand_source                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_all_subs
     ,x_qoh                          OUT NOCOPY      NUMBER
     ,x_rqoh                         OUT NOCOPY      NUMBER
     ,x_qr                           OUT NOCOPY      NUMBER
     ,x_qs                           OUT NOCOPY      NUMBER
     ,x_att                          OUT NOCOPY      NUMBER
     ,x_atr                          OUT NOCOPY      NUMBER
     ,x_sqoh                         OUT NOCOPY      NUMBER
     ,x_srqoh                        OUT NOCOPY      NUMBER
     ,x_sqr                          OUT NOCOPY      NUMBER
     ,x_sqs                          OUT NOCOPY      NUMBER
     ,x_satt                         OUT NOCOPY      NUMBER
     ,x_satr                         OUT NOCOPY      NUMBER
     ,p_transfer_subinventory_code   IN              VARCHAR2 DEFAULT NULL
     ,p_cost_group_id                IN              NUMBER DEFAULT NULL
     ,p_containerized                IN              NUMBER
            DEFAULT inv_quantity_tree_pvt.g_containerized_false
     ,p_lpn_id                       IN              NUMBER DEFAULT NULL
     ,p_transfer_locator_id          IN              NUMBER DEFAULT NULL)
   IS
      l_api_name     CONSTANT VARCHAR2 (30) := 'UPDATE_QUANTITIES';
      l_is_revision_control   BOOLEAN       := FALSE;
      l_is_lot_control        BOOLEAN       := FALSE;
   BEGIN
      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering');
      END IF;

      IF (p_revision IS NOT NULL) THEN
         l_is_revision_control := TRUE;
      END IF;

      IF (p_lot_number IS NOT NULL) THEN
         l_is_lot_control := TRUE;
      END IF;

      IF (NVL (g_debug, 0) = gme_debug.g_log_statement) THEN
         gme_debug.put_line
                           (   g_pkg_name
                            || '.'
                            || l_api_name
                            || ':'
                            || 'Calling Inv_Quantity_Tree_Pub.Update_Quantities');
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Organization ID = '
                             || p_organization_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Inventory Item ID = '
                             || p_inventory_item_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Subinventory = '
                             || p_subinventory_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Lot Number = '
                             || p_lot_number);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Locator ID = '
                             || p_locator_id);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Item Revision = '
                             || p_revision);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Tree Mode = '
                             || p_tree_mode);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Grade = '
                             || p_grade_code);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Lot Expiration Date = '
                             || TO_CHAR (p_lot_expiration_date
                                        ,'MM/DD/YYYY HH24:MI:SS') );
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Quantity Type = '
                             || p_quantity_type);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Primary Quantity = '
                             || p_primary_quantity);
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Secondary Quantity = '
                             || p_secondary_quantity);
      END IF;

      inv_quantity_tree_pub.update_quantities
                (p_api_version_number              => p_api_version_number
                ,p_init_msg_lst                    => p_init_msg_lst
                ,x_return_status                   => x_return_status
                ,x_msg_count                       => x_msg_count
                ,x_msg_data                        => x_msg_data
                ,p_organization_id                 => p_organization_id
                ,p_inventory_item_id               => p_inventory_item_id
                ,p_tree_mode                       => p_tree_mode
                ,p_is_revision_control             => l_is_revision_control
                ,p_is_lot_control                  => l_is_lot_control
                ,p_is_serial_control               => p_is_serial_control
                ,p_grade_code                      => p_grade_code
                ,p_demand_source_type_id           => p_demand_source_type_id
                ,p_demand_source_header_id         => p_demand_source_header_id
                ,p_demand_source_line_id           => p_demand_source_line_id
                ,p_demand_source_name              => p_demand_source_name
                ,p_lot_expiration_date             => p_lot_expiration_date
                ,p_revision                        => p_revision
                ,p_lot_number                      => p_lot_number
                ,p_subinventory_code               => p_subinventory_code
                ,p_locator_id                      => p_locator_id
                ,p_onhand_source                   => p_onhand_source
                ,p_primary_quantity                => p_primary_quantity
                ,p_quantity_type                   => p_quantity_type
                ,p_secondary_quantity              => p_secondary_quantity
                ,x_qoh                             => x_qoh
                ,x_rqoh                            => x_rqoh
                ,x_qr                              => x_qr
                ,x_qs                              => x_qs
                ,x_att                             => x_att
                ,x_atr                             => x_atr
                ,x_sqoh                            => x_sqoh
                ,x_srqoh                           => x_srqoh
                ,x_sqr                             => x_sqr
                ,x_sqs                             => x_sqs
                ,x_satt                            => x_satt
                ,x_satr                            => x_satr
                ,p_transfer_subinventory_code      => p_transfer_subinventory_code
                ,p_cost_group_id                   => p_cost_group_id
                ,p_lpn_id                          => p_lpn_id
                ,p_transfer_locator_id             => p_transfer_locator_id
                ,p_containerized                   => p_containerized);

      IF (NVL (g_debug, 0) IN
                       (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'UNEXPECTED:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF (NVL (g_debug, 0) > 0) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'OTHERS:'
                                || SQLERRM);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count
                                   ,p_data       => x_msg_data);
   END update_quantities;

  /* Bug 4929610 Added fucntion */
  /* +==========================================================================+
  | FUNCTION NAME
  |    is_lot_expired
  |
  | USAGE
  |
  |
  | ARGUMENTS
  |   p_organization_id
  |   p_lot_number
  |   p_inventory_item_id
  |   p_date
  | RETURNS
  |   returns BOOLEAN, TRUE if lot expired
  |
  | HISTORY
  |   Created  16-Feb-06 Chandrashekar Tiruvidula
  |
  +==========================================================================+ */
  FUNCTION is_lot_expired (p_organization_id   IN NUMBER,
                           p_inventory_item_id IN NUMBER,
                           p_lot_number        IN VARCHAR2,
                           p_date              IN DATE) RETURN BOOLEAN IS
    l_expire_date   DATE;
    l_api_name     CONSTANT VARCHAR2 (30) := 'is_lot_expired';
    CURSOR Cur_lot_expire IS
      SELECT expiration_date
      FROM   mtl_lot_numbers
      WHERE  organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND lot_number = p_lot_number;
  BEGIN
    OPEN Cur_lot_expire;
    FETCH Cur_lot_expire INTO l_expire_date;
    CLOSE Cur_lot_expire;
    IF l_expire_date IS NULL THEN
      RETURN FALSE;
    ELSE
      IF l_expire_date < NVL(p_date, SYSDATE) THEN
        gme_common_pvt.log_message(p_product_code => 'INV', p_message_code => 'INV_LOT_EXPIRED');
        RETURN TRUE;
      END IF;
    END IF;
    RETURN FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF (NVL (g_debug, 0) > 0) THEN
        gme_debug.put_line (g_pkg_name|| '.'|| l_api_name|| ':'|| 'WHEN OTHERS:'|| SQLERRM);
      END IF;
      RETURN FALSE;
  END is_lot_expired;

  PROCEDURE insert_txn_inter_hdr(p_mmti_rec      IN  mtl_transactions_interface%ROWTYPE,
                                 x_return_status OUT NOCOPY VARCHAR2) IS
    l_api_name     CONSTANT VARCHAR2 (30) := 'insert_txn_inter_hdr';
  BEGIN
    IF (NVL (g_debug, 0) IN (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
      gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':' || 'Entering');
    END IF;
    x_return_status := fnd_api.g_ret_sts_success;
    INSERT INTO mtl_transactions_interface
                  (transaction_interface_id
                  ,transaction_header_id
                  ,source_code
                  ,source_header_id
                  ,lock_flag
                  ,transaction_mode
                  ,process_flag
                  ,validation_required
                  ,source_line_id
                  ,transaction_source_id
                  ,trx_source_line_id
                  ,last_updated_by
                  ,last_update_login
                  ,last_update_date
                  ,creation_date
                  ,created_by
                  ,inventory_item_id
                  ,revision
                  ,organization_id
                  ,transaction_date
                  ,transaction_type_id
                  ,transaction_action_id
                  ,transaction_quantity
                  ,primary_quantity
                  ,secondary_transaction_quantity
                  ,secondary_uom_code
                  ,transaction_uom
                  ,subinventory_code
                  ,locator_id
                  ,transaction_source_type_id
                  ,wip_entity_type
                  ,transaction_source_name
                  ,transaction_reference
                  ,reason_id
                  ,transaction_batch_id
                  ,transaction_batch_seq
                  ,reservation_quantity
                  ,transaction_sequence_id
                  ,transfer_lpn_id
                  ,lpn_id) -- Bug 6437252 LPN support
           VALUES (p_mmti_rec.transaction_interface_id
                  ,gme_common_pvt.g_transaction_header_id
                  ,'OPM' -- source_code
                  ,p_mmti_rec.transaction_source_id --source_header_id
                  ,1            -- lock_flag
                  ,2              -- transaction_mode
                  ,1                                    -- (Yes) process_flag
                  ,2                                 -- validation_required
                  , NVL (p_mmti_rec.source_line_id, -99)--  transaction_id for reversal
                  ,p_mmti_rec.transaction_source_id -- batch id
                  ,p_mmti_rec.trx_source_line_id  -- material detail id
                  ,gme_common_pvt.g_user_ident              --last_updated_by
                  ,gme_common_pvt.g_user_ident     -- last_update_login
                  ,gme_common_pvt.g_timestamp      --last_update_date
                  ,gme_common_pvt.g_timestamp      --creation_date
                  ,gme_common_pvt.g_user_ident     --created_by
                  ,p_mmti_rec.inventory_item_id    -- inventory_item_id
                  ,p_mmti_rec.revision
                  ,p_mmti_rec.organization_id      --organization_id
                   /* FPBug#4543872 rework
                      removed defaulting the transaction date
                    */
                  ,p_mmti_rec.transaction_date
                  ,p_mmti_rec.transaction_type_id
                  ,                         --(Batch Issue)transaction_type_id
                   p_mmti_rec.transaction_action_id
                  ,                                    --transaction_action_id
                   p_mmti_rec.transaction_quantity
                  ,                                     --transaction_quantity
                   p_mmti_rec.primary_quantity
                  ,                                         --primary_quantity
                   p_mmti_rec.secondary_transaction_quantity -- secondary_quantity
                  ,p_mmti_rec.secondary_uom_code  -- secondary_uom_code
                  ,                                      -- secondary_quantity
                   p_mmti_rec.transaction_uom,               --transaction_uom
                                              p_mmti_rec.subinventory_code
                  ,                                        --subinventory_code
                   p_mmti_rec.locator_id,                         --locator_id
                                         gme_common_pvt.g_txn_source_type
                  ,                      -- (Batch) transaction_source_type_id
                   gme_common_pvt.g_wip_entity_type_batch -- (for batch) wip_entity_type
                  ,p_mmti_rec.transaction_source_name -- transaction_source_name
                  ,p_mmti_rec.transaction_reference
                  ,p_mmti_rec.reason_id
                  ,p_mmti_rec.transaction_batch_id -- must populate for seq
                  ,p_mmti_rec.transaction_batch_seq
                  ,p_mmti_rec.reservation_quantity
                  ,p_mmti_rec.transaction_sequence_id
                  ,p_mmti_rec.transfer_lpn_id
                  ,p_mmti_rec.lpn_id);     -- Bug 6437252 LPN support
    IF (NVL (g_debug, 0) IN (gme_debug.g_log_statement, gme_debug.g_log_procedure) ) THEN
      gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':' || 'Exiting');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF (NVL (g_debug, 0) > 0) THEN
        gme_debug.put_line (g_pkg_name|| '.'|| l_api_name|| ':'|| 'WHEN OTHERS:'|| SQLERRM);
      END IF;
  END insert_txn_inter_hdr;

-- nsinghi bug#5176319. Added this proc.
   /* +==========================================================================+
   | PROCEDURE NAME
   |   get_mmt_transactions
   |
   | USAGE
   |    Gets all transactions from mmt based on transaction_id passed. Unlike get_transactions,
   |    this procedure does not check for enteries in gme_transaction_pairs
   |
   | ARGUMENTS
   |   p_transaction_id -- transaction_id from mmt for fetch
   |
   | RETURNS
   |
   |   returns via x_status OUT parameters
   |   x_mmt_rec -- mtl_material_transactions rowtype
   |   x_mmln_tbl -- table of mtl_trans_lots_number_tbl
   | HISTORY
   |   Created  19-Jun-06 Namit S. Created
   |
   +==========================================================================+ */
   PROCEDURE get_mmt_transactions (
      p_transaction_id   IN              NUMBER
     ,x_mmt_rec          OUT NOCOPY      mtl_material_transactions%ROWTYPE
     ,x_mmln_tbl         OUT NOCOPY      gme_common_pvt.mtl_trans_lots_num_tbl
     ,x_return_status    OUT NOCOPY      VARCHAR2)
   IS

      CURSOR cur_get_transaction (v_transaction_id NUMBER)
      IS
         SELECT *
           FROM mtl_material_transactions mmt
          WHERE transaction_id = v_transaction_id;

      CURSOR cur_get_lot_transaction (v_transaction_id NUMBER)
      IS
         SELECT *
           FROM mtl_transaction_lot_numbers
          WHERE transaction_id = v_transaction_id;

      l_api_name    CONSTANT VARCHAR2 (30) := 'GET_MMT_TRANSACTIONS';
      l_return_status        VARCHAR2 (1)  := fnd_api.g_ret_sts_success;
      l_transaction_id       NUMBER;
      no_transaction_found   EXCEPTION;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'Entering with transaction '||p_transaction_id);
      END IF;

      IF p_transaction_id IS NULL THEN
         gme_common_pvt.log_message ('GME_NO_KEYS', 'TABLE_NAME', l_api_name);

         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'TRANSACTION ID NEEDED FOR RETRIEVAL');
         END IF;
      END IF;

      l_transaction_id := p_transaction_id;
      OPEN cur_get_transaction (l_transaction_id);
      FETCH cur_get_transaction
       INTO x_mmt_rec;
      IF cur_get_transaction%FOUND THEN
         IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'TRANSACTIONS found for '
                                || l_transaction_id);
         END IF;
         get_lot_trans (p_transaction_id      => l_transaction_id
                       ,x_mmln_tbl            => x_mmln_tbl
                       ,x_return_status       => l_return_status);

         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'
                             || 'error from get lot trans');
            END IF;
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE /* IF cur_get_transaction%FOUND THEN */
         CLOSE cur_get_transaction;
         gme_common_pvt.log_message ('GME_NO_TRANS_FOUND');
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE cur_get_transaction;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'TRANSACTION '
                             || x_mmt_rec.transaction_id);
      END IF;

      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line (   g_pkg_name
                             || '.'
                             || l_api_name
                             || ':'
                             || 'Exiting with '
                             || x_return_status);
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);

         IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
            gme_debug.put_line (   g_pkg_name
                                || '.'
                                || l_api_name
                                || ':'
                                || 'WHEN OTHERS:'
                                || SQLERRM);
         END IF;
   END get_mmt_transactions;

  /* Bug 5358129 Added procedure */
  PROCEDURE validate_lot_for_ing(p_organization_id   IN NUMBER,
                                 p_inventory_item_id IN NUMBER,
                                 p_lot_number        IN VARCHAR2,
                                 x_return_status     OUT NOCOPY VARCHAR2) IS
    CURSOR Cur_get_lot IS
      SELECT expiration_date
      FROM   mtl_lot_numbers
      WHERE  organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id
             AND lot_number = p_lot_number;
    l_api_name  CONSTANT VARCHAR2(30) := 'validate_lot_for_ing';
    l_date      DATE;
    expired_lot EXCEPTION;
    invalid_lot EXCEPTION;
  BEGIN
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'|| 'Entering with organization_id = '||p_organization_id
                          ||' inventory_item_id = '||p_inventory_item_id||' lot_number = '||p_lot_number);
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN Cur_get_lot;
    FETCH Cur_get_lot INTO l_date;
    IF (Cur_get_lot%NOTFOUND) THEN
      CLOSE Cur_get_lot;
      RAISE invalid_lot;
    END IF;
    CLOSE Cur_get_lot;
    IF (l_date IS NOT NULL AND l_date < sysdate) THEN
      RAISE expired_lot;
    END IF;
    IF (g_debug <= gme_debug.g_log_procedure) THEN
      gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'|| 'Normal Exiting');
    END IF;
  EXCEPTION
    WHEN expired_lot THEN
    	 gme_common_pvt.log_message(p_message_code => 'INV_LOT_EXPIRED',
    	                            p_product_code => 'INV');
       x_return_status := fnd_api.g_ret_sts_error;
    WHEN invalid_lot THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
    	 gme_common_pvt.log_message(p_message_code => 'INV_INVALID_LOT',
    	                            p_product_code => 'INV');
    WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
       IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
          gme_debug.put_line (   g_pkg_name|| '.'|| l_api_name|| ':'|| 'WHEN OTHERS:'|| SQLERRM);
       END IF;
  END validate_lot_for_ing;

  /* Added for bug 5597385 */
  PROCEDURE gmo_pre_process_val(p_mmti_rec      IN  mtl_transactions_interface%ROWTYPE,
                                p_mmli_tbl      IN  gme_common_pvt.mtl_trans_lots_inter_tbl,
                                p_mode          IN  VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    CURSOR cur_get_item_rec (v_item_id NUMBER, v_org_id NUMBER) IS
      SELECT *
      FROM   mtl_system_items_b
      WHERE inventory_item_id = v_item_id AND organization_id = v_org_id;
    CURSOR Cur_associated_step(v_matl_dtl_id NUMBER) IS
      SELECT step_status
      FROM   gme_batch_steps s, gme_batch_step_items i
      WHERE  s.batchstep_id = i.batchstep_id
             AND i.material_detail_id = v_matl_dtl_id;
      l_mat_dtl_rec                gme_material_details%ROWTYPE;
      l_batch_hdr_rec              gme_batch_header%ROWTYPE;
      l_item_rec                   mtl_system_items_b%ROWTYPE;
      l_available_qty              NUMBER;
      l_step_status                NUMBER;
      l_rel_type                   NUMBER;
      l_return_status              VARCHAR2(1);
      item_not_found               EXCEPTION;
      not_valid_trans              EXCEPTION;
      lot_val_err                  EXCEPTION;
      l_api_name          CONSTANT VARCHAR2(30) := 'GMO_PRE_PROCESS_VAL';
   BEGIN
      -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      IF (g_debug <= gme_debug.g_log_statement) THEN
        gme_debug.put_line (g_pkg_name || '.' || l_api_name || ':'|| 'Entering');
      END IF;
      IF (g_debug <= gme_debug.g_log_statement) THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.transaction_header_id: '||p_mmti_rec.transaction_header_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.subinventory_code: '||p_mmti_rec.subinventory_code);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.transaction_uom: '||p_mmti_rec.transaction_uom);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.inventory_item_id: '||p_mmti_rec.inventory_item_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.trx_source_line_id: '||p_mmti_rec.trx_source_line_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.revision: '||p_mmti_rec.revision);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.transaction_source_id: '||p_mmti_rec.transaction_source_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.locator_id: '||p_mmti_rec.locator_id);
         gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'p_mmti_rec.transaction_type_id: '||p_mmti_rec.transaction_type_id);
      END IF;
      IF p_mmti_rec.transaction_source_id IS NOT NULL THEN
        l_batch_hdr_rec.batch_id := p_mmti_rec.transaction_source_id;
        IF NOT gme_batch_header_dbl.fetch_row(l_batch_hdr_rec, l_batch_hdr_rec) THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
        RAISE fnd_api.g_exc_error;
      END IF;  -- transaction_source_id IS NOT NULL

      IF l_batch_hdr_rec.update_inventory_ind = 'Y' THEN
        IF p_mmti_rec.trx_source_line_id IS NOT NULL THEN
          l_mat_dtl_rec.material_detail_id := p_mmti_rec.trx_source_line_id;
          IF NOT gme_material_details_dbl.fetch_row(l_mat_dtl_rec, l_mat_dtl_rec) THEN
             RAISE fnd_api.g_exc_error;
          END IF; -- material fetch
        ELSE
          RAISE fnd_api.g_exc_error;
        END IF;       -- trx_source_line_id IS NOT NULL
        IF gme_common_pvt.g_batch_status_check = fnd_api.g_true THEN
          IF l_batch_hdr_rec.batch_status NOT IN (2, 3) THEN
            gme_common_pvt.log_message ('GME_INVALID_BATCH_STATUS');
            RAISE fnd_api.g_exc_error;
          END IF;
          -- Check for step status in case the item is associated to a step.
          l_rel_type := gme_common_pvt.is_material_auto_release(l_mat_dtl_rec.material_detail_id);
          IF (l_rel_type = gme_common_pvt.g_mtl_autobystep_release) THEN
            OPEN Cur_associated_step(l_mat_dtl_rec.material_detail_id);
            FETCH Cur_associated_step INTO l_step_status;
            CLOSE Cur_associated_step;
            IF l_step_status NOT IN (2,3) THEN
              gme_common_pvt.log_message ('GME_API_INVALID_STEP_STATUS');
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF; -- IF (   l_rel_type = gme_common_pvt.g_mtl_autobystep_release ) THEN
           -- check for item release type for products
          IF (l_rel_type = gme_common_pvt.g_mtl_auto_release AND l_mat_dtl_rec.line_type IN (1,2) AND l_mat_dtl_rec.phantom_line_id IS NULL) THEN
            IF l_batch_hdr_rec.batch_status <> 3 THEN
              gme_common_pvt.log_message('GME_INVALID_BATCH_STATUS');
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;  -- gme_common_pvt.g_batch_status_check
        IF (l_mat_dtl_rec.line_type <> -1 AND p_mmti_rec.transaction_type_id IN (gme_common_pvt.g_ing_issue, gme_common_pvt.g_ing_return))
           OR (l_mat_dtl_rec.line_type <> 1 AND p_mmti_rec.transaction_type_id IN (gme_common_pvt.g_prod_completion, gme_common_pvt.g_prod_return))
           OR (l_mat_dtl_rec.line_type <> 2 AND p_mmti_rec.transaction_type_id IN (gme_common_pvt.g_byprod_completion, gme_common_pvt.g_byprod_return)) THEN
          gme_common_pvt.log_message ('GME_LINE_TYPE_TXN_TYPE_DIFF');
          RAISE fnd_api.g_exc_error;
        END IF;
        -- get the item propertites
        OPEN cur_get_item_rec (p_mmti_rec.inventory_item_id, p_mmti_rec.organization_id);
        FETCH cur_get_item_rec INTO l_item_rec;
        IF cur_get_item_rec%NOTFOUND THEN
          CLOSE cur_get_item_rec;
          gme_common_pvt.log_message ('PM_INVALID_ITEM');
          IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
            gme_debug.put_line('Item cursor fetch no record in mtl_system_items_b: ');
            gme_debug.put_line('inventory_item_id = '|| TO_CHAR (p_mmti_rec.inventory_item_id));
            gme_debug.put_line('organization_id = '|| TO_CHAR (p_mmti_rec.organization_id));
          END IF;
          RAISE item_not_found;
        END IF;
        CLOSE cur_get_item_rec;
        IF (g_debug <= gme_debug.g_log_statement) THEN
          gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item lot_control Code: '|| l_item_rec.lot_control_code);
          gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item loct_control Code: '|| l_item_rec.location_control_code);
        END IF;

        /* Bug 5358129 for ingredients lots should exist */
        IF (l_mat_dtl_rec.line_type = gme_common_pvt.g_line_type_ing AND l_mat_dtl_rec.phantom_type = 0 AND l_item_rec.lot_control_code = 2) THEN
          FOR i IN 1..p_mmli_tbl.COUNT LOOP
      	    gme_transactions_pvt.validate_lot_for_ing(p_organization_id   => p_mmti_rec.organization_id,
                                                      p_inventory_item_id => p_mmti_rec.inventory_item_id,
                                                      p_lot_number        => p_mmli_tbl(i).lot_number,
                                                      x_return_status     => l_return_status);
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE lot_val_err;
            END IF;
          END LOOP;
        END IF;
        -- if return transaction then check qty was issued and return not more than issued qty
        IF p_mmti_rec.transaction_type_id IN (gme_common_pvt.g_byprod_return, gme_common_pvt.g_prod_return, gme_common_pvt.g_ing_return) THEN
          IF (g_debug <= gme_debug.g_log_statement) THEN
            gme_debug.put_line(g_pkg_name||'.'||l_api_name||':'||'Return transaction for : '||p_mmti_rec.transaction_type_id);
          END IF;
          IF l_item_rec.lot_control_code = 1 THEN
            IF (g_debug <= gme_debug.g_log_statement) THEN
              gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item is  NOT lot_control: '|| l_item_rec.lot_control_code);
            END IF;
            get_returnable_qty(p_mmti_rec      => p_mmti_rec
                              ,p_lot_number    => NULL
                              ,p_lot_control   => l_item_rec.lot_control_code
                              ,x_available_qty => l_available_qty
                              ,x_return_status => x_return_status);
             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                RAISE fnd_api.g_exc_unexpected_error;
             END IF;
             IF (g_debug <= gme_debug.g_log_statement) THEN
               gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Returning Qty '|| p_mmti_rec.transaction_quantity);
               gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Available to Return '|| l_available_qty);
             END IF;
             IF ABS (l_available_qty) < ABS (p_mmti_rec.transaction_quantity) THEN
               gme_common_pvt.log_message ('GME_QTY_LESS_THEN_ISSUED');
               RAISE fnd_api.g_exc_error;
             END IF;
           ELSE /* Lot Control */
             IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
               gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Item is lot control: '|| l_item_rec.lot_control_code);
             END IF;
             FOR i IN 1..p_mmli_tbl.COUNT LOOP
               get_returnable_qty(p_mmti_rec      => p_mmti_rec
                                 ,p_lot_number    => p_mmli_tbl(i).lot_number
                                 ,p_lot_control   => l_item_rec.lot_control_code
                                 ,x_available_qty => l_available_qty
                                 ,x_return_status => x_return_status);
               IF x_return_Status <> fnd_api.g_ret_sts_success THEN
                 RAISE fnd_api.g_exc_unexpected_error;
               END IF;
               IF (NVL (g_debug, -1) = gme_debug.g_log_statement) THEN
                 gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Returning qty: '|| p_mmli_tbl(i).transaction_quantity);
                 gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Available to Return '|| l_available_qty);
               END IF;
               IF ABS(l_available_qty) < ABS(p_mmli_tbl(i).transaction_quantity) THEN
                 gme_common_pvt.log_message ('GME_QTY_LESS_THEN_ISSUED');
                 RAISE fnd_api.g_exc_error;
               END IF;
             END LOOP;
           END IF; /* IF l_item_rec.lot_control_code = 1 THEN */
         END IF; /* IF transaction_type_id in RETURNS */
      END IF;  /* update_inventory_ind = 'Y' */
      IF (g_debug <= gme_debug.g_log_statement) THEN
        gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'Exiting with '|| x_return_status);
      END IF;
   EXCEPTION
     WHEN lot_val_err THEN
       x_return_status := l_return_status;
     WHEN fnd_api.g_exc_error THEN
       x_return_status := fnd_api.g_ret_sts_error;
     WHEN fnd_api.g_exc_unexpected_error THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
     WHEN OTHERS THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
       IF (NVL (g_debug, -1) = gme_debug.g_log_unexpected) THEN
         gme_debug.put_line(g_pkg_name|| '.'|| l_api_name|| ':'|| 'WHEN OTHERS:'|| SQLERRM);
       END IF;
   END gmo_pre_process_val;
END gme_transactions_pvt;


/