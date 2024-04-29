--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_TASKS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSTASKS.pls 120.1 2005/09/27 09:46 ilawler noship $ */

   ------------
   -- Constants
   ------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain parts of the task state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_task in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the task to which this session is assigned.
   -- Exceptions:
   --   If a prior call to execute_task wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_TASK_ID
      RETURN NUMBER;

   -- This API is used to get the next available task for the bundle_id stored in the
   -- bundle state. When no tasks found in queue, returns G_RET_STS_EMPTY - used to detect when
   -- the bundle is fully processed.
   -- Invariants:
   --   Bundle must be initialized otherwise an error is returned.
   -- Parameters:
   --   p_requery:        Boolean indicating whether the task SELECT statement should be re-executed
   --                     or the API should fetch the next row from the last query.
   --   x_task_id:        DSCRAM_TASKS.TASK_ID of task found
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE FETCH_NEXT_TASK(p_requery          IN              BOOLEAN,
                             x_task_id          OUT NOCOPY      NUMBER,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2);

   -- Static API used to validate a task, consumed by _UNITS_PKG.
   -- Invariants:
   --   Internal Assign should have already occured to set up the  state.
   -- Parameters:
   --   p_force_query     Force a query of the entities, typically done after we've seen an error.
   --   p_recurse         Whether to check parent entities (task, bundle, run)
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN,
                                         p_recurse              IN BOOLEAN,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- This API is used after a call to fetch_next_task to execute a task_id.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_task_id:        DSCRAM_TASKS.TASK_ID of task found
   --   x_return_status:  FND_API-compliant return status
   --   x_return_msg:     Message explaining non-success return statuses
   PROCEDURE EXECUTE_TASK(p_task_id             IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_TASKS_PKG;

 

/
