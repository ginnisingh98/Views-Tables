--------------------------------------------------------
--  DDL for Package Body GME_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_DEBUG" AS
/*  $Header: GMEUDBGB.pls 120.4 2005/10/05 14:39:46 snene noship $    */
   g_debug               VARCHAR2 (5)
                                := NVL (fnd_profile.VALUE ('AFLOG_LEVEL')
                                       ,-1);
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GME_DEBUG';

/*
REM *********************************************************************
REM *
REM * FILE:    GMEUDBGB.pls
REM * PURPOSE: Package Body for the GME debug utilities
REM * AUTHOR:  Olivier DABOVAL, OPM Development
REM * DATE:    27th MAY 2001
REM *
REM * PROCEDURE log_initialize
REM * PROCEDURE log
REM *
REM *
REM * HISTORY:
REM * ========
REM * 27-Jun-2001   Olivier DABOVAL
REM *          Created
REM * 05/03/03 Bharati Satpute Bug 2804440 Added WHEN OTHERS
REM * exception which were not defined
REM *
REM *  08-OCT-2004 Shrikant Nene Bug#3865212
REM *        As part of this bug removed the AND delete_mark = V_delete_mark
REM *        From the cursor for display_inventory_txns_gtmp
REM *        Also added subinventory field in the actual put_line statement
REM *        in the above procedure, as it contains the original trans_id
REM *
REM *
REM *
REM **********************************************************************
*/

   --========================================================================
-- PROCEDURE : Log_Initialize             PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
   PROCEDURE log_initialize (
      p_file_name   IN   VARCHAR2 DEFAULT '0'
     ,p_override    IN   NUMBER DEFAULT 0)
   IS
      l_location            VARCHAR2 (500);
      LOG                   UTL_FILE.file_type;
      l_api_name   CONSTANT VARCHAR2 (30)      := 'log_initialize';

      CURSOR c_get_1st_location
      IS
         SELECT NVL (SUBSTRB (VALUE, 1, INSTR (VALUE, ',') - 1), VALUE)
           FROM v$parameter
          WHERE NAME = 'utl_file_dir';
   BEGIN
      IF g_debug = -1 THEN
         g_log_mode := 'OFF';
      ELSE
         IF (TO_NUMBER (fnd_profile.VALUE ('CONC_REQUEST_ID') ) > 0) THEN
            g_log_mode := 'SRS';
         ELSIF p_file_name <> '0' THEN
            g_log_mode := 'LOG';
         ELSE
            g_log_mode := 'SQL';
         END IF;
      END IF;

      IF     (g_log_mode <> 'OFF' AND p_file_name <> '0')
         AND (g_file_name <> p_file_name OR p_override = 1) THEN
         IF (fnd_global.user_id > 0) THEN
            g_log_username := fnd_global.user_name;
         ELSE
            g_log_username := 'GME_NO_USER';
         END IF;

         OPEN c_get_1st_location;

         FETCH c_get_1st_location
          INTO g_log_location;

         CLOSE c_get_1st_location;

         LOG :=
            UTL_FILE.fopen (g_log_location
                           , g_log_username || p_file_name
                           ,'w'
                           ,32767);
         UTL_FILE.put_line (LOG
                           ,    'Log file opened at '
                             || TO_CHAR (SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
                             || ' With log mode: '
                             || g_log_mode);
         UTL_FILE.fflush (LOG);
         UTL_FILE.fclose (LOG);
         g_file_name := p_file_name;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg ('GME_DEBUG', 'LOG_INITIALIZE');

         IF g_debug IS NOT NULL THEN
            gme_debug.put_line ('Error in ' || SQLERRM);
         END IF;
   END log_initialize;

--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_UNEXPECTED
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
   PROCEDURE put_line (
      p_msg         IN   VARCHAR2
     ,p_priority    IN   NUMBER DEFAULT 100
     ,p_file_name   IN   VARCHAR2 DEFAULT '0')
   IS
      LOG                   UTL_FILE.file_type;
      l_file_name           VARCHAR2 (50);
      l_api_name   CONSTANT VARCHAR2 (30)      := 'PUT_LINE';

      CURSOR c_get_1st_location
      IS
         SELECT NVL (SUBSTR (VALUE, 1, INSTR (VALUE, ',') - 1), VALUE)
           FROM v$parameter
          WHERE NAME = 'utl_file_dir';
   BEGIN
      IF ( (g_log_mode <> 'OFF') AND (NVL (p_priority, 100) >= g_debug) ) THEN
         IF g_log_mode = 'LOG' THEN
            IF p_file_name = '0' THEN
               l_file_name := g_file_name;
            ELSE
               l_file_name := p_file_name;
            END IF;

            LOG :=
               UTL_FILE.fopen (g_log_location
                              , g_log_username || l_file_name
                              ,'a'
                              ,32767);
            UTL_FILE.put_line (LOG, p_msg);
            UTL_FILE.fflush (LOG);
            UTL_FILE.fclose (LOG);
         ELSIF (g_log_mode = 'SQL') THEN
            -- SQL*Plus session: uncomment the next line during unit test
            --DBMS_OUTPUT.put_line(p_msg);
            NULL;
         ELSE
            -- Concurrent request
            fnd_file.put_line (fnd_file.LOG, p_msg);
         END IF;
      END IF;
   --Bug2804440
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END put_line;

   PROCEDURE display_messages (p_msg_count IN NUMBER)
   IS
      MESSAGE               VARCHAR2 (2000);
      dummy                 NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30)   := 'DISPLAY_MESSAGES';
   BEGIN
      FOR i IN 1 .. p_msg_count LOOP
         fnd_msg_pub.get (p_msg_index          => i
                         ,p_data               => MESSAGE
                         ,p_encoded            => 'F'
                         ,p_msg_index_out      => dummy);
         gme_debug.put_line ('Message ' || TO_CHAR (i) || ' ' || MESSAGE);
      END LOOP;
   --Bug2804440
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END display_messages;

   PROCEDURE display_resource_gtmp (
      p_batchstep_resource_id   IN   NUMBER
     ,p_batchstep_id            IN   NUMBER
     ,p_batch_id                IN   NUMBER
     ,p_delete_mark             IN   NUMBER DEFAULT 0)
   IS
      l_resource_ids        gme_common_pvt.number_tab;
      l_resources           NUMBER;
      i                     NUMBER;
      l_api_name   CONSTANT VARCHAR2 (30)          := 'display_resource_gtmp';

      CURSOR get_batchstep_resource_id (v_batchstep_id IN NUMBER)
      IS
         SELECT   batchstep_resource_id
             FROM gme_batch_step_resources
            WHERE batchstep_id = v_batchstep_id
         ORDER BY 1;

      CURSOR get_temp_table (
         v_doc_id        IN   NUMBER
        ,v_line_id       IN   NUMBER
        ,v_delete_mark   IN   NUMBER)
      IS
         SELECT   *
             FROM gme_resource_txns_gtmp
            WHERE (doc_id = v_doc_id OR v_doc_id IS NULL)
              AND (line_id = v_line_id OR v_line_id IS NULL)
              AND delete_mark = v_delete_mark
         ORDER BY doc_id, line_id, resources, poc_trans_id;
   BEGIN
      gme_debug.put_line ('Resource transactions temp table');
      gme_debug.put_line
         ('organization_id/line_id/trans_id/trans_date/resources/resource_usage/trans_um/overrided_protected_ind/completed_ind/action_code/reason_id');

      IF p_batchstep_id IS NOT NULL THEN
         OPEN get_batchstep_resource_id (p_batchstep_id);

         FETCH get_batchstep_resource_id
         BULK COLLECT INTO l_resource_ids;

         CLOSE get_batchstep_resource_id;
      ELSE
         l_resource_ids (1) := p_batchstep_resource_id;
      END IF;

      l_resources := l_resource_ids.COUNT;

      IF l_resources = 0 THEN
         l_resources := 1;
      END IF;

      i := 1;

      WHILE i <= l_resources LOOP
         FOR rec IN get_temp_table (p_batch_id
                                   ,l_resource_ids (i)
                                   ,p_delete_mark) LOOP
            gme_debug.put_line (rec.organization_id ||'/'
                                || rec.line_id
                                || '/'
                                || rec.poc_trans_id
                                || '/'
                                || TO_CHAR (rec.trans_date
                                           ,'MM/DD/YYYY HH24:MI:SS')
                                || '/'
                                || rec.resources
                                || '/'
                                || rec.resource_usage
                                || '/'
                                || rec.trans_um
                                || '/'
                                || rec.overrided_protected_ind
                                || '/'
                                || rec.completed_ind
                                || '/'
                                || rec.action_code
                                || '/'
                                || rec.reason_id);
         END LOOP;

         i := i + 1;
      END LOOP;
   --Bug2804440
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   --End Bug2804440
   END display_resource_gtmp;

   PROCEDURE display_exceptions_gtmp (
      p_organization_id      IN   NUMBER
     ,p_material_detail_id   IN   NUMBER
     ,p_batch_id             IN   NUMBER)
   IS
      l_api_name   CONSTANT VARCHAR2 (30) := 'display_exceptions_gtmp';

      CURSOR get_temp_table (
         v_organization_id      IN   NUMBER
        ,v_batch_id             IN   NUMBER
        ,v_material_detail_id   IN   NUMBER)
      IS
         SELECT   *
             FROM gme_exceptions_gtmp
            WHERE organization_id = v_organization_id
              AND (batch_id = v_batch_id OR v_batch_id IS NULL)
              AND (   material_detail_id = v_material_detail_id
                   OR v_material_detail_id IS NULL)
         ORDER BY batch_id, material_detail_id;
   BEGIN
      gme_debug.put_line ('Exceptions temp table');
      gme_debug.put_line
         ('batch_id/material_detail_id/Pend MO/Pend Rsv/onhand/ATT/ATR/TRANSACTED/EXCEPTION');

      FOR rec IN get_temp_table (p_organization_id
                                ,p_batch_id
                                ,p_material_detail_id) LOOP
         gme_debug.put_line (   rec.batch_id
                             || '/'
                             || rec.material_detail_id
                             || '/'
                             || rec.pending_move_order_ind
                             || '/'
                             || rec.pending_reservations_ind
                             || '/'
                             || rec.onhand_qty
                             || '/'
                             || rec.att
                             || '/'
                             || rec.atr
                             || '/'
                             || rec.transacted_qty
                             || '/'
                             || rec.exception_qty);
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END display_exceptions_gtmp;

   PROCEDURE display_inventory_gtmp
( p_material_detail_id	        IN NUMBER
 ,p_batch_id          	        IN NUMBER
 ,p_delete_mark       	        IN NUMBER DEFAULT 0
) IS

	BEGIN
		NULL ;
	END display_inventory_gtmp;

  /*###############################################################
  # NAME
  #	dump_temp_txns_exceptions
  # SYNOPSIS
  #	proc dump_temp_txns_exceptions
  # DESCRIPTION
  #     This procedure is used to retrieve all temporary txns
  #     created by release/complete or IB processes.
  ###############################################################*/
  PROCEDURE dump_temp_txns_exceptions IS
  BEGIN
    IF (g_debug IS NOT NULL) THEN
      gme_debug.put_line('***** Txns created automatically by release/complete/IB etc. *****');
      FOR get_rec IN (SELECT * FROM mtl_material_transactions_temp WHERE transaction_header_id = gme_common_pvt.g_transaction_header_id) LOOP
        gme_debug.put_line('Batch_id = '||get_rec.transaction_source_id||' material_detail_id = '||get_rec.trx_source_line_id||
                           ' inventory_item_id = '||get_rec.inventory_item_id||' revision = '||get_rec.revision||
                           ' subinventory = '||get_rec.subinventory_code||' locator_id = '||get_rec.locator_id||
                           ' transaction_quantity = '||get_rec.transaction_quantity||' transaction_uom = '||get_rec.transaction_uom||
                           ' sec_transaction_qty  = '||get_rec.secondary_transaction_quantity);
      END LOOP;
      gme_debug.put_line('***** End Txns created automatically by release/complete/IB etc. ***** ');
      gme_debug.put_line('***** Exceptions created by release/complete/IB etc. *****');
      FOR get_rec IN (SELECT * FROM gme_exceptions_gtmp) LOOP
        gme_debug.put_line('Batch_id = '||get_rec.batch_id||' material_detail_id = '||get_rec.material_detail_id||
                           ' transacted_qty = '||get_rec.transacted_qty||' exception_qty = '||get_rec.exception_qty||
                           ' pending_move_order = '||get_rec.pending_move_order_ind||' pending_rsv_ind = '||get_rec.pending_reservations_ind);
      END LOOP;
      gme_debug.put_line('***** End Exceptions created by release/complete/IB etc. *****');
    END IF;
  END dump_temp_txns_exceptions;

END gme_debug;

/
