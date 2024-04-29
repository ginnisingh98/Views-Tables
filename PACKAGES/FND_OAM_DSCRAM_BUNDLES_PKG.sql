--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_BUNDLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_BUNDLES_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSBDLS.pls 120.3 2005/12/19 09:37 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the bundle to which this session is assigned.
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_BUNDLE_ID
      RETURN NUMBER;

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the worker assigned to this bundle in this session.
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_WORKER_ID
      RETURN NUMBER;

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The number of concurrent workers allowed for this bundle.
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_WORKERS_ALLOWED
      RETURN NUMBER;

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The default batch size (unit = # of rows) for an AD API unit
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_BATCH_SIZE
      RETURN NUMBER;

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The minimum weight required for a bundle's unit to suggest parallelization.
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_MIN_PARALLEL_UNIT_WEIGHT
      RETURN NUMBER;

   -- API used to validate the currently executing bundle, consumed by _TASKS_PKG.  Similar to other
   -- VALIDATE_CONTINUED_EXECUTION methods it checks if the bundle should continue executing.
   -- It may also check the run if p_recurse is set.
   -- Invariants:
   --   Internal Assign should have already occured to set up the bundle state.
   -- Parameters:
   --   p_force_query     Force a query of the entities, typically done after we've seen an error.
   --   p_recurse         Whether to check parent entities (run)
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN,
                                         p_recurse              IN BOOLEAN,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- Entry point for a scramble to launch a worker for a specific run's bundle.
   -- Each invocation of execute_bundle continues until the bundle has been determined to be
   -- finished.  If workers are unable to find tasks available for execution in a bundle but the
   -- bundle is not finished, the worker waits for a progress update alert from another worker or
   -- until a timeout is hit.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID to which this worker is assigned
   --   p_bundle_id:      DSCRAM_BUNDLES.BUNDLE_ID to which this worker is assigned
   --   p_worker_id:      Numeric ID of this worker, on first invocation must be null, restarts of the worker
   --                     should specify the previously returned ID to keep counters valid.
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE EXECUTE_BUNDLE(p_run_id            IN NUMBER,
                            p_bundle_id         IN NUMBER,
                            px_worker_id        IN OUT NOCOPY NUMBER,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2);

   -- Wrapper on top of EXECUTE_BUNDLE to query the bundles for this host using the given
   -- run_id and execute each serially.  This simplifies our callout from controller code.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID to which this worker is assigned
   --   p_worker_id:      Numeric ID of this worker, on first invocation must be null, restarts of the worker
   --                     should specify the previously returned ID to keep counters valid.
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE EXECUTE_HOST_BUNDLES(p_run_id              IN NUMBER,
                                  px_worker_id          IN OUT NOCOPY NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_BUNDLES_PKG;

 

/
