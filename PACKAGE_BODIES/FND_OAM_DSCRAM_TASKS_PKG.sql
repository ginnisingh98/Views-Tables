--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_TASKS_PKG" as
/* $Header: AFOAMDSTASKB.pls 120.4 2006/05/04 15:16 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_TASKS_PKG.';

   ----------------------------------------
   -- Private Body Variables
   ----------------------------------------
   -- Includes a non-authoritative check that the task has valid units with worker spots to keep
   -- from constantly assigning workers to full tasks before open ones.  Unit will verify
   -- during its assign that the available unit is valid and in phase.  Since work cannot be created
   -- during execution, this optimizes fetching without skipping work since we override the check when
   -- no workers are assigned.
   CURSOR B_TASKS
   IS
      SELECT /*+ FIRST_ROWS(1) */ T.task_id, T.task_status
      FROM fnd_oam_dscram_tasks T
      WHERE T.bundle_id = FND_OAM_DSCRAM_BUNDLES_PKG.GET_BUNDLE_ID
      AND T.task_status in (FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                            FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                            FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_RESTARTABLE)
      AND (EXISTS (SELECT unit_id
                   FROM fnd_oam_dscram_units U
                   WHERE U.task_id = T.task_id
                   AND U.unit_status IN (FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                                         FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                                         FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_RESTARTABLE)
                   AND U.concurrent_group_unit_id IS NULL
                   AND (U.actual_workers_allowed IS NULL OR U.actual_workers_allowed > U.workers_assigned)) OR
           T.workers_assigned = 0)
      ORDER BY priority ASC, weight DESC;

   --package cache of currently executing task
   TYPE b_task_cache_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       task_id                  NUMBER          := NULL,
       last_validated           DATE            := NULL,
       last_validation_ret_sts  VARCHAR2(6)     := NULL
       );
   b_task_info          b_task_cache_type;

   --not part of state because stored before assign
   b_last_fetched_task_id       NUMBER(15) := NULL;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_TASK_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_task_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_task_info.task_id;
   END;

   -- Public
   -- Return Statuses:
   -- SUCCESS, ERROR, ERROR_UNEXP, EMPTY
   PROCEDURE FETCH_NEXT_TASK(p_requery          IN              BOOLEAN,
                             x_task_id          OUT NOCOPY      NUMBER,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_NEXT_TASK';

      l_task_id NUMBER(15);
      l_status  VARCHAR2(30);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --handle closing/opening the cursor as necessary depending on p_requery
      IF p_requery OR
         NOT B_TASKS%ISOPEN THEN
         --reset the last vars when doing a requery
         b_last_fetched_task_id := NULL;

         IF p_requery AND
            B_TASKS%ISOPEN THEN
            CLOSE B_TASKS;
         END IF;
         OPEN B_TASKS;
      END IF;

      --FETCH the next row
      FETCH B_TASKS INTO l_task_id, l_status;

      -- no rows is an empty
      IF B_TASKS%NOTFOUND THEN
         fnd_oam_debug.log(1, l_ctxt, 'B_TASKS empty');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY;
         CLOSE B_TASKS;
         RETURN;
      END IF;

      --cache the last task fetched to allow a quick validation later
      fnd_oam_debug.log(1, l_ctxt, 'Task ID(Status): '||l_task_id||'('||l_status||')');
      x_task_id := l_task_id;
      b_last_fetched_task_id := l_task_id;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF B_TASKS%ISOPEN THEN
            CLOSE B_TASKS;
         END IF;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private
   -- Called by execute_task before assigning the worker to sanity check
   -- the input args.
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP
   --  -Converted- : SKIP, PROCESSED, STOPPED, ERROR_FATAL, ERROR_UNKNOWN
   FUNCTION VALIDATE_START_EXECUTION(p_task_id          IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_START_EXECUTION';

      l_status                  VARCHAR2(30);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);

      CURSOR C1
      IS
         SELECT task_status
         FROM fnd_oam_dscram_tasks
         WHERE task_id = p_task_id;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- automatically valid if task_id same as last fetched, if status has changed
      -- then assign will catch it.
      IF p_task_id = b_last_fetched_task_id THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         RETURN TRUE;
      END IF;

      --fetch necessary task attributes
      OPEN C1;
      FETCH C1 INTO l_status;
      IF C1%NOTFOUND THEN
         x_return_msg := 'Invalid task_id: ('||p_task_id||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;
      CLOSE C1;

      --make sure the task has been marked as started by the controller
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         -- report the true status of the task to execute to pass on to execute's caller
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid task status('||l_status||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
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
      l_return_msg              VARCHAR2(2048);

      CURSOR C1
      IS
         SELECT task_status
         FROM fnd_oam_dscram_tasks
         WHERE task_id = b_task_info.task_id;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- make sure the state's initialized
      IF NOT b_task_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- check if we should do work or if we can presume the cached status
      IF (p_force_query OR
          FND_OAM_DSCRAM_UTILS_PKG.VALIDATION_DUE(b_task_info.last_validated)) THEN

         fnd_oam_debug.log(1, l_ctxt, '>RE-QUERYING<');

         -- re-init the cached fields to allow easy exit
         b_task_info.last_validation_ret_sts := x_return_status;
         b_task_info.last_validated := SYSDATE;

         --otherwise, fetch necessary run attributes and evaluate
         OPEN C1;
         FETCH C1 INTO l_status;
         IF C1%NOTFOUND THEN
            --shouldn't happen since we're using the cache
            x_return_msg := 'Invalid cached task_id: '||b_task_info.task_id;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
         CLOSE C1;

         --make sure the task has been marked as processing
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_PROCESSING(l_status) THEN
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_CONT_STS_TO_RET(l_status);
            b_task_info.last_validation_ret_sts := x_return_status;
            IF x_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED THEN
               x_return_msg := 'Invalid task status('||l_status||')';
               fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            END IF;
            RETURN FALSE;
         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_status := b_task_info.last_validation_ret_sts;
      END IF;

      -- make a recursive call to the bundle if required
      IF p_recurse THEN
         IF NOT FND_OAM_DSCRAM_BUNDLES_PKG.VALIDATE_CONTINUED_EXECUTION(p_force_query,
                                                                        TRUE,
                                                                        l_return_status,
                                                                        l_return_msg) THEN
            -- the run/bundle has an invalid status, tell the execute to stop the task
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
            x_return_msg := '[Continued Validation Parent(s) Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||'))';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
      END IF;

      --success
      b_task_info.last_validation_ret_sts := x_return_status;
      b_task_info.last_validated := SYSDATE;
      RETURN (x_return_status = FND_API.G_RET_STS_SUCCESS);
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         b_task_info.last_validation_ret_sts := x_return_status;
         b_task_info.last_validated := SYSDATE;
         RETURN FALSE;
   END;

   -- Private: Autonomous Txn
   -- Invariant:
   --   Validate_statr must preceed this call so we can assume the p_task_id has a valid
   --   database row.
   -- Before a call to execute_task can start doing work, it needs to call this procedure
   -- to make sure the status is set to processing and a stats row is created for it.
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP
   --  -Conv Validate_start statuses-
   PROCEDURE ASSIGN_WORKER_TO_TASK(p_task_id            IN NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'ASSIGN_WORKER_TO_TASK';

      l_stat_id                 NUMBER;
      l_status                  VARCHAR2(30) := NULL;
      l_workers_assigned        NUMBER(15);

   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- Do a locking select without a pre-select since we always have to update the
      -- row to add to the # of workers assigned.  Also updates the status to started if it
      -- hasn't been set yet.
      SELECT task_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_tasks
         WHERE task_id = p_task_id
         FOR UPDATE;

      fnd_oam_debug.log(1, l_ctxt, 'Task Status(Workers): '||l_status||'('||l_workers_assigned||')');

      -- make sure the status is runnable after the lock
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid task in assign, status('||l_status||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      -- if we're executable but not processing we should start the entry
      IF l_status <> FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING THEN
         IF l_workers_assigned = 0 THEN
            --create a new stats entry for the task
            FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY(p_source_object_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_TASK,
                                                  p_source_object_id    => p_task_id,
                                                  p_start_time          => SYSDATE,
                                                  p_prestart_status     => l_status,
                                                  x_stat_id             => l_stat_id);
            UPDATE fnd_oam_dscram_tasks
               SET task_status = FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
               STATS_FINISHED = FND_API.G_FALSE
               WHERE task_id = p_task_id;
         ELSE
            --the bundle isn't processing but the worker count's nonzero, this shouldn't happen
            x_return_msg := 'Task Status ('||l_status||') is not in-progress but the number of workers assigned('||l_workers_assigned||') is nonzero.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            ROLLBACK;
            RETURN;
         END IF;
      END IF;

      --update the task's # of workers assigned
      UPDATE fnd_oam_dscram_tasks
         SET workers_assigned = workers_assigned + 1,
         last_updated_by = fnd_global.user_id,
         last_update_login = fnd_global.user_id,
         last_update_date = SYSDATE
         WHERE task_id = p_task_id;

      --commit the changes and release the lock
      COMMIT;

      --populate the task state
      b_task_info.task_id := p_task_id;
      b_task_info.last_validated := NULL;
      b_task_info.initialized := TRUE;

      -- invalidate the last_fetched vars since we've changed things
      b_last_fetched_task_id := NULL;

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
   -- Called when a task is completed in some way, usually when there are no more
   -- processable units to fetch.  Duties include updating the task's status and completing
   -- the stats record.
   PROCEDURE COMPLETE_TASK(p_proposed_status    IN VARCHAR2,
                           p_proposed_ret_sts   IN VARCHAR2,
                           x_final_status       OUT NOCOPY VARCHAR2,
                           x_final_ret_sts      OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_TASK';

      l_final_status    VARCHAR2(30);
      l_final_ret_sts   VARCHAR2(6);

      l_status                  VARCHAR2(30);
      l_workers_assigned        NUMBER(15);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- always lock the task since we have to decrement the worker count
      SELECT task_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_tasks
         WHERE task_id = b_task_info.task_id
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

      --if we discovered that we're full, possibly temporarily, just decrement the worker count and leave as long as we're not the last worker
      IF l_final_ret_sts = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL AND l_workers_assigned > 1 THEN
         UPDATE fnd_oam_dscram_tasks
            SET workers_assigned = workers_assigned - 1,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE task_id = b_task_info.task_id;
      ELSE
         -- otherwise, update the status and workers_assigned
         UPDATE fnd_oam_dscram_tasks
            SET task_status = l_final_status,
            workers_assigned = workers_assigned - 1,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE task_id = b_task_info.task_id;

         --only complete stats if we changed state
         IF l_final_status <> l_status AND
            FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_FINAL(l_final_status) THEN

            FND_OAM_DSCRAM_STATS_PKG.COMPLETE_ENTRY(p_source_object_type        => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_TASK,
                                                    p_source_object_id          => b_task_info.task_id,
                                                    p_end_time                  => SYSDATE,
                                                    p_postend_status            => l_final_status);
         END IF;
      END IF;

      -- push the changes and release the lock
      COMMIT;

      x_final_status := l_final_status;
      x_final_ret_sts := l_final_ret_sts;

      --after completing the task, kill the state
      b_task_info.initialized := FALSE;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_final_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
         x_final_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
   END;

   -- Public
   PROCEDURE EXECUTE_TASK(p_task_id             IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_TASK';

      l_unit_id         NUMBER;
      l_completed_status        VARCHAR2(30);

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_temp            VARCHAR2(30);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- do an initial validation of the task
      IF NOT VALIDATE_START_EXECUTION(p_task_id,
                                      l_return_status,
                                      l_return_msg) THEN
         x_return_status := l_return_status;
         x_return_msg := '[Task Validation Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- attempt to assign this invocation as a worker for the bundle
      ASSIGN_WORKER_TO_TASK(p_task_id,
                            l_return_status,
                            l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := '[Task Worker Assignment Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --before proceeding after the assign, check our parent objects to make sure
      --their state suggests we should continue
      IF NOT FND_OAM_DSCRAM_BUNDLES_PKG.VALIDATE_CONTINUED_EXECUTION(FALSE,
                                                                     TRUE,
                                                                     l_return_status,
                                                                     l_return_msg) THEN
         --we don't care why a parent is invalid, just knowing so forces us to
         --stop our work
         COMPLETE_TASK(FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED,
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
      l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED;
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      -- we're in, start pulling units and executing them.
      <<outer>>
      LOOP
         --get the next available task
         FND_OAM_DSCRAM_UNITS_PKG.FETCH_NEXT_UNIT(TRUE,
                                                  l_unit_id,
                                                  l_return_status,
                                                  l_return_msg);
         IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY THEN
            -- empty means no units left, independent of phase
            l_return_status := FND_API.G_RET_STS_SUCCESS;
            EXIT outer;
         ELSIF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
            -- full means nothing available right now so return and find another task.
            EXIT outer;
         ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
            x_return_msg := '[Fetch Next Unit Failed]:('||l_return_msg||')';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            EXIT outer;
         END IF;

         --execute the unit
         FND_OAM_DSCRAM_UNITS_PKG.EXECUTE_UNIT(l_unit_id,
                                               l_return_status,
                                               l_return_msg);
         IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
            --If we got past the fetch but the execute found it full, continue
            --fetching.
            <<inner>>
            LOOP
               FND_OAM_DSCRAM_UNITS_PKG.FETCH_NEXT_UNIT(FALSE,
                                                        l_unit_id,
                                                        l_return_status,
                                                        l_return_msg);
               IF l_return_status IN (FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY,
                                      FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL) THEN
                  -- seeing an empty or full here doesn't mean the task's done, just that it's busy.
                  -- return full to the bundle_pkg to pick another task.
                  l_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
                  EXIT outer;
               ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
                  x_return_msg := '[Inner Fetch Next Unit Failed]:('||l_return_msg||')';
                  fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                  EXIT outer;
               END IF;

               -- try to execute this unit
               FND_OAM_DSCRAM_UNITS_PKG.EXECUTE_UNIT(l_unit_id,
                                                     l_return_status,
                                                     l_return_msg);
               IF l_return_status = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
                  --continue to the next inner loop iteration for the next fetch
                  null;
               ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                  --on success break out of the loop so we can requery the units table from scratch
                  EXIT inner;
               ELSIF l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED AND
                     l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED THEN
                  -- unexpected execution failure, since units have phases, there may be dependencies between
                  -- units which will break if we continue with the task. To handle this, we'll stop the task and
                  -- allow the user to choose whether to ignore the failed unit or retry them when restarting the task.
                  x_return_msg := '[Inner Execute Unit Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||')). Stopping task.';
                  fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                  l_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
                  l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED;
                  EXIT outer;
               END IF;
            END LOOP inner;
         ELSIF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
               l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED AND
               l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_SKIPPED THEN
            -- take the same actions as when the inner execute fails
            x_return_msg := '[Outer Execute Unit Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||')). Stopping task.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            l_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED;
            EXIT outer;
         END IF;

         --after every unit evaluation, check on the task and its parents.
         --tell it to requery if the child's execution came back non-successful since this should
         --be pretty uncommon and will help detect when a child has seen a stop in a parent.
         IF NOT VALIDATE_CONTINUED_EXECUTION((l_return_status <> FND_API.G_RET_STS_SUCCESS),
                                             TRUE,
                                             l_return_status,
                                             l_return_msg) THEN
            --complete the task based on what validate found
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_RET_STS_TO_COMPL_STATUS(l_return_status);
            IF FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_ERROR(l_return_status) THEN
               x_return_msg := '[End-of-Loop Validate Failed]:('||l_return_msg||')';
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            END IF;
            EXIT outer;
         END IF;

      END LOOP outer;

      --finished processing the bundle
      fnd_oam_debug.log(1, l_ctxt, 'Finished Task with status: '||l_completed_status||'('||l_return_status||')');
      COMPLETE_TASK(l_completed_status,
                    l_return_status,
                    l_temp,
                    x_return_status);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         COMPLETE_TASK(FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN,
                         FND_API.G_RET_STS_UNEXP_ERROR,
                         l_completed_status,
                         x_return_status);
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

END FND_OAM_DSCRAM_TASKS_PKG;

/
