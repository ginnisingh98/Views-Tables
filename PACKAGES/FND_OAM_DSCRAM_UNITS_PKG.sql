--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_UNITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_UNITS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSUNITS.pls 120.3 2005/11/01 17:14 ilawler noship $ */

   -------------
   -- Constants
   -------------

   ----------------
   -- Public Types
   ----------------

   --define types for the work list used by the INTERNAL_EXECUTE_WORK_LIST
   --method, allows creation of a sorted work queue.
   TYPE work_item_type IS RECORD
      (
       priority         NUMBER          := NULL,
       weight           NUMBER          := NULL,
       item_type        VARCHAR2(30)    := NULL,
       item_id          NUMBER          := NULL,
       item_msg         VARCHAR2(2048)  := NULL
       );

   -- the work queue is a single flat list of work items ordered by unit priority ascending (NULLs at end)
   -- then work item priority ascending and finally weight descending (NULLs at start).  This is flattened
   --from a 2D or 3D array to optimize for traversal over insert since concurrent units are less common.
   TYPE ordered_work_queue_type IS TABLE OF work_item_type;

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function to obtain parts of the unit state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_unit in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the unit to which this session is assigned.
   -- Exceptions:
   --   If a prior call to execute_unit wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_UNIT_ID
      RETURN NUMBER;

   -- Accessor function to obtain parts of the bundle state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_bundle in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The number of concurrent workers allowed for this unit.
   -- Exceptions:
   --   If a prior call to execute_bundle wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_WORKERS_ALLOWED
      RETURN NUMBER;

   -- Accessor function to obtain parts of the unit state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_unit in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The execution batch size.
   -- Exceptions:
   --   If a prior call to execute_unit wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_BATCH_SIZE
      RETURN NUMBER;

   -- Accessor function to obtain parts of the unit state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_unit in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The object_owner associated with the currently executing unit.
   -- Exceptions:
   --   If a prior call to execute_unit wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_UNIT_OBJECT_OWNER
      RETURN VARCHAR2;

   -- Accessor function to obtain parts of the unit state
   -- Invariants:
   --   State must have been initialized by a prior call to execute_unit in the session.
   -- Parameters:
   --   None
   -- Returns:
   --   The object_name associated with the currently executing unit.
   -- Exceptions:
   --   If a prior call to execute_unit wasn't executed, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_UNIT_OBJECT_NAME
      RETURN VARCHAR2;

   --"Constructor" for new work_item_type objects
   FUNCTION CREATE_WORK_ITEM(p_priority         IN NUMBER,
                             p_weight           IN NUMBER,
                             p_item_type        IN VARCHAR2,
                             p_item_id          IN NUMBER)
      RETURN work_item_type;

   -- This API is used to get the next available unit for the supplied task_id.
   -- Instead of blindly returning the next row in the dscram_units table, we need
   -- to take phase into consideration on re-query to keep from violating dependencies.
   -- Invariants:
   --   None, unit execution will fail if the task hasn't been initialized.
   -- Parameters:
   --   p_requery:        Boolean indicating whether the unit SELECT statement should be re-executed
   --                     or the API should fetch the next row from the last query.
   --   x_unit_id:        DSCRAM_UNITS.UNIT_ID of unit found
   --   x_return_status:  FND_API-like return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_EMPTY       If the fetch hits the end of the rowset
   --   G_RET_STS_FULL        If the query could have returned a unit but all processing were busy or
   --                         the remaining units are in a subsequent phase.
   --   G_RET_STS_STOPPED     If a unit is found in status STOPPING/STOPPED, assume this worker should
   --                         also be stopping(helps cover corner cases).
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE FETCH_NEXT_UNIT(p_requery          IN              BOOLEAN,
                             x_unit_id          OUT NOCOPY      NUMBER,
                             x_return_status    OUT NOCOPY      VARCHAR2,
                             x_return_msg       OUT NOCOPY      VARCHAR2);

   -- Static API used to validate a unit, consumed by the internal_execute as a continue check.  Only
   -- considers state of parent unit, child unit statuses are not populated so we don't check them.
   -- Invariants:
   --   Internal Assign should have already occured to set up the unit state.
   -- Parameters:
   --   p_force_query     Force a query of the entities, typically done after we've seen an error.
   --   p_recurse         Whether to check parent entities (task, bundle, run)
   --   x_return_status:  FND_API-like return status
   --   x_return_msg:     Message explaining non-success return statuses
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN,
                                         p_recurse              IN BOOLEAN,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN;

   -- This API is used after a call to fetch_next_unit to execute a unit_id.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_unit_id:        DSCRAM_UNITS.UNIT_ID of unit found
   --   x_return_status:  FND_API-like return status
   --   x_return_msg:     Message explaining non-success return statuses
   -- Return Statuses:
   --   G_RET_STS_FULL        Occurs when a unit fetch had worker spots open but by the time we did
   --                         an assign there were none left, covers contention.
   --   G_RET_STS_STOPPED     If a unit's execution detects a STOPPING/STOPPED state, push it up the
   --                         execution stack.
   --   G_RET_STS_SUCCESS     Success
   --   G_RET_STS_ERROR       Expected, possible error found. See return_msg.
   --   G_RET_STS_ERROR_UNEXP Unexpected Error found.  See return_msg.
   PROCEDURE EXECUTE_UNIT(p_unit_id             IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
                          x_return_msg          OUT NOCOPY VARCHAR2);

END FND_OAM_DSCRAM_UNITS_PKG;

 

/
