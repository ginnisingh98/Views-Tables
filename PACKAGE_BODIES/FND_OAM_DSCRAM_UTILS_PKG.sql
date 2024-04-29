--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_UTILS_PKG" as
/* $Header: AFOAMDSUTILB.pls 120.8 2006/06/07 17:46:54 ilawler noship $ */

   -- Private Body Constants
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_UTILS_PKG.';
   B_ARG_ROWID_CLAUSE           CONSTANT VARCHAR2(60) := 'ROWID BETWEEN :'||G_ARG_ROWID_LBOUND_NAME||' AND :'||G_ARG_ROWID_UBOUND_NAME;

   -- number of seconds to wait for a unit to finish.  This is kept low so in case we register to
   -- wait for a progress update and we miss the alert we'll wake up and check for ourselves
   B_PROGRESS_ALERT_MAX_WAIT    CONSTANT NUMBER := 60;
   B_PROGRESS_ALERT_DIAG_WAIT   CONSTANT NUMBER := 1;

   -- Public
   FUNCTION CONV_VALIDATE_START_STS_TO_RET(p_status IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_ret_sts VARCHAR2(6) := G_RET_STS_ERROR_UNKNOWN;
   BEGIN
      IF p_status = G_STATUS_PROCESSED THEN
         l_ret_sts := G_RET_STS_PROCESSED;
      ELSIF p_status = G_STATUS_FINISHING THEN
         l_ret_sts := G_RET_STS_PROCESSED;
      ELSIF p_status = G_STATUS_STOPPED THEN
         l_ret_sts := G_RET_STS_STOPPED;
      ELSIF p_status = G_STATUS_STOPPING THEN
         l_ret_sts := G_RET_STS_STOPPED;
      ELSIF p_status = G_STATUS_SKIPPED THEN
         l_ret_sts := G_RET_STS_SKIPPED;
      ELSIF p_status = G_STATUS_ERROR_FATAL THEN
         l_ret_sts := G_RET_STS_ERROR_FATAL;
      END IF;
      RETURN l_ret_sts;
   END;

   -- Public
   FUNCTION CONV_VALIDATE_CONT_STS_TO_RET(p_status IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_ret_sts VARCHAR2(6) := G_RET_STS_ERROR_UNKNOWN;
   BEGIN
      IF p_status = G_STATUS_PROCESSED THEN
         l_ret_sts := G_RET_STS_PROCESSED;
      ELSIF p_status = G_STATUS_FINISHING THEN
         l_ret_sts := G_RET_STS_PROCESSED;
      ELSIF p_status = G_STATUS_STOPPED THEN
         l_ret_sts := G_RET_STS_STOPPED;
      ELSIF p_status = G_STATUS_STOPPING THEN
         l_ret_sts := G_RET_STS_STOPPED;
      ELSIF p_status = G_STATUS_SKIPPED THEN
         l_ret_sts := G_RET_STS_SKIPPED;
      ELSIF p_status = G_STATUS_ERROR_FATAL THEN
         l_ret_sts := G_RET_STS_ERROR_FATAL;
      END IF;
      RETURN l_ret_sts;
   END;

   -- Public
   FUNCTION CONV_RET_STS_TO_COMPL_STATUS(p_ret_sts IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_status  VARCHAR2(30) := G_STATUS_ERROR_UNKNOWN;
   BEGIN
      IF p_ret_sts = FND_API.G_RET_STS_SUCCESS OR p_ret_sts = G_RET_STS_PROCESSED THEN
         l_status := G_STATUS_PROCESSED;
      ELSIF p_ret_sts = G_RET_STS_STOPPED THEN
         l_status := G_STATUS_STOPPED;
      ELSIF p_ret_sts = G_RET_STS_ERROR_FATAL THEN
         l_status := G_STATUS_ERROR_FATAL;
      END IF;
      RETURN l_status;
   END;

   -- Public
   FUNCTION STATUS_IS_EXECUTABLE(p_status IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_status IS NULL THEN
         RETURN FALSE;
      END IF;
      --FINISHING not included so we can't start something that's finishing, breaks other
      --assumptions and allows for querying on what should be a done deal
      RETURN (p_status IN (G_STATUS_UNPROCESSED,
                           G_STATUS_PROCESSING,
                           G_STATUS_RESTARTABLE));
   END;

   -- Public
   FUNCTION STATUS_IS_PROCESSING(p_status IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_status IS NULL THEN
         RETURN FALSE;
      END IF;
      --include finishing as an ok processing state for a parent
      RETURN (p_status IN (G_STATUS_PROCESSING,
                           G_STATUS_FINISHING));
   END;

   FUNCTION STATUS_IS_FINAL(p_status IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_status IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN (p_status IN (G_STATUS_ERROR_FATAL,
                           G_STATUS_ERROR_UNKNOWN,
                           G_STATUS_PROCESSED,
                           G_STATUS_STOPPED,
                           G_STATUS_SKIPPED));
   END;

   -- Public
   FUNCTION STATUS_IS_ERROR(p_status IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_status IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN (p_status IN (G_STATUS_ERROR_FATAL,
                           G_STATUS_ERROR_UNKNOWN));
   END;

   -- Public
   FUNCTION RET_STS_IS_ERROR(p_ret_sts IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_ret_sts IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN (p_ret_sts IN (FND_API.G_RET_STS_ERROR,
                            FND_API.G_RET_STS_UNEXP_ERROR,
                            G_RET_STS_ERROR_FATAL,
                            G_RET_STS_ERROR_UNKNOWN));
   END;

   -- Public
   PROCEDURE TRANSLATE_COMPLETED_STATUS(p_current_status        IN VARCHAR2,
                                        p_workers_assigned      IN NUMBER,
                                        p_proposed_status       IN VARCHAR2,
                                        p_proposed_ret_sts      IN VARCHAR2,
                                        x_final_status          OUT NOCOPY VARCHAR2,
                                        x_final_ret_sts         OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      x_final_status := p_proposed_status;
      x_final_ret_sts := p_proposed_ret_sts;

      --can't lose an unknown error, not even for other errors
      IF p_current_status = G_STATUS_ERROR_UNKNOWN THEN
         x_final_status := G_STATUS_ERROR_UNKNOWN;
         x_final_ret_sts := G_RET_STS_ERROR_UNKNOWN;
         RETURN;
      END IF;

      --if any other form of error then let it override
      IF STATUS_IS_ERROR(p_proposed_status) THEN
         RETURN;
      END IF;

      --otherwise follow some rules to keep the status transitions valid
      IF p_current_status IN (G_STATUS_PROCESSING, G_STATUS_FINISHING) THEN
         --if we're in a processing-like state, each worker returns processed when
         --it can't find any more work, but the first N-1 workers really just set it
         --to finishing to keep more workers out, only the last one sets it processed.
         IF p_proposed_status = G_STATUS_PROCESSED THEN
            IF p_workers_assigned > 1 THEN
               --don't let it stay in processing, allows race where worker re-enters before
               --others finish
               x_final_status := G_STATUS_FINISHING;
            END IF;
            --unless our proposed return status is full, make sure the final return status is success
            IF p_proposed_ret_sts <> G_RET_STS_FULL THEN
               x_final_ret_sts := FND_API.G_RET_STS_SUCCESS;
            END IF;
         ELSIF p_proposed_status = G_STATUS_STOPPED THEN
            x_final_ret_sts := G_RET_STS_STOPPED;
            IF p_workers_assigned > 1 THEN
               x_final_status := G_STATUS_STOPPING;
            ELSE
               x_final_status := G_STATUS_STOPPED;
            END IF;
         END IF;
      ELSIF p_current_status = G_STATUS_PROCESSED THEN
         --if we're processed and moving to processed, that's a success
         IF p_proposed_status = G_STATUS_PROCESSED THEN
            --unless our proposed return status is full, make sure the final return status is success
            IF p_proposed_ret_sts <> G_RET_STS_FULL THEN
               x_final_ret_sts := FND_API.G_RET_STS_SUCCESS;
            END IF;
         END IF;
      ELSIF p_current_status = G_STATUS_STOPPING THEN
         --only update it to stopped if we're the last worker completing.
         x_final_ret_sts := G_RET_STS_STOPPED;
         IF p_workers_assigned > 1 THEN
            x_final_status := G_STATUS_STOPPING;
         ELSE
            x_final_status := G_STATUS_STOPPED;
         END IF;
      ELSIF p_current_status = G_STATUS_STOPPED THEN
         --if we're stopped already, don't let somebody say we're processed
         --shouldn't happen
         x_final_ret_sts := G_RET_STS_STOPPED;
         IF p_proposed_status = G_STATUS_PROCESSED THEN
            x_final_status := G_STATUS_STOPPED;
         END IF;
      END IF;

   END;

   -- Public
   FUNCTION VALIDATION_DUE(p_last_validated IN DATE)
      RETURN BOOLEAN
   IS
      l_interval        NUMBER;
   BEGIN
      IF p_last_validated IS NULL THEN
         RETURN TRUE;
      END IF;

      l_interval := FND_OAM_DSCRAM_RUNS_PKG.GET_VALID_CHECK_INTERVAL;

      --allows the user to turn off status checking
      IF l_interval IS NULL OR l_interval <= 0 THEN
         RETURN FALSE;
      END IF;

      RETURN (trunc((SYSDATE - p_last_validated)*86400) >= l_interval);
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION FLAG_TO_BOOLEAN(p_flag      IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_flag IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN (p_flag = FND_API.G_TRUE);
   END;

   -- Public
   FUNCTION BOOLEAN_TO_FLAG(p_bool      IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_bool THEN
         RETURN FND_API.G_TRUE;
      END IF;
      RETURN FND_API.G_FALSE;
   END;

   --Public
   PROCEDURE PROPOGATE_FATALITY_LEVEL(p_fatality_level  IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'PROPOGATE_FATALITY_LEVEL';

      l_id              NUMBER;
      l_current_status  VARCHAR2(30);
   BEGIN
      IF p_fatality_level = G_TYPE_TASK THEN
         l_id := FND_OAM_DSCRAM_TASKS_PKG.GET_TASK_ID;
         fnd_oam_debug.log(1, l_ctxt, 'Attempting to stop Task ID: '||l_id);
         SELECT task_status
            INTO l_current_status
            FROM fnd_oam_dscram_tasks
            WHERE task_id = l_id
            FOR UPDATE;

         IF STATUS_IS_PROCESSING(l_current_status) THEN
            UPDATE fnd_oam_dscram_tasks
               SET task_status = G_STATUS_STOPPING,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.user_id,
               last_update_date = SYSDATE
               WHERE task_id = l_id;
            COMMIT;
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'Skipping stopping task due to current status: '||l_current_status);
         END IF;
      ELSIF p_fatality_level = G_TYPE_BUNDLE THEN
         l_id := FND_OAM_DSCRAM_BUNDLES_PKG.GET_BUNDLE_ID;
         fnd_oam_debug.log(1, l_ctxt, 'Attempting to stop Bundle ID: '||l_id);
         SELECT bundle_status
            INTO l_current_status
            FROM fnd_oam_dscram_bundles
            WHERE bundle_id = l_id
            FOR UPDATE;

         IF STATUS_IS_PROCESSING(l_current_status) THEN
            UPDATE fnd_oam_dscram_bundles
               SET bundle_status = G_STATUS_STOPPING,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.user_id,
               last_update_date = SYSDATE
               WHERE bundle_id = l_id;
            COMMIT;
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'Skipping stopping bundle due to current status: '||l_current_status);
         END IF;
      ELSIF p_fatality_level = G_TYPE_RUN THEN
         l_id := FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ID;
         fnd_oam_debug.log(1, l_ctxt, 'Attempting to stop Run ID: '||l_id);
         SELECT run_status
            INTO l_current_status
            FROM fnd_oam_dscram_runs_b
            WHERE run_id = l_id
            FOR UPDATE;

         IF STATUS_IS_PROCESSING(l_current_status) THEN
            UPDATE fnd_oam_dscram_runs_b
               SET run_status = G_STATUS_STOPPING,
               last_updated_by = fnd_global.user_id,
               last_update_login = fnd_global.user_id,
               last_update_date = SYSDATE
               WHERE run_id = l_id;
            COMMIT;
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'Skipping stopping run due to current status: '||l_current_status);
         END IF;
      ELSE
         fnd_oam_debug.log(6, l_ctxt, 'Unknown fatality level: '|| p_fatality_level);
         ROLLBACK;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         -- what do you do when fatally erroring a parent fails?
         RETURN;
   END;

   -- Public
   FUNCTION MAKE_AD_SCRIPT_KEY(p_run_id         IN NUMBER,
                               p_unit_id        IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN G_DSCRAM_GLOBAL_PREFIX||to_char(p_run_id)||'_'||to_char(p_unit_id);
   END;

   -- Public
   FUNCTION MAKE_AD_SCRIPT_KEY(p_unit_id        IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN G_DSCRAM_GLOBAL_PREFIX||to_char(FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ID)||'_'||to_char(p_unit_id);
   END;

   -- Helper to lock_run to provide the named lock's name
   FUNCTION MAKE_RUN_LOCK_NAME(p_run_id IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'DSCRAM.RUN.'||p_run_id;
   END;

   --wrapped dbms_lock procedure in this procedure to use an autonomous txn to keep it from committing the parent txn.
   PROCEDURE ALLOCATE_LOCK(p_lock_name          IN VARCHAR2,
                           x_lock_handle        OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DBMS_LOCK.ALLOCATE_UNIQUE(p_lock_name,
                                x_lock_handle);
      COMMIT;
   END;

   -- Private helper to grant exclusive access to a possibly non-existent run
   FUNCTION LOCK_RUN(p_run_id           IN NUMBER,
                     x_lock_handle      OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'LOCK_RUN';

      l_retval          NUMBER;
      l_lock_name       VARCHAR2(30);
      l_lock_handle     VARCHAR2(128);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      l_lock_name := MAKE_RUN_LOCK_NAME(p_run_id);

      --fnd_oam_debug.log(1, l_ctxt, 'Allocated lock handle: '||l_lock_handle);
      ALLOCATE_LOCK(l_lock_name,
                    l_lock_handle);
      l_retval := DBMS_LOCK.REQUEST(l_lock_handle,
                                    dbms_lock.x_mode,
                                    dbms_lock.maxwait,
                                    TRUE);
      --fnd_oam_debug.log(1, l_ctxt, 'Retval: '||l_retval);
      IF (l_retval <> 0) THEN
         fnd_oam_debug.log(6, l_ctxt, 'Run ID ('||p_run_id||'), lock request failed: '||l_retval);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_lock_handle := l_lock_handle;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
            END IF;
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- helper to lock arg
   FUNCTION MAKE_ARG_LOCK_NAME(p_arg_id IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'DSCRAM.ARG.'||p_arg_id;
   END;

   --Public
   FUNCTION LOCK_ARG(p_arg_id           IN NUMBER,
                     x_lock_handle      OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt    VARCHAR2(60) := PKG_NAME||'LOCK_ARG';

      l_retval          NUMBER;
      l_lock_name       VARCHAR2(30);
      l_lock_handle     VARCHAR2(128) := NULL;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      l_lock_name := MAKE_ARG_LOCK_NAME(p_arg_id);

      ALLOCATE_LOCK(l_lock_name,
                    l_lock_handle);
      --fnd_oam_debug.log(1, l_ctxt, 'Allocated lock handle: '||l_lock_handle);

      --Allow lock releases on commit/rollback so we can keep write_once args locked when first set until the
      --batch is comitted or rolled back.
      l_retval := DBMS_LOCK.REQUEST(l_lock_handle,
                                    dbms_lock.x_mode,
                                    dbms_lock.maxwait,
                                    TRUE);
      --fnd_oam_debug.log(1, l_ctxt, 'Retval: '||l_retval);
      IF (l_retval <> 0) THEN
         fnd_oam_debug.log(6, l_ctxt, 'Arg ID ('||p_arg_id||'), lock request failed: '||l_retval);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_lock_handle := l_lock_handle;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
            IF l_retval <> 0 THEN
               fnd_oam_debug.log(6, l_ctxt, 'Failed to release arg lock: '||l_retval);
            END IF;
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- helper to DELETE_<entity> functions
   PROCEDURE DELETE_STATS(p_object_type IN VARCHAR2,
                          p_object_id   IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_STATS';
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --fnd_oam_debug.log(1, l_ctxt, 'Deleting stats...');
      DELETE FROM fnd_oam_dscram_stats
         WHERE source_object_type = p_object_type
         AND source_object_id = p_object_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   --helper to DELETE_<entity> functions
   PROCEDURE DELETE_ARGS(p_object_type  IN VARCHAR2,
                         p_object_id    IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_ARGS';
      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;
      l_id              NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --fnd_oam_debug.log(1, l_ctxt, 'Deleting args...');
      SELECT arg_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_args_b
         WHERE parent_type = p_object_type
         AND parent_id = p_object_id;

      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         l_id := l_ids(k);
         DELETE FROM fnd_oam_dscram_args_b
            WHERE arg_id = l_id;
         DELETE FROM fnd_oam_dscram_args_tl
            WHERE arg_id = l_id;
         DELETE FROM fnd_oam_dscram_arg_values
            WHERE arg_id = l_id;
         k := l_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   --helper to DELETE_UNIT to delete AD parallel updates info when splitting was involved.
   FUNCTION DELETE_AD_DATA(p_run_id             IN NUMBER,
                           p_unit_id            IN NUMBER,
                           p_owner              IN VARCHAR2,
                           p_table_name         IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_AD_DATA';

      l_script_key      VARCHAR2(30) := MAKE_AD_SCRIPT_KEY(p_run_id, p_unit_id);
      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_id              NUMBER;

      k                 NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      --fnd_oam_debug.log(1, l_ctxt, 'Deleting args...');
      SELECT update_id
         BULK COLLECT INTO l_ids
         FROM ad_parallel_updates
         WHERE owner = p_owner
         AND table_name = p_table_name
         AND script_name = l_script_key;

      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         l_id := l_ids(k);
         fnd_oam_debug.log(1, l_ctxt, 'AD Update ID: '||l_id);
         DELETE FROM ad_parallel_workers
            WHERE update_id = l_id;
         DELETE FROM ad_parallel_update_units
            WHERE update_id = l_id;
         DELETE FROM ad_parallel_updates
            WHERE update_id = l_id;
         k := l_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to DELETE_UNIT to delete plsqls
   FUNCTION DELETE_PLSQL(p_plsql_id     IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_PLSQL';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'PLSQL ID: '||p_plsql_id);

      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                   p_plsql_id);

      DELETE_ARGS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL,
                   p_plsql_id);

      --delete the actual entity
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_plsqls
         WHERE plsql_id = p_plsql_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to DELETE_UNIT
   FUNCTION DELETE_DML(p_dml_id IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_DML';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'DML ID: '||p_dml_id);

      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                   p_dml_id);

      DELETE_ARGS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML,
                   p_dml_id);

      --delete the actual entity
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_dmls
         WHERE dml_id = p_dml_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to DELETE_TASK
   FUNCTION DELETE_UNIT(p_run_id        IN NUMBER,
                        p_unit_id       IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_UNIT';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_unit_type       VARCHAR2(30);
      l_object_owner    VARCHAR2(30);
      l_object_name     VARCHAR2(30);

      k                 NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Unit ID: '||p_unit_id);

      --get the unit type
      SELECT unit_type, unit_object_owner, unit_object_name
         INTO l_unit_type, l_object_owner, l_object_name
         FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id;

      --first get the list of child units
      SELECT unit_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_units
         WHERE concurrent_group_unit_id = p_unit_id;

      --nuke the children
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_UNIT(p_run_id,
                            l_ids(k)) THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN FALSE;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      --now grab the list of dmls
      SELECT dml_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_dmls
         WHERE unit_id = p_unit_id;

      --nuke the dmls
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_DML(l_ids(k)) THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN FALSE;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      --grab the list of plsqls
      SELECT plsql_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_plsqls
         WHERE unit_id = p_unit_id;

      --nuke them
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_PLSQL(l_ids(k)) THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN FALSE;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      --nuke any ad data
      IF NOT DELETE_AD_DATA(p_run_id,
                            p_unit_id,
                            l_object_owner,
                            l_object_name) THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_UNIT,
                   p_unit_id);

      --delete the actual entity
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to DELETE_BUNDLE
   FUNCTION DELETE_TASK(p_run_id        IN NUMBER,
                        p_task_id       IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_TASK';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Task ID: '||p_task_id);

      --grab the list of top-level units
      SELECT unit_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_units
         WHERE task_id = p_task_id
         AND concurrent_group_unit_id IS NULL;

      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_UNIT(p_run_id,
                            l_ids(k)) THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN FALSE;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_TASK,
                   p_task_id);

      --delete the actual entity
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_tasks
         WHERE task_id = p_task_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   --helper to DELETE_RUN
   FUNCTION DELETE_BUNDLE(p_run_id      IN NUMBER,
                          p_bundle_id   IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_BUNDLE';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Bundle ID: '||p_bundle_id);

      --grab the list of tasks
      SELECT task_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_tasks
         WHERE bundle_id = p_bundle_id;

      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_TASK(p_run_id,
                            l_ids(k)) THEN
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN FALSE;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_BUNDLE,
                   p_bundle_id);

      --delete the actual entity
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_bundles
         WHERE bundle_id = p_bundle_id;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Public: Called before a test invocation to clear space for a test run.
   FUNCTION DELETE_RUN(p_run_id         IN NUMBER)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'DELETE_RUN';

      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;

      l_retbool         BOOLEAN;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get a lock on the run
      IF NOT LOCK_RUN(p_run_id,
                      l_lock_handle) THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Run ID: '||p_run_id);

      --grab the list of bundles
      SELECT bundle_id
         BULK COLLECT INTO l_ids
         FROM fnd_oam_dscram_bundles
         WHERE RUN_ID = p_run_id;

      --delete the child bundles
      l_retbool := TRUE;
      k := l_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         IF NOT DELETE_BUNDLE(p_run_id,
                              l_ids(k)) THEN
            l_retbool := FALSE;
            EXIT;
         END IF;

         k := l_ids.NEXT(k);
      END LOOP;

      --delete the run's stats
      DELETE_STATS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN,
                   p_run_id);

      DELETE_ARGS(FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_RUN,
                  p_run_id);

      --delete the actual run
      fnd_oam_debug.log(1, l_ctxt, 'Deleting entity...');
      DELETE FROM fnd_oam_dscram_runs_b
         WHERE run_id = p_run_id;
      DELETE FROM fnd_oam_dscram_runs_tl
         WHERE run_id = p_run_id;

      --release the lock on the run
      l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
      IF l_retval <> 0 THEN
         fnd_oam_debug.log(6, l_ctxt, 'Failed to release run lock: '||l_retval);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      SELECT count(*)
         INTO k
         FROM fnd_oam_dscram_runs_b;
      fnd_oam_debug.log(1, l_ctxt, 'Found '||k||' remaining base run rows.');
      SELECT count(*)
         INTO k
         FROM fnd_oam_dscram_runs_tl;
      fnd_oam_debug.log(1, l_ctxt, 'Found '||k||' remaining trans run rows.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      RETURN l_retbool;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Public
   FUNCTION RUN_IS_NORMAL
      RETURN BOOLEAN
   IS
      l_mode    VARCHAR2(30);
   BEGIN
      l_mode := FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE;
      IF l_mode IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN l_mode = G_MODE_NORMAL;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION RUN_IS_DIAGNOSTIC
      RETURN BOOLEAN
   IS
      l_mode    VARCHAR2(30);
   BEGIN
      l_mode := FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE;
      IF l_mode IS NULL THEN
         RETURN FALSE;
      END IF;
      RETURN l_mode = G_MODE_DIAGNOSTIC;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN FALSE;
   END;

   -- Public
   FUNCTION SOURCE_TYPE_USES_SQL(p_source_type IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN p_source_type IN (G_SOURCE_SQL,
                               G_SOURCE_SQL_RESTRICTABLE);
   END;

   -- Public
   PROCEDURE MAKE_FINAL_SQL_STMT(px_arg_context         IN FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                 p_stmt                 IN VARCHAR2,
                                 p_where_clause         IN VARCHAR2,
                                 p_use_splitting        IN BOOLEAN,
                                 x_final_stmt           OUT NOCOPY VARCHAR2,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'MAKE_FINAL_SQL_STMT';
      l_final_stmt      VARCHAR2(4000);
      l_stmt_length     NUMBER;
      l_stmt_maxlen     NUMBER := 4000;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --for now, all bind variables are bound in the cursor and not replaced in the DML statement.  If in
      --the future we tag some bind variables as being "bound" at design time and not run time, we'll do
      --the string replacement here. Also means px_arg_context is unused here.
      IF p_use_splitting THEN
         --make sure we have room
         IF p_where_clause IS NULL THEN
            l_stmt_length := length(p_stmt) + length(B_ARG_ROWID_CLAUSE) + 7;
         ELSE
            l_stmt_length := length(p_stmt) + length(p_where_clause) + length(B_ARG_ROWID_CLAUSE) + 12;
         END IF;
         IF l_stmt_length > l_stmt_maxlen THEN
            x_return_msg := 'Total length of statement would be '||l_stmt_length||', greater than max ('||l_stmt_maxlen||').';
            x_final_stmt := NULL;
            RETURN;
         END IF;
         fnd_oam_debug.log(1, l_ctxt, 'Determined statement length: '||l_stmt_length);

         --form the statement
         IF p_where_clause IS NULL THEN
            l_final_stmt := p_stmt||' WHERE '||B_ARG_ROWID_CLAUSE;
         ELSE
            l_final_stmt := p_stmt||' WHERE '||p_where_clause||' AND '||B_ARG_ROWID_CLAUSE;
         END IF;
      ELSE
         --make sure we have room
         IF p_where_clause IS NOT NULL THEN
            l_stmt_length := length(p_stmt) + length(p_where_clause) + 7;

            IF l_stmt_length > l_stmt_maxlen THEN
               x_return_msg := 'Total length of statement would be '||l_stmt_length||', greater than max '||l_stmt_maxlen||'.';
               x_final_stmt := NULL;
               RETURN;
            END IF;
            fnd_oam_debug.log(1, l_ctxt, 'Determined statement length: '||l_stmt_length);

            --no added clauses so just append parts
            l_final_stmt := p_stmt||' WHERE '||p_where_clause;
         ELSE
            l_final_stmt := p_stmt;
         END IF;
      END IF;

      --return success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_final_stmt := l_final_stmt;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_final_stmt := NULL;
   END;

   -- Public
   FUNCTION MAKE_PROGRESS_ALERT_NAME(p_run_id   IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN G_DSCRAM_GLOBAL_PREFIX||to_char(p_run_id);
   END;

   -- Public
   -- Autonomous because WAITONE does an implicit commit
   PROCEDURE WAIT_FOR_PROGRESS_ALERT
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'WAIT_FOR_PROGRESS_ALERT';

      l_progress_alert_name     VARCHAR2(30);
      l_msg                     VARCHAR2(3);
      l_status                  INTEGER;
      l_wait                    NUMBER := B_PROGRESS_ALERT_MAX_WAIT;
   BEGIN
      l_progress_alert_name := MAKE_PROGRESS_ALERT_NAME(FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ID);
      --register first
      DBMS_ALERT.REGISTER(l_progress_alert_name);

      --if we're in a mode where the work is very quuick, cut down the max end of run wait
      IF FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_MODE IN (G_MODE_DIAGNOSTIC,
                                                  G_MODE_TEST_NO_EXEC) THEN
         l_wait := B_PROGRESS_ALERT_DIAG_WAIT;
      END IF;
      DBMS_ALERT.WAITONE(l_progress_alert_name,
                         l_msg,
                         l_status,
                         l_wait);
      --ignore the message and status, we just want the notification
      ROLLBACK;
   EXCEPTION
      WHEN OTHERS THEN
         fnd_oam_debug.log(1, l_ctxt, 'Failed to wait for progress alert: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         ROLLBACK;

   END;

   -- Public
   -- Not autonomous because the alert is sent with the parent transaction's commit
   PROCEDURE SIGNAL_PROGRESS_ALERT
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SIGNAL_PROGRESS_ALERT';

      l_progress_alert_name VARCHAR2(30);
   BEGIN
      l_progress_alert_name := MAKE_PROGRESS_ALERT_NAME(FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ID);
      DBMS_ALERT.SIGNAL(l_progress_alert_name,
                        NULL);
   EXCEPTION
      WHEN OTHERS THEN
         --log it but don't throw it since this is only to help minimize delay
         fnd_oam_debug.log(1, l_ctxt, 'Failed to signal progress alert: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
   END;

   -- Public
   PROCEDURE SIGNAL_AUT_PROGRESS_ALERT
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      SIGNAL_PROGRESS_ALERT;
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
   END;

   -- Private helper function to take the keys of a number_table and return them as an in order list. Useful
   -- for cases where we need a list that's 1->N for FORALL bulk binding. Keys are assumed to be numeric.
   FUNCTION GET_MAP_KEYS(p_map          IN DBMS_SQL.NUMBER_TABLE)
      RETURN DBMS_SQL.NUMBER_TABLE
   IS
      l_list    DBMS_SQL.NUMBER_TABLE;
      k         NUMBER;
      j         NUMBER := 1;
   BEGIN
      k := p_map.FIRST;
      WHILE k IS NOT NULL LOOP
         l_list(j) := k;
         j := j + 1;
         k := p_map.NEXT(k);
      END LOOP;

      RETURN l_list;
   END;

   -- Forward Declarations
   PROCEDURE PREPARE_RUNS_FOR_RETRY(p_run_ids                   IN DBMS_SQL.NUMBER_TABLE,
                                    p_recurse_children          IN VARCHAR2);
   PROCEDURE PREPARE_BUNDLES_FOR_RETRY(p_bundle_ids             IN DBMS_SQL.NUMBER_TABLE,
                                       p_recurse_parents        IN VARCHAR2,
                                       p_recurse_children       IN VARCHAR2);
   PROCEDURE PREPARE_TASKS_FOR_RETRY(p_task_ids                 IN DBMS_SQL.NUMBER_TABLE,
                                     p_recurse_parents          IN VARCHAR2,
                                     p_recurse_children         IN VARCHAR2);
   PROCEDURE PREPARE_UNITS_FOR_RETRY(p_unit_ids                 IN DBMS_SQL.NUMBER_TABLE,
                                     p_recurse_parents          IN VARCHAR2,
                                     p_recurse_children         IN VARCHAR2);
   PROCEDURE PREPARE_DMLS_FOR_RETRY(p_dml_ids                   IN DBMS_SQL.NUMBER_TABLE,
                                    p_recurse_parents           IN VARCHAR2);
   PROCEDURE PREPARE_PLSQLS_FOR_RETRY(p_plsql_ids               IN DBMS_SQL.NUMBER_TABLE,
                                      p_recurse_parents         IN VARCHAR2);

   -- Private, prepares multiple plsqls for retry at once.
   PROCEDURE PREPARE_PLSQLS_FOR_RETRY(p_plsql_ids               IN DBMS_SQL.NUMBER_TABLE,
                                      p_recurse_parents         IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_PLSQLS_FOR_RETRY';

      l_parent_id       NUMBER;
      l_parents_map     DBMS_SQL.NUMBER_TABLE;
      j                 NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_plsql_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the parents
      IF p_recurse_parents IS NOT NULL AND p_recurse_parents = FND_API.G_TRUE THEN
         FOR k in p_plsql_ids.FIRST..p_plsql_ids.LAST LOOP
            SELECT unit_id
               INTO l_parent_id
               FROM fnd_oam_dscram_plsqls
               WHERE plsql_id = p_plsql_ids(k);

            --add it to the parents_map if not present
            IF NOT l_parents_map.EXISTS(l_parent_id) THEN
               l_parents_map(l_parent_id) := 1;
               fnd_oam_debug.log(1, l_ctxt, 'Adding parent unit_id: '||l_parent_id);
            END IF;
         END LOOP;

         --delegate the list to the parent prepare_for_retry procedure
         IF l_parents_map.COUNT > 0 THEN
            PREPARE_UNITS_FOR_RETRY(GET_MAP_KEYS(l_parents_map),
                                    FND_API.G_TRUE,
                                    FND_API.G_FALSE);
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'No parent units found.');
         END IF;
      END IF;

      --and finally update the local entities
      fnd_oam_debug.log(1, l_ctxt, 'Processing '||p_plsql_ids.COUNT||' plsqls...');
      FORALL k in p_plsql_ids.FIRST..p_plsql_ids.LAST
         UPDATE fnd_oam_dscram_plsqls
           SET finished_ret_sts = NULL
           WHERE plsql_id = p_plsql_ids(k)
           AND finished_ret_sts <> FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing plsqls for retry';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Private, prepares multiple dmls for retry at once.
   PROCEDURE PREPARE_DMLS_FOR_RETRY(p_dml_ids           IN DBMS_SQL.NUMBER_TABLE,
                                     p_recurse_parents  IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_DMLS_FOR_RETRY';

      l_parent_id       NUMBER;
      l_parents_map     DBMS_SQL.NUMBER_TABLE;
      j                 NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_dml_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the parents
      IF p_recurse_parents IS NOT NULL AND p_recurse_parents = FND_API.G_TRUE THEN
         FOR k in p_dml_ids.FIRST..p_dml_ids.LAST LOOP
            SELECT unit_id
               INTO l_parent_id
               FROM fnd_oam_dscram_dmls
               WHERE dml_id = p_dml_ids(k);

            --add it to the parents_map if not present
            IF NOT l_parents_map.EXISTS(l_parent_id) THEN
               l_parents_map(l_parent_id) := 1;
               fnd_oam_debug.log(1, l_ctxt, 'Adding parent unit_id: '||l_parent_id);
            END IF;
         END LOOP;

         --delegate the list to the parent prepare_for_retry procedure
         IF l_parents_map.COUNT > 0 THEN
            PREPARE_UNITS_FOR_RETRY(GET_MAP_KEYS(l_parents_map),
                                    FND_API.G_TRUE,
                                    FND_API.G_FALSE);
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'No parent units found.');
         END IF;
      END IF;

      --and finally update the local entities
      fnd_oam_debug.log(1, l_ctxt, 'Processing '||p_dml_ids.COUNT||' dmls...');
      FORALL k in p_dml_ids.FIRST..p_dml_ids.LAST
         UPDATE fnd_oam_dscram_dmls
           SET finished_ret_sts = NULL
           WHERE dml_id = p_dml_ids(k)
           AND finished_ret_sts <> FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing dmls for retry.';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Private, prepares multiple units for retry at once.
   PROCEDURE PREPARE_UNITS_FOR_RETRY(p_unit_ids         IN DBMS_SQL.NUMBER_TABLE,
                                     p_recurse_parents  IN VARCHAR2,
                                     p_recurse_children IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_UNITS_FOR_RETRY';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_parent_id       NUMBER;
      l_parents_map     DBMS_SQL.NUMBER_TABLE;
      j                 NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_unit_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the children
      IF p_recurse_children IS NOT NULL AND p_recurse_children = FND_API.G_TRUE THEN
         FOR k in p_unit_ids.FIRST..p_unit_ids.LAST LOOP
            --query out any child units
            fnd_oam_debug.log(1, l_ctxt, 'Processing child units of unit_id: '||p_unit_ids(k));
            SELECT unit_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_units
               WHERE concurrent_group_unit_id = p_unit_ids(k);

            PREPARE_UNITS_FOR_RETRY(l_ids,
                                    FND_API.G_FALSE,
                                    FND_API.G_TRUE);

            fnd_oam_debug.log(1, l_ctxt, 'Processing dmls of unit_id: '||p_unit_ids(k));

            --get the dmls for the k'th unit
            l_ids.DELETE;
            SELECT dml_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_dmls
               WHERE unit_id = p_unit_ids(k)
               AND finished_ret_sts <> FND_API.G_RET_STS_SUCCESS;

            --delegate the list to the child prepare_for_retry procedure
            PREPARE_DMLS_FOR_RETRY(l_ids,
                                   FND_API.G_FALSE);

            fnd_oam_debug.log(1, l_ctxt, 'Processing plsqls of unit_id: '||p_unit_ids(k));

            --get the dmls for the k'th unit
            l_ids.DELETE;
            SELECT plsql_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_plsqls
               WHERE unit_id = p_unit_ids(k)
               AND finished_ret_sts <> FND_API.G_RET_STS_SUCCESS;

            --delegate the list to the child prepare_for_retry procedure
            PREPARE_PLSQLS_FOR_RETRY(l_ids,
                                     FND_API.G_FALSE);

         END LOOP;
      END IF;

      --handle the parents
      IF p_recurse_parents IS NOT NULL AND p_recurse_parents = FND_API.G_TRUE THEN
         FOR k in p_unit_ids.FIRST..p_unit_ids.LAST LOOP
            SELECT task_id
               INTO l_parent_id
               FROM fnd_oam_dscram_units
               WHERE unit_id = p_unit_ids(k);

            --add it to the parents_map if not present
            IF NOT l_parents_map.EXISTS(l_parent_id) THEN
               l_parents_map(l_parent_id) := 1;
               fnd_oam_debug.log(1, l_ctxt, 'Adding parent task_id: '||l_parent_id);
            END IF;
         END LOOP;

         --delegate the list to the parent prepare_for_retry procedure
         IF l_parents_map.COUNT > 0 THEN
            PREPARE_TASKS_FOR_RETRY(GET_MAP_KEYS(l_parents_map),
                                    FND_API.G_TRUE,
                                    FND_API.G_FALSE);
         ELSE
            --this happens for units when they're child units
            fnd_oam_debug.log(1, l_ctxt, 'No parent tasks found.');
         END IF;
      END IF;

      --and finally update the local entities
      fnd_oam_debug.log(1, l_ctxt, 'Processing '||p_unit_ids.COUNT||' units...');
      FORALL k in p_unit_ids.FIRST..p_unit_ids.LAST
         UPDATE fnd_oam_dscram_units
           SET unit_status = G_STATUS_RESTARTABLE,
               workers_assigned = 0
           WHERE unit_id = p_unit_ids(k)
           AND unit_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_NO_STATUS, G_STATUS_UNPROCESSED);
      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing units for retry';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Private, prepares multiple tasks for retry at once.
   PROCEDURE PREPARE_TASKS_FOR_RETRY(p_task_ids         IN DBMS_SQL.NUMBER_TABLE,
                                     p_recurse_parents  IN VARCHAR2,
                                     p_recurse_children IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_TASKS_FOR_RETRY';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_parent_id       NUMBER;
      l_parents_map     DBMS_SQL.NUMBER_TABLE;
      j                 NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_task_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the children
      IF p_recurse_children IS NOT NULL AND p_recurse_children = FND_API.G_TRUE THEN
         FOR k in p_task_ids.FIRST..p_task_ids.LAST LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Processing children of task_id: '||p_task_ids(k));

            --get the units for the k'th task
            SELECT unit_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_units
               WHERE task_id = p_task_ids(k)
               AND unit_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_NO_STATUS, G_STATUS_UNPROCESSED);

            --delegate the list to the child prepare_for_retry procedure
            PREPARE_UNITS_FOR_RETRY(l_ids,
                                    FND_API.G_FALSE,
                                    FND_API.G_TRUE);
         END LOOP;
      END IF;

      --handle the parents
      IF p_recurse_parents IS NOT NULL AND p_recurse_parents = FND_API.G_TRUE THEN
         FOR k in p_task_ids.FIRST..p_task_ids.LAST LOOP
            SELECT bundle_id
               INTO l_parent_id
               FROM fnd_oam_dscram_tasks
               WHERE task_id = p_task_ids(k);

            --add it to the parents_map if not present
            IF NOT l_parents_map.EXISTS(l_parent_id) THEN
               l_parents_map(l_parent_id) := 1;
               fnd_oam_debug.log(1, l_ctxt, 'Adding parent bundle_id: '||l_parent_id);
            END IF;
         END LOOP;

         --delegate the list to the parent prepare_for_retry procedure
         IF l_parents_map.COUNT > 0 THEN
            PREPARE_BUNDLES_FOR_RETRY(GET_MAP_KEYS(l_parents_map),
                                      FND_API.G_TRUE,
                                      FND_API.G_FALSE);
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'No parent bundles found.');
         END IF;
      END IF;

      --and finally update the local entities
      fnd_oam_debug.log(1, l_ctxt, 'Processing '||p_task_ids.COUNT||' tasks...');
      FORALL k in p_task_ids.FIRST..p_task_ids.LAST
         UPDATE fnd_oam_dscram_tasks
           SET task_status = G_STATUS_RESTARTABLE,
               workers_assigned = 0
           WHERE task_id = p_task_ids(k)
           AND task_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_UNPROCESSED);
      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing tasks for retry';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Private, prepares multiple bundles for retry at once.
   PROCEDURE PREPARE_BUNDLES_FOR_RETRY(p_bundle_ids             IN DBMS_SQL.NUMBER_TABLE,
                                       p_recurse_parents        IN VARCHAR2,
                                       p_recurse_children       IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_BUNDLES_FOR_RETRY';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      l_parent_id       NUMBER;
      l_parents_map     DBMS_SQL.NUMBER_TABLE;
      j                 NUMBER;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_bundle_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the children
      IF p_recurse_children IS NOT NULL AND p_recurse_children = FND_API.G_TRUE THEN
         FOR k in p_bundle_ids.FIRST..p_bundle_ids.LAST LOOP
            fnd_oam_debug.log(1, l_ctxt, 'Processing children of bundle_id: '||p_bundle_ids(k));

            --get the tasks for the k'th bundle
            SELECT task_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_tasks
               WHERE bundle_id = p_bundle_ids(k)
               AND task_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_UNPROCESSED);

            --delegate the list to the child prepare_for_retry procedure
            PREPARE_TASKS_FOR_RETRY(l_ids,
                                    FND_API.G_FALSE,
                                    FND_API.G_TRUE);
         END LOOP;
      END IF;

      --handle the parents
      IF p_recurse_parents IS NOT NULL AND p_recurse_parents = FND_API.G_TRUE THEN
         FOR k in p_bundle_ids.FIRST..p_bundle_ids.LAST LOOP
            SELECT run_id
               INTO l_parent_id
               FROM fnd_oam_dscram_bundles
               WHERE bundle_id = p_bundle_ids(k);

            --add it to the parents_map if not present
            IF NOT l_parents_map.EXISTS(l_parent_id) THEN
               l_parents_map(l_parent_id) := 1;
               fnd_oam_debug.log(1, l_ctxt, 'Adding parent run_id: '||l_parent_id);
            END IF;
         END LOOP;

         --delegate the list to the parent prepare_for_retry procedure
         IF l_parents_map.COUNT > 0 THEN
            PREPARE_RUNS_FOR_RETRY(GET_MAP_KEYS(l_parents_map),
                                   FND_API.G_FALSE);
         ELSE
            fnd_oam_debug.log(1, l_ctxt, 'No parent runs found.');
         END IF;
      END IF;

      --and finally update the local entities
      fnd_oam_debug.log(1, l_ctxt, 'Processing '||p_bundle_ids.COUNT||' bundles...');
      FORALL k in p_bundle_ids.FIRST..p_bundle_ids.LAST
         UPDATE fnd_oam_dscram_bundles
           SET bundle_status = G_STATUS_RESTARTABLE,
               workers_assigned = 0
           WHERE bundle_id = p_bundle_ids(k)
           AND bundle_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_UNPROCESSED);
      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing bundles for retry';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Private, prepares multiple runs at once.
   PROCEDURE PREPARE_RUNS_FOR_RETRY(p_run_ids           IN DBMS_SQL.NUMBER_TABLE,
                                    p_recurse_children  IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_RUNS_FOR_RETRY';

      l_ids             DBMS_SQL.NUMBER_TABLE;
      k                 NUMBER;
      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --sanity check
      IF (p_run_ids.COUNT < 1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'No IDs to process.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --handle the children
      IF p_recurse_children IS NOT NULL AND p_recurse_children = FND_API.G_TRUE THEN
         FOR k in p_run_ids.FIRST..p_run_ids.LAST LOOP
            --get the bundles for the k'th task
            SELECT bundle_id
               BULK COLLECT INTO l_ids
               FROM fnd_oam_dscram_bundles
               WHERE run_id = p_run_ids(k)
               AND bundle_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_UNPROCESSED);

         --delegate the list to the child prepare_for_retry procedure
         PREPARE_BUNDLES_FOR_RETRY(l_ids,
                                   FND_API.G_FALSE,
                                   FND_API.G_TRUE);
         END LOOP;
      END IF;

      --and finally update the local entities
      FORALL k in p_run_ids.FIRST..p_run_ids.LAST
         UPDATE fnd_oam_dscram_runs_b
           SET run_status = G_STATUS_RESTARTABLE
           WHERE run_id = p_run_ids(k)
           AND run_status NOT IN (G_STATUS_PROCESSED, G_STATUS_SKIPPED, G_STATUS_UNPROCESSED);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing runs for retry.';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

   -- Public
   PROCEDURE PREPARE_RUN_FOR_RETRY(p_run_id             IN NUMBER,
                                   p_recurse_children   IN VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PREPARE_RUN_FOR_RETRY';

      l_lock_handle     VARCHAR2(128);
      l_retval          NUMBER;
      l_status          VARCHAR2(30);
      l_ids             DBMS_SQL.NUMBER_TABLE;

      l_msg             VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --get a lock on the run
      IF NOT LOCK_RUN(p_run_id,
                      l_lock_handle) THEN
         RAISE_APPLICATION_ERROR(-20000, 'Failed to get a lock on run_id: '||p_run_id);
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Run ID: '||p_run_id);

      --make sure the run's in a state where we can retry it
      SELECT run_status
         INTO l_status
         FROM fnd_oam_dscram_runs_b
         WHERE run_id = p_run_id;

      IF l_status NOT IN (G_STATUS_STOPPED, G_STATUS_ERROR_UNKNOWN, G_STATUS_ERROR_FATAL) THEN
         RAISE_APPLICATION_ERROR(-20000, 'Run is in an invalid status('||l_status||') and cannot be retried.');
      END IF;

      IF p_recurse_children IS NOT NULL AND p_recurse_children = FND_API.G_TRUE THEN
         --grab the list of bundles
         SELECT bundle_id
            BULK COLLECT INTO l_ids
            FROM fnd_oam_dscram_bundles
            WHERE RUN_ID = p_run_id;

         --delegate to the bundles_retry
         PREPARE_BUNDLES_FOR_RETRY(l_ids,
                                   FND_API.G_FALSE,
                                   FND_API.G_TRUE);
      END IF;

      --update the run
      UPDATE fnd_oam_dscram_runs_b
         SET run_status = G_STATUS_RESTARTABLE
         WHERE run_id = p_run_id;

      --release the lock on the run
      l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
      IF l_retval <> 0 THEN
         RAISE_APPLICATION_ERROR(-20000, 'Failed to release run lock: '||l_retval);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         l_msg := 'Unexpected Error preparing run_id ('||p_run_id||') for retry.';
         fnd_oam_debug.log(6, l_ctxt, l_msg);
         IF l_lock_handle IS NOT NULL THEN
            l_retval := DBMS_LOCK.RELEASE(l_lock_handle);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE_APPLICATION_ERROR(-20000, l_msg, TRUE);
   END;

END FND_OAM_DSCRAM_UTILS_PKG;

/
