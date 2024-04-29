--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_DMLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_DMLS_PKG" as
/* $Header: AFOAMDSDMLB.pls 120.6 2006/06/07 18:02:20 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_DMLS_PKG.';

   --exception used by INTERNAL_EXECUTE to do common cleanup code when failing an execute
   EXECUTE_FAILED               EXCEPTION;

   ----------------------------------------
   -- Private Body Types/Variables
   ----------------------------------------
   TYPE b_dml_cache_entry IS RECORD
      (
       dml_id                   NUMBER(15)      := NULL,
       cursor_id                INTEGER         := NULL,
       arg_list                 FND_OAM_DSCRAM_ARGS_PKG.arg_list,
       use_splitting            BOOLEAN         := FALSE,
       has_writable_args        BOOLEAN         := FALSE,
       rows_processed           NUMBER          := NULL,
       last_execute_ret_sts     VARCHAR2(3)     := NULL,
       last_execute_ret_msg     VARCHAR2(2048)  := NULL
       );
   TYPE b_dml_cache_type IS TABLE OF b_dml_cache_entry INDEX BY BINARY_INTEGER;

   -- Package cache of DMLs that have been prepared and parsed
   -- into a dbms_sql cursor
   b_dml_cache          b_dml_cache_type;

   -- DML ID of the currently executing DML
   b_current_dml_id     NUMBER := NULL;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_CURRENT_DML_ID
      RETURN NUMBER
   IS
   BEGIN
      IF b_current_dml_id IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_current_dml_id;
   END;

   -- Public
   PROCEDURE FETCH_DML_IDS(p_unit_id            IN              NUMBER,
                           x_work_queue         OUT NOCOPY      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type,
                           x_return_status      OUT NOCOPY      VARCHAR2,
                           x_return_msg         OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_DML_IDS';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_priorities      DBMS_SQL.NUMBER_TABLE;
      l_weights         DBMS_SQL.NUMBER_TABLE;

      l_work_queue      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type := FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type();
      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- bulk select all valid dmls with work to do
      SELECT dml_id, priority, weight
         BULK COLLECT INTO l_ids, l_priorities, l_weights
         FROM fnd_oam_dscram_dmls
         WHERE unit_id = p_unit_id
         AND finished_ret_sts IS NULL
         ORDER BY priority ASC, weight DESC;

      --allocate the work queue
      l_work_queue.EXTEND(l_ids.COUNT);

      --since we select them in the proper order, construct the work queue by doing a single pass of the array
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         l_work_queue(k) := FND_OAM_DSCRAM_UNITS_PKG.CREATE_WORK_ITEM(l_priorities(k),
                                                                      l_weights(k),
                                                                      FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                                                      l_ids(k));
         k := l_ids.NEXT(k);
      END LOOP;

      --success
      x_work_queue := l_work_queue;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unit ID ('||p_unit_id||') failed to fetch dml_ids: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE UPDATE_COMP_DML_WRITABLE_ARGS(p_dml_id             IN NUMBER,
                                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                           p_using_splitting    IN BOOLEAN,
                                           x_return_status      OUT NOCOPY VARCHAR2,
                                           x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_COMP_DML_WRITABLE_ARGS';

      l_arg_list                FND_OAM_DSCRAM_ARGS_PKG.arg_list;
      l_has_writable_args       BOOLEAN;
      l_dml_cache_entry         b_dml_cache_entry;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the dml's in the cache, if not we need to fetch its arg list now to update the writable args
      --and place it in the cache if its possible that we will update an arg here.
      IF NOT b_dml_cache.EXISTS(p_dml_id) THEN
         --fetch the arg list first
         FND_OAM_DSCRAM_ARGS_PKG.FETCH_ARG_LIST(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                                p_dml_id,
                                                l_arg_list,
                                                l_has_writable_args,
                                                l_return_status,
                                                l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND l_has_writable_args THEN
            --to allow these args to be pushed into the context, we also need to make a dml cache entry so that
            --destroy_dml_cache_entry can get the computed value
            l_dml_cache_entry.dml_id := p_dml_id;
            l_dml_cache_entry.arg_list := l_arg_list;
            l_dml_cache_entry.use_splitting := p_using_splitting;
            l_dml_cache_entry.has_writable_args := l_has_writable_args;
            b_dml_cache(p_dml_id) := l_dml_cache_entry;
         END IF;
      END IF;

      --if the dml made it into the cache and has writable args, update them
      IF b_dml_cache.EXISTS(p_dml_id) AND b_dml_cache(p_dml_id).has_writable_args THEN
         FND_OAM_DSCRAM_ARGS_PKG.UPDATE_WRITABLE_ARG_VALUES(b_dml_cache(p_dml_id).arg_list,
                                                            px_arg_context,
                                                            TRUE,
                                                            b_dml_cache(p_dml_id).use_splitting,
                                                            NULL,
                                                            NULL,
                                                            NULL,
                                                            l_return_status,
                                                            l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      END IF;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private helper to the destroy procedures to do the actual work of destroying a
   -- cache entry, assumes p_dml_id is in the cache.
   PROCEDURE INTERNAL_DESTROY_CACHE_ENTRY(p_dml_id              IN NUMBER,
                                          px_arg_context        IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                          p_update_context      IN BOOLEAN,
                                          x_return_status       OUT NOCOPY VARCHAR2,
                                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_DESTROY_CACHE_ENTRY';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- if requested, roll the arg list into the context
      IF p_update_context THEN
         FND_OAM_DSCRAM_ARGS_PKG.UPDATE_CONTEXT_USING_ARG_LIST(px_arg_context,
                                                               b_dml_cache(p_dml_id).arg_list,
                                                               b_dml_cache(p_dml_id).use_splitting);
      END IF;

      --first destroy the argument list
      FND_OAM_DSCRAM_ARGS_PKG.DESTROY_ARG_LIST(b_dml_cache(p_dml_id).arg_list,
                                               l_return_status,
                                               l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         RETURN;
      END IF;

      --now de-allocate the local cursor
      IF b_dml_cache(p_dml_id).cursor_id IS NOT NULL AND DBMS_SQL.IS_OPEN(b_dml_cache(p_dml_id).cursor_id) THEN
         DBMS_SQL.CLOSE_CURSOR(b_dml_cache(p_dml_id).cursor_id);
      END IF;

      --remove the dml from the cache
      b_dml_cache.DELETE(p_dml_id);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE DESTROY_DML_CACHE_ENTRY(p_dml_id           IN NUMBER,
                                     px_arg_context     IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                     p_update_context   IN BOOLEAN,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_DML_CACHE_ENTRY';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the dml's in the cache and get it's entry
      IF NOT b_dml_cache.EXISTS(p_dml_id) THEN
         --not existing is fine here
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(1, l_ctxt, 'DML ID ('||p_dml_id||') not found in cache.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --call the internal procedure to do the work and return the status of the operation
      INTERNAL_DESTROY_CACHE_ENTRY(p_dml_id,
                                   px_arg_context,
                                   p_update_context,
                                   x_return_status,
                                   x_return_msg);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE DESTROY_DML_CACHE(px_arg_context   IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_return_msg     OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_DML_CACHE';

      k                         NUMBER;
      l_found_failure           BOOLEAN := FALSE;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --loop through what's left in the cache, destroying each, ignore rolling the args into the context
      k := b_dml_cache.FIRST;
      WHILE k IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'DML ID: '||k);
         INTERNAL_DESTROY_CACHE_ENTRY(k,
                                      px_arg_context,
                                      FALSE,
                                      l_return_status,
                                      l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_found_failure := TRUE;
            --don't return, let it try to destroy the others first
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
         END IF;

         k := b_dml_cache.NEXT(k);
      END LOOP;

      --delete all members of the cache even if some failed
      b_dml_cache.DELETE;

      IF NOT l_found_failure THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE COMPLETE_DML(p_dml_id              IN NUMBER,
                          p_finished_ret_sts    IN VARCHAR2,
                          p_message             IN VARCHAR2,
                          p_workers_assigned    IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_DML';

      l_message                 VARCHAR2(2048);
      l_finished_ret_sts        VARCHAR2(3);
      l_finished_status         VARCHAR2(30);
      l_rows_processed          NUMBER := 0;

      l_dml_in_cache            BOOLEAN;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the dml's in the cache
      IF b_dml_cache.EXISTS(p_dml_id) THEN
         l_dml_in_cache := TRUE;
      ELSE
         -- its possible for a split dml to execute but not have any ad units.  In this case,
         -- the dml will not make it into the cache since there's no point in parsing it. Instead
         -- we just need to complete the record if workers_assigned = 1.
         l_dml_in_cache := FALSE;
         fnd_oam_debug.log(1, l_ctxt, 'DML id ('||p_dml_id||') not in dml cache. This happens.');
      END IF;

      --perform a blocking select for update on the DML, allows sequencing of rows_processed updates
      SELECT finished_ret_sts
         INTO l_finished_ret_sts
         FROM fnd_oam_dscram_dmls
         WHERE dml_id = p_dml_id
         FOR UPDATE;

      --make sure it's not already finished, only the last complete_dml should do this
      IF l_finished_ret_sts IS NOT NULL THEN
         x_return_msg := 'DML id ('||p_dml_id||') has finished already set.  This should not happen.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         --don't rollback, parent can do it
         RETURN;
      END IF;

      --only deal with the finished state if we're the last worker
      IF p_workers_assigned IS NOT NULL AND p_workers_assigned = 1 THEN
         --default the status, message to those of the last execute if not passed in explicitly
         IF l_dml_in_cache THEN
            l_finished_ret_sts := NVL(p_finished_ret_sts, b_dml_cache(p_dml_id).last_execute_ret_sts);
            l_message := NVL(p_message, b_dml_cache(p_dml_id).last_execute_ret_msg);
            l_rows_processed := NVL(b_dml_cache(p_dml_id).rows_processed, 0);
         ELSE
            l_finished_ret_sts := p_finished_ret_sts;
            l_message := p_message;
         END IF;
         l_finished_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_RET_STS_TO_COMPL_STATUS(l_finished_ret_sts);

         fnd_oam_debug.log(1, l_ctxt, 'Finished DML with Status: '||l_finished_status||'('||l_finished_ret_sts||')');

         --update the dml
         UPDATE fnd_oam_dscram_dmls
            SET finished_ret_sts = l_finished_ret_sts
            WHERE dml_id = p_dml_id;

         --dump a stats row as well
         FND_OAM_DSCRAM_STATS_PKG.COMPLETE_ENTRY(p_source_object_type   => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                                 p_source_object_id     => p_dml_id,
                                                 p_end_time             => SYSDATE,
                                                 p_end_message          => l_message,
                                                 p_postend_status       => l_finished_status);
      ELSIF l_dml_in_cache THEN
         l_rows_processed := NVL(b_dml_cache(p_dml_id).rows_processed, 0);
      END IF;

      --always update the number of rows processed
      UPDATE fnd_oam_dscram_dmls
         SET rows_processed = NVL(rows_processed, 0) + l_rows_processed, --needed since its different for each dml and not stored in AD
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE dml_id = p_dml_id;

      --exit without committing, leave that to the parent

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private wrapper on COMPLETE_DML to do it in an autonomous transaction.  This is often used when
   -- a piece of work has failed and we want to update the metadata even though the data will be
   -- rolled back.
   PROCEDURE COMPLETE_DML_AUTONOMOUSLY(p_dml_id                 IN NUMBER,
                                       p_finished_ret_sts       IN VARCHAR2,
                                       p_message                IN VARCHAR2,
                                       p_workers_assigned       IN NUMBER,
                                       x_return_status          OUT NOCOPY VARCHAR2,
                                       x_return_msg             OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_DML_AUTONOMOUSLY';
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      COMPLETE_DML(p_dml_id,
                   p_finished_ret_sts,
                   p_message,
                   p_workers_assigned,
                   x_return_status,
                   x_return_msg);
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         COMMIT;
         fnd_oam_debug.log(1, l_ctxt, 'Committed completion of DML ('||p_dml_id||')');
      ELSE
         fnd_oam_debug.log(3, l_ctxt, 'Failed to complete DML ('||p_dml_id||') autonomously: status('||x_return_status||'), message('||x_return_msg||')');
         ROLLBACK;
      END IF;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private: helper to ADD_DML_TO_CACHE to prepare the final statement for a DML.  This is
   -- autonomous to keep from commiting data on the transaction.
   PROCEDURE GENERATE_FINAL_DML_STMT(p_dml_id           IN NUMBER,
                                     px_arg_context     IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                     p_use_splitting    IN BOOLEAN,
                                     x_final_dml_stmt   OUT NOCOPY VARCHAR2,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'GENERATE_FINAL_DML_STMT';

      l_dml_stmt        VARCHAR2(4000);
      l_where_clause    VARCHAR2(4000);
      l_final_dml_stmt  VARCHAR2(4000);

      l_stmt_length     NUMBER;
      l_stmt_maxlen     NUMBER := 4000;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --assume that the check already occured in add_dml_to_cache so proceed right to the lock
      SELECT dml_stmt, dml_where_clause, dml_final_stmt
         INTO l_dml_stmt, l_where_clause, l_final_dml_stmt
         FROM fnd_oam_dscram_dmls
         WHERE dml_id = p_dml_id
         FOR UPDATE;

      --make sure the final stmt's still null
      IF l_final_dml_stmt IS NOT NULL THEN
         x_final_dml_stmt := l_final_dml_stmt;
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --prepare the final stmt from the stmt, where clause and possible the rowid restrict where clause
      FND_OAM_DSCRAM_UTILS_PKG.MAKE_FINAL_SQL_STMT(px_arg_context,
                                                   l_dml_stmt,
                                                   l_where_clause,
                                                   p_use_splitting,
                                                   l_final_dml_stmt,
                                                   l_return_status,
                                                   l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         --commit the stats entry, make_final just does string manipulation
         COMMIT;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --store this string as the final stmt
      UPDATE fnd_oam_dscram_dmls
         SET dml_final_stmt = l_final_dml_stmt,
         stats_finished = FND_API.G_FALSE,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE dml_id = p_dml_id;

      --commit the autonomous txn to release the lock
      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_final_dml_stmt := l_final_dml_stmt;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'DML ID ('||p_dml_id||'), failed to generate final dml stmt: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private helper to EXECUTE_DML* to take a foreign dml_id and prepare it by generating the
   -- final dml statement if necessary, parsing it into a cursor and fetching the arg list
   PROCEDURE ADD_DML_TO_CACHE(p_dml_id          IN NUMBER,
                              px_arg_context    IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                              p_use_splitting   IN BOOLEAN,
                              x_return_status   OUT NOCOPY VARCHAR2,
                              x_return_msg      OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_DML_TO_CACHE';

      l_stat_id         NUMBER;
      l_cache_entry     b_dml_cache_entry;
      l_final_dml_stmt  VARCHAR2(4000);
      l_cursor_id       INTEGER;
      l_arg_list        FND_OAM_DSCRAM_ARGS_PKG.arg_list;
      l_has_writable_args       BOOLEAN;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_temp            VARCHAR2(30);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --if the dml isn't cached, there's a chance that its stats row hasn't been created yet, query and
      --create if necessary.  This is not mt-safe but extra calls to create_entry will be discarded due to
      --the unique index on fnd_oam_dscram_stats.
      IF NOT FND_OAM_DSCRAM_STATS_PKG.HAS_ENTRY(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                                p_dml_id) THEN
         --autonomously create the stats entry
         FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY_AUTONOMOUSLY(p_source_object_type        => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                                            p_source_object_id          => p_dml_id,
                                                            p_start_time                => SYSDATE,
                                                            p_prestart_status           => NULL,
                                                            p_dismiss_failure           => FND_API.G_TRUE,
                                                            x_stat_id                   => l_stat_id);
      END IF;

      --query out the prepared DML statement
      SELECT dml_final_stmt
         INTO l_final_dml_stmt
         FROM fnd_oam_dscram_dmls
         WHERE dml_id = p_dml_id;

      --if it's not present, generate it
      IF l_final_dml_stmt IS NULL THEN
         GENERATE_FINAL_DML_STMT(p_dml_id,
                                 px_arg_context,
                                 p_use_splitting,
                                 l_final_dml_stmt,
                                 l_return_status,
                                 l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      END IF;

      --got a final stmt, put it into a cursor
      l_cursor_id := DBMS_SQL.OPEN_CURSOR;
      BEGIN
         DBMS_SQL.PARSE(l_cursor_id,
                        l_final_dml_stmt,
                        DBMS_SQL.NATIVE);
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            x_return_msg := 'DML_ID ('||p_dml_id||'), failed to parse final stmt: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      --now lets get the arg list for the dml
      FND_OAM_DSCRAM_ARGS_PKG.FETCH_ARG_LIST(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                                             p_dml_id,
                                             l_arg_list,
                                             l_has_writable_args,
                                             l_return_status,
                                             l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --SUCCESS, update internal structures

      --initialize the entry
      l_cache_entry.dml_id := p_dml_id;
      l_cache_entry.cursor_id := l_cursor_id;
      l_cache_entry.arg_list := l_arg_list;
      l_cache_entry.use_splitting := p_use_splitting;
      l_cache_entry.has_writable_args := l_has_writable_args;
      l_cache_entry.rows_processed := 0;
      l_cache_entry.last_execute_ret_sts := NULL;
      l_cache_entry.last_execute_ret_msg := NULL;

      --store the entry in the cache
      b_dml_cache(p_dml_id) := l_cache_entry;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'DML ID ('||p_dml_id||'), failed to add to cache: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private, helper to EXECUTE_DML* procedures to do the grunt work.  the call to complete the DML
   -- will be done by the caller.  No commits or rollbacks are done here.
   PROCEDURE INTERNAL_EXECUTE_DML(p_dml_id              IN NUMBER,
                                  px_arg_context        IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                  p_use_splitting       IN BOOLEAN,
                                  p_rowid_lbound        IN ROWID,
                                  p_rowid_ubound        IN ROWID,
                                  x_rows_processed      OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_EXECUTE_DML';

      l_rows_processed  NUMBER;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'DML ID: '||p_dml_id);

      --set the current dml id before binding args to allow for access of the dml_id from a state argument
      b_current_dml_id := p_dml_id;

      --first see if the dml's in the cache
      IF b_dml_cache.EXISTS(p_dml_id) THEN
         --make sure the cursor isn't configured for splitting
         IF b_dml_cache(p_dml_id).use_splitting <> p_use_splitting THEN
            x_return_msg := 'DML ID ('||p_dml_id||'), cached splitting enabled not equal to provided splitting enabled.  This should not happen.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            RAISE EXECUTE_FAILED;
         END IF;
      ELSE
         --no cache entry, create one
         ADD_DML_TO_CACHE(p_dml_id,
                          px_arg_context,
                          p_use_splitting,
                          l_return_status,
                          l_return_msg);
         --react to the return status to skip execution if we failed
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            RAISE EXECUTE_FAILED;
         END IF;
      END IF;

      --before every execution, re-bind the readable argument values.  This may or may not change the
      --value of the binding depending on the arg's write policy.
      FND_OAM_DSCRAM_ARGS_PKG.BIND_ARG_LIST_TO_CURSOR(b_dml_cache(p_dml_id).arg_list,
                                                      px_arg_context,
                                                      b_dml_cache(p_dml_id).cursor_id,
                                                      p_use_splitting,
                                                      p_rowid_lbound,
                                                      p_rowid_ubound,
                                                      l_return_status,
                                                      l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         RAISE EXECUTE_FAILED;
      END IF;

      --cache entry should be valid now, do additional bindings if needed
      IF p_use_splitting THEN
         fnd_oam_debug.log(1, l_ctxt, 'Binding lower('||p_rowid_lbound||') and upper('||p_rowid_ubound||') rowids');
         DBMS_SQL.BIND_VARIABLE(b_dml_cache(p_dml_id).cursor_id,
                                FND_OAM_DSCRAM_UTILS_PKG.G_ARG_ROWID_LBOUND_NAME,
                                p_rowid_lbound);
         DBMS_SQL.BIND_VARIABLE(b_dml_cache(p_dml_id).cursor_id,
                                FND_OAM_DSCRAM_UTILS_PKG.G_ARG_ROWID_UBOUND_NAME,
                                p_rowid_ubound);
      END IF;

      --skip the execute if we're in test-no-exec mode
      IF FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE = FND_OAM_DSCRAM_UTILS_PKG.G_MODE_TEST_NO_EXEC THEN
         fnd_oam_debug.log(1, l_ctxt, 'Skipping Executiong due to run mode.');
         l_rows_processed := 0;
      ELSE
         --do the execute
         fnd_oam_debug.log(1, l_ctxt, 'Executing cursor...');
         BEGIN
            l_rows_processed := DBMS_SQL.EXECUTE(b_dml_cache(p_dml_id).cursor_id);
         EXCEPTION
            WHEN OTHERS THEN
               x_return_msg := 'SQL execute error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               RAISE EXECUTE_FAILED;
         END;
         fnd_oam_debug.log(1, l_ctxt, '...Done.('||l_rows_processed||' rows)');
      END IF;

      -- If the dml has any output variables, we should get values for them now if we can
      IF b_dml_cache(p_dml_id).has_writable_args THEN
         FND_OAM_DSCRAM_ARGS_PKG.UPDATE_WRITABLE_ARG_VALUES(b_dml_cache(p_dml_id).arg_list,
                                                            px_arg_context,
                                                            NOT p_use_splitting,        --we're finished if we're not splitting
                                                            p_use_splitting,
                                                            p_rowid_lbound,
                                                            p_rowid_ubound,
                                                            b_dml_cache(p_dml_id).cursor_id,
                                                            l_return_status,
                                                            l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            RAISE EXECUTE_FAILED;
         END IF;
      END IF;

      -- Success
      b_current_dml_id := NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_rows_processed := l_rows_processed;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
    EXCEPTION
       WHEN EXECUTE_FAILED THEN
          b_current_dml_id := NULL;
          fnd_oam_debug.log(2, l_ctxt, 'EXIT');
          RETURN;
       WHEN OTHERS THEN
          b_current_dml_id := NULL;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
          fnd_oam_debug.log(6, l_ctxt, x_return_msg);
          fnd_oam_debug.log(2, l_ctxt, 'EXIT');
          RETURN;
   END;

   -- Public
   PROCEDURE EXECUTE_DML(p_dml_id               IN NUMBER,
                         px_arg_context         IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_DML';
      l_rows_processed  NUMBER;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_return_status2  VARCHAR2(6);
      l_return_msg2     VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --do the single-threaded execute
      INTERNAL_EXECUTE_DML(p_dml_id,
                           px_arg_context,
                           FALSE,
                           NULL,
                           NULL,
                           l_rows_processed,
                           l_return_status,
                           l_return_msg);

      -- if successful, complete the dml
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         --update the rows dml cache's derived attributes
         b_dml_cache(p_dml_id).rows_processed := b_dml_cache(p_dml_id).rows_processed + l_rows_processed;
         b_dml_cache(p_dml_id).last_execute_ret_sts := l_return_status;
         b_dml_cache(p_dml_id).last_execute_ret_msg := l_return_msg;

         --complete differently based on the run mode
         IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
            --complete the dml as part of the transaction
            COMPLETE_DML(p_dml_id,
                         l_return_status,
                         l_return_msg,
                         1,
                         x_return_status,
                         x_return_msg);
         ELSE
            --if not in normal mode, or our writable args action failed, we need to complete autonomously
            COMPLETE_DML_AUTONOMOUSLY(p_dml_id,
                                      l_return_status,
                                      l_return_msg,
                                      1,
                                      x_return_status,
                                      x_return_msg);
         END IF;
       ELSE
          --update the rows dml cache's derived attributes
          IF b_dml_cache.EXISTS(p_dml_id) THEN
             b_dml_cache(p_dml_id).last_execute_ret_sts := l_return_status;
             b_dml_cache(p_dml_id).last_execute_ret_msg := l_return_msg;
          END IF;

         --if failed, complete it autonomously since the data will be rolled back and errors override
         --this does not need to be atomic with the unit update since individually executed DMLs are
         --not queried concurrently and passing the data back to the unit to commit is extra unnecessary work.
         COMPLETE_DML_AUTONOMOUSLY(p_dml_id,
                                   l_return_status,
                                   l_return_msg,
                                   1,
                                   l_return_status2,
                                   l_return_msg2);

         --return status/msg of execute failure, not possible complete failure
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE EXECUTE_DML_ON_RANGE(p_dml_id              IN NUMBER,
                                  px_arg_context        IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                  p_rowid_lbound        IN ROWID,
                                  p_rowid_ubound        IN ROWID,
                                  x_rows_processed      OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_DML_ON_RANGE';

      l_rows_processed          NUMBER;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      INTERNAL_EXECUTE_DML(p_dml_id,
                           px_arg_context,
                           TRUE,
                           p_rowid_lbound,
                           p_rowid_ubound,
                           l_rows_processed,
                           l_return_status,
                           l_return_msg);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         --update the rows dml cache's derived attributes
         b_dml_cache(p_dml_id).rows_processed := b_dml_cache(p_dml_id).rows_processed + l_rows_processed;
         b_dml_cache(p_dml_id).last_execute_ret_sts := l_return_status;
         b_dml_cache(p_dml_id).last_execute_ret_msg := l_return_msg;
      ELSE
         --update the rows dml cache's derived attributes
         IF b_dml_cache.EXISTS(p_dml_id) THEN
            b_dml_cache(p_dml_id).last_execute_ret_sts := l_return_status;
            b_dml_cache(p_dml_id).last_execute_ret_msg := l_return_msg;
         END IF;

         --return status/msg of execute failure
         x_rows_processed := 0;
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --success
      x_rows_processed := l_rows_processed;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

END FND_OAM_DSCRAM_DMLS_PKG;

/
