--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_PLSQLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_PLSQLS_PKG" as
/* $Header: AFOAMDSPLSB.pls 120.2 2006/06/07 18:04:33 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_PLSQLS_PKG.';

   --exception used by INTERNAL_EXECUTE to do common cleanup code when failing an execute
   EXECUTE_FAILED               EXCEPTION;

   ----------------------------------------
   -- Private Body Types/Variables
   ----------------------------------------
   TYPE b_plsql_cache_entry IS RECORD
      (
       plsql_id                 NUMBER(15)      := NULL,
       cursor_id                INTEGER         := NULL,
       arg_list                 FND_OAM_DSCRAM_ARGS_PKG.arg_list,
       use_splitting            BOOLEAN         := FALSE,          --not needed for plsqls, just for args of plsql
       has_writable_args        BOOLEAN         := FALSE,
       last_execute_ret_sts     VARCHAR2(3)     := NULL,
       last_execute_ret_msg     VARCHAR2(2048)  := NULL
       );
   TYPE b_plsql_cache_type IS TABLE OF b_plsql_cache_entry INDEX BY BINARY_INTEGER;

   -- Package cache of PLSQLs that have been prepared and parsed
   -- into a dbms_sql cursor
   b_plsql_cache                b_plsql_cache_type;

   -- PLSQL ID of the currently executing PLSQL
   b_current_plsql_id   NUMBER := NULL;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_CURRENT_PLSQL_ID
      RETURN NUMBER
   IS
   BEGIN
      IF b_current_plsql_id IS NULL THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_current_plsql_id;
   END;

   -- Public
   PROCEDURE FETCH_PLSQL_IDS(p_unit_id          IN              NUMBER,
                             x_work_queue       OUT NOCOPY      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_PLSQL_IDS';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_priorities      DBMS_SQL.NUMBER_TABLE;
      l_weights         DBMS_SQL.NUMBER_TABLE;

      l_work_queue      FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type := FND_OAM_DSCRAM_UNITS_PKG.ordered_work_queue_type();
      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- bulk select all valid plsqls with work to do
      SELECT plsql_id, priority, weight
         BULK COLLECT INTO l_ids, l_priorities, l_weights
         FROM fnd_oam_dscram_plsqls
         WHERE unit_id = p_unit_id
         AND finished_ret_sts IS NULL
         ORDER BY priority ASC, weight DESC;

      --allocate the work queue
      l_work_queue.EXTEND(l_ids.COUNT);

      --since we select them in the proper order, construct the work queue by traversing the arrays
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         l_work_queue(k) := FND_OAM_DSCRAM_UNITS_PKG.CREATE_WORK_ITEM(l_priorities(k),
                                                                      l_weights(k),
                                                                      FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
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
         x_return_msg := 'Unit ID ('||p_unit_id||') failed to fetch plsql_ids: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE UPDATE_COMP_PLS_WRITABLE_ARGS(p_plsql_id           IN NUMBER,
                                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                           p_using_splitting    IN BOOLEAN,
                                           x_return_status      OUT NOCOPY VARCHAR2,
                                           x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'UPDATE_COMP_PLS_WRITABLE_ARGS';

      l_arg_list                FND_OAM_DSCRAM_ARGS_PKG.arg_list;
      l_has_writable_args       BOOLEAN;
      l_plsql_cache_entry       b_plsql_cache_entry;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the plsql's in the cache, if not we need to fetch its arg list now to update the writable args
      --and place it in the cache if its possible that we will update an arg here.
      IF NOT b_plsql_cache.EXISTS(p_plsql_id) THEN
         --fetch the arg list first
         FND_OAM_DSCRAM_ARGS_PKG.FETCH_ARG_LIST(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                                                   p_plsql_id,
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
            --to allow these args to be pushed into the context, we also need to make a plsql cache entry so that
            --destroy_plsql_cache_entries can get the computed value
            l_plsql_cache_entry.plsql_id := p_plsql_id;
            l_plsql_cache_entry.arg_list := l_arg_list;
            l_plsql_cache_entry.use_splitting := p_using_splitting;
            l_plsql_cache_entry.has_writable_args := l_has_writable_args;
            b_plsql_cache(p_plsql_id) := l_plsql_cache_entry;
         END IF;
      END IF;

      --if the plsql made it into the cache and has writable args, update them
      IF b_plsql_cache.EXISTS(p_plsql_id) AND b_plsql_cache(p_plsql_id).has_writable_args THEN
         FND_OAM_DSCRAM_ARGS_PKG.UPDATE_WRITABLE_ARG_VALUES(b_plsql_cache(p_plsql_id).arg_list,
                                                            px_arg_context,
                                                            TRUE,
                                                            b_plsql_cache(p_plsql_id).use_splitting,
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
   -- cache entry, assumes p_plsql_id is in the cache.
   PROCEDURE INTERNAL_DESTROY_CACHE_ENTRY(p_plsql_id            IN NUMBER,
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
                                                               b_plsql_cache(p_plsql_id).arg_list,
                                                               b_plsql_cache(p_plsql_id).use_splitting);
      END IF;

      --first destroy the argument list
      FND_OAM_DSCRAM_ARGS_PKG.DESTROY_ARG_LIST(b_plsql_cache(p_plsql_id).arg_list,
                                               l_return_status,
                                               l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         RETURN;
      END IF;

      --now de-allocate the local cursor
      IF b_plsql_cache(p_plsql_id).cursor_id IS NOT NULL AND DBMS_SQL.IS_OPEN(b_plsql_cache(p_plsql_id).cursor_id) THEN
         DBMS_SQL.CLOSE_CURSOR(b_plsql_cache(p_plsql_id).cursor_id);
      END IF;

      --remove the plsql from the cache
      b_plsql_cache.DELETE(p_plsql_id);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   PROCEDURE DESTROY_PLSQL_CACHE_ENTRY(p_plsql_id       IN NUMBER,
                                       px_arg_context   IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                       p_update_context IN BOOLEAN,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_return_msg     OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_PLSQL_CACHE_ENTRY';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the plsql's in the cache and get it's entry
      IF NOT b_plsql_cache.EXISTS(p_plsql_id) THEN
         --not existing is fine here
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(1, l_ctxt, 'PLSQL ID ('||p_plsql_id||') not found in cache.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --call the internal procedure to do the work and return the status of the operation
      INTERNAL_DESTROY_CACHE_ENTRY(p_plsql_id,
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
   PROCEDURE DESTROY_PLSQL_CACHE(px_arg_context         IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DESTROY_PLSQL_CACHE';

      k                         NUMBER;
      l_found_failure           BOOLEAN := FALSE;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --loop through what's left in the cache, destroying each, ignore rolling the args into the context
      k := b_plsql_cache.FIRST;
      WHILE k IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'PLSQL ID: '||k);
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

         k := b_plsql_cache.NEXT(k);
      END LOOP;

      --delete all members of the cache even if some failed
      b_plsql_cache.DELETE;

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
   PROCEDURE COMPLETE_PLSQL(p_plsql_id          IN NUMBER,
                            p_finished_ret_sts  IN VARCHAR2,
                            p_message           IN VARCHAR2,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_PLSQL';

      l_message                 VARCHAR2(2048);
      l_finished_ret_sts        VARCHAR2(3);
      l_finished_status         VARCHAR2(30);

      l_plsql_in_cache          BOOLEAN;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the plsql's in the cache
      IF b_plsql_cache.EXISTS(p_plsql_id) THEN
         l_plsql_in_cache := TRUE;
      ELSE
         -- its possible for a split plsql to execute but not have any ad units.  In this case,
         -- the plsql will not make it into the cache since there's no point in parsing it. Instead
         -- we just need to complete the record if workers_assigned = 1.
         l_plsql_in_cache := FALSE;
         fnd_oam_debug.log(1, l_ctxt, 'PLSQL id ('||p_plsql_id||') not in plsql cache. This happens.');
      END IF;

      --perform a blocking select for update on the PLSQL, shouldn't be contention since complete_plsql is called once
      --and shouldn't already be finished.
      SELECT finished_ret_sts
         INTO l_finished_ret_sts
         FROM fnd_oam_dscram_plsqls
         WHERE plsql_id = p_plsql_id
         FOR UPDATE;

      --make sure it's not already finished.
      IF l_finished_ret_sts IS NOT NULL THEN
         x_return_msg := 'PLSQL id ('||p_plsql_id||') has finished already set.  This should not happen.';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         --don't rollback, parent can do it
         RETURN;
      END IF;

      --go ahead and always update the finished_ret_sts, invariant assumes this is only called once for a plsql.

      --default the status, message to those of the last execute if not passed in explicitly
      IF l_plsql_in_cache THEN
         l_finished_ret_sts := NVL(p_finished_ret_sts, b_plsql_cache(p_plsql_id).last_execute_ret_sts);
         l_message := NVL(p_message, b_plsql_cache(p_plsql_id).last_execute_ret_msg);
      ELSE
         l_finished_ret_sts := p_finished_ret_sts;
         l_message := p_message;
      END IF;
      l_finished_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_RET_STS_TO_COMPL_STATUS(l_finished_ret_sts);

      fnd_oam_debug.log(1, l_ctxt, 'Finished PLSQL with Status: '||l_finished_status||'('||l_finished_ret_sts||')');

      --update the plsql
      UPDATE fnd_oam_dscram_plsqls
         SET finished_ret_sts = l_finished_ret_sts,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE plsql_id = p_plsql_id;

      --dump a stats row as well
      FND_OAM_DSCRAM_STATS_PKG.COMPLETE_ENTRY(p_source_object_type      => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                                              p_source_object_id        => p_plsql_id,
                                              p_end_time                => SYSDATE,
                                              p_end_message             => l_message,
                                              p_postend_status          => l_finished_status);

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

   -- Private wrapper on COMPLETE_PLSQL to do it in an autonomous transaction.  This is often used when
   -- a piece of work has failed and we want to update the metadata even though the data will be
   -- rolled back.
   PROCEDURE COMPLETE_PLSQL_AUTONOMOUSLY(p_plsql_id             IN NUMBER,
                                         p_finished_ret_sts     IN VARCHAR2,
                                         p_message              IN VARCHAR2,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      COMPLETE_PLSQL(p_plsql_id,
                     p_finished_ret_sts,
                     p_message,
                     x_return_status,
                     x_return_msg);
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   END;

   -- Private: helper to ADD_PLSQL_TO_CACHE to prepare the final statement for a PLSQL.  This is
   -- autonomous to keep from commiting data on the transaction.
   PROCEDURE GENERATE_FINAL_PLSQL_TEXT(p_plsql_id               IN NUMBER,
                                       px_arg_context           IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                       x_final_plsql_text       OUT NOCOPY VARCHAR2,
                                       x_return_status          OUT NOCOPY VARCHAR2,
                                       x_return_msg             OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'GENERATE_FINAL_PLSQL_TEXT';

      l_plsql_text              VARCHAR2(3000);
      l_final_plsql_text        VARCHAR2(4000);

      l_length          NUMBER;
      l_maxlen          NUMBER := 4000;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --assume that the check already occured in add_plsql_to_cache so proceed right to the lock
      SELECT plsql_text, plsql_final_text
         INTO l_plsql_text, l_final_plsql_text
         FROM fnd_oam_dscram_plsqls
         WHERE plsql_id = p_plsql_id
         FOR UPDATE;

      --make sure the final text's still null
      IF l_final_plsql_text IS NOT NULL THEN
         x_final_plsql_text := l_final_plsql_text;
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --create the SQL statement by wrapping the plsql procedure text in an anonymous block
      l_length :=  LENGTH(l_plsql_text) + LENGTH(FND_OAM_DSCRAM_UTILS_PKG.G_PLSQL_PREFIX) +
                   LENGTH(FND_OAM_DSCRAM_UTILS_PKG.G_PLSQL_SUFFIX) + 1;
      IF l_length > l_maxlen THEN
         x_return_msg := 'PLSQL Final text length would be '||l_length||', greater than max: '||l_maxlen;
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;
      l_final_plsql_text := FND_OAM_DSCRAM_UTILS_PKG.G_PLSQL_PREFIX||l_plsql_text||';'||FND_OAM_DSCRAM_UTILS_PKG.G_PLSQL_SUFFIX;

      --store this string as the final text
      UPDATE fnd_oam_dscram_plsqls
         SET plsql_final_text = l_final_plsql_text,
         stats_finished = FND_API.G_FALSE,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE plsql_id = p_plsql_id;

      --commit the autonomous txn to release the lock
      COMMIT;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_final_plsql_text := l_final_plsql_text;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'PLSQL ID ('||p_plsql_id||'), failed to generate final plsql text: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private helper to EXECUTE_PLSQL* to take a foreign plsql_id and prepare it by parsing it into
   -- a cursor and fetching the arg list
   PROCEDURE ADD_PLSQL_TO_CACHE(p_plsql_id      IN NUMBER,
                                px_arg_context  IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                p_use_splitting IN BOOLEAN,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_return_msg    OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ADD_PLSQL_TO_CACHE';

      l_final_plsql_text        VARCHAR2(4000);

      l_stat_id                 NUMBER;
      l_cache_entry             b_plsql_cache_entry;
      l_cursor_id               INTEGER;
      l_arg_list                FND_OAM_DSCRAM_ARGS_PKG.arg_list;
      l_has_writable_args       BOOLEAN;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --if the plsql isn't cached, there's a chance that its stats row hasn't been created yet, query and
      --create if necessary.  This is not mt-safe but extra calls to create_entry will be discarded due to
      --the unique index on fnd_oam_dscram_stats.
      IF NOT FND_OAM_DSCRAM_STATS_PKG.HAS_ENTRY(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                                                p_plsql_id) THEN
         --autonomously create the stats entry
         FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY_AUTONOMOUSLY(p_source_object_type        => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                                                            p_source_object_id          => p_plsql_id,
                                                            p_start_time                => SYSDATE,
                                                            p_prestart_status           => NULL,
                                                            p_dismiss_failure           => FND_API.G_TRUE,
                                                            x_stat_id                   => l_stat_id);
      END IF;

      --query out the prepared plsql text
      SELECT plsql_final_text
         INTO l_final_plsql_text
         FROM fnd_oam_dscram_plsqls
         WHERE plsql_id = p_plsql_id;

      --if it's not present, generate it
      IF l_final_plsql_text IS NULL THEN
         GENERATE_FINAL_PLSQL_TEXT(p_plsql_id,
                                   px_arg_context,
                                   l_final_plsql_text,
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
                        l_final_plsql_text,
                        DBMS_SQL.NATIVE);
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
            x_return_msg := 'PLSQL_ID ('||p_plsql_id||'), failed to parse final stmt: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
      END;

      --now lets get the arg list for the plsql
      FND_OAM_DSCRAM_ARGS_PKG.FETCH_ARG_LIST(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                                             p_plsql_id,
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
      l_cache_entry.plsql_id := p_plsql_id;
      l_cache_entry.cursor_id := l_cursor_id;
      l_cache_entry.arg_list := l_arg_list;
      l_cache_entry.use_splitting := p_use_splitting;
      l_cache_entry.has_writable_args := l_has_writable_args;
      l_cache_entry.last_execute_ret_sts := NULL;
      l_cache_entry.last_execute_ret_msg := NULL;

      --store the entry in the cache
      b_plsql_cache(p_plsql_id) := l_cache_entry;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'PLSQL ID ('||p_plsql_id||'), unexpected error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private, helper to EXECUTE_PLSQL* procedures to do the grunt work.  the call to complete the PLSQL
   -- will be done by the caller.  No commits or rollbacks are done here.
   PROCEDURE INTERNAL_EXECUTE_PLSQL(p_plsql_id          IN NUMBER,
                                    px_arg_context      IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                    p_use_splitting     IN BOOLEAN,
                                    p_rowid_lbound      IN ROWID,
                                    p_rowid_ubound      IN ROWID,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_EXECUTE_PLSQL';

      l_rows_processed  NUMBER;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'PLSQL ID: '||p_plsql_id);

      --set the current plsql id before binding args to allow for access of the plsql_id from a state argument
      b_current_plsql_id := p_plsql_id;

      --first see if the plsql's in the cache
      IF b_plsql_cache.EXISTS(p_plsql_id) THEN
         --make sure the cursor isn't configured for splitting
         IF b_plsql_cache(p_plsql_id).use_splitting <> p_use_splitting THEN
            x_return_msg := 'PLSQL ID ('||p_plsql_id||'), cached splitting enabled not equal to provided splitting enabled.  This should not happen.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            RAISE EXECUTE_FAILED;
         END IF;
      ELSE
         --no cache entry, create one
         ADD_PLSQL_TO_CACHE(p_plsql_id,
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
      FND_OAM_DSCRAM_ARGS_PKG.BIND_ARG_LIST_TO_CURSOR(b_plsql_cache(p_plsql_id).arg_list,
                                                      px_arg_context,
                                                      b_plsql_cache(p_plsql_id).cursor_id,
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

      --do not automatically bind the rowids if we're using splitting, it's up to the plsql to declare what args it requires
      --independent of the context in which it's called

      --skip the execute if we're in test-no-exec mode
      IF FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE = FND_OAM_DSCRAM_UTILS_PKG.G_MODE_TEST_NO_EXEC THEN
         fnd_oam_debug.log(1, l_ctxt, 'Skipping Executiong due to run mode.');
      ELSE
         --do the execute
         fnd_oam_debug.log(1, l_ctxt, 'Executing cursor...');
         BEGIN
            l_rows_processed := DBMS_SQL.EXECUTE(b_plsql_cache(p_plsql_id).cursor_id);
         EXCEPTION
            WHEN OTHERS THEN
               x_return_msg := 'SQL execute error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               RAISE EXECUTE_FAILED;
         END;
         fnd_oam_debug.log(1, l_ctxt, '...Done.('||l_rows_processed||' rows)');
      END IF;

      -- If the plsql has any output variables, we should get values for them
      IF b_plsql_cache(p_plsql_id).has_writable_args THEN
         FND_OAM_DSCRAM_ARGS_PKG.UPDATE_WRITABLE_ARG_VALUES(b_plsql_cache(p_plsql_id).arg_list,
                                                            px_arg_context,
                                                            NOT p_use_splitting,        --we're finished if we're not splitting
                                                            p_use_splitting,
                                                            p_rowid_lbound,
                                                            p_rowid_ubound,
                                                            b_plsql_cache(p_plsql_id).cursor_id,
                                                            l_return_status,
                                                            l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            RAISE EXECUTE_FAILED;
         END IF;
      END IF;

      -- Success
      b_current_plsql_id := NULL;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
    EXCEPTION
       WHEN EXECUTE_FAILED THEN
          b_current_plsql_id := NULL;
          fnd_oam_debug.log(2, l_ctxt, 'EXIT');
          RETURN;
       WHEN OTHERS THEN
          b_current_plsql_id := NULL;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
          fnd_oam_debug.log(6, l_ctxt, x_return_msg);
          fnd_oam_debug.log(2, l_ctxt, 'EXIT');
          RETURN;
   END;

   -- Public
   PROCEDURE EXECUTE_PLSQL(p_plsql_id           IN NUMBER,
                           px_arg_context       IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_PLSQL';

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_return_status2  VARCHAR2(6);
      l_return_msg2     VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --do the single-threaded execute
      INTERNAL_EXECUTE_PLSQL(p_plsql_id,
                             px_arg_context,
                             FALSE,
                             NULL,
                             NULL,
                             l_return_status,
                             l_return_msg);

      -- if successful, complete the plsql
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         --update the rows plsql cache's derived attributes
         b_plsql_cache(p_plsql_id).last_execute_ret_sts := l_return_status;
         b_plsql_cache(p_plsql_id).last_execute_ret_msg := l_return_msg;

         --if in normal mode, complete normally, otherwise we need to complete autonomously for progress to be maintained
         --the status of the complete is returned as the overall execute status so we have insight into whether the entire
         --operation suceeded
         IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
            COMPLETE_PLSQL(p_plsql_id,
                           l_return_status,
                           l_return_msg,
                           x_return_status,
                           x_return_msg);
         ELSE
            COMPLETE_PLSQL_AUTONOMOUSLY(p_plsql_id,
                                        l_return_status,
                                        l_return_msg,
                                        x_return_status,
                                        x_return_msg);
         END IF;
       ELSE
          --update the rows plsql cache's derived attributes
          IF b_plsql_cache.EXISTS(p_plsql_id) THEN
             b_plsql_cache(p_plsql_id).last_execute_ret_sts := l_return_status;
             b_plsql_cache(p_plsql_id).last_execute_ret_msg := l_return_msg;
          END IF;

         --if failed, complete it autonomously since the data will be rolled back and errors override
         --this does not need to be atomic with the unit update since individually executed PLSQLs are
         --not queried concurrently and passing the data back to the unit to commit is extra unnecessary work.
         COMPLETE_PLSQL_AUTONOMOUSLY(p_plsql_id,
                                     l_return_status,
                                     l_return_msg,
                                     l_return_status2,
                                     l_return_msg2);
         --return status/msg of execute failure since we're more concerned about that
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
   PROCEDURE EXECUTE_PLSQL_ON_RANGE(p_plsql_id          IN NUMBER,
                                    px_arg_context      IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                    p_rowid_lbound      IN ROWID,
                                    p_rowid_ubound      IN ROWID,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_PLSQL_ON_RANGE';

      l_plsql_id                NUMBER;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_return_status2  VARCHAR2(6);
      l_return_msg2     VARCHAR2(2048);
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      INTERNAL_EXECUTE_PLSQL(p_plsql_id,
                             px_arg_context,
                             TRUE,
                             p_rowid_lbound,
                             p_rowid_ubound,
                             l_return_status,
                             l_return_msg);
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         --update the rows plsql cache's derived attributes
         b_plsql_cache(p_plsql_id).last_execute_ret_sts := l_return_status;
         b_plsql_cache(p_plsql_id).last_execute_ret_msg := l_return_msg;
      ELSE
         --update the rows plsql cache's derived attributes
         IF b_plsql_cache.EXISTS(p_plsql_id) THEN
            b_plsql_cache(p_plsql_id).last_execute_ret_sts := l_return_status;
            b_plsql_cache(p_plsql_id).last_execute_ret_msg := l_return_msg;
         END IF;

         --return status/msg of execute failure
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

END FND_OAM_DSCRAM_PLSQLS_PKG;

/
