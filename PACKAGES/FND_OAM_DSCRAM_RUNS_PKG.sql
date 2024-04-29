--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_RUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_RUNS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSRUNS.pls 120.2 2005/11/07 19:43 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the run to which this session is assigned.
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_RUN_ID
      RETURN NUMBER;

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical stat ID of the stats row for this run's last execution.
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_RUN_STAT_ID
      RETURN NUMBER;

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   None
   -- Returns:
   --   The number of seconds before an entity should be revalidated
   --   from source.
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_VALID_CHECK_INTERVAL
      RETURN NUMBER;

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   None
   -- Returns:
   --   A string representing our mode, controls whether the physical work
   --   is committed or rolled back.
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_RUN_MODE
      RETURN VARCHAR2;

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   px_arg_context:   the variable receiving the run arg_context
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   PROCEDURE GET_RUN_ARG_CONTEXT(px_arg_context IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context);

   -- Accessor function to obtain parts of the run state
   -- Invariants:
   --   State must have been initialized by a prior call to ASSIGN
   -- Parameters:
   --   p_arg_context:    the new run arg_context
   -- Exceptions:
   --   If the run state isn't initialized yet,
   --   a NO_DATA_FOUND exception is thrown.
   PROCEDURE SET_RUN_ARG_CONTEXT(p_arg_context IN FND_OAM_DSCRAM_ARGS_PKG.arg_context);

   -- After a worker has been assigned to a worker and a bundle, this is called by the
   -- bundle's assign to create the arg context for the run.  This is placed here instead
   -- of in the ASSIGN_WORKER_TO_RUN because we need run and bundle state to be initialized
   -- for certain kinds of args prior to calling ASSIGN_WORKER_TO_RUN.  This is somewhat
   -- of an artifact of the print_arg_context invoked in diagnostic modes.
   -- Invariants:
   --   Called after ASSIGN_WORKER_TO_RUN and BUNDLES_PKG.ASSIGN_WORKER_TO_BUNDLE.
   -- Parameters:
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE INITIALIZE_RUN_ARG_CONTEXT(x_return_status         OUT NOCOPY VARCHAR2,
                                        x_return_msg            OUT NOCOPY VARCHAR2);

   -- Static API used by _BUNDLES_PKG to validate a run before beginning execution.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   FUNCTION VALIDATE_START_EXECUTION(p_run_id           IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- Static API used by _BUNDLES_PKG to validate a run periocially
   -- has started.
   -- Invariants:
   --   Assign should have already occured to set up the run state.
   -- Parameters:
   --   p_force_query     Force a query of the entities, typically done after we've seen an error.
   --   p_recurse         Whether to check parent entities (task, bundle, run)
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN DEFAULT FALSE,
                                         p_recurse              IN BOOLEAN DEFAULT FALSE,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- Before a worker is assigned to a bundle by execute_bundle, it is first assigned
   -- to the run to take care of initializing any run state.  This assign is different
   -- from others because it is not autonomous.  This comes from
   -- the fact that the master controller updates all state prior to pl/sql execution and
   -- there is no impact on a run to add a worker(e.g. no counts).
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE ASSIGN_WORKER_TO_RUN(p_run_id              IN NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2);

   /*

   -- API used to modify a run and its child entities to make 'stopped' entities have status 'restarting'
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE PREPARE_RUN_FOR_RESUME(p_run_id            IN NUMBER,
                                    x_return_status     OUT NOCOPY VARCHAR2,
                                    x_return_msg        OUT NOCOPY VARCHAR2);

   -- API used to modify a run and its child entities to reset 'finished' entities to status
   -- 'unprocessed' depending on certain criteria.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_run_id:         DSCRAM_RUNS.RUN_ID
   --   p_errored_only:   If TRUE, reset finished entities that encountered errors, otherwise
   --                     reset all to retry from start.
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE PREPARE_RUN_FOR_RETRY(p_run_id             IN NUMBER,
                                   p_errored_only       IN BOOLEAN DEFAULT TRUE,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2);
   */


   -- Bug #47007636 - ilawler - Fri Nov  4 12:25:23 2005
   -- Table handler required for translated entities to populate the _TL table when
   -- a new language is added to an environment.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   PROCEDURE ADD_LANGUAGE;

END FND_OAM_DSCRAM_RUNS_PKG;

 

/
