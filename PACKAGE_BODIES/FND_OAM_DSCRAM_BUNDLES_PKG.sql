--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_BUNDLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_BUNDLES_PKG" as
/* $Header: AFOAMDSBDLB.pls 120.8 2006/05/16 20:47:20 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_BUNDLES_PKG.';

   ----------------------------------------
   -- Private Body Variables
   ----------------------------------------
   TYPE b_bundle_cache_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       bundle_id                NUMBER          := NULL,
       worker_id                NUMBER          := NULL,
       workers_allowed          NUMBER          := NULL,
       batch_size               NUMBER          := NULL,
       min_parallel_unit_weight NUMBER          := NULL,
       last_validated           DATE            := NULL,
       last_validation_ret_sts  VARCHAR2(6)     := NULL
       );
   b_bundle_info        b_bundle_cache_type;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_BUNDLE_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_bundle_info.bundle_id;
   END;

   -- Public
   FUNCTION GET_WORKER_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_bundle_info.worker_id;
   END;

   -- Public
   FUNCTION GET_WORKERS_ALLOWED
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_bundle_info.workers_allowed;
   END;

   -- Public
   FUNCTION GET_BATCH_SIZE
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_bundle_info.batch_size;
   END;

   -- Public
   FUNCTION GET_MIN_PARALLEL_UNIT_WEIGHT
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_bundle_info.min_parallel_unit_weight;
   END;

   -- Private
   -- Called by execute_bundle before assigning the worker to sanity check
   -- the input args and make sure the bundle is prepared for another worker.
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP, SKIPPED, FULL
   --  -Converted- : PROCESSED, STOPPED, ERROR_FATAL, ERROR_UNKNOWN
   FUNCTION VALIDATE_START_EXECUTION(p_run_id           IN NUMBER,
                                     p_bundle_id        IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_START_EXECUTION';

      l_status                  VARCHAR2(30);
      l_workers_allowed         NUMBER(15);
      l_workers_assigned        NUMBER(15);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(4000);
      CURSOR C1
      IS
         SELECT bundle_status, workers_allowed, workers_assigned
         FROM fnd_oam_dscram_bundles
         WHERE run_id = p_run_id
         AND bundle_id = p_bundle_id;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- first validate the run
      IF NOT FND_OAM_DSCRAM_RUNS_PKG.VALIDATE_START_EXECUTION(p_run_id,
                                                              l_return_status,
                                                              l_return_msg) THEN
         -- the run has an invalid status, tell the execute to stop the bundle and return.
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
         x_return_msg := '[Run Validation Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||'))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --fetch necessary bundle attributes
      OPEN C1;
      FETCH C1 INTO l_status, l_workers_allowed, l_workers_assigned;
      IF C1%NOTFOUND THEN
         x_return_msg := 'Invalid run_id: ('||p_run_id||') and/or bundle_id('||p_bundle_id||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;
      CLOSE C1;

      --make sure the bundle is in a startable state
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         -- report the true status of the bundle to execute to pass on to execute's caller
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid bundle status('||l_status||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --make sure there's a worker spot, assign will allocate but this check helps short
      --circuit the lock.
      IF l_workers_assigned >= l_workers_allowed THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Public
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP, STOPPED
   --  -Converted- : PROCESSED, STOPPED, ERROR_FATAL, ERROR_UNKNOWN
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN,
                                         p_recurse              IN BOOLEAN,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_CONTINUED_EXECUTION';

      l_status                  VARCHAR2(30) := NULL;
      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(4000);

      CURSOR C1
      IS
         SELECT bundle_status
         FROM fnd_oam_dscram_bundles
         WHERE bundle_id = b_bundle_info.bundle_id;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- make sure the state's initialized
      IF NOT b_bundle_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- check if we should do work or if we can presume the cached status
      IF (p_force_query OR
          FND_OAM_DSCRAM_UTILS_PKG.VALIDATION_DUE(b_bundle_info.last_validated)) THEN

         fnd_oam_debug.log(1, l_ctxt, '>RE-QUERYING<');

         -- re-init the cached fields to allow easy exit
         b_bundle_info.last_validation_ret_sts := x_return_status;
         b_bundle_info.last_validated := SYSDATE;

         --otherwise, fetch necessary run attributes and evaluate
         OPEN C1;
         FETCH C1 INTO l_status;
         IF C1%NOTFOUND THEN
            --shouldn't happen since we're using the cache
            x_return_msg := 'Invalid cached bundle_id: '||b_bundle_info.bundle_id;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
         CLOSE C1;

         --make sure the bundle has been marked as some valid processing state
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_PROCESSING(l_status) THEN
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_CONT_STS_TO_RET(l_status);
            b_bundle_info.last_validation_ret_sts := x_return_status;
            IF x_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED THEN
               x_return_msg := 'Invalid bundle status('||l_status||')';
               fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            END IF;
            RETURN FALSE;
         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_status := b_bundle_info.last_validation_ret_sts;
      END IF;

      -- make a recursive call to the run if required
      IF p_recurse THEN
         IF NOT FND_OAM_DSCRAM_RUNS_PKG.VALIDATE_CONTINUED_EXECUTION(p_force_query,
                                                                     TRUE,
                                                                     l_return_status,
                                                                     l_return_msg) THEN
            -- the run has an invalid status, tell the execute to stop the bundle
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
            x_return_msg := '[Continued Run Validation Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||'))';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
      END IF;

      --success
      b_bundle_info.last_validation_ret_sts := x_return_status;
      b_bundle_info.last_validated := SYSDATE;
      RETURN (x_return_status = FND_API.G_RET_STS_SUCCESS);
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         b_bundle_info.last_validation_ret_sts := x_return_status;
         b_bundle_info.last_validated := SYSDATE;
         RETURN FALSE;
   END;

   -- Private: Autonomous Txn
   -- Before a call to execute_bundle can start doing work, it needs to call this procedure
   -- to allocate a space in the bundle for this worker.  Since this updates the bundle, this
   -- is done in an autonomous transaction that locks the bundle temporarily.
   -- Invariant: VALIDATE_FOR_EXECUTION should have preceeded this to make sure the status was
   -- startable.
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP, FULL
   PROCEDURE ASSIGN_WORKER_TO_BUNDLE(p_run_id           IN NUMBER,
                                     p_bundle_id        IN NUMBER,
                                     px_worker_id       IN OUT NOCOPY NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'ASSIGN_WORKER_TO_BUNDLE';

      l_workers_allowed          NUMBER;
      l_workers_assigned         NUMBER;
      l_batch_size               NUMBER;
      l_min_parallel_unit_weight NUMBER;
      l_status                   VARCHAR2(30);
      l_stat_id                  NUMBER;
      l_new_worker_id            NUMBER := NULL;

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- assign the worker to the run first
      -- first validate the run
      FND_OAM_DSCRAM_RUNS_PKG.ASSIGN_WORKER_TO_RUN(p_run_id,
                                                   l_return_status,
                                                   l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := '[Assigning Worker to Run Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- Do a locking select without a pre-select since we always have to update the bundle
      -- row to add to the # of workers assigned.  Also updates the status to started if it
      -- hasn't been set yet.
      SELECT bundle_status, workers_allowed, workers_assigned, batch_size, min_parallel_unit_weight
         INTO l_status, l_workers_allowed, l_workers_assigned, l_batch_size, l_min_parallel_unit_weight
         FROM fnd_oam_dscram_bundles
         WHERE bundle_id = p_bundle_id
         FOR UPDATE;

      fnd_oam_debug.log(1, l_ctxt, 'Bundle Status: '||l_status);
      fnd_oam_debug.log(1, l_ctxt, 'Workers Allowed: '||l_workers_allowed);
      fnd_oam_debug.log(1, l_ctxt, 'Workers Assigned: '||l_workers_assigned);
      fnd_oam_debug.log(1, l_ctxt, 'Argument Worker ID: '||to_char(px_worker_id));

      -- make sure the status is still good
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid status for assign: ('||l_status||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      -- make sure there's room for this worker
      IF l_workers_assigned >= l_workers_allowed THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
         x_return_msg := 'Workers Assigned('||l_workers_assigned||') >= workers allowed('||l_workers_allowed||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Creating a New Worker...');
      IF l_status <> FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING THEN
         IF l_workers_assigned = 0 THEN
            --create a stats entry
            FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY(p_source_object_type       => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_BUNDLE,
                                                  p_source_object_id         => p_bundle_id,
                                                  p_start_time               => SYSDATE,
                                                  p_prestart_status          => l_status,
                                                  x_stat_id                  => l_stat_id);
            --update the status
            UPDATE fnd_oam_dscram_bundles
               SET bundle_status = FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
               STATS_FINISHED = FND_API.G_FALSE
               WHERE bundle_id = p_bundle_id;
         ELSE
            --the bundle isn't processing but somebody's set it to processing, this shouldn't happen
            x_return_msg := 'Bundle Status ('||l_status||') is not in-progress but the number of workers assigned('||l_workers_assigned||') is nonzero.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            ROLLBACK;
            RETURN;
         END IF;
      END IF;

      -- sanity check the worker id
      IF px_worker_id IS NOT NULL AND (px_worker_id <= 0 OR px_worker_id > l_workers_allowed) THEN
         fnd_oam_debug.log(1, l_ctxt, 'Invalid argument worker_id, resetting to NULL.');
         px_worker_id := NULL;
      END IF;
      -- default the worker_id if one was not provided
      IF px_worker_id IS NULL THEN
         px_worker_id := l_workers_assigned + 1;
      END IF;

      UPDATE fnd_oam_dscram_bundles
         SET workers_assigned = l_workers_assigned + 1,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE bundle_id = p_bundle_id;
      COMMIT;

      --now populate the bundle info state
      b_bundle_info.bundle_id := p_bundle_id;
      b_bundle_info.worker_id := px_worker_id;
      b_bundle_info.workers_allowed := l_workers_allowed;
      b_bundle_info.batch_size := l_batch_size;
      b_bundle_info.min_parallel_unit_weight := NVL(l_min_parallel_unit_weight, 0);
      b_bundle_info.last_validated := NULL;
      b_bundle_info.initialized := TRUE;

      --now call run API for initializing arg context, needs to occur after the bundle is
      --initialized to allow per-worker args to print correctly here.
      FND_OAM_DSCRAM_RUNS_PKG.INITIALIZE_RUN_ARG_CONTEXT(l_return_status,
                                                         l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         b_bundle_info.initialized := FALSE;
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'Worker Assigned.');
      fnd_oam_debug.log(1, l_ctxt, 'Worker ID: '||px_worker_id);
      fnd_oam_debug.log(1, l_ctxt, 'Default Batch Size: '||l_batch_size);

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
   END;

   -- Private: Autonomous Txn
   -- Called when a bundle is completed in some way, usually when there are no more
   -- tasks to fetch.  Duties include updating the bundle's status, workers_assigned and completing
   -- the stats record.  If the final_status is the same as the current_status, assume
   -- that some other worker already completed it.
   -- Invariant: since this is private, assume the bundle state is valid.
   -- Returns the ret_sts that execute should return
   PROCEDURE COMPLETE_BUNDLE(p_proposed_status  IN VARCHAR2,
                             p_proposed_ret_sts IN VARCHAR2,
                             x_final_status     OUT NOCOPY VARCHAR2,
                             x_final_ret_sts    OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_BUNDLE';

      l_final_status    VARCHAR2(30);
      l_final_ret_sts   VARCHAR2(6);

      l_status                  VARCHAR2(30);
      l_workers_assigned        NUMBER;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- always lock the bundle since we have to decrement the worker count
      SELECT bundle_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_bundles
         WHERE bundle_id = b_bundle_info.bundle_id
         FOR UPDATE;

      -- translate the new_status into a valid final status
      FND_OAM_DSCRAM_UTILS_PKG.TRANSLATE_COMPLETED_STATUS(l_status,
                                                          l_workers_assigned,
                                                          p_proposed_status,
                                                          p_proposed_ret_sts,
                                                          l_final_status,
                                                          l_final_ret_sts);
      fnd_oam_debug.log(1, l_ctxt, 'Translated status "'||p_proposed_status||'" into "'||l_final_status||'"');
      fnd_oam_debug.log(1, l_ctxt, 'Translated Execute Ret Sts "'||p_proposed_ret_sts||'" into "'||l_final_ret_sts||'"');

      --update the status, workers_assigned
      UPDATE fnd_oam_dscram_bundles
         SET bundle_status = l_final_status,
             workers_assigned = workers_assigned - 1,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.user_id,
             last_update_date = SYSDATE
         WHERE bundle_id = b_bundle_info.bundle_id;

      --only complete stats if we changed state
      IF l_final_status <> l_status AND
         FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_FINAL(l_final_status) THEN

         FND_OAM_DSCRAM_STATS_PKG.COMPLETE_ENTRY(p_source_object_type   => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_BUNDLE,
                                                 p_source_object_id     => b_bundle_info.bundle_id,
                                                 p_end_time             => SYSDATE,
                                                 p_postend_status       => l_final_status);
      END IF;

      --signal a progress alert to wake up any waiting workers for the run.
      --this is done here as well as the unit to increase the chance that a waiting
      --worker will see a progress alert
      FND_OAM_DSCRAM_UTILS_PKG.SIGNAL_PROGRESS_ALERT;

      -- push the changes and release the lock
      COMMIT;

      x_final_status := l_final_status;
      x_final_ret_sts := l_final_ret_sts;

      --after completing the bundle, kill the state
      b_bundle_info.initialized := FALSE;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_final_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
         x_final_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
   END;

   -- Private
   -- When a task fails, we don't want the bundle to exit immediately because there's other, independent
   -- tasks which can still be executed.  Instead, we accumulate the messages into the return_msg and set the
   -- final return status to stopped.
   PROCEDURE HANDLE_FAILED_TASK(p_task_id               IN NUMBER,
                                p_task_return_status    IN VARCHAR2,
                                px_final_status         IN OUT NOCOPY VARCHAR2,
                                px_return_msg           IN OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'HANDLE_FAILED_TASK';

      l_msg             VARCHAR2(200);
      l_msg_maxlen      NUMBER := 4000;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      fnd_oam_debug.log(1, l_ctxt, 'Task ID('||p_task_id||') seen as failed - current bundle final status('||px_final_status||')');

      --set the final status to stopped if it's not set to error
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_ERROR(px_final_status) THEN
         px_final_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED;
      END IF;
      l_msg := '(Task with ID('||p_task_id||') failed with Status('||p_task_return_status||'))';
      IF ((px_return_msg IS NULL) OR
         ((length(px_return_msg) + length(l_msg)) < l_msg_maxlen)) THEN
         px_return_msg := px_return_msg||l_msg;
      END IF;

      fnd_oam_debug.log(1, l_ctxt, 'New bundle final status: '||px_final_status);
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   -- Return Statuses:
   --   SUCCESS, ERROR, ERROR_UNEXP
   --   Pass Through: SKIPPED, FULL, PROCESSED, STOPPED, ERROR_FATAL, ERROR_UNKNOWN
   PROCEDURE EXECUTE_BUNDLE(p_run_id            IN NUMBER,
                            p_bundle_id         IN NUMBER,
                            px_worker_id        IN OUT NOCOPY NUMBER,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_BUNDLE';

      l_task_id                 NUMBER;
      l_completed_status        VARCHAR2(30);

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(4000);
      l_temp            VARCHAR2(30);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- do an initial validation of the bundle
      IF NOT VALIDATE_START_EXECUTION(p_run_id,
                                      p_bundle_id,
                                      l_return_status,
                                      l_return_msg) THEN
         x_return_status := l_return_status;
         IF l_return_status NOT IN (FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED,
                                    FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED) THEN
            x_return_msg := '[Bundle Start Validation Failed]:('||l_return_msg||')';
         END IF;
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- attempt to assign this invocation as a worker for the bundle
      ASSIGN_WORKER_TO_BUNDLE(p_run_id,
                              p_bundle_id,
                              px_worker_id,
                              l_return_status,
                              l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := '[Bundle Worker Assignment Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --before proceeding after the assign, check our parent objects to make sure
      --their state suggests we should continue
      IF NOT FND_OAM_DSCRAM_RUNS_PKG.VALIDATE_CONTINUED_EXECUTION(FALSE,
                                                                  TRUE,
                                                                  l_return_status,
                                                                  l_return_msg) THEN
         --we don't care why a parent is invalid, just knowing so forces us to
         --stop our work
         COMPLETE_BUNDLE(FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED,
                         FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED,
                         l_completed_status,
                         x_return_status);
         x_return_msg := '[Post-Assignment Parent Validation Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --at this point, we're assigned so we need to issue a complete before returning.
      --this means no quick returns, so we hit the complete after the loop.
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED;

      -- we're in, start pulling tasks and executing them.
      <<outer>>
      LOOP
         --get the next available task
         FND_OAM_DSCRAM_TASKS_PKG.FETCH_NEXT_TASK(TRUE,
                                                  l_task_id,
                                                  l_return_status,
                                                  l_return_msg);
         IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY THEN
            --the bundle is processed when a requery of task queue is empty
            l_return_status := FND_API.G_RET_STS_SUCCESS;
            EXIT outer;
         ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
            x_return_msg := '[Fetch Next Task Failed]:('||l_return_msg||')';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            EXIT outer;
         END IF;

         --execute the task
         FND_OAM_DSCRAM_TASKS_PKG.EXECUTE_TASK(l_task_id,
                                               l_return_status,
                                               l_return_msg);
         IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
            -- the task is full when all available(in-phase) child units have the max
            -- # of workers assigned.
            -- to handle this, loop to fetch additional tasks and try to execute those
            fnd_oam_debug.log(1, l_ctxt, 'Exec task found the task was full, loop fetch for more tasks');
            <<inner>>
            LOOP
               FND_OAM_DSCRAM_TASKS_PKG.FETCH_NEXT_TASK(FALSE,
                                                        l_task_id,
                                                        l_return_status,
                                                        l_return_msg);
               IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY THEN
                  -- seeing an empty here doesn't mean the bundle's finished, just that
                  --the bundle is busy and we should pause before restarting the outer loop.
                  fnd_oam_debug.log(1, l_ctxt, '[Inner Fetch Empty, Waiting for a progress alert]');
                  FND_OAM_DSCRAM_UTILS_PKG.WAIT_FOR_PROGRESS_ALERT;
                  EXIT inner;
               ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
                  x_return_msg := '[Inner Fetch Next Task Failed]:('||l_return_msg||')';
                  fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                  EXIT outer;
               END IF;

               -- try to execute this task
               FND_OAM_DSCRAM_TASKS_PKG.EXECUTE_TASK(l_task_id,
                                                     l_return_status,
                                                     l_return_msg);
               IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
                  --continue to the next inner loop iteration for the next fetch
                  null;
               ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
                     l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED AND
                     l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED THEN
                  HANDLE_FAILED_TASK(l_task_id,
                                     l_return_status,
                                     l_completed_status,
                                     x_return_msg);
                  --besides knowing that the inner task was full and we should keep pulling from
                  --the initialized task queue, how the task completed - even with errors - has no
                  --bearing on the bundle.  If the task wants the bundle to stop, it'll update the
                  --bundle's status which is checked at the end of the outer loop. Instead, we just
                  --assume the task is done and proceed with the bundle from the top.
                  EXIT inner;
               ELSE
                  --success means jump to the outer loop
                  EXIT inner;
               END IF;
            END LOOP inner;
         ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
               l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED AND
               l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED THEN
            HANDLE_FAILED_TASK(l_task_id,
                               l_return_status,
                               l_completed_status,
                               x_return_msg);
         -- no ELSE here because a success should just continue on.
         END IF;

         --after every task evaluation, check on the bundle and its parent run.
         --tell it to requery if the child's execution came back non-successful since this should
         --be pretty uncommon and will help detect when a child has seen a stop in a parent such as
         --this bundle.
         IF NOT VALIDATE_CONTINUED_EXECUTION((l_return_status <> FND_API.G_RET_STS_SUCCESS),
                                             TRUE,
                                             l_return_status,
                                             l_return_msg) THEN
            --complete the bundle based on what validate found
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_RET_STS_TO_COMPL_STATUS(l_return_status);
            --change stop to stopped
            IF FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_ERROR(l_return_status) THEN
               x_return_msg := '[End-of-Loop Validate Failed]:('||l_return_msg||')';
               fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            END IF;
            EXIT outer;
         END IF;

      END LOOP outer;

      --finished processing the bundle
      fnd_oam_debug.log(1, l_ctxt, 'Finished Bundle with status: '||l_completed_status||'('||l_return_status||')');
      COMPLETE_BUNDLE(l_completed_status,
                      l_return_status,
                      l_temp,
                      x_return_status);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         COMPLETE_BUNDLE(FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN,
                         FND_API.G_RET_STS_UNEXP_ERROR,
                         l_completed_status,
                         x_return_status);
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   -- Return Statuses:
   --   Whatever are listed for EXECUTE_BUNDLE
   --   Pass Through: SKIPPED, FULL, PROCESSED, STOPPED, ERROR_FATAL, ERROR_UNKNOWN
   PROCEDURE EXECUTE_HOST_BUNDLES(p_run_id              IN NUMBER,
                                  px_worker_id          IN OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_HOST_BUNDLES';

      l_host_name       VARCHAR2(256);
      l_bundle_ids      DBMS_SQL.NUMBER_TABLE;
      l_bundle_id       NUMBER;

      k                 NUMBER;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(4000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --default to success if there's no bundles for this host
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_return_msg := '';

      --query the host name
      SELECT UPPER(host_name)
         INTO l_host_name
         FROM v$instance;

      --query the bundles for the host as well as any bundles for all hosts denoted by a null hostname
      SELECT bundle_id
         BULK COLLECT INTO l_bundle_ids
         FROM fnd_oam_dscram_bundles
         WHERE run_id = p_run_id
         AND (target_hostname = l_host_name OR target_hostname IS NULL)
         ORDER BY target_hostname DESC, weight DESC;

      --iterate and call
      k := l_bundle_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         fnd_oam_debug.log(2, l_ctxt, 'Executing bundle_id: '||l_bundle_ids(k));
         EXECUTE_BUNDLE(p_run_id,
                        l_bundle_ids(k),
                        px_worker_id,
                        x_return_status,
                        x_return_msg);
         IF x_return_status IN (FND_API.G_RET_STS_SUCCESS,
                                FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED,
                                FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL,
                                FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED) THEN
            --override the output status to success if it's a success-like status
            x_return_status := FND_API.G_RET_STS_SUCCESS;
         ELSE
            --if we didn't succeed, exit early
            EXIT;
         END IF;

         k := l_bundle_ids.NEXT(k);
      END LOOP;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

END FND_OAM_DSCRAM_BUNDLES_PKG;

/
