--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_UNITS_PKG" as
/* $Header: AFOAMDSUNITB.pls 120.8 2006/06/07 17:43:32 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_UNITS_PKG.';

   ----------------------------------------
   -- Private Body Variables
   ----------------------------------------
   CURSOR B_UNITS
   IS
      SELECT /*+ FIRST_ROWS(1) */ unit_id, unit_status, phase, actual_workers_allowed, workers_assigned
      FROM fnd_oam_dscram_units
      WHERE task_id = FND_OAM_DSCRAM_TASKS_PKG.GET_TASK_ID
      AND unit_status in (FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_UNPROCESSED,
                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_RESTARTABLE,
                          FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_FINISHING) --need to include finishing to keep from violating phases
      AND concurrent_group_unit_id IS NULL --only select top-level units, all units with a conc_unit_id should belong to a parent unit
      ORDER BY phase ASC, priority ASC, weight DESC;

   TYPE b_unit_cache_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       unit_id                  NUMBER(15)      := NULL,
       unit_type                VARCHAR2(30)    := NULL,
       weight                   NUMBER          := NULL,
       unit_object_owner        VARCHAR2(30)    := NULL,
       unit_object_name         VARCHAR2(30)    := NULL,
       error_fatality_level     VARCHAR2(30)    := NULL,
       use_splitting            BOOLEAN         := NULL,
       batch_size               NUMBER(15)      := NULL,
       actual_workers_allowed   NUMBER(15)      := NULL,
       last_validated           DATE            := NULL,
       last_validation_ret_sts  VARCHAR2(6)     := NULL
       );
   b_unit_info          b_unit_cache_type;

   --not part of state because it's set before assign
   b_last_fetched_unit_id       NUMBER(15) := NULL;
   b_last_fetched_unit_phase    NUMBER := NULL;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------
   -- Public
   FUNCTION GET_UNIT_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_unit_info.unit_id;
   END;

   -- Public
   FUNCTION GET_WORKERS_ALLOWED
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_unit_info.actual_workers_allowed;
   END;

   -- Public
   FUNCTION GET_BATCH_SIZE
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_unit_info.batch_size;
   END;

   -- Public
   FUNCTION GET_UNIT_OBJECT_OWNER
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_unit_info.unit_object_owner;
   END;

   -- Public
   FUNCTION GET_UNIT_OBJECT_NAME
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_unit_info.unit_object_name;
   END;

   -- Public
   FUNCTION CREATE_WORK_ITEM(p_priority         IN NUMBER,
                             p_weight           IN NUMBER,
                             p_item_type        IN VARCHAR2,
                             p_item_id          IN NUMBER)
      RETURN work_item_type
   IS
      l_work_item       work_item_type;
   BEGIN
      l_work_item.priority      := p_priority;
      l_work_item.weight        := p_weight;
      l_work_item.item_type     := p_item_type;
      l_work_item.item_id       := p_item_id;
      l_work_item.item_msg      := NULL;       -- NULL causes complete to defer to the work item cache's value

      RETURN l_work_item;
   END;

   -- Public
   PROCEDURE FETCH_NEXT_UNIT(p_requery          IN              BOOLEAN,
                             x_unit_id          OUT NOCOPY      NUMBER,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'FETCH_NEXT_UNIT';

      l_unit_id                 NUMBER(15);
      l_status                  VARCHAR2(30);
      l_phase                   NUMBER;
      l_workers_allowed         NUMBER(15);
      l_workers_assigned        NUMBER(15);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --handle closing/opening the cursor as necessary depending on p_requery
      IF p_requery OR
         NOT B_UNITS%ISOPEN THEN
         --reset the last vars when doing a requery
         b_last_fetched_unit_id := NULL;
         b_last_fetched_unit_phase := NULL;

         IF p_requery AND
            B_UNITS%ISOPEN THEN
            CLOSE B_UNITS;
         END IF;
         OPEN B_UNITS;
      END IF;

      --FETCH the next row
      FETCH B_UNITS INTO l_unit_id, l_status, l_phase, l_workers_allowed, l_workers_assigned;

      -- no rows is an empty
      IF B_UNITS%NOTFOUND THEN
         fnd_oam_debug.log(1, l_ctxt, 'B_UNITS empty');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_EMPTY;
         CLOSE B_UNITS;
         RETURN;
      END IF;

      -- begin a loop here to do additional fetches if we detect there isn't a spot for a worker
      LOOP
         fnd_oam_debug.log(1, l_ctxt, 'Unit ID(Status): '||l_unit_id||'('||l_status||')');

         -- if the last_phase isn't null, make sure we're not looking at a unit in a later
         -- phase, makes the assumption that there is no phase after null.
         IF b_last_fetched_unit_phase IS NOT NULL AND
            (l_phase IS NULL OR b_last_fetched_unit_phase < l_phase) THEN
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
            -- close the cursor to allow the current, invalid unit to get queried up next time
            CLOSE B_UNITS;
            fnd_oam_debug.log(1, l_ctxt, 'Unit Phase('||l_phase||') later than last_phase('||b_last_fetched_unit_phase||')');
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --if the unit's finishing, we're just here to log its phase and fetch the next - we can't return this unit
         IF l_status = FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_FINISHING THEN
            fnd_oam_debug.log(1, l_ctxt, 'Found finishing unit, Fetching Next');
         ELSE
            -- see if there's space in the unit
            IF l_workers_allowed IS NULL OR l_workers_assigned < l_workers_allowed THEN
               --exit to return the unit
               EXIT;
            ELSE
               fnd_oam_debug.log(1, l_ctxt, 'Unit Full, Fetching Next');
            END IF;
         END IF;

         -- if we're still in the loop at this point, set this unit to the last fetched and fetch
         -- the next
         b_last_fetched_unit_id := l_unit_id;
         b_last_fetched_unit_phase := l_phase;

         --FETCH the next row
         FETCH B_UNITS INTO l_unit_id, l_status, l_phase, l_workers_allowed, l_workers_assigned;

         -- no rows at this point isn't an empty but a full
         IF B_UNITS%NOTFOUND THEN
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
            CLOSE B_UNITS;
            fnd_oam_debug.log(1, l_ctxt, 'No more units to Fetch');
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      END LOOP;

      --cache the last unit fetched to allow a quick validation later
      x_unit_id := l_unit_id;
      b_last_fetched_unit_id := l_unit_id;
      b_last_fetched_unit_phase := l_phase;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         IF B_UNITS%ISOPEN THEN
            CLOSE B_UNITS;
         END IF;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private
   -- Called by execute_unit as a sanity check on the unit_id before beginning execution.
   FUNCTION VALIDATE_START_EXECUTION(p_unit_id          IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_UNIT_FOR_EXECUTION';

      l_status                  VARCHAR2(30);

      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);

      CURSOR C1
      IS
         SELECT unit_status
         FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- automatically valid if unit_id same as last fetched
      IF p_unit_id = b_last_fetched_unit_id THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN TRUE;
      END IF;

      --fetch necessary unit attributes
      OPEN C1;
      FETCH C1 INTO l_status;
      IF C1%NOTFOUND THEN
         x_return_msg := 'Invalid unit_id: ('||p_unit_id||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;
      CLOSE C1;

      --check that the status executes it's executable
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         -- report the true status of the unit to execute to pass on to execute's caller
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
      l_return_msg              VARCHAR2(2048);

      CURSOR C1
      IS
         SELECT unit_status
         FROM fnd_oam_dscram_units
         WHERE unit_id = b_unit_info.unit_id;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- make sure the state's initialized
      IF NOT b_unit_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- check if we should do work or if we can presume the cached status
      IF (p_force_query OR
          FND_OAM_DSCRAM_UTILS_PKG.VALIDATION_DUE(b_unit_info.last_validated)) THEN

         fnd_oam_debug.log(1, l_ctxt, '>RE-QUERYING<');

         -- re-init the cached fields to allow easy exit
         b_unit_info.last_validation_ret_sts := x_return_status;
         b_unit_info.last_validated := SYSDATE;

         --otherwise, fetch necessary run attributes and evaluate
         OPEN C1;
         FETCH C1 INTO l_status;
         IF C1%NOTFOUND THEN
            --shouldn't happen since we're using the cache
            x_return_msg := 'Invalid cached unit_id: '||b_unit_info.unit_id;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
         CLOSE C1;

         --make sure the unit has been marked as processing
         IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_PROCESSING(l_status) THEN
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_CONT_STS_TO_RET(l_status);
            b_unit_info.last_validation_ret_sts := x_return_status;
            IF x_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED THEN
               x_return_msg := 'Invalid unit status('||l_status||')';
               fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            END IF;
            RETURN FALSE;
         END IF;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
         x_return_status := b_unit_info.last_validation_ret_sts;
      END IF;

      -- make a recursive call to the the task if required
      IF p_recurse THEN
         IF NOT FND_OAM_DSCRAM_TASKS_PKG.VALIDATE_CONTINUED_EXECUTION(p_force_query,
                                                                      TRUE,
                                                                      l_return_status,
                                                                      l_return_msg) THEN
            -- the run has an invalid status, tell the execute to stop the unit
            x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED;
            x_return_msg := '[Continued Validation of Parent(s) Failed]:(Status('||l_return_status||'), Msg('||l_return_msg||'))';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
            RETURN FALSE;
         END IF;
      END IF;

      --success
      b_unit_info.last_validation_ret_sts := x_return_status;
      b_unit_info.last_validated := SYSDATE;
      RETURN (x_return_status = FND_API.G_RET_STS_SUCCESS);
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         b_unit_info.last_validation_ret_sts := x_return_status;
         b_unit_info.last_validated := SYSDATE;
         RETURN FALSE;
   END;

   -- Private: Autonomous Txn
   -- Invariant:
   --   Validate_unit must preceed this call so we can assume the p_unit_id has a valid
   --   database row.
   -- Before a call to execute_unit can start doing work, it needs to call this procedure
   -- to make sure the status is set to processing and a stats row is created for it.
   PROCEDURE ASSIGN_WORKER_TO_UNIT(p_unit_id            IN NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'ASSIGN_WORKER_TO_UNIT';

      l_suggest_workers_allowed NUMBER;
      l_actual_workers_allowed  NUMBER;
      l_workers_assigned        NUMBER;
      l_stat_id                 NUMBER;
      l_unit_type               VARCHAR2(30);
      l_weight                  NUMBER;
      l_unit_object_owner       VARCHAR2(30);
      l_unit_object_name        VARCHAR2(30);
      l_batch_size              NUMBER;
      l_error_fatality_level    VARCHAR2(30);
      l_suggest_disable_splitting VARCHAR2(3);
      l_actual_disable_splitting  VARCHAR2(3);

      l_use_splitting           BOOLEAN;

      l_status                  VARCHAR2(30) := NULL;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- Do a locking select without a pre-select since we always have to update the unit
      -- row to add to the # of workers assigned.  Also updates the status to started if it
      -- hasn't been started yet.
      SELECT unit_status, suggest_workers_allowed, actual_workers_allowed, workers_assigned, unit_type, weight,
             unit_object_owner, unit_object_name, error_fatality_level, suggest_disable_splitting, actual_disable_splitting, batch_size
         INTO l_status, l_suggest_workers_allowed, l_actual_workers_allowed, l_workers_assigned, l_unit_type, l_weight,
             l_unit_object_owner, l_unit_object_name, l_error_fatality_level, l_suggest_disable_splitting, l_actual_disable_splitting, l_batch_size
         FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id
         FOR UPDATE;

      fnd_oam_debug.log(1, l_ctxt, 'Unit Status: '||l_status);
      fnd_oam_debug.log(1, l_ctxt, 'Workers Allow(Sug/Act), Assigned: ('||l_suggest_workers_allowed||')('||l_actual_workers_allowed||'), '||l_workers_assigned||')');

      -- make sure the status is runnable after the lock
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_EXECUTABLE(l_status) THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid unit in assign, status('||l_status||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      -- make sure there's a spot for us to work here
      IF ((l_actual_workers_allowed IS NOT NULL AND
           l_workers_assigned >= l_actual_workers_allowed) OR
          (l_actual_workers_allowed IS NULL AND
           l_workers_assigned >= l_suggest_workers_allowed)) THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL;
         fnd_oam_debug.log(1, l_ctxt, 'No workers slot available, returning full.');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         ROLLBACK;
         RETURN;
      END IF;

      -- first start, create a stats entry
      IF l_status <> FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING THEN
         IF l_workers_assigned = 0 THEN
            --create a stats entry
            FND_OAM_DSCRAM_STATS_PKG.CREATE_ENTRY(p_source_object_type  => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_UNIT,
                                                  p_source_object_id    => p_unit_id,
                                                  p_start_time          => SYSDATE,
                                                  p_prestart_status     => l_status,
                                                  x_stat_id             => l_stat_id);

            --for small units, instead of paying the cost of using the parallelization infrastructure, we
            --can limit the number of workers to one and disable splitting to get the unit components done faster.
            --the workers allowed count is also set to one because later components can't
            --execute in parallel with earlier ones unless we're using the AD parallization infrastructure where they
            --all execute at once on a chunk of rows.
            IF ((l_weight IS NOT NULL AND
                 l_weight < FND_OAM_DSCRAM_BUNDLES_PKG.GET_MIN_PARALLEL_UNIT_WEIGHT) OR
                (l_suggest_disable_splitting = FND_API.G_TRUE)) THEN
               fnd_oam_debug.log(1, l_ctxt, 'Small unit or forced disable splitting, using Serial Execution.');

               -- don't overwrite the actual values if they've been set by a previous start, don't want to change state after
               -- we've already set it..
               l_actual_workers_allowed := NVL(l_actual_workers_allowed, 1);
               l_actual_disable_splitting := NVL(l_actual_disable_splitting, FND_API.G_TRUE);
            END IF;

            --set to suggested if still no value
            l_actual_workers_allowed := NVL(l_actual_workers_allowed, l_suggest_workers_allowed); --acceptable to push a NULL
            l_actual_disable_splitting := NVL(l_actual_disable_splitting, NVL(l_suggest_disable_splitting, FND_API.G_FALSE));

            -- update the status and other fields
            UPDATE fnd_oam_dscram_units
               SET unit_status = FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING,
               stats_finished = FND_API.G_FALSE,
               actual_workers_allowed = l_actual_workers_allowed,
               actual_disable_splitting = l_actual_disable_splitting
               WHERE unit_id = p_unit_id;
         ELSE
            --the unit isn't processing but somebody's set it to processing, this shouldn't happen
            x_return_msg := 'Unit Status ('||l_status||') is not in-progress but the number of workers assigned('||l_workers_assigned||') is nonzero.';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            ROLLBACK;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;
      END IF;

      -- convert our splitting decision
      l_use_splitting := NOT(FND_OAM_DSCRAM_UTILS_PKG.FLAG_TO_BOOLEAN(l_actual_disable_splitting));

      -- finally, always update the last updated fields and the # of workers assigned.
      UPDATE fnd_oam_dscram_units
         SET workers_assigned = workers_assigned + 1,
             last_updated_by = fnd_global.user_id,
             last_update_login = fnd_global.user_id,
             last_update_date = SYSDATE
         WHERE unit_id = p_unit_id;

      -- push changes and release lock
      COMMIT;

      -- populate the unit state
      b_unit_info.unit_id                := p_unit_id;
      b_unit_info.unit_type              := l_unit_type;
      b_unit_info.weight                 := l_weight;
      b_unit_info.unit_object_owner      := l_unit_object_owner;
      b_unit_info.unit_object_name       := l_unit_object_name;
      b_unit_info.error_fatality_level   := l_error_fatality_level;
      b_unit_info.use_splitting          := l_use_splitting;
      b_unit_info.actual_workers_allowed := l_actual_workers_allowed;
      b_unit_info.batch_size             := l_batch_size;
      b_unit_info.last_validated         := NULL;
      b_unit_info.initialized            := TRUE;

      --invalidate the last fetched unit since we just changed its state, we'll requery next time anyway
      b_last_fetched_unit_id := NULL;
      b_last_fetched_unit_phase := NULL;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private
   -- Called when a unit is completed in some way. Duties include updating the
   -- unit's status, decrementing workers_assigned, completing the stats record.  The unit may also be given
   -- a list of plsqls, dmls and other work items to complete while we're here.  This update is made atomic with the unit update
   -- to disallow the case where a second worker enters a unit after the work item has been updated but before the unit is
   -- updated and draws a false conclusion on whether there's any work left.  (6/6/06) This is not as important now because
   -- the unit would enter the 'FINISHING' state but still be put into the proper final state by the worker aborted processing
   -- the unit because of an errored dml.  Unlike other COMPLETE_<entity> methods,
   -- we explicitly provide the p_unit_id in case we need to complete other units in the future since unit is a composite type.
   PROCEDURE COMPLETE_UNIT(p_unit_id                    IN NUMBER,
                           p_proposed_status            IN VARCHAR2,
                           p_proposed_ret_sts           IN VARCHAR2,
                           p_message                    IN VARCHAR2,
                           px_arg_context               IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                           p_destroy_caches             IN BOOLEAN,
                           px_work_queue_to_complete    IN OUT NOCOPY ordered_work_queue_type,
                           x_final_ret_sts              OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'COMPLETE_UNIT';

      l_proposed_status         VARCHAR2(30)    := p_proposed_status;
      l_proposed_ret_sts        VARCHAR2(6)     := p_proposed_ret_sts;
      l_final_status            VARCHAR2(30);
      l_final_ret_sts           VARCHAR2(6);

      COMPLETE_FAILED           EXCEPTION;
      l_update_context          BOOLEAN         := FALSE;
      l_message                 VARCHAR2(2048)  := p_message;
      l_status                  VARCHAR2(30);
      l_workers_assigned        NUMBER(15);

      k                 NUMBER;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      -- always lock the unit since we have to decrement the worker count
      SELECT unit_status, workers_assigned
         INTO l_status, l_workers_assigned
         FROM fnd_oam_dscram_units
         WHERE unit_id = p_unit_id
         FOR UPDATE;

      --first take care of our child work items that need concurrent completion (DMLs, PLSQLs, ...)
      IF px_work_queue_to_complete IS NOT NULL AND px_work_queue_to_complete.COUNT > 0 THEN
         BEGIN
            --if we're the last worker and we think all work suceeded so far, update the un-set, writable args of all completed
            --work items
            IF l_workers_assigned = 1 AND
               l_proposed_ret_sts = FND_API.G_RET_STS_SUCCESS THEN

               k := px_work_queue_to_complete.FIRST;
               WHILE k IS NOT NULL LOOP
                  CASE px_work_queue_to_complete(k).item_type
                     WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                        FND_OAM_DSCRAM_DMLS_PKG.UPDATE_COMP_DML_WRITABLE_ARGS(px_work_queue_to_complete(k).item_id,
                                                                              px_arg_context,
                                                                              b_unit_info.use_splitting,
                                                                              l_proposed_ret_sts,
                                                                              l_return_msg);

                     WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                        FND_OAM_DSCRAM_PLSQLS_PKG.UPDATE_COMP_PLS_WRITABLE_ARGS(px_work_queue_to_complete(k).item_id,
                                                                                px_arg_context,
                                                                                b_unit_info.use_splitting,
                                                                                l_proposed_ret_sts,
                                                                                l_return_msg);

                     ELSE
                        --attach the error message to the unit, completing the work items with an unknown type won't get far
                        l_message := 'Work Item ID ('||px_work_queue_to_complete(k).item_id||'), invalid work item type: '||px_work_queue_to_complete(k).item_type;
                        fnd_oam_debug.log(6, l_ctxt, l_return_msg);
                        RAISE COMPLETE_FAILED;
                  END CASE;

                  --if the called update method failed, exit early
                  IF l_proposed_ret_sts <> FND_API.G_RET_STS_SUCCESS THEN
                     l_proposed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
                     --store the failure message on the item
                     px_work_queue_to_complete(k).item_msg := l_return_msg||px_work_queue_to_complete(k).item_msg;
                     --stop processing the loop
                     EXIT;
                  END IF;

                  k := px_work_queue_to_complete.NEXT(k);
               END LOOP;

               --see if the update worked
               IF l_proposed_ret_sts = FND_API.G_RET_STS_SUCCESS THEN
                  --mark that the DESTROY_<type>_CACHE_ENTRY methods should update the context with values from each
                  --work item's arg list.
                  l_update_context := TRUE;
               END IF;
            END IF;

            --always call work item's complete procedure for each work_item, message is derived from the work item's
            --entry, which defaults to NULL to use the work item's cache message.
            k := px_work_queue_to_complete.FIRST;
            WHILE k IS NOT NULL LOOP
               CASE px_work_queue_to_complete(k).item_type
                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                     FND_OAM_DSCRAM_DMLS_PKG.COMPLETE_DML(px_work_queue_to_complete(k).item_id,
                                                          l_proposed_ret_sts,
                                                          px_work_queue_to_complete(k).item_msg,
                                                          l_workers_assigned,
                                                          l_return_status,
                                                          l_return_msg);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                     --since pl/sqls don't write the # of rows processed, they only need to be completed by the last worker
                     IF l_workers_assigned = 1 THEN
                        FND_OAM_DSCRAM_PLSQLS_PKG.COMPLETE_PLSQL(px_work_queue_to_complete(k).item_id,
                                                                 l_proposed_ret_sts,
                                                                 px_work_queue_to_complete(k).item_msg,
                                                                 l_return_status,
                                                                 l_return_msg);
                     END IF;
                  ELSE
                     l_message := 'Work Item ID ('||px_work_queue_to_complete(k).item_id||'), invalid work item type: '||px_work_queue_to_complete(k).item_type;
                     fnd_oam_debug.log(6, l_ctxt, l_message);
                     RAISE COMPLETE_FAILED;
               END CASE;

               --check if the complete_<entity> succeeded, stop processing if it did
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE COMPLETE_FAILED;
               END IF;

               k := px_work_queue_to_complete.NEXT(k);
            END LOOP;

            --only manually destroy the cache entities when the work item was successful, otherwise
            --let the catch-all destroy_cache methods get it
            fnd_oam_debug.log(1, l_ctxt, 'Proposed Unit(s) Ret Sts: '||l_proposed_ret_sts);
            IF l_proposed_ret_sts = FND_API.G_RET_STS_SUCCESS THEN
               --we don't need to clone the context here before execution because the run requires an explicit
               --set_context to update the real context object.
               k := px_work_queue_to_complete.FIRST;
               WHILE k IS NOT NULL LOOP
                  CASE px_work_queue_to_complete(k).item_type
                     WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                        FND_OAM_DSCRAM_DMLS_PKG.DESTROY_DML_CACHE_ENTRY(px_work_queue_to_complete(k).item_id,
                                                                        px_arg_context,
                                                                        l_update_context,
                                                                        l_return_status,
                                                                        l_return_msg);

                     WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                        FND_OAM_DSCRAM_PLSQLS_PKG.DESTROY_PLSQL_CACHE_ENTRY(px_work_queue_to_complete(k).item_id,
                                                                            px_arg_context,
                                                                            l_update_context,
                                                                            l_return_status,
                                                                            l_return_msg);

                     --skip else case, can't happen, complete would have raised an error.
                  END CASE;

                  --if destroy failed, log it in the unit, too late for the work item.  don't keep executing
                  --destroys to keep dependent parts of the updated context from being rolled up without prior
                  --work items rolling up correctly.  Catch-all destroy_cache methods will take care of cleanup.
                  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     l_message := l_return_msg;
                     RAISE COMPLETE_FAILED;
                  END IF;

                  k := px_work_queue_to_complete.NEXT(k);
               END LOOP;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               --if anything went wrong while processing the work units, still complete the unit but with an error
               l_proposed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
               l_proposed_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
         END;
      END IF;

      -- if specified, destroy the work item base caches to keep out leaks
      IF p_destroy_caches THEN
         BEGIN
            --destroy the DML cache
            FND_OAM_DSCRAM_DMLS_PKG.DESTROY_DML_CACHE(px_arg_context,
                                                      l_return_status,
                                                      l_return_msg);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
               NOT FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
               --only error when failing to destory if we're in a non-normal mode
               l_message := l_return_msg;
               RAISE COMPLETE_FAILED;
            END IF;

            --destroy the PLSQL cache
            FND_OAM_DSCRAM_PLSQLS_PKG.DESTROY_PLSQL_CACHE(px_arg_context,
                                                          l_return_status,
                                                          l_return_msg);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS AND
               NOT FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
               --only error when failing to destory if we're in a non-normal mode
               l_message := l_return_msg;
               RAISE COMPLETE_FAILED;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               --if anything went wrong in the DMLs, still complete the unit, just differently
               l_proposed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN;
               l_proposed_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
         END;
      END IF;

      -- translate the new_status into a valid final status
      FND_OAM_DSCRAM_UTILS_PKG.TRANSLATE_COMPLETED_STATUS(l_status,
                                                          l_workers_assigned,
                                                          l_proposed_status,
                                                          l_proposed_ret_sts,
                                                          l_final_status,
                                                          l_final_ret_sts);
      fnd_oam_debug.log(1, l_ctxt, 'Translated status "'||l_proposed_status||'" into "'||l_final_status||'"');
      fnd_oam_debug.log(1, l_ctxt, 'Translated Execute Ret Sts "'||l_proposed_ret_sts||'" into "'||l_final_ret_sts||'"');

      --if we discovered that we're full, possibly temporarily, just decrement the worker count and leave if we're not the last worker
      IF l_final_ret_sts = FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL AND l_workers_assigned > 1 THEN
         UPDATE fnd_oam_dscram_units
            SET workers_assigned = workers_assigned - 1,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE unit_id = p_unit_id;
      ELSE
         -- otherwise, update the status and workers_assigned
         UPDATE fnd_oam_dscram_units
            SET unit_status = l_final_status,
            workers_assigned = workers_assigned - 1,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id,
            last_update_date = SYSDATE
            WHERE unit_id = p_unit_id;

         --only complete stats if we changed state
         IF l_final_status <> l_status AND
            FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_FINAL(l_final_status) THEN

            FND_OAM_DSCRAM_STATS_PKG.COMPLETE_ENTRY(p_source_object_type        => FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_UNIT,
                                                    p_source_object_id          => p_unit_id,
                                                    p_end_time                  => SYSDATE,
                                                    p_postend_status            => l_final_status,
                                                    p_end_message               => l_message);
         END IF;
      END IF;

      -- commit the completed unit and any completed work items in the autonomous transaction
      COMMIT;

      --return our computed return status
      x_final_ret_sts := l_final_ret_sts;

      --after completing the unit, kill the state if we completed the topmost unit, should occur only after
      --completing all child units.
      IF p_unit_id = b_unit_info.unit_id THEN
         b_unit_info.initialized := FALSE;

         --also close the unit fetch cursor
         IF B_UNITS%ISOPEN THEN
            CLOSE B_UNITS;
         END IF;
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_final_ret_sts := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(6, l_ctxt, 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         --safety rollback
         ROLLBACK;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Private wrapper for aborted unit executions
   PROCEDURE COMPLETE_UNIT_IN_ERROR(p_unit_id           IN NUMBER,
                                    p_proposed_status   IN VARCHAR2,
                                    p_proposed_ret_sts  IN VARCHAR2,
                                    p_message           IN VARCHAR2,
                                    x_final_ret_sts     OUT NOCOPY VARCHAR2)
   IS
      l_empty_arg_context       FND_OAM_DSCRAM_ARGS_PKG.arg_context;
      l_empty_work_queue        ordered_work_queue_type;
   BEGIN
      --this is only called from execute_unit, which is only called once on the topmost unit
      COMPLETE_UNIT(p_unit_id,
                    p_proposed_status,
                    p_proposed_ret_sts,
                    p_message,
                    l_empty_arg_context,
                    TRUE,
                    l_empty_work_queue,
                    x_final_ret_sts);
   END;

   -- Private wrapper for the AD initialize procedure.  Autonomous to keep from
   -- committing the parent transaction.
   PROCEDURE INITIALIZE_AD_SPLIT(p_unit_id              IN NUMBER,
                                 p_object_owner         IN VARCHAR2,
                                 p_object_name          IN VARCHAR2,
                                 p_num_workers          IN NUMBER,
                                 p_batch_size           IN NUMBER,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'INITIALIZE_AD_SPLIT';
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'Using owner.table: '||p_object_owner||'.'||p_object_name);

      --Default the # of workers and batch size from the bundle if they're not defined for the unit.
      --Values in the bundle are non-null and these fields are required for AD to function in the multi-worker case.
      AD_PARALLEL_UPDATES_PKG.INITIALIZE_ROWID_RANGE(X_update_type      => AD_PARALLEL_UPDATES_PKG.ROWID_RANGE,
                                                     X_owner            => p_object_owner,
                                                     X_table            => p_object_name,
                                                     X_script           => FND_OAM_DSCRAM_UTILS_PKG.MAKE_AD_SCRIPT_KEY(p_unit_id),
                                                     X_worker_id        => FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKER_ID,
                                                     X_num_workers      => NVL(p_num_workers, FND_OAM_DSCRAM_BUNDLES_PKG.GET_WORKERS_ALLOWED),
                                                     X_batch_size       => NVL(p_batch_size, FND_OAM_DSCRAM_BUNDLES_PKG.GET_BATCH_SIZE),
                                                     X_debug_level      => 0,
                                                     X_processed_mode   => AD_PARALLEL_UPDATES_PKG.PRESERVE_PROCESSED_UNITS);
      --safety commit
      COMMIT;

      fnd_oam_debug.log(1, l_ctxt, 'Finished initialize.');

      -- no return code indicating whether it succeeded, exceptions are thrown
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unit ID ('||p_unit_id||'), Failed to initialize the AD table splitting infrastructure: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
   END;

   -- Private wrapper for the AD get next procedure.  Autonomous to keep from
   -- committing the parent transaction.  Success is indicated by the "x_rows_found" boolean.
   PROCEDURE GET_NEXT_AD_RANGE(x_rowid_lbound   OUT NOCOPY ROWID,
                               x_rowid_ubound   OUT NOCOPY ROWID,
                               x_rows_found     OUT NOCOPY BOOLEAN,
                               x_return_status  OUT NOCOPY VARCHAR2,
                               x_return_msg     OUT NOCOPY VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;

      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_NEXT_AD_RANGE';
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      fnd_oam_debug.log(1, l_ctxt, 'Getting next range...');

      AD_PARALLEL_UPDATES_PKG.GET_ROWID_RANGE(X_start_rowid     => x_rowid_lbound,
                                              X_end_rowid       => x_rowid_ubound,
                                              X_any_rows        => x_rows_found,
                                              X_num_rows        => NULL,   --unused in 120.2
                                              X_restart         => FALSE); --also unused in 120.2
      --safety commit
      COMMIT;

      fnd_oam_debug.log(1, l_ctxt, 'Done.');

      --make sure rows found has a value
      IF x_rows_found IS NULL THEN
         x_rows_found := FALSE;
      END IF;

      -- no return code indicating whether it succeeded, exceptions are thrown
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Failed to fetch next AD range: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK;
   END;

   -- Private wrapper for the AD complete procedure.  This AD API also
   -- calls a commit on the transaction but in this case we want it to commit
   -- the main transaction with previously executed DMLs to keep the operation and its
   -- AD metadata atmoic.
   PROCEDURE COMPLETE_AD_RANGE(p_rowid_ubound           IN ROWID,
                               p_rows_processed         IN NUMBER)

   IS
   BEGIN
      --Note: the rows_processed here is based on how many rows the DMLs actually interacted with, not the number
      --in the range.  This means it can be zero even for a large range.
      AD_PARALLEL_UPDATES_pkg.PROCESSED_ROWID_RANGE(X_rows_processed    => p_rows_processed,
                                                    X_last_rowid        => p_rowid_ubound);
   END;

   --Wrapper to perform range commit autonomously.  Used in non-normal modes to roll back the work
   --but still progress the AD iterator.
   PROCEDURE COMPLETE_AD_RANGE_AUTONOMOUSLY(p_rowid_ubound              IN ROWID,
                                            p_rows_processed            IN NUMBER)

   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      COMPLETE_AD_RANGE(p_rowid_ubound,
                        p_rows_processed);

      --safety commit
      COMMIT;
   END;

   -- Executor called by the various EXECUTE_<TYPE>_UNIT delegates to take care of executing
   -- a list of work.  State is read from the unit package cache.  If splitting is enabled,
   -- all work items in the queue are executed on each segment before a commit.  If not, each
   -- work item is executed serially and a commit is issued between each.
   PROCEDURE INTERNAL_EXECUTE_WORK_QUEUE(px_work_queue                  IN OUT NOCOPY ordered_work_queue_type,
                                         px_arg_context                 IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                         x_work_queue_to_complete       OUT NOCOPY ordered_work_queue_type,
                                         x_return_status                OUT NOCOPY VARCHAR2,
                                         x_return_msg                   OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'INTERNAL_EXECUTE_WORK_QUEUE';

      l_rowid_lbound                    ROWID;
      l_rowid_ubound                    ROWID;
      l_rows_found                      BOOLEAN;
      l_rows_processed                  NUMBER;
      l_max_range_rows_processed        NUMBER;

      k                 NUMBER;
      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      --fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_msg := '';

      --if we've got no work, just return
      IF px_work_queue IS NULL OR px_work_queue.COUNT = 0 THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         fnd_oam_debug.log(1, l_ctxt, 'Work queue empty, returning success.');
         RETURN;
      END IF;

      --work to do, default the status
      x_return_status := FND_API.G_RET_STS_ERROR;

      --at this point either split the work using AD or execute the dmls directly
      IF b_unit_info.use_splitting THEN
         --default the work queue to complete to our input queue
         x_work_queue_to_complete := px_work_queue;

         --initialize the AD Parallel Updates infrastructure
         INITIALIZE_AD_SPLIT(b_unit_info.unit_id,
                             b_unit_info.unit_object_owner,
                             b_unit_info.unit_object_name,
                             b_unit_info.actual_workers_allowed,
                             b_unit_info.batch_size,
                             l_return_status,
                             l_return_msg);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := '[Error initializing AD Split]: '||l_return_msg;
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
            --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --before beginning the loop, force a check of the unit since the only way a worker could get
         --a different set of Work Items to execute than a peer would be if the DML and UNIT were updated.
         --don't recurse but force a requery.  Only checks root unit, assumed to be in sync with child
         --units.
         IF NOT VALIDATE_CONTINUED_EXECUTION(TRUE,
                                             FALSE,
                                             l_return_status,
                                             l_return_msg) THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --loop over ranges of rows
         LOOP
            --ask AD for the next range of rowids
            GET_NEXT_AD_RANGE(l_rowid_lbound,
                              l_rowid_ubound,
                              l_rows_found,
                              l_return_status,
                              l_return_msg);
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
            END IF;

            --if no work, exit the loop
            IF NOT l_rows_found THEN
               EXIT;
            END IF;

            -- work found, so execute the work list in the order found
            l_max_range_rows_processed := 0;
            k := px_work_queue.FIRST;
            WHILE k IS NOT NULL LOOP
               --choose the proper execution function
               CASE px_work_queue(k).item_type
                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                     FND_OAM_DSCRAM_DMLS_PKG.EXECUTE_DML_ON_RANGE(px_work_queue(k).item_id,
                                                                  px_arg_context,
                                                                  l_rowid_lbound,
                                                                  l_rowid_ubound,
                                                                  l_rows_processed,
                                                                  l_return_status,
                                                                  l_return_msg);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                     --set rows processed to zero sinze pl/sql procedures don't report it
                     l_rows_processed := 0;
                     FND_OAM_DSCRAM_PLSQLS_PKG.EXECUTE_PLSQL_ON_RANGE(px_work_queue(k).item_id,
                                                                      px_arg_context,
                                                                      l_rowid_lbound,
                                                                      l_rowid_ubound,
                                                                      l_return_status,
                                                                      l_return_msg);

                  ELSE
                     x_return_msg := 'Work Item ID('||px_work_queue(k).item_id||'), invalid work item type:'||px_work_queue(k).item_type;
                     --skip setting the work item's message since this can only be logged at the unit level
                     fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                     --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                     RETURN;
               END CASE;

               --check if our work suceeded, if not we quick fail because AD can't
               --continue fetching ranges and we can't commit only some work items for a range.
               --Nothing needs to be done for the AD infrastructure, the block will be re-tried
               --automatically next time.
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  ROLLBACK;
                  x_return_status := l_return_status;
                  --attach the failure message to the work item
                  px_work_queue(k).item_msg := l_return_msg||px_work_queue(k).item_msg;
                  x_work_queue_to_complete(k).item_msg := l_return_msg||x_work_queue_to_complete(k).item_msg;
                  -- Although sometimes this message will also be logged with the DML, we pass up the message to get logged
                  -- with the unit also in case the error occurred before the entity could get into the entity's cache and
                  -- store such an error message locally.
                  x_return_msg := 'Work Item with type('||px_work_queue(k).item_type||'),id('||px_work_queue(k).item_id||') failed: '||l_return_msg;
                  --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
               END IF;

               --work item suceeded, see if the number of rows processed was greater than our currently seen max
               IF l_rows_processed > l_max_range_rows_processed THEN
                  l_max_range_rows_processed := l_rows_processed;
               END IF;

               --fetch the next work item
               k := px_work_queue.NEXT(k);
            END LOOP;

            --if we got here, all the work items must have suceeded, complete the ad range
            IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
               COMPLETE_AD_RANGE(l_rowid_ubound,
                                 l_max_range_rows_processed);
               COMMIT;
            ELSE
               ROLLBACK;
               fnd_oam_debug.log(1, l_ctxt, 'Rolling back changes because of non-standard run mode');
               --autonomously complete the range to keep AD progressing
               COMPLETE_AD_RANGE_AUTONOMOUSLY(l_rowid_ubound,
                                              l_max_range_rows_processed);
            END IF;

            --before getting the next range, validate the unit and above to make sure
            --we should keep working
            IF NOT VALIDATE_CONTINUED_EXECUTION(FALSE,
                                                TRUE,
                                                l_return_status,
                                                l_return_msg) THEN
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
            END IF;

         END LOOP;
         fnd_oam_debug.log(1, l_ctxt, 'Done splitting, ad range selection loop exhausted.');
      ELSE
         --if we're not splitting, just execute each work item serially.  Here we call
         --the individual execute_<type> APIs so that we can do incremental complete and
         --commits after each one.  This ensures we save our work as we go.
         x_work_queue_to_complete := NULL;
         k := px_work_queue.FIRST;
         WHILE k IS NOT NULL LOOP
            --choose the proper execution function, entity stats are created and completed within these functions
            CASE px_work_queue(k).item_type
               WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                  FND_OAM_DSCRAM_DMLS_PKG.EXECUTE_DML(px_work_queue(k).item_id,
                                                      px_arg_context,
                                                      l_return_status,
                                                      l_return_msg);

               WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                  FND_OAM_DSCRAM_PLSQLS_PKG.EXECUTE_PLSQL(px_work_queue(k).item_id,
                                                          px_arg_context,
                                                          l_return_status,
                                                          l_return_msg);

               ELSE
                  x_return_msg := 'Work Item ID('||px_work_queue(k).item_id||'), invalid work item type:'||px_work_queue(k).item_type;
                  fnd_oam_debug.log(6, l_ctxt, x_return_msg);
                  --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
            END CASE;

            --see if our work suceeded or not
            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
               --destroy the work item's cache entry exp to get its arg list pushed into the arg context
               CASE px_work_queue(k).item_type
                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_DML THEN
                     FND_OAM_DSCRAM_DMLS_PKG.DESTROY_DML_CACHE_ENTRY(px_work_queue(k).item_id,
                                                                     px_arg_context,
                                                                     TRUE,
                                                                     l_return_status,
                                                                     l_return_msg);

                  WHEN FND_OAM_DSCRAM_UTILS_PKG.G_TYPE_PLSQL THEN
                     FND_OAM_DSCRAM_PLSQLS_PKG.DESTROY_PLSQL_CACHE_ENTRY(px_work_queue(k).item_id,
                                                                         px_arg_context,
                                                                         TRUE,
                                                                         l_return_status,
                                                                         l_return_msg);

               END CASE;

               --see if the destroy worked
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  ROLLBACK;
                  x_return_status := l_return_status;
                  --attach the failure message to the work item
                  px_work_queue(k).item_msg := l_return_msg||px_work_queue(k).item_msg;
                  --now return the error to the unit
                  x_return_msg := 'Work Item with type('||px_work_queue(k).item_type||'),id('||px_work_queue(k).item_id||') failed: '||l_return_msg;
                  --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
                  RETURN;
               END IF;

               --at this point, the work item was sucessfully executed and its cache entry was removed, commit the work
               --on success, we can commit the completed DML locally (unless we're in a non-normal mode)
               --to mark our incremental success since we're the only worker.
               IF FND_OAM_DSCRAM_UTILS_PKG.RUN_IS_NORMAL THEN
                  COMMIT;
               ELSE
                  fnd_oam_debug.log(1, l_ctxt, 'Rolling back changes because of non-standard run mode');
                  ROLLBACK;
               END IF;
            ELSE
               --the work failed, don't continue executing other work units in this case to cover
               --for cross-unit dependencies.
               ROLLBACK;

               --now return the error
               x_return_status := l_return_status;
               --also push up the message so it shows up in a list of units
               x_return_msg := 'Work Item with type('||px_work_queue(k).item_type||'),id('||px_work_queue(k).item_id||') failed: '||l_return_msg;
               --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
            END IF;

            --before getting the next work item, validate the unit and above to make sure
            --we should keep working
            IF NOT VALIDATE_CONTINUED_EXECUTION(FALSE,
                                                TRUE,
                                                l_return_status,
                                                l_return_msg) THEN
               x_return_status := l_return_status;
               x_return_msg := l_return_msg;
               --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
            END IF;

            --fetch the next work item
            k := px_work_queue.NEXT(k);
         END LOOP;
      END IF;

      --if we got here, we're done.

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         -- include a safety rollback since this procedure calls other procedures that
         -- leave results on the main transaction.
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         --fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- helper to EXECUTE_UNIT to handle the case where the topmost unit is a DML_SET type unit.
   -- responsibilities include querying out the dmls for the unit, preparing the structure used by
   -- internal_execute_work_queue to execute the dmls, and returning the results to execute_unit.
   PROCEDURE EXECUTE_DML_SET_UNIT(px_arg_context                IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                  x_work_queue_to_complete      OUT NOCOPY ordered_work_queue_type,
                                  x_return_status               OUT NOCOPY VARCHAR2,
                                  x_return_msg                  OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_DML_SET_UNIT';

      l_work_queue      ordered_work_queue_type;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --get the list of dmls as a work queue
      FND_OAM_DSCRAM_DMLS_PKG.FETCH_DML_IDS(b_unit_info.unit_id,
                                            l_work_queue,
                                            l_return_status,
                                            l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --execute the work queue
      INTERNAL_EXECUTE_WORK_QUEUE(l_work_queue,
                                  px_arg_context,
                                  x_work_queue_to_complete,
                                  x_return_status,
                                  x_return_msg);

      --return status of the internal execute
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- helper to EXECUTE_UNIT to handle the case where the topmost unit is a DML_SET type unit.
   -- responsibilities include querying out the dmls for the unit, preparing the structure used by
   -- internal_execute_work_queue to execute the dmls, and returning the results to execute_unit.
   PROCEDURE EXECUTE_PLSQL_SET_UNIT(px_arg_context              IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                    x_work_queue_to_complete    OUT NOCOPY ordered_work_queue_type,
                                    x_return_status             OUT NOCOPY VARCHAR2,
                                    x_return_msg                OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_PLSQL_SET_UNIT';

      l_work_queue      ordered_work_queue_type;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --get the list of plsqls as a work queue
      FND_OAM_DSCRAM_PLSQLS_PKG.FETCH_PLSQL_IDS(b_unit_info.unit_id,
                                                l_work_queue,
                                                l_return_status,
                                                l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         x_return_msg := l_return_msg;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --execute the work queue
      INTERNAL_EXECUTE_WORK_QUEUE(l_work_queue,
                                  px_arg_context,
                                  x_work_queue_to_complete,
                                  x_return_status,
                                  x_return_msg);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- standard work item comparator, -1 if left scheduled earlier than right, 0 if same, 1 if right scheduled earlier.
   -- takes into account the priority and then the weight with priority overriding weight.  Null priorites come last,
   -- Null weights come first.
   FUNCTION COMPARE_WORK_ITEMS(p_left   IN OUT NOCOPY work_item_type,
                               p_right  IN OUT NOCOPY work_item_type)
      RETURN INTEGER
   IS
   BEGIN
      -- priorities are sorted in an ascending order. null priorities are after non-null
      IF p_left.priority < p_right.priority THEN
         RETURN -1;
      ELSIF p_left.priority > p_right.priority THEN
         RETURN 1;
      ELSIF p_left.priority IS NOT NULL AND p_right.priority IS NULL THEN
         RETURN -1;
      ELSIF p_left.priority IS NULL AND p_right.priority IS NOT NULL THEN
         RETURN 1;
      ELSE
         --priorities either both null or both not null and equal, move on to weight which is sorted in a descending order.
         --null weights are before non-null
         IF p_left.weight > p_right.weight THEN
            RETURN -1;
         ELSIF p_left.weight < p_right.weight THEN
            RETURN 1;
         ELSIF p_left.weight IS NULL AND p_right.weight IS NOT NULL THEN
            RETURN -1;
         ELSIF p_left.weight IS NOT NULL AND p_right.weight IS NULL THEN
            RETURN 1;
         ELSE
            --when priorities and weights are the same, they're comparatively the same
            RETURN 0;
         END IF;
      END IF;
   END;

   -- Private debug procedure
   PROCEDURE PRINT_WORK_QUEUE(p_work_queue      IN OUT NOCOPY ordered_work_queue_type)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'PRINT_WORK_QUEUE';

      k NUMBER;
   BEGIN
      k := p_work_queue.FIRST;
      WHILE k IS NOT NULL LOOP
         fnd_oam_debug.log(1, l_ctxt, 'Q['||k||']: (P:'||p_work_queue(k).priority||')(W:'||p_work_queue(k).weight||') '||p_work_queue(k).item_id||'('||p_work_queue(k).item_type||')');
         k := p_work_queue.NEXT(k);
      END LOOP;
   END;

   -- Private helper to EXECUTE_UNIT to handle the case where the topmost unit is a concurrent group meta unit.
   -- Responsibilities include querying out all child units, constructing an ordered work queue from the unit priority,
   -- work item priority and work item weight and calling INTERNAL_EXECUTE_WORK_QUEUE.
   -- The only fields we interact with in a child unit are: unit_id, task_id, concurrent_group_unit_id, unit_type, priority and weight.
   -- All other fields are left untouched and unread. Of the above, only the unit_id, unit type and priority are used in code,
   -- the rest participate only in the child unit select.
   PROCEDURE EXECUTE_CONC_GROUP_UNIT(px_arg_context             IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context,
                                     x_work_queue_to_complete   OUT NOCOPY ordered_work_queue_type,
                                     x_return_status            OUT NOCOPY VARCHAR2,
                                     x_return_msg               OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_CONC_GROUP_UNIT';

      l_master_pos                      NUMBER;
      l_master_pos_finished_ubound      NUMBER := 0;
      l_master_work_queue               ordered_work_queue_type := ordered_work_queue_type();
      l_work_queue                      ordered_work_queue_type;

      l_unit_ids                DBMS_SQL.NUMBER_TABLE;
      l_types                   DBMS_SQL.VARCHAR2_TABLE;
      l_priorities              DBMS_SQL.NUMBER_TABLE;

      l_priority                NUMBER;
      l_last_unit_priority      NUMBER;

      j                         NUMBER;
      k                         NUMBER;
      m                         NUMBER;
      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --first we need to fetch the component units of this meta-unit
      SELECT unit_id, unit_type, priority
         BULK COLLECT INTO l_unit_ids, l_types, l_priorities
         FROM fnd_oam_dscram_units
         WHERE task_id = FND_OAM_DSCRAM_TASKS_PKG.GET_TASK_ID
         AND concurrent_group_unit_id = b_unit_info.unit_id
         ORDER BY priority ASC, weight DESC;

      --now go through the unit list to create the master work queue
      k := l_unit_ids.FIRST;
      WHILE k IS NOT NULL LOOP
         --based on the type, call a different API to get the work queue for this child unit
         CASE l_types(k)
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET THEN
               FND_OAM_DSCRAM_DMLS_PKG.FETCH_DML_IDS(l_unit_ids(k),
                                                     l_work_queue,
                                                     l_return_status,
                                                     l_return_msg);
            WHEN FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET THEN
               FND_OAM_DSCRAM_PLSQLS_PKG.FETCH_PLSQL_IDS(l_unit_ids(k),
                                                         l_work_queue,
                                                         l_return_status,
                                                         l_return_msg);
            ELSE
               --unknown unit type
               x_return_msg := 'Unknown unit type: '||l_types(k);
               fnd_oam_debug.log(6, l_ctxt, x_return_msg);
               fnd_oam_debug.log(2, l_ctxt, 'EXIT');
               RETURN;
         END CASE;

         --see if the fetch suceeded, if not quick exit
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
            x_return_msg := l_return_msg;
            fnd_oam_debug.log(2, l_ctxt, 'EXIT');
            RETURN;
         END IF;

         --debug
         IF fnd_oam_debug.test(1) THEN
            PRINT_WORK_QUEUE(l_work_queue);
         END IF;

         --merge the work items into the master ordered queue
         l_priority := l_priorities(k);
         IF l_master_work_queue.COUNT = 0 THEN
            fnd_oam_debug.log(1, l_ctxt, 'Replace');
            --master's empty, just replace it
            l_master_work_queue := l_work_queue;
         ELSE
            --if this unit has a later priority, just append
            IF ((l_last_unit_priority IS NOT NULL AND l_priority IS NULL) OR
                (l_last_unit_priority < l_priority)) THEN

               fnd_oam_debug.log(1, l_ctxt, 'Append');
               --since we're traversing the child units in order, set our finished_ubound to
               --the current end point, we can't find later units that need to insert before this point
               l_master_pos_finished_ubound := l_master_work_queue.COUNT;

               --extend our queue by N entries
               l_master_work_queue.EXTEND(l_work_queue.COUNT);

               --insert each entry
               j := l_work_queue.FIRST;
               WHILE j IS NOT NULL LOOP
                  l_master_work_queue(l_master_pos_finished_ubound + j) := l_work_queue(j);
                  j := l_work_queue.NEXT(j);
               END LOOP;
            ELSE
               --this is the ugly part where we have to merge the work items of two or more units
               --with the same unit priority.  Since there's no nice way of doing an insert, proceed from the
               --tail of both queues to minimize number of bumps from an in-list insert.  Since the new work
               --queue is also sorted, we only need to perform one pass on both lists.  Also, all entries before
               --the finishined_ubound are off limits since they are in an earlier unit priority.
               l_master_pos := l_master_work_queue.COUNT;
               j := l_work_queue.LAST;
               fnd_oam_debug.log(1, l_ctxt, 'Merge: finished_ubound('||l_master_pos_finished_ubound||')');
               WHILE j IS NOT NULL LOOP
                  fnd_oam_debug.log(1, l_ctxt, 'Item('||j||'), initial master_pos('||l_master_pos||')');
                  --loop till we find that the work item at master_pos is less than the current item, then set our pos
                  --to be one past this previous item, stop when we go past the logical(possibly real) end of the master queue
                  WHILE l_master_pos > l_master_pos_finished_ubound LOOP
                     IF COMPARE_WORK_ITEMS(l_master_work_queue(l_master_pos),
                                           l_work_queue(j)) <= 0 THEN
                        l_master_pos := l_master_pos + 1;
                        fnd_oam_debug.log(1, l_ctxt, 'Found position: '||l_master_pos);
                        EXIT;
                     END IF;
                     l_master_pos := l_master_work_queue.PRIOR(l_master_pos);
                  END LOOP;

                  --if we didn't determine a spot, master pos must be reset to the first available slot
                  IF l_master_pos <= l_master_pos_finished_ubound THEN
                     l_master_pos := l_master_pos_finished_ubound + 1;
                  END IF;
                  fnd_oam_debug.log(1, l_ctxt, 'Final position: '||l_master_pos);

                  --insert the work queue's item at l_master_pos by first moving everything from pos to count up one index
                  m := l_master_work_queue.COUNT;
                  l_master_work_queue.EXTEND(1);
                  WHILE m >= l_master_pos LOOP
                     l_master_work_queue(m+1) := l_master_work_queue(m);
                     m := l_master_work_queue.PRIOR(m);
                  END LOOP;
                  --and then inserting the object at this point
                  l_master_work_queue(l_master_pos) := l_work_queue(j);

                  --since we know the work queue is sorted, skip comparing the next item to this position.
                  --move the master_pos down one if we can
                  IF l_master_pos > l_master_pos_finished_ubound+1 THEN
                     l_master_pos := l_master_pos - 1;
                  END IF;

                  j := l_work_queue.PRIOR(j);
               END LOOP;
            END IF;
         END IF;

         l_last_unit_priority := l_priority;

         k := l_unit_ids.NEXT(k);
      END LOOP;

      --debug
      IF fnd_oam_debug.test(1) THEN
         fnd_oam_debug.log(1, l_ctxt, 'Master Work Queue:');
         PRINT_WORK_QUEUE(l_master_work_queue);
      END IF;

      --at this point we have the finished work queue, just execute it
      INTERNAL_EXECUTE_WORK_QUEUE(l_master_work_queue,
                                  px_arg_context,
                                  x_work_queue_to_complete,
                                  x_return_status,
                                  x_return_msg);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public, called once for the topmost unit
   PROCEDURE EXECUTE_UNIT(p_unit_id             IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'EXECUTE_UNIT';

      l_completed_status        VARCHAR2(30);
      l_arg_context             FND_OAM_DSCRAM_ARGS_PKG.arg_context;

      l_work_queue_to_complete  ordered_work_queue_type;

      l_return_status   VARCHAR2(6);
      l_return_msg      VARCHAR2(2048);
      l_ignore          VARCHAR2(2048);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --make sure the unit's ok to start execution
      IF NOT VALIDATE_START_EXECUTION(p_unit_id,
                                      l_return_status,
                                      l_return_msg) THEN
         x_return_status := l_return_status;
         x_return_msg := '[Unit Validation Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- attempt to assign this invocation as a worker for the unit
      ASSIGN_WORKER_TO_UNIT(p_unit_id,
                            l_return_status,
                            l_return_msg);
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         x_return_status := l_return_status;
         IF l_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_FULL THEN
            x_return_msg := '[Unit Worker Assignment Failed]:('||l_return_msg||')';
            fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      --before proceeding after the assign, check our parent objects to make sure
      --their state suggests we should continue
      IF NOT FND_OAM_DSCRAM_TASKS_PKG.VALIDATE_CONTINUED_EXECUTION(FALSE,
                                                                   TRUE,
                                                                   l_return_status,
                                                                   l_return_msg) THEN
         --we don't care why a parent is invalid, just knowing so forces us to
         --stop our work
         COMPLETE_UNIT_IN_ERROR(b_unit_info.unit_id,
                                FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_STOPPED,
                                FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_STOPPED,
                                l_return_msg,
                                x_return_status);
         x_return_msg := '[Post-Assignment Parent Validation Failed]:('||l_return_msg||')';
         fnd_oam_debug.log(1, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;

      -- after assign we can start using stuff from the unit_info package state.  First, we need to
      -- see what type of unit we've got so we delegate to the right subfunction.
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(1, l_ctxt, 'Executing Unit...');

      -- for now, just use the arg context of the run for execution, later we may want to introduce
      -- a specific task context that layers on top of the run context that lets units communicate
      -- values without affecting other tasks
      FND_OAM_DSCRAM_RUNS_PKG.GET_RUN_ARG_CONTEXT(l_arg_context);

      -- in the lowest debug level, print the arg context
      IF fnd_oam_debug.test(1) THEN
         FND_OAM_DSCRAM_ARGS_PKG.PRINT_ARG_CONTEXT(l_arg_context);
      END IF;

      --delegate the work to different procedures based on the unit type
      CASE b_unit_info.unit_type
         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_DML_SET THEN
            EXECUTE_DML_SET_UNIT(l_arg_context,
                                 l_work_queue_to_complete,
                                 l_return_status,
                                 l_return_msg);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_PLSQL_SET THEN
            EXECUTE_PLSQL_SET_UNIT(l_arg_context,
                                   l_work_queue_to_complete,
                                   l_return_status,
                                   l_return_msg);

         WHEN FND_OAM_DSCRAM_UTILS_PKG.G_UNIT_TYPE_CONC_GROUP THEN
            EXECUTE_CONC_GROUP_UNIT(l_arg_context,
                                    l_work_queue_to_complete,
                                    l_return_status,
                                    l_return_msg);
         ELSE
            l_return_msg := 'Unhandled Type:'||b_unit_info.unit_type;
            fnd_oam_debug.log(6, l_ctxt, l_return_msg);
      END CASE;

      --determine the status to apply to the unit from the execute's return status
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         --unit was sucessful
         l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED;
      ELSE
         --determine what status the unit should have
         l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_RET_STS_TO_COMPL_STATUS(l_return_status);

         --take the fatality level into account to error out parent objects if need be
         IF l_completed_status <> FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSED AND
            b_unit_info.error_fatality_level IS NOT NULL THEN

            --update the corresponding parent unit
            FND_OAM_DSCRAM_UTILS_PKG.PROPOGATE_FATALITY_LEVEL(b_unit_info.error_fatality_level);

            --also change our status to error_fatal
            l_completed_status := FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_FATAL;
         END IF;
      END IF;

      --finished processing the unit
      fnd_oam_debug.log(1, l_ctxt, 'Finished Unit with status: '||l_completed_status||'('||l_return_status||')');
      COMPLETE_UNIT(b_unit_info.unit_id,
                    l_completed_status,
                    l_return_status,
                    l_return_msg,
                    l_arg_context,
                    TRUE,
                    l_work_queue_to_complete,
                    x_return_status);

      -- in the lowest debug level, print the arg context
      IF fnd_oam_debug.test(1) THEN
         FND_OAM_DSCRAM_ARGS_PKG.PRINT_ARG_CONTEXT(l_arg_context);
      END IF;

      --if sucessfull, set the run arg context to our local context, can't modify object by reference
      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
         FND_OAM_DSCRAM_RUNS_PKG.SET_RUN_ARG_CONTEXT(l_arg_context);
      END IF;

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: [Code('||SQLCODE||'), Message("'||SQLERRM||'")]';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         --safety rollback
         ROLLBACK;
         COMPLETE_UNIT_IN_ERROR(p_unit_id,
                                FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_ERROR_UNKNOWN,
                                FND_API.G_RET_STS_UNEXP_ERROR,
                                x_return_msg,
                                x_return_status);
   END;

END FND_OAM_DSCRAM_UNITS_PKG;

/
